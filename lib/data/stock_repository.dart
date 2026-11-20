// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// What an article is made of, as its form edits it (`stock/models.py:68-122`).
/// [threshold] and [unitPrice] are typed text: empty for none, else a decimal
/// with at most two places.
class ArticleInput {
  const ArticleInput({
    required this.name,
    this.manufacturerReference = '',
    this.dimensions = '',
    this.storageLocation = '',
    this.unit = '',
    this.unitOther = '',
    this.threshold = '',
    this.unitPrice = '',
    this.notes = '',
    this.ean = '',
    this.roomIds = const [],
    this.itemIds = const [],
  });

  final String name;
  final String manufacturerReference;
  final String dimensions;
  final String storageLocation;
  final String unit;
  final String unitOther;
  final String threshold;
  final String unitPrice;
  final String notes;

  /// The barcode as typed or scanned (web ADR 0083).
  final String ean;

  /// Rooms where it is used, and items it fits, of the article's home.
  final List<String> roomIds;
  final List<String> itemIds;
}

/// What a supplier is made of (`stock/models.py:148-157`).
class SupplierInput {
  const SupplierInput({
    required this.name,
    this.reference = '',
    this.url = '',
    this.lastPrice = '',
  });

  factory SupplierInput.of(SupplierRow row) => SupplierInput(
    name: row.name,
    reference: row.reference,
    url: row.url,
    lastPrice: row.lastPrice == null
        ? ''
        : stock.plain(stock.readQuantity(row.lastPrice!)),
  );

  final String name;
  final String reference;
  final String url;
  final String lastPrice;
}

/// An article with its stock, the sum of its movements.
class ArticleEntry {
  const ArticleEntry(this.article, this.level);

  final ArticleRow article;
  final Decimal level;

  Decimal? get threshold =>
      article.threshold == null ? null : stock.readQuantity(article.threshold!);

  bool get low => stock.isLow(level, threshold);
}

/// A line of the ledger with its effect on the stock, and the task whose
/// closing wrote it, if any.
class MovementEntry {
  const MovementEntry(this.movement, this.effect, {this.taskId, this.task});

  final MovementRow movement;
  final Decimal effect;
  final String? taskId;
  final String? task;

  Decimal get quantity => stock.readQuantity(movement.quantity);
}

/// An article a task needs, the quantity, and what is in stock now.
class MaterialEntry {
  const MaterialEntry(this.line, this.article, this.level);

  final TaskMaterialRow line;
  final ArticleRow article;
  final Decimal level;

  Decimal get quantity => stock.readQuantity(line.quantity);
}

/// An article the stock could not give in full when a task was marked done
/// (`tasks/materials.py` `Shortage`).
class Shortage {
  const Shortage(this.article, this.wanted, this.drawn);

  final ArticleRow article;
  final Decimal wanted;
  final Decimal drawn;

  Decimal get missing => wanted - drawn;
}

/// The stock of a home (`stock/services.py`, `tasks/materials.py`): articles,
/// suppliers, the ledger of movements, the materials of tasks and what a done
/// occurrence takes. Every rule is the web's; the stock of an article is
/// computed from its movements in the order of their clocks, never stored.
extension StockRepository on Repository {
  // ---------- ids (docs/adr/0003-sync-protocol.md, "Deterministic ids") ----------

  static String materialId(String home, String task, String article) =>
      Repository._uuid.v5(home, 'material:$task:$article');

  static String drawId(String home, String occurrence, String article) =>
      Repository._uuid.v5(home, 'draw:$occurrence:$article');

  static String articleRoomId(String home, String article, String room) =>
      Repository._uuid.v5(home, 'stock.article_rooms:$article:$room');

  static String articleItemId(String home, String article, String item) =>
      Repository._uuid.v5(
        home,
        'stock.article_compatible_items:$article:$item',
      );

  // ---------- reading ----------

  Future<ArticleRow?> article(String id) =>
      (db.select(db.articles)
            ..where((a) => a.id.equalsValue(id) & a.deletedAt.isNull()))
          .getSingleOrNull();

  /// The movements of [articleIds] (or of a whole home), in the order of the
  /// clock that created them, then device and id: the order an inventory
  /// line's effect is computed in (docs/adr/0003-sync-protocol.md).
  Future<List<MovementRow>> _ledgerRows({
    String? homeId,
    String? articleId,
  }) async {
    final clock = db.fieldClock;
    final query =
        db.select(db.movements).join([
            leftOuterJoin(
              clock,
              clock.entity.equals('stock.movement') &
                  clock.rowId.equalsExp(db.movements.id) &
                  clock.field.equals('created_at'),
            ),
          ])
          ..where(
            db.movements.deletedAt.isNull() &
                (homeId == null
                    ? db.movements.articleId.equalsValue(articleId!)
                    : db.movements.homeId.equalsValue(homeId)),
          )
          ..orderBy([
            OrderingTerm.asc(clock.hlc),
            OrderingTerm.asc(clock.device),
            OrderingTerm.asc(db.movements.id),
          ]);
    return [for (final row in await query.get()) row.readTable(db.movements)];
  }

  static stock.LedgerLine _line(MovementRow m) =>
      stock.LedgerLine(m.kind, stock.readQuantity(m.quantity));

  /// The stock of the article: the sum of the effects of its movements.
  Future<Decimal> stockLevel(String articleId) async => stock.levelOf([
    for (final m in await _ledgerRows(articleId: articleId)) _line(m),
  ]);

  /// The stock of every article of [homeId], by article id.
  Future<Map<String, Decimal>> _levels(String homeId) async {
    final byArticle = <String, List<stock.LedgerLine>>{};
    for (final m in await _ledgerRows(homeId: homeId)) {
      (byArticle[m.articleId] ??= []).add(_line(m));
    }
    return {
      for (final MapEntry(:key, :value) in byArticle.entries)
        key: stock.levelOf(value),
    };
  }

  /// The articles of a home by name, each with its stock
  /// (`stock/services.py` `search_articles`): [query] matches the name, the
  /// manufacturer reference, the barcode (web ADR 0083) or a supplier's name
  /// or reference; [low] keeps
  /// those at or below their threshold.
  Future<List<ArticleEntry>> articles(
    String homeId, {
    String query = '',
    bool low = false,
  }) async {
    final rows =
        await (db.select(db.articles)
              ..where(
                (a) => a.homeId.equalsValue(homeId) & a.deletedAt.isNull(),
              )
              ..orderBy([
                (a) => OrderingTerm.asc(a.name),
                (a) => OrderingTerm.asc(a.createdAt),
                (a) => OrderingTerm.asc(a.id),
              ]))
            .get();
    final levels = await _levels(homeId);
    final needle = foldForSearch(query.trim());
    final bySupplier = <String>{};
    if (needle.isNotEmpty) {
      final suppliers =
          await (db.select(db.suppliers)..where(
                (s) => s.homeId.equalsValue(homeId) & s.deletedAt.isNull(),
              ))
              .get();
      for (final s in suppliers) {
        if (matchesSearch(needle, [
          foldForSearch(s.name),
          foldForSearch(s.reference),
        ])) {
          bySupplier.add(s.articleId);
        }
      }
    }
    return [
      for (final a in rows)
        if (needle.isEmpty ||
            matchesSearch(needle, [
              foldForSearch(a.name),
              foldForSearch(a.manufacturerReference),
            ]) ||
            gtinMatches(query, a.ean) ||
            bySupplier.contains(a.id))
          ArticleEntry(a, levels[a.id] ?? stock.zero),
    ].where((e) => !low || e.low).toList();
  }

  /// The ledger of an article, the latest first (`stock/models.py` `Meta`),
  /// each line with its effect.
  Future<List<MovementEntry>> movementsOf(String articleId) async {
    final rows = await _ledgerRows(articleId: articleId);
    final effects = stock.effectsOf([for (final m in rows) _line(m)]);
    final titles = <String, (String, String)>{};
    for (final m in rows) {
      final occurrenceId = m.occurrenceId;
      if (occurrenceId == null || titles.containsKey(occurrenceId)) continue;
      final o = await (db.select(
        db.occurrences,
      )..where((t) => t.id.equalsValue(occurrenceId))).getSingleOrNull();
      final t = o == null ? null : await task(o.taskId);
      if (t != null) titles[occurrenceId] = (t.id, t.title);
    }
    final entries = [
      for (final (i, m) in rows.indexed)
        MovementEntry(
          m,
          effects[i],
          taskId: titles[m.occurrenceId]?.$1,
          task: titles[m.occurrenceId]?.$2,
        ),
    ];
    // Display order of the web: the day, then the latest written first.
    final position = {for (final (i, m) in rows.indexed) m.id: i};
    entries.sort((a, b) {
      final byDay = b.movement.occurredOn.compareTo(a.movement.occurredOn);
      return byDay != 0
          ? byDay
          : position[b.movement.id]!.compareTo(position[a.movement.id]!);
    });
    return entries;
  }

  Future<List<RoomRow>> roomsOfArticle(String articleId) async {
    final links =
        await (db.select(db.articleRooms)..where(
              (l) => l.articleId.equalsValue(articleId) & l.deletedAt.isNull(),
            ))
            .get();
    final ids = links.map((l) => l.roomId).toSet();
    if (ids.isEmpty) return [];
    final article = await this.article(articleId);
    if (article == null) return [];
    return [
      for (final r in await rooms(article.homeId))
        if (ids.contains(r.id)) r,
    ];
  }

  /// The items an article fits, by the name of their room, then by name
  /// (`stock/views.py` `ArticleDetailView`: `room__name`, `name`).
  Future<List<ItemRow>> compatibleItemsOf(String articleId) async {
    final links =
        await (db.select(db.articleItems)..where(
              (l) => l.articleId.equalsValue(articleId) & l.deletedAt.isNull(),
            ))
            .get();
    final ids = links.map((l) => l.itemId).toSet();
    if (ids.isEmpty) return [];
    final article = await this.article(articleId);
    if (article == null) return [];
    final roomNames = {
      for (final r in await rooms(article.homeId)) r.id: r.name,
    };
    final items = [
      for (final i in await itemsOfHome(article.homeId))
        if (ids.contains(i.id)) i,
    ];
    int byRoomThenName(ItemRow a, ItemRow b) {
      final room = (roomNames[a.roomId] ?? '').compareTo(
        roomNames[b.roomId] ?? '',
      );
      return room != 0 ? room : a.name.compareTo(b.name);
    }

    return items..sort(byRoomThenName);
  }

  /// The articles that concern a room (`stock/services.py`
  /// `articles_of_room`): the room is listed on the article, the article fits
  /// an item of the room that is not deleted, or it is the tin of paint left
  /// over in the memory of the room. By name, each with its stock.
  Future<List<ArticleEntry>> articlesOfRoom(String roomId) async {
    final room = await this.room(roomId);
    if (room == null) return [];
    final kept = await (db.select(
      db.articleRooms,
    )..where((l) => l.roomId.equalsValue(roomId) & l.deletedAt.isNull())).get();
    final items = {for (final i in await itemsOf(roomId)) i.id};
    final fitting = items.isEmpty
        ? const <ArticleItemRow>[]
        : await (db.select(db.articleItems)..where(
                (l) => l.homeId.equalsValue(room.homeId) & l.deletedAt.isNull(),
              ))
              .get();
    final ids = {
      for (final l in kept) l.articleId,
      for (final l in fitting)
        if (items.contains(l.itemId)) l.articleId,
      ?room.paintArticleId,
    };
    if (ids.isEmpty) return [];
    return [
      for (final entry in await articles(room.homeId))
        if (ids.contains(entry.article.id)) entry,
    ];
  }

  /// The tasks that list the article (`tasks/materials.py` `tasks_using`).
  Future<List<TaskRow>> tasksUsing(String articleId) async {
    final lines =
        await (db.select(db.taskMaterials)..where(
              (l) => l.articleId.equalsValue(articleId) & l.deletedAt.isNull(),
            ))
            .get();
    return [for (final l in lines) ?await task(l.taskId)]
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  Future<List<SupplierRow>> suppliersOf(String articleId) =>
      (db.select(db.suppliers)
            ..where(
              (s) => s.articleId.equalsValue(articleId) & s.deletedAt.isNull(),
            )
            ..orderBy([
              (s) => OrderingTerm.asc(s.name),
              (s) => OrderingTerm.asc(s.createdAt),
              (s) => OrderingTerm.asc(s.id),
            ]))
          .get();

  Future<SupplierRow?> supplier(String id) =>
      (db.select(db.suppliers)
            ..where((s) => s.id.equalsValue(id) & s.deletedAt.isNull()))
          .getSingleOrNull();

  // ---------- writing helpers ----------

  /// A typed quantity or amount: `null` when empty and [optional], else a
  /// decimal of the model.
  static Decimal? _quantity(String text, {bool optional = true}) {
    if (text.trim().isEmpty) {
      if (optional) return null;
      throw const Refused(Refusal.quantityInvalid);
    }
    final value = stock.parseQuantity(text);
    if (value == null) throw const Refused(Refusal.quantityInvalid);
    return value;
  }

  static String? _stored(Decimal? value) =>
      value == null ? null : stock.storedQuantity(value);

  /// Writes [fields] on the row [id] of [table], creating it if it does not
  /// exist: the rows whose id is deterministic come back this way.
  Future<void> _upsert(
    String table,
    String id,
    Map<String, Object?> fields,
    String homeId,
  ) async {
    final found = await db
        .customSelect(
          'SELECT 1 FROM $table WHERE id = ?',
          variables: [Variable<Uint8List>(uuidBytes(id))],
        )
        .getSingleOrNull();
    await _put(table, id, fields, homeId: homeId, create: found == null);
  }

  Future<ArticleRow> _writableArticle(String id) async {
    final found = await article(id);
    if (found == null) throw const Refused(Refusal.notFound);
    await _writableHome(found.homeId);
    return found;
  }

  Future<Map<String, Object?>> _articleFields(
    ArticleInput input,
    String homeId,
  ) async {
    if (input.unit.isNotEmpty) Repository._oneOf(input.unit, stock.units);
    final other = input.unit == 'other'
        ? input.unitOther.trim().split(RegExp(r'\s+')).join(' ')
        : '';
    if (input.unit == 'other' && other.isEmpty) {
      throw const Refused(Refusal.unitOtherRequired);
    }
    final rooms = {for (final r in await this.rooms(homeId)) r.id};
    final items = {for (final i in await itemsOfHome(homeId)) i.id};
    if (!input.roomIds.every(rooms.contains) ||
        !input.itemIds.every(items.contains)) {
      throw const Refused(Refusal.notInHome);
    }
    return {
      'name': Repository._name(input.name, 120),
      'manufacturer_reference': Repository._text(
        input.manufacturerReference,
        120,
      ),
      'dimensions': Repository._text(input.dimensions, 120),
      'storage_location': Repository._text(input.storageLocation, 200),
      'unit': input.unit,
      'unit_other': Repository._text(other, 24),
      'threshold': _stored(_quantity(input.threshold)),
      'unit_price': _stored(_quantity(input.unitPrice)),
      'notes': Repository._text(input.notes, notesMaxLength),
      'ean': cleanEan(input.ean),
    };
  }

  /// Makes the links of [articleId] to rooms (or items) exactly [wanted].
  Future<void> _setLinks(
    String table,
    String column,
    String homeId,
    String articleId,
    Iterable<String> wanted,
    String Function(String home, String article, String other) idOf,
  ) async {
    final now = _now();
    final rows = await db
        .customSelect(
          'SELECT id, $column AS other FROM $table '
          'WHERE article_id = ? AND deleted_at IS NULL',
          variables: [Variable<Uint8List>(uuidBytes(articleId))],
        )
        .get();
    final existing = {
      for (final r in rows)
        Uuid.unparse(r.read<Uint8List>('other')): Uuid.unparse(
          r.read<Uint8List>('id'),
        ),
    };
    final keep = wanted.toSet();
    for (final MapEntry(key: other, value: id) in existing.entries) {
      if (!keep.contains(other)) await _put(table, id, {'deleted_at': now});
    }
    for (final other in keep.difference(existing.keys.toSet())) {
      await _upsert(table, idOf(homeId, articleId, other), {
        'article_id': articleId,
        column: other,
        'deleted_at': null,
      }, homeId);
    }
  }

  // ---------- articles ----------

  Future<String> addArticle(String homeId, ArticleInput input) async {
    await _writableHome(homeId);
    final fields = await _articleFields(input, homeId);
    final id = newId();
    await db.transaction(() async {
      await _put(
        'articles',
        id,
        {...fields, 'label': null, 'deleted_at': null},
        homeId: homeId,
        create: true,
      );
      await _setLinks(
        'article_rooms',
        'room_id',
        homeId,
        id,
        input.roomIds,
        articleRoomId,
      );
      await _setLinks(
        'article_items',
        'item_id',
        homeId,
        id,
        input.itemIds,
        articleItemId,
      );
    });
    return id;
  }

  /// Gives the article [id] the photo of a product found by its barcode as
  /// its label, with its credit (web ADR 0083, `attach_to_article`), only
  /// when it has no label yet: `false` and nothing written otherwise. The
  /// photo is already re-encoded, without metadata.
  Future<bool> setFoundLabel(
    String id,
    ProcessedPhoto photo,
    Map<String, String> attribution,
  ) async {
    final current = await _writableArticle(id);
    if (current.label != null) return false;
    final directory = homeDirectory(current.homeId)
      ..createSync(recursive: true);
    final file = File('${directory.path}/$id.jpg');
    file.writeAsBytesSync(photo.image, flush: true);
    try {
      await db.transaction(
        () => _put('articles', id, {
          'label': photo.fileReference().encode(),
          'label_attribution': attributionJson(attribution) ?? '{}',
        }),
      );
    } catch (_) {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    }
    return true;
  }

  Future<void> updateArticle(String id, ArticleInput input) async {
    final current = await _writableArticle(id);
    final changes = _changes(
      current,
      await _articleFields(input, current.homeId),
    );
    await db.transaction(() async {
      if (changes.isNotEmpty) await _put('articles', id, changes);
      await _setLinks(
        'article_rooms',
        'room_id',
        current.homeId,
        id,
        input.roomIds,
        articleRoomId,
      );
      await _setLinks(
        'article_items',
        'item_id',
        current.homeId,
        id,
        input.itemIds,
        articleItemId,
      );
    });
  }

  /// Soft-deletes the article with its suppliers, movements and links
  /// (`stock/services.py` `delete_article`); the tasks that listed it no
  /// longer show it.
  Future<void> deleteArticle(String id) async {
    await _writableArticle(id);
    final now = _now();
    final key = Variable<Uint8List>(uuidBytes(id));
    await db.transaction(() async {
      for (final table in [
        'suppliers',
        'movements',
        'article_rooms',
        'article_items',
      ]) {
        final rows = await db
            .customSelect(
              'SELECT id FROM $table WHERE article_id = ? AND deleted_at IS NULL',
              variables: [key],
            )
            .get();
        for (final r in rows) {
          await _put(table, Uuid.unparse(r.read<Uint8List>('id')), {
            'deleted_at': now,
          });
        }
      }
      await _put('articles', id, {'deleted_at': now});
    });
  }

  // ---------- suppliers ----------

  Map<String, Object?> _supplierFields(SupplierInput input) => {
    'name': Repository._name(input.name, 120),
    'reference': Repository._text(input.reference, 120),
    'url': input.url.trim().isEmpty ? '' : Repository._webUrl(input.url),
    'last_price': _stored(_quantity(input.lastPrice)),
  };

  /// An article with no unit price takes the last price paid at a supplier
  /// (`stock/services.py` `_prefill_unit_price`); a typed price is never
  /// replaced.
  Future<void> _prefillUnitPrice(String articleId, String? lastPrice) async {
    final current = await article(articleId);
    if (current == null || current.unitPrice != null || lastPrice == null) {
      return;
    }
    await _put('articles', articleId, {'unit_price': lastPrice});
  }

  Future<String> addSupplier(String articleId, SupplierInput input) async {
    final owner = await _writableArticle(articleId);
    final fields = _supplierFields(input);
    final id = newId();
    await db.transaction(() async {
      await _put(
        'suppliers',
        id,
        {'article_id': articleId, ...fields, 'deleted_at': null},
        homeId: owner.homeId,
        create: true,
      );
      await _prefillUnitPrice(articleId, fields['last_price'] as String?);
    });
    return id;
  }

  Future<void> updateSupplier(String id, SupplierInput input) async {
    final current = await supplier(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableArticle(current.articleId);
    final changes = _changes(current, _supplierFields(input));
    if (changes.isEmpty) return;
    await db.transaction(() async {
      await _put('suppliers', id, changes);
      // Only a last price that really changed prefills.
      if (changes.containsKey('last_price')) {
        await _prefillUnitPrice(
          current.articleId,
          changes['last_price'] as String?,
        );
      }
    });
  }

  Future<void> deleteSupplier(String id) async {
    final current = await supplier(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableArticle(current.articleId);
    await db.transaction(() => _put('suppliers', id, {'deleted_at': _now()}));
  }

  // ---------- movements ----------

  Future<String> _append(
    ArticleRow article, {
    required String kind,
    required Decimal quantity,
    required Day on,
    String note = '',
    String? occurrenceId,
  }) async {
    final id = newId();
    await _put(
      'movements',
      id,
      {
        'article_id': article.id,
        'kind': kind,
        'quantity': stock.storedQuantity(quantity),
        'occurred_on': on,
        'note': note,
        'occurrence_id': occurrenceId,
        'deleted_at': null,
      },
      homeId: article.homeId,
      create: true,
    );
    return id;
  }

  /// Adds a line to the ledger of the article (`stock/services.py`
  /// `record_movement`): an entry adds [quantity], an exit takes it (never
  /// more than there is), an inventory states the count; its effect is the
  /// count minus the stock before it.
  Future<String> recordMovement(
    String articleId, {
    required String kind,
    required String quantity,
    Day? on,
    String note = '',
  }) async {
    final owner = await _writableArticle(articleId);
    if (!stock.movementKinds.contains(kind)) {
      throw ArgumentError.value(kind, 'kind');
    }
    final value = _quantity(quantity, optional: false)!;
    if (kind != stock.inventoryKind && value <= stock.zero) {
      throw const Refused(Refusal.quantityNotPositive);
    }
    _checkDate(on);
    final clean = Repository._text(note, 200);
    late String id;
    await db.transaction(() async {
      if (kind == stock.exitKind) {
        final level = await stockLevel(articleId);
        if (value > level) throw Refused(Refusal.stockShort, level);
      }
      id = await _append(
        owner,
        kind: kind,
        quantity: value,
        on: on ?? today(),
        note: clean,
      );
    });
    return id;
  }

  // ---------- materials of a task (`tasks/materials.py`) ----------

  /// The articles a task needs, by article name, each with its stock now
  /// (`materials_of`). A deleted article is not listed.
  Future<List<MaterialEntry>> materialsOf(String taskId) async {
    final owner = await task(taskId);
    if (owner == null) return [];
    final lines = await (db.select(
      db.taskMaterials,
    )..where((l) => l.taskId.equalsValue(taskId) & l.deletedAt.isNull())).get();
    final levels = await _levels(owner.homeId);
    return [
      for (final l in lines)
        if (await article(l.articleId) case final a?)
          MaterialEntry(l, a, levels[a.id] ?? stock.zero),
    ]..sort((a, b) {
      final byName = a.article.name.compareTo(b.article.name);
      return byName != 0
          ? byName
          : a.line.createdAt.compareTo(b.line.createdAt);
    });
  }

  /// The quantity of an article on the task: listed if it is not, else
  /// changed (`save_material`). The article must be of the task's home.
  Future<void> saveMaterial(
    String taskId,
    String articleId,
    String quantity,
  ) async {
    final owner = await task(taskId);
    if (owner == null) throw const Refused(Refusal.notFound);
    await _writableHome(owner.homeId);
    final listed = await article(articleId);
    if (listed == null || listed.homeId != owner.homeId) {
      throw const Refused(Refusal.notInHome);
    }
    final value = _quantity(quantity, optional: false)!;
    if (value <= stock.zero) throw const Refused(Refusal.quantityNotPositive);
    final id = materialId(owner.homeId, taskId, articleId);
    final current = await (db.select(
      db.taskMaterials,
    )..where((l) => l.id.equalsValue(id))).getSingleOrNull();
    final open = current != null && current.deletedAt == null;
    if (!open) {
      final count =
          await (db.select(db.taskMaterials)..where(
                (l) => l.taskId.equalsValue(taskId) & l.deletedAt.isNull(),
              ))
              .get();
      if (count.length >= stock.maxMaterialsPerTask) {
        throw const Refused(Refusal.tooManyMaterials);
      }
    }
    if (open && stock.readQuantity(current.quantity) == value) return;
    await db.transaction(
      () => _upsert('task_materials', id, {
        'task_id': taskId,
        'article_id': articleId,
        'quantity': stock.storedQuantity(value),
        'deleted_at': null,
      }, owner.homeId),
    );
  }

  /// Lists an article on the task; refused if it is already listed
  /// (`add_material`).
  Future<void> addMaterial(
    String taskId,
    String articleId,
    String quantity,
  ) async {
    final owner = await task(taskId);
    if (owner == null) throw const Refused(Refusal.notFound);
    final id = materialId(owner.homeId, taskId, articleId);
    final current =
        await (db.select(db.taskMaterials)
              ..where((l) => l.id.equalsValue(id) & l.deletedAt.isNull()))
            .getSingleOrNull();
    if (current != null) throw const Refused(Refusal.materialListed);
    await saveMaterial(taskId, articleId, quantity);
  }

  Future<void> removeMaterial(String taskId, String articleId) async {
    final owner = await task(taskId);
    if (owner == null) throw const Refused(Refusal.notFound);
    await _writableHome(owner.homeId);
    final id = materialId(owner.homeId, taskId, articleId);
    await db.transaction(
      () => _put('task_materials', id, {'deleted_at': _now()}),
    );
  }

  /// What the closing of [occurrenceId] took, by article name.
  Future<List<(MaterialDrawRow, ArticleRow)>> drawsOf(
    String occurrenceId,
  ) async {
    final rows =
        await (db.select(db.materialDraws)..where(
              (d) =>
                  d.occurrenceId.equalsValue(occurrenceId) &
                  d.deletedAt.isNull(),
            ))
            .get();
    return [
      for (final d in rows)
        if (await article(d.articleId) case final a?) (d, a),
    ]..sort((a, b) => a.$2.name.compareTo(b.$2.name));
  }

  // ---------- taking the stock when a task is done (web ADR 0046) ----------

  /// Takes the planned quantity of each material of the task from the stock
  /// (`draw_for_done`), inside the transaction that closes [occurrence]:
  /// never more than the stock holds, never more than wanted; returns what
  /// was short. Marking done is never refused for lack of stock.
  Future<List<Shortage>> _drawForDone(OccurrenceRow occurrence, Day on) async {
    final lines =
        await (db.select(db.taskMaterials)
              ..where(
                (l) =>
                    l.taskId.equalsValue(occurrence.taskId) &
                    l.deletedAt.isNull(),
              )
              ..orderBy([(l) => OrderingTerm.asc(l.articleId)]))
            .get();
    final short = <Shortage>[];
    for (final line in lines) {
      final listed = await article(line.articleId);
      if (listed == null) continue;
      final wanted = stock.readQuantity(line.quantity);
      final taken = stock.drawable(wanted, await stockLevel(listed.id));
      if (taken > stock.zero) {
        await _append(
          listed,
          kind: stock.exitKind,
          quantity: taken,
          on: on,
          occurrenceId: occurrence.id,
        );
      }
      await _upsert(
        'material_draws',
        drawId(occurrence.homeId, occurrence.id, listed.id),
        {
          'occurrence_id': occurrence.id,
          'article_id': listed.id,
          'wanted': stock.storedQuantity(wanted),
          'drawn': stock.storedQuantity(taken),
          'deleted_at': null,
        },
        occurrence.homeId,
      );
      if (taken < wanted) short.add(Shortage(listed, wanted, taken));
    }
    return short;
  }

  /// Undoes the closing's draws: what was taken goes back by entries, never
  /// by erasing a line, and the draws end (`return_draws`).
  Future<void> _returnDraws(OccurrenceRow occurrence) async {
    final draws =
        await (db.select(db.materialDraws)..where(
              (d) =>
                  d.occurrenceId.equalsValue(occurrence.id) &
                  d.deletedAt.isNull(),
            ))
            .get();
    draws.sort((a, b) => a.articleId.compareTo(b.articleId));
    for (final draw in draws) {
      final listed = await article(draw.articleId);
      final drawn = stock.readQuantity(draw.drawn);
      if (listed != null && drawn > stock.zero) {
        await _append(
          listed,
          kind: stock.entryKind,
          quantity: drawn,
          on: today(),
          occurrenceId: occurrence.id,
        );
      }
      await _put('material_draws', draw.id, {'deleted_at': _now()});
    }
  }
}
