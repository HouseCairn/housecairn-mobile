// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// One room, item or stock article of a home that can carry a label, with
/// its active label when it has one (`Entry` of web `labels/services.py`).
class LabelEntry {
  const LabelEntry({
    required this.kind,
    required this.id,
    required this.name,
    required this.place,
    this.label,
  });

  final LabelKind kind;
  final String id;
  final String name;

  /// Where it is, as printed: the room of an item, the storage place of an
  /// article, nothing for a room (`Label.place`).
  final String place;
  final LabelRow? label;
}

/// What a scanned code opens on this phone.
enum LabelLookup {
  /// An active label of an object that exists.
  found,

  /// A label this phone made or knew, revoked since: the sticker opens
  /// nothing.
  revoked,

  /// A label whose object was deleted.
  gone,

  /// A code this phone does not know: a sticker of another phone, of the
  /// web, or of a home that is not here.
  unknown,
}

/// The answer of [LabelRepository.lookUpLabel]: the label and its object
/// when [lookup] is [LabelLookup.found].
class LabelTarget {
  const LabelTarget(this.lookup, {this.label});

  final LabelLookup lookup;
  final LabelRow? label;
}

/// QR labels (web `labels/services.py`, web ADR 0047; docs/adr/0014-qr-labels.md).
///
/// The rows are written by plain SQL, not by `_put`: a label is kept on this
/// phone only, in every way of the app (no `field_clock`, no `op_log`), until
/// a server carries the type `labels.label`. The rules of the web hold:
/// making, regenerating and revoking need a home that is written (not
/// archived, not read only on a server, not the example of the guide); an
/// object has at most one active label; a revoked row is kept, so that its
/// code is never given again.
extension LabelRepository on Repository {
  static const _target = {
    LabelKind.room: 'room_id',
    LabelKind.item: 'item_id',
    LabelKind.article: 'article_id',
  };

  Future<HomeRow> _labelHome(String homeId) async {
    final home = await _writableHome(homeId);
    // The example home of the guide has no QR label (web
    // `labels/services.py` `_require_write`, ADR 0084).
    if (home.isExample) throw const Refused(Refusal.notFound);
    if (await serverRole(homeId) == 'read_only') {
      throw const Refused(Refusal.readOnlyHome);
    }
    return home;
  }

  /// The name and the place of the object of [kind] and [id] in [homeId],
  /// or `null` when there is none (deleted, or of another home).
  Future<(String, String)?> _labelObject(
    String homeId,
    LabelKind kind,
    String id,
  ) async {
    switch (kind) {
      case LabelKind.room:
        final room = await this.room(id);
        if (room == null || room.homeId != homeId) return null;
        return (room.name, '');
      case LabelKind.item:
        final item = await this.item(id);
        if (item == null || item.homeId != homeId) return null;
        return (item.name, (await room(item.roomId))?.name ?? '');
      case LabelKind.article:
        final article = await this.article(id);
        if (article == null || article.homeId != homeId) return null;
        return (article.name, article.storageLocation);
    }
  }

  /// The id of the object a label opens.
  static String targetOf(LabelRow label) =>
      switch (LabelKind.parse(label.kind)) {
        LabelKind.room => label.roomId!,
        LabelKind.item => label.itemId!,
        LabelKind.article || null => label.articleId!,
      };

  /// The active label of the object of [kind] and [id], if it has one.
  Future<LabelRow?> activeLabel(LabelKind kind, String id) =>
      (db.select(db.labels)..where(
            (l) =>
                l.kind.equals(kind.wire) &
                l.revokedAt.isNull() &
                switch (kind) {
                  LabelKind.room => l.roomId.equalsValue(id),
                  LabelKind.item => l.itemId.equalsValue(id),
                  LabelKind.article => l.articleId.equalsValue(id),
                },
          ))
          .getSingleOrNull();

  Future<LabelRow?> label(String id) => (db.select(
    db.labels,
  )..where((l) => l.id.equalsValue(id))).getSingleOrNull();

  /// The name and the place a label prints, read from its object now.
  Future<(String, String)?> labelText(LabelRow label) =>
      _labelObject(label.homeId, LabelKind.parse(label.kind)!, targetOf(label));

  /// Every room, item and stock article of [homeId], in that order, with its
  /// label (`entries_of` of the web: rooms by position, items by room then
  /// name, articles by name).
  Future<List<LabelEntry>> labelEntries(String homeId) async {
    final active = await (db.select(
      db.labels,
    )..where((l) => l.homeId.equalsValue(homeId) & l.revokedAt.isNull())).get();
    LabelRow? of(LabelKind kind, String id) => active
        .where((l) => l.kind == kind.wire && targetOf(l) == id)
        .firstOrNull;
    final rooms = await this.rooms(homeId);
    final roomNames = {for (final r in rooms) r.id: r.name};
    final roomOrder = {for (final (i, r) in rooms.indexed) r.id: i};
    final items = await itemsOfHome(homeId)
      ..sort((a, b) {
        final byRoom = (roomOrder[a.roomId] ?? 1 << 30).compareTo(
          roomOrder[b.roomId] ?? 1 << 30,
        );
        if (byRoom != 0) return byRoom;
        final byName = a.name.compareTo(b.name);
        return byName != 0 ? byName : a.id.compareTo(b.id);
      });
    final articles =
        await (db.select(db.articles)
              ..where(
                (a) => a.homeId.equalsValue(homeId) & a.deletedAt.isNull(),
              )
              ..orderBy([
                (a) => OrderingTerm.asc(a.name),
                (a) => OrderingTerm.asc(a.id),
              ]))
            .get();
    return [
      for (final r in rooms)
        LabelEntry(
          kind: LabelKind.room,
          id: r.id,
          name: r.name,
          place: '',
          label: of(LabelKind.room, r.id),
        ),
      for (final i in items)
        if (roomNames.containsKey(i.roomId))
          LabelEntry(
            kind: LabelKind.item,
            id: i.id,
            name: i.name,
            place: roomNames[i.roomId]!,
            label: of(LabelKind.item, i.id),
          ),
      for (final a in articles)
        LabelEntry(
          kind: LabelKind.article,
          id: a.id,
          name: a.name,
          place: a.storageLocation,
          label: of(LabelKind.article, a.id),
        ),
    ];
  }

  Future<String> _freshCode() async {
    while (true) {
      final code = newLabelCode(_random);
      final taken = await (db.select(
        db.labels,
      )..where((l) => l.code.equals(code))).getSingleOrNull();
      if (taken == null) return code;
    }
  }

  Future<LabelRow> _insertLabel(
    String homeId,
    LabelKind kind,
    String id,
  ) async {
    final labelId = newId();
    final now = _now();
    await db.customInsert(
      'INSERT INTO labels (id, created_at, updated_at, home_id, kind, '
      '${_target[kind]}, code) VALUES (?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable<Uint8List>(uuidBytes(labelId)),
        Variable<int>(now),
        Variable<int>(now),
        Variable<Uint8List>(uuidBytes(homeId)),
        Variable<String>(kind.wire),
        Variable<Uint8List>(uuidBytes(id)),
        Variable<String>(await _freshCode()),
      ],
    );
    return (await label(labelId))!;
  }

  /// The active label of an object, made when it has none: `(label,
  /// created)` (`create_label` of the web).
  Future<(LabelRow, bool)> createLabel(
    String homeId,
    LabelKind kind,
    String id,
  ) => db.transaction(() async {
    await _labelHome(homeId);
    if (await _labelObject(homeId, kind, id) == null) {
      throw const Refused(Refusal.notInHome);
    }
    final existing = await activeLabel(kind, id);
    if (existing != null) return (existing, false);
    return (await _insertLabel(homeId, kind, id), true);
  });

  Future<void> _revoke(LabelRow label) => db.customUpdate(
    'UPDATE labels SET revoked_at = ?, updated_at = ? '
    'WHERE id = ? AND revoked_at IS NULL',
    variables: [
      Variable<int>(_now()),
      Variable<int>(_now()),
      Variable<Uint8List>(uuidBytes(label.id)),
    ],
    updates: {db.labels},
  );

  /// Stops the sticker from opening anything; the row stays, so its code is
  /// never given again (`revoke_label`).
  Future<void> revokeLabel(String labelId) => db.transaction(() async {
    final found = await label(labelId);
    if (found == null || found.revokedAt != null) {
      throw const Refused(Refusal.notFound);
    }
    await _labelHome(found.homeId);
    await _revoke(found);
  });

  /// Revokes the label and makes another for the same object, with a new
  /// code, in one transaction (`regenerate_label`).
  Future<LabelRow> regenerateLabel(String labelId) => db.transaction(() async {
    final found = await label(labelId);
    if (found == null || found.revokedAt != null) {
      throw const Refused(Refusal.notFound);
    }
    await _labelHome(found.homeId);
    final kind = LabelKind.parse(found.kind)!;
    await _revoke(found);
    return _insertLabel(found.homeId, kind, targetOf(found));
  });

  /// The labels of the objects [wanted] (kind and id), in that order, for a
  /// sheet: one is made for an object that has none when the home is
  /// written; otherwise only the existing ones are printed
  /// (`labels_to_print`). At most [maxLabelsPerSheet].
  Future<List<LabelRow>> labelsToPrint(
    String homeId,
    List<(LabelKind, String)> wanted,
  ) => db.transaction(() async {
    final unique = wanted.toSet().toList();
    if (unique.isEmpty || unique.length > maxLabelsPerSheet) {
      throw const Refused(Refusal.tooManyLabels);
    }
    final found = <LabelRow>[];
    for (final (kind, id) in unique) {
      final existing = await activeLabel(kind, id);
      if (existing != null) {
        found.add(existing);
      } else {
        found.add((await createLabel(homeId, kind, id)).$1);
      }
    }
    return found;
  });

  /// What the code [code] opens on this phone. A code that is not shaped as
  /// one, or that no label of this phone has, is [LabelLookup.unknown].
  Future<LabelTarget> lookUpLabel(String code) async {
    if (!isLabelCode(code)) return const LabelTarget(LabelLookup.unknown);
    final found = await (db.select(
      db.labels,
    )..where((l) => l.code.equals(code))).getSingleOrNull();
    if (found == null || await home(found.homeId) == null) {
      return const LabelTarget(LabelLookup.unknown);
    }
    if (found.revokedAt != null) {
      return LabelTarget(LabelLookup.revoked, label: found);
    }
    if (await labelText(found) == null) {
      return LabelTarget(LabelLookup.gone, label: found);
    }
    return LabelTarget(LabelLookup.found, label: found);
  }
}

/// The PDF of a sheet, written for the share sheet of the phone and removed
/// once it is shared: nothing of a sheet is kept.
extension LabelSheetFiles on Repository {
  Future<String> writeLabelSheet(Uint8List bytes) async {
    final directory = Directory('${files.path}/print')
      ..createSync(recursive: true);
    final file = File('${directory.path}/housecairn-labels.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> removeLabelSheet(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
