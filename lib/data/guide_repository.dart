// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// The example home of the interactive guide on the phone (web ADR 0084,
/// lot A2): made by the person in scenario 1, filled scenario after
/// scenario, deleted in one gesture, and the ticks of the steps.
///
/// It is a home like another for every write (rooms, tasks, reports,
/// projects go through the ordinary methods), with one mark,
/// `homes.is_example`, that keeps it on this phone: [Repository._put] writes
/// no `field_clock` and no `op_log` for its rows, so the sync engine, the
/// relay snapshot, an export and the upload of the homes of the phone to a
/// server have nothing of it to carry, in every way of the app; and
/// [Repository.homes] leaves it out unless asked. This file is the one
/// place that sets the mark.
extension GuideRepository on Repository {
  /// The example home of this phone, if it has one: there is at most one.
  Future<HomeRow?> exampleHome() async {
    final rows =
        await (db.select(db.homes)
              ..where((h) => h.isExample.equals(true) & h.deletedAt.isNull())
              ..orderBy([(h) => OrderingTerm.asc(h.id)]))
            .get();
    return rows.firstOrNull;
  }

  /// Makes the example home, empty: the person fills it scenario after
  /// scenario (`guide.services.create_example_home`).
  ///
  /// The name, the currency and the hemisphere are those of the form of
  /// step 1, pre-filled with the values of [guide]: what is left out reads
  /// from the file, in [language] (the code of the phone's language, `fr`
  /// or `fr-FR`; English when the file does not have it). One example home
  /// per phone, also when two calls come at once: a second is refused
  /// ([Refusal.exampleExists]) until the first is deleted.
  Future<String> createExampleHome(
    Guide guide, {
    String? language,
    String? name,
    String? currency,
    String? hemisphere,
  }) async {
    final chosen = guide.languageFor(language);
    final clean = Repository._name(
      name ?? '${guide.text(guide.home['name'], chosen)}',
      120,
    );
    final money = currency ?? guide.home['currency'] as String? ?? 'EUR';
    final half =
        hemisphere ?? guide.home['hemisphere'] as String? ?? recurrence.north;
    Repository._checkHomeFields(money, half);
    final id = newId();
    // The check and the insert are one transaction: two calls at once are
    // taken one after the other, and the second finds the first.
    var known = false;
    try {
      await db.transaction(() async {
        if (await exampleHome() != null) {
          throw const Refused(Refusal.exampleExists);
        }
        // Known as the example before its first write, so that the row of
        // the home itself has no clock and no operation either.
        _examples.add(id);
        known = true;
        await _put('homes', id, {
          'name': clean,
          'currency': money,
          'hemisphere': half,
          'archived_at': null,
          'deleted_at': null,
          'is_example': true,
        }, create: true);
      });
    } catch (_) {
      if (known) _examples.remove(id);
      rethrow;
    }
    return id;
  }

  /// Deletes the example home in one gesture: no typed name, no export
  /// (`guide.services.remove_example`). Its rows, its files and its ticks
  /// go; nothing is kept of it, not even among the purged homes, since no
  /// other side ever had it. [Repository.deleteHome] hands it here.
  Future<void> removeExample(String homeId) async {
    final found = await home(homeId);
    if (found == null) throw const Refused(Refusal.notFound);
    if (!found.isExample) {
      throw ArgumentError.value(
        homeId,
        'homeId',
        'Only the example home is removed this way.',
      );
    }
    await _eraseHome(homeId, remember: false);
  }

  // ---------- the states of the steps ----------

  static Object? _guideValue(GeneratedColumn column, Object? value) {
    if (value == null) return null;
    return switch (column.type) {
      DriftSqlType.blob => Uuid.unparse(value as Uint8List),
      DriftSqlType.bool => value == 1 || value == true,
      _ => value,
    };
  }

  /// The rows of [homeId] that the states of [guide] read, as
  /// `{entity, fields}` (this home only, deleted rows left out): a field is
  /// named as in the file, a reference without `_id` (`states.rows_of`).
  Future<List<GuideRow>> guideRows(Guide guide, String homeId) async {
    final found = <GuideRow>[];
    for (final MapEntry(key: entity, value: names) in wantedFields(
      guide,
    ).entries) {
      final table = tableOfEntity[entity];
      if (table == null) {
        throw FormatException('The guide names an unknown entity: $entity');
      }
      final columns = _columns(table);
      GeneratedColumn columnOf(String name) {
        final column = columns[name] ?? columns['${name}_id'];
        if (column == null) {
          throw FormatException('The guide names an unknown field: $name');
        }
        return column;
      }

      final rows = await db
          .customSelect(
            'SELECT * FROM $table WHERE '
            '${table == 'homes' ? 'id' : 'home_id'} = ? '
            'AND deleted_at IS NULL',
            variables: [Variable<Uint8List>(uuidBytes(homeId))],
          )
          .get();
      for (final row in rows) {
        found.add(
          GuideRow(entity, {
            for (final name in names)
              name: _guideValue(columnOf(name), row.data[columnOf(name).$name]),
          }),
        );
      }
    }
    return found;
  }

  /// The steps of [homeId] that are ticked.
  Future<Set<String>> guideTicks(String homeId) async => {
    for (final t in await (db.select(
      db.stepTicks,
    )..where((t) => t.homeId.equalsValue(homeId))).get())
      t.stepId,
  };

  Future<void> _storeTicks(String homeId, Iterable<String> stepIds) async {
    final now = _now();
    for (final id in stepIds) {
      await db.customInsert(
        'INSERT OR IGNORE INTO step_ticks (home_id, step_id, ticked_at) '
        'VALUES (?, ?, ?)',
        variables: [
          Variable<Uint8List>(uuidBytes(homeId)),
          Variable<String>(id),
          Variable<int>(now),
        ],
      );
    }
  }

  /// Stores a tick for each step whose state is true now and that has none;
  /// the ids ticked (`states.tick`). Only the example home has ticks. A tick
  /// is never removed: a step done stays done, even if its state goes away
  /// afterwards (a room deleted, a task marked done and then undone).
  Future<List<String>> tickGuide(Guide guide, String homeId) async {
    if (!await isExampleHome(homeId)) return const [];
    final already = await guideTicks(homeId);
    final made = [
      for (final id in trueSteps(guide, await guideRows(guide, homeId)))
        if (!already.contains(id)) id,
    ];
    await _storeTicks(homeId, made);
    return made;
  }

  /// Ticks [stepId], a step of [guide] that has no state of its own
  /// (`manual`), on the example home (`guide.services.tick_by_hand`).
  /// Whether a tick was made (`false` when it was there already).
  Future<bool> tickByHand(Guide guide, String homeId, String stepId) async {
    if (!await isExampleHome(homeId)) {
      throw ArgumentError.value(homeId, 'homeId', 'Only the example home.');
    }
    await _writableHome(homeId);
    final manual = {
      for (final s in guide.steps)
        if (s.manual) s.id,
    };
    if (!manual.contains(stepId)) {
      throw ArgumentError.value(stepId, 'stepId', 'Not a step ticked by hand.');
    }
    if ((await guideTicks(homeId)).contains(stepId)) return false;
    await _storeTicks(homeId, [stepId]);
    return true;
  }

  // ---------- catching up ----------

  /// Adds what the scenarios before number [upTo] make and the example home
  /// lacks (`guide.services.fill_example`): "Add what the earlier scenarios
  /// make", for a person who opens scenario 3 without having done scenario
  /// 2. The rows of [guide] whose `stage` is below [upTo] that are missing
  /// are made through the ordinary methods, in [language]; never a row of
  /// stage [upTo] or later, so that it ticks nothing ahead. A row already
  /// there (same name, or same title) is kept as it is. Returns the steps
  /// ticked by what it made.
  Future<List<String>> fillExample(
    Guide guide,
    String homeId, {
    required int upTo,
    String? language,
  }) async {
    final found = await home(homeId);
    if (found == null) throw const Refused(Refusal.notFound);
    if (!found.isExample) {
      throw ArgumentError.value(homeId, 'homeId', 'Only the example home.');
    }
    await _writableHome(homeId);
    final maker = _ExampleMaker(
      this,
      homeId,
      guide,
      guide.languageFor(language),
    );
    await db.transaction(() async {
      for (final row in guide.rows) {
        if (row.stage < upTo) await maker.add(row);
      }
    });
    return tickGuide(guide, homeId);
  }
}

/// Adds the rows of the file that the example home lacks, through the
/// ordinary methods of the repository (`guide.services._Maker`).
class _ExampleMaker {
  _ExampleMaker(this.repo, this.homeId, this.guide, this.language)
    : today = repo.today();

  final Repository repo;
  final String homeId;
  final Guide guide;
  final String language;
  final Day today;

  /// The id of the row made or found for each key of the file.
  final made = <String, String?>{};

  /// Fields whose value is a choice, never the key of a row.
  static const _choices = {'kind', 'status', 'nature', 'trade'};

  /// A field of the file as the repository takes it: a text in the
  /// language, the id of a row for its key.
  Object? value(String name, Object? raw) {
    if (raw is List) return [for (final key in raw) made[key]];
    if (raw is String && !_choices.contains(name)) {
      return made.containsKey(raw) ? made[raw] : raw;
    }
    return guide.text(raw, language);
  }

  Future<void> add(ExampleRow row) async {
    final fields = {
      for (final MapEntry(:key, value: raw) in row.fields.entries)
        key: value(key, raw),
    };
    made[row.key] = await switch (row.entity) {
      'rooms.room' => _room(fields),
      'rooms.item' => _item(fields),
      'tasks.task' => _task(fields),
      'tasks.occurrence' => _occurrence(fields),
      'reports.report' => _report(fields),
      'projects.project' => _project(fields),
      'projects.budgetline' => _line(fields),
      'tasks.contractor' => _contractor(fields),
      'projects.quote' => _quote(fields),
      'projects.annualenvelope' => _envelope(fields),
      _ => throw FormatException(
        'The guide makes an unknown entity: ${row.entity}',
      ),
    };
  }

  /// The fields of [fields] this maker reads, refusing any other: a field
  /// the file gains later is not dropped in silence.
  static void _only(Map<String, Object?> fields, Set<String> known) {
    final unknown = fields.keys.toSet().difference(known);
    if (unknown.isNotEmpty) {
      throw FormatException(
        'Fields the guide makes and the app does not: $unknown',
      );
    }
  }

  static String _text(Object? value) => value == null ? '' : '$value';

  Day? _offset(Object? days) =>
      days == null ? null : today.addDays((days as num).toInt());

  Future<String> _room(Map<String, Object?> f) async {
    _only(f, {'name', 'kind'});
    final name = _text(f['name']);
    final found = (await repo.rooms(homeId)).where((r) => r.name == name);
    if (found.isNotEmpty) return found.first.id;
    return repo.createRoom(homeId, name: name, kind: _text(f['kind']));
  }

  Future<String> _item(Map<String, Object?> f) async {
    _only(f, {'room', 'name', 'kind', 'brand', 'model'});
    final room = f['room']! as String;
    final name = _text(f['name']);
    final found = (await repo.itemsOf(room)).where((i) => i.name == name);
    if (found.isNotEmpty) return found.first.id;
    return repo.addItem(
      room,
      ItemInput(
        name: name,
        kind: _text(f['kind'] ?? 'equipment'),
        brand: _text(f['brand']),
        model: _text(f['model']),
      ),
    );
  }

  Future<String> _task(Map<String, Object?> f) async {
    _only(f, {
      'title',
      'room',
      'item',
      'procedure',
      'repeat_mode',
      'repeat_unit',
      'repeat_interval',
      'estimated_minutes',
      'due_offset_days',
    });
    final title = _text(f['title']);
    final found =
        await (repo.db.select(repo.db.tasks)..where(
              (t) =>
                  t.homeId.equalsValue(homeId) &
                  t.title.equals(title) &
                  t.deletedAt.isNull(),
            ))
            .get();
    if (found.isNotEmpty) return found.first.id;
    return repo.createTask(
      homeId,
      TaskInput(
        title: title,
        roomId: f['room'] as String?,
        itemId: f['item'] as String?,
        procedure: _text(f['procedure']),
        repeatMode: _text(f['repeat_mode'] ?? recurrence.once),
        repeatUnit: _text(f['repeat_unit'] ?? recurrence.monthUnit),
        repeatInterval: (f['repeat_interval'] as num?)?.toInt() ?? 1,
        estimatedMinutes: (f['estimated_minutes'] as num?)?.toInt(),
        dueOn: _offset(f['due_offset_days']),
      ),
    );
  }

  Future<String?> _occurrence(Map<String, Object?> f) async {
    _only(f, {'task', 'status', 'completed_offset_days'});
    final task = f['task']! as String;
    final done =
        await (repo.db.select(repo.db.occurrences)..where(
              (o) =>
                  o.homeId.equalsValue(homeId) &
                  o.taskId.equalsValue(task) &
                  o.status.equals('done') &
                  o.deletedAt.isNull(),
            ))
            .get();
    if (done.isNotEmpty) return done.first.id;
    final open = await repo.openOccurrencesOf(task);
    if (open.isEmpty) return null;
    final closing = await repo.complete(
      open.first.id,
      on: _offset(f['completed_offset_days']),
    );
    return closing.occurrenceId;
  }

  Future<String> _report(Map<String, Object?> f) async {
    _only(f, {'title', 'room', 'status'});
    final title = _text(f['title']);
    final found =
        await (repo.db.select(repo.db.reports)..where(
              (r) =>
                  r.homeId.equalsValue(homeId) &
                  r.title.equals(title) &
                  r.deletedAt.isNull(),
            ))
            .get();
    if (found.isNotEmpty) return found.first.id;
    final roomId = f['room'] as String?;
    final room = roomId == null ? null : await repo.room(roomId);
    final id = await repo.createReport(
      homeId,
      title: title,
      roomId: roomId,
      place: room?.name ?? '',
    );
    final status = _text(f['status'] ?? reportOpen);
    if (reportClosedStatuses.contains(status)) {
      await repo.closeReport(id, status);
    }
    return id;
  }

  Future<String> _project(Map<String, Object?> f) async {
    _only(f, {'title', 'goal', 'rooms', 'status'});
    final title = _text(f['title']);
    final found =
        await (repo.db.select(repo.db.projects)..where(
              (p) =>
                  p.homeId.equalsValue(homeId) &
                  p.title.equals(title) &
                  p.deletedAt.isNull(),
            ))
            .get();
    if (found.isNotEmpty) return found.first.id;
    return repo.createProject(
      homeId,
      ProjectInput(
        title: title,
        goal: _text(f['goal']),
        status: _text(f['status'] ?? 'idea'),
        roomIds: [
          for (final r in (f['rooms'] as List? ?? const []))
            if (r is String) r,
        ],
      ),
    );
  }

  Future<String> _line(Map<String, Object?> f) async {
    _only(f, {'project', 'label', 'nature', 'planned', 'paid'});
    final project = f['project']! as String;
    final label = _text(f['label']);
    final found =
        await (repo.db.select(repo.db.budgetLines)..where(
              (l) =>
                  l.homeId.equalsValue(homeId) &
                  l.projectId.equalsValue(project) &
                  l.label.equals(label) &
                  l.deletedAt.isNull(),
            ))
            .get();
    if (found.isNotEmpty) return found.first.id;
    return repo.createLine(
      project,
      LineInput(
        label: label,
        nature: _text(f['nature'] ?? budget.other),
        planned: _text(f['planned']),
        paid: _text(f['paid']),
      ),
    );
  }

  Future<String> _contractor(Map<String, Object?> f) async {
    _only(f, {'name', 'trade'});
    final name = _text(f['name']);
    final found = (await repo.contractors(homeId)).where((c) => c.name == name);
    if (found.isNotEmpty) return found.first.id;
    return repo.addContractor(
      homeId,
      ContractorInput(name: name, trade: _text(f['trade'])),
    );
  }

  Future<String> _quote(Map<String, Object?> f) async {
    _only(f, {
      'project',
      'contractor',
      'budget_line',
      'status',
      'amount',
      'issued_offset_days',
      'valid_days',
    });
    final project = f['project']! as String;
    final contractor = f['contractor'] as String?;
    final found =
        await (repo.db.select(repo.db.quotes)..where(
              (q) =>
                  q.homeId.equalsValue(homeId) &
                  q.projectId.equalsValue(project) &
                  (contractor == null
                      ? q.contractorId.isNull()
                      : q.contractorId.equalsValue(contractor)) &
                  q.deletedAt.isNull(),
            ))
            .get();
    if (found.isNotEmpty) return found.first.id;
    final issued = _offset(f['issued_offset_days']);
    final valid = f['valid_days'] as num?;
    return repo.createQuote(
      project,
      QuoteInput(
        contractorId: contractor,
        amount: _text(f['amount']),
        issuedOn: issued,
        validUntil: issued == null || valid == null
            ? null
            : issued.addDays(valid.toInt()),
        status: _text(f['status'] ?? 'requested'),
        budgetLineId: f['budget_line'] as String?,
      ),
    );
  }

  Future<String> _envelope(Map<String, Object?> f) async {
    _only(f, {'year', 'amount'});
    final raw = f['year'];
    final year = raw == 'current' ? today.year : int.parse('$raw');
    final id = envelopeIdOf(homeId, year);
    final existing =
        await (repo.db.select(repo.db.annualEnvelopes)
              ..where((e) => e.id.equalsValue(id) & e.deletedAt.isNull()))
            .getSingleOrNull();
    if (existing == null) {
      await repo.setEnvelope(homeId, year, _text(f['amount']));
    }
    return id;
  }
}
