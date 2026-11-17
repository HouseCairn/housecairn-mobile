// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// What the third way keeps on the phone (docs/adr/0010, "The way of the
/// phone"): the server's address and the transport's state in
/// `local_settings`, never synced, never in an export; the credential is in
/// `Store`, never here.
extension ServerSettings on Repository {
  /// The address typed, as `ServerAddress.display` gives it.
  Future<String?> serverAddress() => _setting('server_address');

  Future<void> setServerAddress(String? address) =>
      _setSetting('server_address', address);

  /// This phone's device id, in `b64`, as the server's push reads it.
  String get deviceB64 => b64(_device);

  /// The [ServerStateStore] of the transport, on `local_settings`.
  ServerStateStore get serverState => _RepositoryServerState(this);

  /// The [ServerSeenStore] of the transport, on `server_seen`.
  ServerSeenStore get serverSeen => _RepositoryServerSeen(this);

  /// The role of the signed-in account in [homeId] on the server, `null`
  /// when it is not a home of a server.
  Future<String?> serverRole(String homeId) async {
    final roles = _serverRoles ??= {
      for (final h in ServerSyncState.decode(
        await _setting('server_sync'),
      ).homes)
        h.id: h.role,
    };
    return roles[homeId];
  }

  /// A read-only member writes nothing; only an owner archives (lot 4b).
  Future<void> _checkServerRole(
    String homeId,
    String table,
    Map<String, Object?> fields,
  ) async {
    final role = await serverRole(homeId);
    if (role == null) return;
    if (role == 'read_only') throw const Refused(Refusal.readOnlyHome);
    if (table == 'homes' &&
        fields.containsKey('archived_at') &&
        role != 'owner') {
      throw const Refused(Refusal.ownersOnly);
    }
  }

  // ---------- the mark "seen by the server" (protocol section 2.10) ----------

  /// Marks [rows] (`(t, h, id)`) as seen by the server.
  Future<void> markServerSeen(Iterable<ServerRowKey> rows) async {
    await db.transaction(() async {
      for (final (type, home, id) in rows) {
        if (!tableOfEntity.containsKey(type)) continue;
        await db.customInsert(
          'INSERT OR IGNORE INTO server_seen (entity, row_id, home_id) '
          'VALUES (?, ?, ?)',
          variables: [
            Variable<String>(type),
            Variable<Uint8List>(uuidBytes(id)),
            Variable<Uint8List>(uuidBytes(home)),
          ],
        );
      }
    });
  }

  /// The rows of [homeId] marked seen by the server, as `(t, id)`.
  Future<Set<(String, String)>> serverSeenIn(String homeId) async {
    final rows = await db
        .customSelect(
          'SELECT entity, row_id FROM server_seen WHERE home_id = ?',
          variables: [Variable<Uint8List>(uuidBytes(homeId))],
        )
        .get();
    return {
      for (final r in rows)
        (
          r.data['entity'] as String,
          Uuid.unparse(r.data['row_id'] as Uint8List),
        ),
    };
  }

  /// Leaving the server: every mark goes.
  Future<void> forgetServerSeen() =>
      db.customStatement('DELETE FROM server_seen');

  /// The rule of protocol section 2.10, "Starting again after 410", for
  /// [homeId], once the server's snapshot of it is applied: [present] is
  /// every row (`(t, id)`) of that snapshot, tombstones included.
  ///
  /// 1. a row of the snapshot was merged as any change: it gets the mark;
  /// 2. a row absent from the snapshot with the mark was deleted, then
  ///    purged, on the server: it is deleted here with its clocks and what
  ///    `extra` keeps of it, its waiting changes are dropped (a long text of
  ///    them goes to the other versions), and it is listed (one notice a
  ///    row; the reports of a home, which a changed view takes from a
  ///    member, make one notice for the home);
  /// 3. a row absent without the mark never reached the server: it is kept
  ///    and sent again as a `put` of every field with its clock;
  /// 4. the changes still waiting for the rows of 1 and 3 are pushed as
  ///    usual;
  /// 5. the rows of the snapshot the phone did not have came with it.
  Future<List<SyncNotice>> reconcileAfterRestart(
    String homeId,
    Set<(String, String)> present,
  ) async {
    final notices = <SyncNotice>[];
    final seen = await serverSeenIn(homeId);
    final key = uuidBytes(homeId);
    final resend = <(String, String)>{};
    var reportsDropped = false;
    final now = _now();
    await db.transaction(() async {
      for (final table in homeTables) {
        final type = entityOf[table]!;
        final rows = await db
            .customSelect(
              'SELECT id FROM $table WHERE home_id = ?',
              variables: [Variable<Uint8List>(key)],
            )
            .get();
        for (final r in rows) {
          final id = Uuid.unparse(r.data['id'] as Uint8List);
          final row = (type, id);
          if (present.contains(row)) continue;
          if (!seen.contains(row)) {
            resend.add(row);
            continue;
          }
          await _dropRow(table, type, id, homeId, now);
          if (type == entityOf['reports']) {
            // A report gone from the snapshot is most often one the server
            // no longer gives this member (a changed view): one notice for
            // all of them, below, that does not say it was deleted.
            reportsDropped = true;
            continue;
          }
          notices.add(
            SyncNotice(
              SyncNoticeKind.droppedAfterRestart,
              entity: type,
              rowId: id,
            ),
          );
        }
      }
      if (reportsDropped) {
        notices.add(
          SyncNotice(SyncNoticeKind.viewChanged, entity: entityOf['reports']),
        );
      }
      await markServerSeen([
        for (final (type, id) in present) (type, homeId, id),
      ]);
      if (resend.isEmpty) return;
      final snapshot = await this.snapshot();
      for (final row in snapshot.rows) {
        if (!resend.contains((row.type, row.id))) continue;
        for (final op in row.operations(schemaVersion: schemaVersion)) {
          await db.customInsert(
            'INSERT INTO op_log (device, hlc, home_id, body) '
            'VALUES (?, ?, ?, ?)',
            variables: [
              Variable<Uint8List>(_device),
              Variable<String>(op[Op.clock]! as String),
              Variable<Uint8List>(key),
              Variable<String>(jsonEncode(op)),
            ],
          );
        }
      }
    });
    return notices;
  }

  /// Rule 2: the row [id] of [table] goes, with its clocks, `extra`, mark
  /// and waiting changes; a long text of those changes is kept 30 days as
  /// an other version.
  Future<void> _dropRow(
    String table,
    String type,
    String id,
    String homeId,
    int now,
  ) async {
    final bytes = uuidBytes(id);
    final waiting = await db
        .customSelect(
          "SELECT seq, body FROM op_log WHERE json_extract(body, '\$.t') = ? "
          "AND json_extract(body, '\$.id') = ?",
          variables: [Variable<String>(type), Variable<String>(id)],
        )
        .get();
    for (final w in waiting) {
      final op = (jsonDecode(w.data['body'] as String) as Map)
          .cast<String, Object?>();
      final fields = (op[Op.fields] as Map?)?.cast<String, Object?>() ?? {};
      for (final MapEntry(:key, :value) in fields.entries) {
        if (longTextFields.contains(key) && value is String && value != '') {
          await _keepOtherVersion(
            type,
            id,
            homeId,
            key,
            value,
            _Clock(op[Op.clock]! as String, _device),
            now,
          );
        }
      }
      await db.customStatement('DELETE FROM op_log WHERE seq = ?', [
        w.data['seq'],
      ]);
    }
    for (final sql in [
      'DELETE FROM field_clock WHERE entity = ? AND row_id = ?',
      'DELETE FROM extra WHERE entity = ? AND row_id = ?',
      'DELETE FROM server_seen WHERE entity = ? AND row_id = ?',
    ]) {
      await db.customStatement(sql, [type, bytes]);
    }
    if (fileHolders.containsKey(table)) {
      await db.customStatement('DELETE FROM file_sync WHERE row_id = ?', [
        bytes,
      ]);
    }
    await db.customStatement('DELETE FROM $table WHERE id = ?', [bytes]);
    // Its local files: a photo and its thumbnail, an attachment.
    for (final name in [id, '$id.jpg', '$id.thumb.jpg']) {
      final file = File('${homeDirectory(homeId).path}/$name');
      if (file.existsSync()) file.deleteSync();
    }
  }
}

/// A row as the server names it: `(t, h, id)`.
typedef ServerRowKey = (String, String, String);

class _RepositoryServerState implements ServerStateStore {
  _RepositoryServerState(this.repository);

  final Repository repository;

  @override
  Future<String?> readServerState() => repository._setting('server_sync');

  @override
  Future<void> writeServerState(String? state) async {
    await repository._setSetting('server_sync', state);
    repository._serverRoles = null;
  }
}

class _RepositoryServerSeen implements ServerSeenStore {
  _RepositoryServerSeen(this.repository);

  final Repository repository;

  @override
  Future<void> markSeen(Iterable<ServerRowKey> rows) =>
      repository.markServerSeen(rows);
}
