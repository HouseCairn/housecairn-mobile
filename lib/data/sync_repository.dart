// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// What a sync did that the person must be told
/// (docs/adr/0003-sync-protocol.md).
enum SyncNoticeKind {
  /// An undo made on this phone was taken back because the next occurrence
  /// was worked on elsewhere in the meantime ("Invariants across rows").
  undoReverted,

  /// A long text lost the merge; the losing one is kept 30 days on this
  /// phone ("Merge rule by kind of field", long text).
  otherVersionKept,

  /// The space asks for a newer app (`min_sv`): this phone reads but does
  /// not write ("Versions of the schema between phones").
  updateRequired,

  /// After a server answered 410, a row it had seen was no longer in its
  /// snapshot (deleted, then purged, there): the phone deleted it and
  /// dropped its waiting changes (docs/protocol.md section 2.10, rule 2).
  droppedAfterRestart,
}

class SyncNotice {
  const SyncNotice(this.kind, {this.entity, this.rowId});

  final SyncNoticeKind kind;
  final String? entity;
  final String? rowId;

  @override
  String toString() => 'SyncNotice(${kind.name}, $entity, $rowId)';
}

/// An operation waiting in `op_log` to be sent.
class OutgoingOperation {
  const OutgoingOperation(this.seq, this.operation);

  final int seq;
  final SyncOperation operation;
}

/// The table of each entity type of docs/protocol.md section 2.2.
final Map<String, String> tableOfEntity = {
  for (final MapEntry(:key, :value) in entityOf.entries) value: key,
};

/// Instants are UTC milliseconds in the database and HLC strings in the
/// operations (docs/adr/0002, "Instants").
const instantFields = {
  'created_at',
  'updated_at',
  'deleted_at',
  'archived_at',
  'closed_at',
};

/// The long texts of the model: the losing one of a merge is kept 30 days
/// (docs/adr/0003-sync-protocol.md).
const longTextFields = {'notes', 'procedure', 'goal', 'memory_notes'};

/// How long a losing long text is kept on the phone.
const otherVersionDays = 30;

/// The fields an operation never sets: the row's key, its home and the
/// instant of its last change, which each phone works out.
const _keyFields = {'id', 'home_id', 'updated_at'};

/// The key of `local_settings` of what an undo made on this phone changed,
/// so that it can be taken back.
String _undoKey(String occurrenceId) => 'undo:$occurrenceId';

final _columnCache = <String, Map<String, GeneratedColumn>>{};

class _Clock {
  const _Clock(this.hlc, this.device);

  final String hlc;
  final Uint8List device;
}

/// The sync side of the repository (docs/plan.md, lot 4): operations out of
/// `op_log`, operations in by the field rules of ADR 0003, the repair rules,
/// the purge of a home, `extra`, `pending`, `min_sv` and snapshots. It knows
/// no transport: lib/sync/engine.dart moves the operations.
extension SyncRepository on Repository {
  /// The schema version written in every operation (`sv`).
  int get schemaVersion => db.schemaVersion;

  Map<String, GeneratedColumn> _columns(String table) =>
      _columnCache[table] ??= {
        for (final column
            in db.allTables
                .firstWhere((t) => t.actualTableName == table)
                .$columns)
          column.$name: column,
      };

  static Object? _wire(String field, Object? value) => switch (value) {
    Day() => value.iso,
    int() when instantFields.contains(field) => Hlc.format(value << 16),
    _ => value,
  };

  static Object? _toWire(GeneratedColumn column, Object? value) {
    if (value == null) return null;
    return switch (column.type) {
      DriftSqlType.blob => Uuid.unparse(value as Uint8List),
      DriftSqlType.bool => value == 1 || value == true,
      DriftSqlType.int when instantFields.contains(column.$name) => Hlc.format(
        (value as int) << 16,
      ),
      _ => value,
    };
  }

  /// The SQL value of [value] for [column]; a [FormatException] or a
  /// [TypeError] when it is not of the column's type.
  static Object? _fromWire(GeneratedColumn column, Object? value) {
    if (value == null) return null;
    return switch (column.type) {
      DriftSqlType.blob => uuidBytes(value as String),
      DriftSqlType.bool => (value as bool) ? 1 : 0,
      DriftSqlType.int when instantFields.contains(column.$name) =>
        Hlc.parse(value as String) >> 16,
      DriftSqlType.int => value as int,
      DriftSqlType.string => value as String,
      _ => value,
    };
  }

  static Object? _zero(GeneratedColumn column) => switch (column.type) {
    DriftSqlType.blob => Uint8List(16),
    DriftSqlType.string => '',
    _ => 0,
  };

  Future<String?> _homeOf(String table, String id) async {
    if (table == 'homes') return id;
    final row = await db
        .customSelect(
          'SELECT home_id FROM $table WHERE id = ?',
          variables: [Variable<Uint8List>(uuidBytes(id))],
        )
        .getSingleOrNull();
    final bytes = row?.data['home_id'] as Uint8List?;
    return bytes == null ? null : Uuid.unparse(bytes);
  }

  /// [id] when it names a row of [table] in [homeId], else `null`: a
  /// reference to a row of another home is kept as it came and read as
  /// empty (docs/adr/0003-sync-protocol.md, "Every row belongs to one home").
  Future<String?> referenceIn(String homeId, String table, String? id) async =>
      id != null && await _homeOf(table, id) == homeId ? id : null;

  /// Writes the operation of a local change in `op_log`, inside the
  /// transaction of [Repository._put].
  Future<void> _logOperation(
    String table,
    String id,
    String? homeId,
    Map<String, Object?> fields,
    String hlc,
  ) async {
    final home = table == 'homes' ? id : homeId ?? await _homeOf(table, id);
    final op = <String, Object?>{
      Op.type: entityOf[table],
      Op.home: ?home,
      Op.id: id,
      Op.kind: Op.put,
      Op.clock: hlc,
      Op.device: b64(_device),
      Op.schema: schemaVersion,
      Op.fields: {
        for (final MapEntry(:key, :value) in fields.entries)
          key: _wire(key, value),
      },
    };
    await db.customInsert(
      'INSERT INTO op_log (device, hlc, home_id, body) VALUES (?, ?, ?, ?)',
      variables: [
        Variable<Uint8List>(_device),
        Variable<String>(hlc),
        Variable<Uint8List>(home == null ? null : uuidBytes(home)),
        Variable<String>(jsonEncode(op)),
      ],
    );
  }

  // ---------- out ----------

  /// The operations written on this phone and not yet taken by the other
  /// side, oldest first.
  Future<List<OutgoingOperation>> outgoing() async {
    final rows = await db
        .customSelect('SELECT seq, body FROM op_log ORDER BY seq')
        .get();
    return [
      for (final row in rows)
        OutgoingOperation(
          row.data['seq'] as int,
          (jsonDecode(row.data['body'] as String) as Map)
              .cast<String, Object?>(),
        ),
    ];
  }

  /// The other side took every operation up to [seq].
  Future<void> acknowledge(int seq) =>
      db.customStatement('DELETE FROM op_log WHERE seq <= ?', [seq]);

  // ---------- in ----------

  Future<bool> isPurged(String homeId) async =>
      await db
          .customSelect(
            'SELECT 1 FROM purged_homes WHERE home_id = ?',
            variables: [Variable<Uint8List>(uuidBytes(homeId))],
          )
          .getSingleOrNull() !=
      null;

  Future<Map<String, _Clock>> _clocksOf(String entity, String id) async {
    final rows = await db
        .customSelect(
          'SELECT field, hlc, device FROM field_clock '
          'WHERE entity = ? AND row_id = ?',
          variables: [
            Variable<String>(entity),
            Variable<Uint8List>(uuidBytes(id)),
          ],
        )
        .get();
    return {
      for (final r in rows)
        r.data['field'] as String: _Clock(
          r.data['hlc'] as String,
          r.data['device'] as Uint8List,
        ),
    };
  }

  /// Applies [operations] of other phones (or of this one, sent back) by
  /// the field rules of docs/adr/0003-sync-protocol.md, in one transaction,
  /// then runs the repair rules unless [repair] is false. The result is the
  /// same in any order and with duplicates.
  Future<List<SyncNotice>> applyOperations(
    List<SyncOperation> operations, {
    bool repair = true,
  }) async {
    final notices = <SyncNotice>[];
    _applyingSync = true;
    try {
      await db.transaction(() async {
        for (final op in operations) {
          await _applyOne(op, notices);
        }
        if (repair) notices.addAll(await repairMerged());
      });
    } finally {
      _applyingSync = false;
    }
    return notices;
  }

  Future<void> _applyOne(SyncOperation op, List<SyncNotice> notices) async {
    final type = op[Op.type] as String;
    final home = op[Op.home] as String?;
    final id = op[Op.id] as String;
    final hlc = op[Op.clock] as String;
    final device = unb64(op[Op.device] as String);
    if (home != null && await isPurged(home)) return;
    _hlc.receive(Hlc.parse(hlc));
    final table = tableOfEntity[type];
    if (table == null && !type.startsWith('family.')) {
      // A type of a newer app: kept as it came, applied after the update.
      await db.customInsert(
        'INSERT OR IGNORE INTO pending (key, entity, home_id, body) '
        'VALUES (?, ?, ?, ?)',
        variables: [
          Variable<String>('$type|${home ?? ''}|$id|$hlc|${op[Op.device]}'),
          Variable<String>(type),
          Variable<Uint8List>(home == null ? null : uuidBytes(home)),
          Variable<String>(jsonEncode(op)),
        ],
      );
      return;
    }
    final columns = table == null
        ? const <String, GeneratedColumn>{}
        : _columns(table);
    Map<String, Object?>? row;
    if (table != null) {
      if (home == null || (table == 'homes' && home != id)) return;
      row =
          (await db
                  .customSelect(
                    'SELECT * FROM $table WHERE id = ?',
                    variables: [Variable<Uint8List>(uuidBytes(id))],
                  )
                  .getSingleOrNull())
              ?.data;
      // A row never changes home: an operation that says otherwise is not
      // of this row.
      if (row != null && table != 'homes') {
        if (Uuid.unparse(row['home_id'] as Uint8List) != home) return;
      }
    }
    final clocks = await _clocksOf(type, id);
    final won = <String, Object?>{};
    final now = _now();
    for (final MapEntry(key: field, :value) in fieldsOf(op).entries) {
      if (_keyFields.contains(field)) continue;
      final stored = clocks[field];
      final order = stored == null
          ? 1
          : compareWrites(hlc, device, stored.hlc, stored.device);
      if (order == 0) continue;
      final column = columns[field];
      final long = column != null && longTextFields.contains(field);
      if (order > 0) {
        won[field] = value;
        final current = row?[field];
        if (long && stored != null && current is String && current != value) {
          await _keepOtherVersion(type, id, home, field, current, stored, now);
          notices.add(
            SyncNotice(
              SyncNoticeKind.otherVersionKept,
              entity: type,
              rowId: id,
            ),
          );
        }
      } else if (long && value is String && value != row?[field]) {
        await _keepOtherVersion(
          type,
          id,
          home,
          field,
          value,
          _Clock(hlc, device),
          now,
        );
        notices.add(
          SyncNotice(SyncNoticeKind.otherVersionKept, entity: type, rowId: id),
        );
      }
    }
    if (won.isEmpty) return;
    final known = <String, Object?>{};
    final unknown = <String, Object?>{};
    for (final MapEntry(key: field, :value) in won.entries) {
      final column = columns[field];
      if (column == null) {
        unknown[field] = value;
        continue;
      }
      try {
        known[field] = _fromWire(column, value);
      } on Object {
        // A value this version cannot hold in its column (a type changed by
        // a newer app): kept as it came, as an unknown field is.
        unknown[field] = value;
      }
    }
    final changed = Hlc.parse(hlc) >> 16;
    if (known.isNotEmpty) {
      if (row == null) {
        // The row's creation has not arrived yet (operations may come in any
        // order): a row with the required columns empty, filled when it does.
        final placeholder = <String, Object?>{
          'id': uuidBytes(id),
          if (table != 'homes') 'home_id': uuidBytes(home!),
          for (final column in columns.values)
            if (!column.$nullable &&
                column.defaultValue == null &&
                column.clientDefault == null &&
                !{'id', 'home_id'}.contains(column.$name))
              column.$name: _zero(column),
          'updated_at': changed,
        };
        await db.customInsert(
          'INSERT INTO $table (${placeholder.keys.join(', ')}) '
          'VALUES (${List.filled(placeholder.length, '?').join(', ')})',
          variables: [for (final v in placeholder.values) Variable<Object>(v)],
        );
      }
      await db.customUpdate(
        'UPDATE $table SET '
        '${[for (final c in known.keys) '$c = ?', 'updated_at = MAX(updated_at, ?)'].join(', ')} '
        'WHERE id = ?',
        variables: [
          for (final v in known.values) Variable<Object>(v),
          Variable<int>(changed),
          Variable<Uint8List>(uuidBytes(id)),
        ],
      );
    }
    if (unknown.isNotEmpty) await _mergeExtra(type, id, home, unknown);
    for (final field in won.keys) {
      await db.customInsert(
        'INSERT INTO field_clock (entity, row_id, field, hlc, device) '
        'VALUES (?, ?, ?, ?, ?) ON CONFLICT (entity, row_id, field) '
        'DO UPDATE SET hlc = excluded.hlc, device = excluded.device',
        variables: [
          Variable<String>(type),
          Variable<Uint8List>(uuidBytes(id)),
          Variable<String>(field),
          Variable<String>(hlc),
          Variable<Uint8List>(device),
        ],
      );
    }
  }

  Future<void> _keepOtherVersion(
    String type,
    String id,
    String? home,
    String field,
    String value,
    _Clock clock,
    int now,
  ) => db.customInsert(
    'INSERT OR IGNORE INTO other_versions (entity, row_id, home_id, field, '
    'value, hlc, device, kept_until) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable<String>(type),
      Variable<Uint8List>(uuidBytes(id)),
      Variable<Uint8List>(home == null ? null : uuidBytes(home)),
      Variable<String>(field),
      Variable<String>(value),
      Variable<String>(clock.hlc),
      Variable<Uint8List>(clock.device),
      Variable<int>(now + otherVersionDays * Duration.millisecondsPerDay),
    ],
  );

  Future<Map<String, Object?>> _extraOf(String type, String id) async {
    final row = await db
        .customSelect(
          'SELECT json FROM extra WHERE entity = ? AND row_id = ?',
          variables: [
            Variable<String>(type),
            Variable<Uint8List>(uuidBytes(id)),
          ],
        )
        .getSingleOrNull();
    return row == null
        ? <String, Object?>{}
        : (jsonDecode(row.data['json'] as String) as Map)
              .cast<String, Object?>();
  }

  Future<void> _mergeExtra(
    String type,
    String id,
    String? home,
    Map<String, Object?> fields,
  ) async {
    final merged = {...await _extraOf(type, id), ...fields};
    final sorted = {for (final k in merged.keys.toList()..sort()) k: merged[k]};
    await db.customInsert(
      'INSERT INTO extra (entity, row_id, home_id, json) VALUES (?, ?, ?, ?) '
      'ON CONFLICT (entity, row_id) DO UPDATE SET json = excluded.json',
      variables: [
        Variable<String>(type),
        Variable<Uint8List>(uuidBytes(id)),
        Variable<Uint8List>(home == null ? null : uuidBytes(home)),
        Variable<String>(jsonEncode(sorted)),
      ],
    );
  }

  /// The fields this version keeps without knowing them, of the row [id].
  Future<Map<String, Object?>> extraFields(String entity, String id) =>
      _extraOf(entity, id);

  /// Applies the operations kept in `pending` whose type this version now
  /// knows (after an update).
  Future<void> retryPending() async {
    final rows = await db
        .customSelect('SELECT key, entity, body FROM pending ORDER BY key')
        .get();
    final known = [
      for (final r in rows)
        if (tableOfEntity.containsKey(r.data['entity']) ||
            (r.data['entity'] as String).startsWith('family.'))
          r,
    ];
    if (known.isEmpty) return;
    await db.transaction(() async {
      for (final r in known) {
        await db.customStatement('DELETE FROM pending WHERE key = ?', [
          r.data['key'],
        ]);
      }
      await applyOperations([
        for (final r in known)
          (jsonDecode(r.data['body'] as String) as Map).cast<String, Object?>(),
      ]);
    });
  }

  /// Whether the space asks for a newer schema than this app writes
  /// (`min_sv` of `family.settings`): the phone then reads but does not
  /// write.
  Future<bool> updateRequired() async {
    final rows = await db
        .customSelect("SELECT json FROM extra WHERE entity = 'family.settings'")
        .get();
    for (final r in rows) {
      final minSv = (jsonDecode(r.data['json'] as String) as Map)['min_sv'];
      if (minSv is int && minSv > schemaVersion) return true;
    }
    return false;
  }

  // ---------- purge of a home ----------

  /// Erases the home [homeId] for good, as a `purge` of the membership log
  /// or a home gone from a server does (docs/protocol.md section 2.2): every
  /// row of it, their clocks, what is kept of it in `extra`, `pending`,
  /// `op_log` and `other_versions`, and its files; then keeps its id, so
  /// that every later operation of it is dropped, whatever its clock.
  Future<void> purgeHome(String homeId) async {
    final key = uuidBytes(homeId);
    await db.transaction(() async {
      for (final table in homeTables) {
        await db.customStatement(
          'DELETE FROM field_clock WHERE entity = ? AND row_id IN '
          '(SELECT id FROM $table WHERE home_id = ?)',
          [entityOf[table], key],
        );
        await db.customStatement('DELETE FROM $table WHERE home_id = ?', [key]);
      }
      await db.customStatement(
        'DELETE FROM field_clock WHERE EXISTS (SELECT 1 FROM extra '
        'WHERE extra.entity = field_clock.entity '
        'AND extra.row_id = field_clock.row_id AND extra.home_id = ?)',
        [key],
      );
      await db.customStatement(
        "DELETE FROM field_clock WHERE entity = 'homes.home' AND row_id = ?",
        [key],
      );
      await db.customStatement('DELETE FROM homes WHERE id = ?', [key]);
      for (final table in [
        'extra',
        'pending',
        'op_log',
        'other_versions',
        'server_seen',
      ]) {
        await db.customStatement('DELETE FROM $table WHERE home_id = ?', [key]);
      }
      await db.customStatement(
        'INSERT OR IGNORE INTO purged_homes (home_id) VALUES (?)',
        [key],
      );
      if (await _setting('current_home') == homeId) {
        await _setSetting('current_home', null);
      }
    });
    final directory = homeDirectory(homeId);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }

  // ---------- snapshot ----------

  /// The merged state of this phone (docs/protocol.md section 2.4): every
  /// row with each field's value, clock and writer, tombstones included,
  /// the fields kept in `extra`, and the operations kept in `pending`.
  Future<SyncSnapshot> snapshot() async {
    final rows = <String, SnapshotRow>{};
    final clockRows = await db
        .customSelect(
          'SELECT entity, row_id, field, hlc, device FROM field_clock '
          'ORDER BY entity, row_id, field',
        )
        .get();
    final tableRows = <String, Map<String, Object?>?>{};
    final extras = <String, (String?, Map<String, Object?>)>{};
    for (final r
        in await db
            .customSelect('SELECT entity, row_id, home_id, json FROM extra')
            .get()) {
      final home = r.data['home_id'] as Uint8List?;
      extras['${r.data['entity']}|${Uuid.unparse(r.data['row_id'] as Uint8List)}'] =
          (
            home == null ? null : Uuid.unparse(home),
            (jsonDecode(r.data['json'] as String) as Map)
                .cast<String, Object?>(),
          );
    }
    for (final c in clockRows) {
      final type = c.data['entity'] as String;
      final id = Uuid.unparse(c.data['row_id'] as Uint8List);
      final field = c.data['field'] as String;
      final key = '$type|$id';
      final table = tableOfEntity[type];
      if (table != null && !tableRows.containsKey(key)) {
        tableRows[key] =
            (await db
                    .customSelect(
                      'SELECT * FROM $table WHERE id = ?',
                      variables: [Variable<Uint8List>(uuidBytes(id))],
                    )
                    .getSingleOrNull())
                ?.data;
      }
      final row = tableRows[key];
      final extra = extras[key];
      final column = table == null ? null : _columns(table)[field];
      Object? value;
      if (column != null && row != null) {
        value = _toWire(column, row[field]);
      } else if (extra != null && extra.$2.containsKey(field)) {
        value = extra.$2[field];
      } else {
        continue;
      }
      final home = table == 'homes'
          ? id
          : row != null
          ? Uuid.unparse(row['home_id'] as Uint8List)
          : extra?.$1;
      final entry = rows[key] ??= SnapshotRow(
        type: type,
        home: home,
        id: id,
        fields: {},
      );
      entry.fields[field] = [
        value,
        c.data['hlc'] as String,
        b64(c.data['device'] as Uint8List),
      ];
    }
    final pending = await db
        .customSelect('SELECT body FROM pending ORDER BY key')
        .get();
    return SyncSnapshot(
      schemaVersion: schemaVersion,
      rows: [for (final k in rows.keys.toList()..sort()) rows[k]!],
      pending: [
        for (final p in pending)
          (jsonDecode(p.data['body'] as String) as Map).cast<String, Object?>(),
      ],
    );
  }

  // ---------- repair rules (docs/adr/0003, "Invariants across rows") ----------

  /// Runs the repair rules on the merged data. Their result depends only on
  /// it, so two phones that repair the same data write the same values; the
  /// writes are operations like any other.
  Future<List<SyncNotice>> repairMerged() async {
    final notices = <SyncNotice>[];
    await _repairTwoOpenOccurrences();
    notices.addAll(await _repairUndoAgainstEdit());
    return notices;
  }

  /// Two open occurrences of one task (one phone postponed, the other
  /// closed): the one that follows the other stays open; the earlier one is
  /// closed as done if a phone marked it done, else as skipped.
  Future<void> _repairTwoOpenOccurrences() async {
    final open =
        await (db.select(db.occurrences)
              ..where((o) => o.deletedAt.isNull() & o.status.isIn(openStatuses))
              ..orderBy([(o) => OrderingTerm.asc(o.id)]))
            .get();
    final byTask = <String, List<OccurrenceRow>>{};
    for (final o in open) {
      (byTask[o.taskId] ??= []).add(o);
    }
    for (final group in byTask.values) {
      if (group.length < 2) continue;
      for (final earlier in group) {
        final followed = group.any(
          (o) =>
              o.id != earlier.id &&
              (o.follows == earlier.id ||
                  o.id == Repository.successorId(earlier.homeId, earlier.id)),
        );
        if (!followed) continue;
        await _put('occurrences', earlier.id, {
          'status_before': earlier.status,
          'status': earlier.completedOn != null ? 'done' : 'skipped',
        });
      }
    }
  }

  /// An undo made on this phone whose next occurrence was worked on by
  /// another phone in the meantime: the edit wins, and this phone takes its
  /// undo back (the next occurrence restored, the closing as it was, its
  /// materials taken again), with a notice.
  Future<List<SyncNotice>> _repairUndoAgainstEdit() async {
    final notices = <SyncNotice>[];
    final records =
        await (db.select(db.localSettings)
              ..where((s) => s.key.like('undo:%'))
              ..orderBy([(s) => OrderingTerm.asc(s.key)]))
            .get();
    for (final record in records) {
      final id = record.key.substring('undo:'.length);
      final closed = await occurrence(id);
      if (closed == null || !openStatuses.contains(closed.status)) {
        // Closed again by the other side's write (a server that refused the
        // undo gives the values that won, lot 4b): the undo was taken back
        // there, and the person is told so here.
        final by = closed == null
            ? null
            : (await _clocksOf('tasks.occurrence', id))['status'];
        if (by != null && b64(by.device) != b64(_device)) {
          notices.add(
            SyncNotice(
              SyncNoticeKind.undoReverted,
              entity: 'tasks.occurrence',
              rowId: id,
            ),
          );
        }
        await _setSetting(record.key, null);
        continue;
      }
      final nextId = Repository.successorId(closed.homeId, id);
      final next = await (db.select(
        db.occurrences,
      )..where((o) => o.id.equalsValue(nextId))).getSingleOrNull();
      if (next == null) continue;
      if (next.deletedAt == null) {
        await _setSetting(record.key, null);
        continue;
      }
      final deletedBy = (await _clocksOf(
        'tasks.occurrence',
        nextId,
      ))['deleted_at'];
      // Only the phone that made the undo takes it back.
      if (deletedBy == null || b64(deletedBy.device) != b64(_device)) {
        continue;
      }
      final untouched =
          next.status == 'planned' &&
          next.postponedFrom == null &&
          next.actualCost == null &&
          next.completionNote.isEmpty;
      if (untouched) continue;
      final before = (jsonDecode(record.value) as Map).cast<String, Object?>();
      await _put('occurrences', nextId, {'follows': id, 'deleted_at': null});
      await _put('occurrences', id, before);
      if (before['status'] == 'done' && before['completed_on'] is String) {
        final again = await occurrence(id);
        await _drawForDone(
          again!,
          Day.parse(before['completed_on']! as String),
        );
      }
      await _setSetting(record.key, null);
      notices.add(
        SyncNotice(
          SyncNoticeKind.undoReverted,
          entity: 'tasks.occurrence',
          rowId: id,
        ),
      );
    }
    return notices;
  }

  /// Keeps what [undo] changes on the occurrence [found], so that a repair
  /// can take the undo back.
  Future<void> _rememberUndo(OccurrenceRow found) => _setSetting(
    _undoKey(found.id),
    jsonEncode({
      'status': found.status,
      'status_before': found.statusBefore,
      'completed_on': found.completedOn,
      'completion_note': found.completionNote,
      'actual_cost': found.actualCost,
    }),
  );

  /// Drops the long texts kept longer than [otherVersionDays].
  Future<void> dropOldVersions() => db.customStatement(
    'DELETE FROM other_versions WHERE kept_until < ?',
    [_now()],
  );

  /// The long texts that lost a merge on the row [id], newest first.
  Future<List<OtherVersionRow>> otherVersions(String entity, String id) =>
      (db.select(db.otherVersions)
            ..where((v) => v.entity.equals(entity) & v.rowId.equalsValue(id))
            ..orderBy([(v) => OrderingTerm.desc(v.hlc)]))
          .get();

  // ---------- the cursor of the transport (this phone, never synced) ----------

  Future<SyncPosition?> syncCursor() async {
    final text = await _setting('sync_cursor');
    return text == null ? null : int.parse(text);
  }

  Future<void> setSyncCursor(SyncPosition? position) =>
      _setSetting('sync_cursor', position?.toString());
}
