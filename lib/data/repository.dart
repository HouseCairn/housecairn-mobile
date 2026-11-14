// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/clock.dart';
import '../core/hlc.dart';
import '../domain/day.dart';
import '../domain/recurrence.dart' as recurrence;
import 'database.dart';

/// Why the repository refused a change. Each value has its message in the
/// ARB files (lib/ui/messages.dart); the web gives the same refusals.
enum Refusal {
  /// A task, a home, a room needs a name or a title (`tasks/models.py:162`).
  titleRequired,

  /// Longer than the web allows (`max_length` of the model).
  tooLong,

  /// The interval is out of range (`recurrence.problems`).
  intervalOutOfRange,

  /// A season needs its first and last month.
  seasonMonthsRequired,

  /// A task that repeats on a fixed date needs a date (`tasks/services.py:378-381`).
  fixedNeedsDate,

  /// A date more than 100 years from today (`tasks/services.py:99-120`).
  dateOutOfRange,

  /// A completion date in the future (`tasks/services.py:545-546`).
  futureDate,

  /// A postponement to a day in the past (`tasks/services.py:595-596`).
  pastDate,

  /// The occurrence is already closed.
  alreadyClosed,

  /// Only a done or skipped occurrence can be undone.
  notClosed,

  /// The next occurrence was worked on since (`tasks/services.py:605-613`).
  nextChanged,

  /// An archived home is read only (docs/spec.md, "Homes").
  homeArchived,

  /// The last active home can be neither archived nor deleted.
  lastActiveHome,

  /// A home is deleted only once its exact name is typed
  /// (`homes/services.py:239-252`).
  nameMismatch,

  /// A currency is an ISO 4217 code (`homes/models.py:33-39`).
  currencyInvalid,

  /// The row does not exist (or not in this home).
  notFound,
}

class Refused implements Exception {
  const Refused(this.reason);

  final Refusal reason;

  @override
  String toString() => 'Refused: ${reason.name}';
}

/// What a task is made of, as the Task screen edits it. Only [title] is
/// required.
class TaskInput {
  const TaskInput({
    required this.title,
    this.dueOn,
    this.repeatMode = recurrence.once,
    this.repeatUnit = recurrence.monthUnit,
    this.repeatInterval = 1,
    this.season = '',
    this.seasonStartMonth,
    this.seasonEndMonth,
    this.priority = 'normal',
    this.notes = '',
    this.hideDaysBefore = 0,
    this.roomId,
    this.itemId,
  });

  final String title;
  final Day? dueOn;
  final String repeatMode;
  final String repeatUnit;
  final int repeatInterval;

  /// `''` (the whole year), a predefined season, or `custom`.
  final String season;
  final int? seasonStartMonth;
  final int? seasonEndMonth;
  final String priority;
  final String notes;
  final int hideDaysBefore;
  final String? roomId;
  final String? itemId;
}

/// An occurrence just closed and the one that follows it, if any.
class Closing {
  const Closing(this.occurrenceId, this.nextId);

  final String occurrenceId;
  final String? nextId;
}

/// A row of Today: an open occurrence, its task and its home.
class TodayEntry {
  const TodayEntry({
    required this.occurrence,
    required this.task,
    required this.home,
  });

  final OccurrenceRow occurrence;
  final TaskRow task;
  final HomeRow home;

  Day? get dueOn =>
      occurrence.dueOn == null ? null : Day.parse(occurrence.dueOn!);
}

const openStatuses = ['planned', 'postponed'];
const closedStatuses = ['done', 'skipped'];

/// How far ahead Today looks (`tasks/models.py:421-426`: one week).
const todayHorizonDays = 7;

/// Years around today a date may be in (`tasks/services.py:91`).
const dateSpanYears = 100;

/// Entity types of the operations, by table (docs/protocol.md, section 2.2).
const entityOf = {
  'homes': 'homes.home',
  'rooms': 'rooms.room',
  'items': 'rooms.item',
  'photos': 'rooms.photo',
  'contractors': 'tasks.contractor',
  'tasks': 'tasks.task',
  'occurrences': 'tasks.occurrence',
};

/// The tables whose rows belong to a home, children first.
const homeTables = [
  'occurrences',
  'tasks',
  'photos',
  'items',
  'rooms',
  'contractors',
];

/// The one layer that writes the model (docs/adr/0002-local-storage-and-migrations.md,
/// "Consequences"): every change sets the row and the `field_clock` of each
/// field it writes in one transaction, with one clock per change, as one
/// operation of docs/protocol.md would. No screen writes SQL.
class Repository {
  Repository(
    this.db, {
    required this.clock,
    required this.files,
    Random? random,
  }) : _random = random ?? Random.secure();

  final AppDatabase db;
  final Clock clock;

  /// The private directory of the app: the files of a home are in
  /// `files/homes/<home id>/`, named by the id of their row.
  final Directory files;
  final Random _random;
  static const _uuid = Uuid();

  late Hlc _hlc;
  late Uint8List _device;

  /// Opens the database and reads the id of this phone (16 random bytes,
  /// made at the first start) and the last clock it gave.
  Future<void> open() async {
    await db.open();
    final stored = await _setting('device_id');
    if (stored == null) {
      _device = Uint8List.fromList(
        List<int>.generate(16, (_) => _random.nextInt(256)),
      );
      await _setSetting('device_id', _hex(_device));
    } else {
      _device = _unhex(stored);
    }
    final last = await db
        .customSelect(
          'SELECT MAX(hlc) AS last FROM field_clock WHERE device = ?',
          variables: [Variable<Uint8List>(_device)],
        )
        .getSingle();
    final text = last.data['last'] as String?;
    _hlc = Hlc(clock, last: text == null ? 0 : Hlc.parse(text));
  }

  Uint8List get device => _device;

  /// Today, in the time zone of the phone (docs/spec.md).
  Day today() => Day.of(clock.today());

  int _now() => clock.now().millisecondsSinceEpoch;

  String newId() => _uuid.v4();

  // ---------- writing ----------

  static bool _isReference(String field) =>
      field.endsWith('_id') || field == 'follows';

  static Variable<Object> _variable(String field, Object? value) {
    if (value == null) return const Variable<Object>(null);
    if (value is Day) return Variable<Object>(value.iso);
    if (value is String && (_isReference(field) || field == 'id')) {
      return Variable<Object>(uuidBytes(value));
    }
    if (value is bool) return Variable<Object>(value ? 1 : 0);
    return Variable<Object>(value);
  }

  /// One operation: sets [fields] of the row [id] of [table] (creating it
  /// when [create]), and their clocks. Runs inside the caller's transaction.
  Future<void> _put(
    String table,
    String id,
    Map<String, Object?> fields, {
    String? homeId,
    bool create = false,
  }) async {
    final now = _now();
    final clocked = {...fields, if (create) 'created_at': now};
    if (create) {
      final columns = {
        'id': id,
        'home_id': ?homeId,
        ...clocked,
        'updated_at': now,
      };
      await db.customInsert(
        'INSERT INTO $table (${columns.keys.join(', ')}) '
        'VALUES (${List.filled(columns.length, '?').join(', ')})',
        variables: [
          for (final MapEntry(:key, :value) in columns.entries)
            _variable(key, value),
        ],
      );
    } else {
      final columns = {...clocked, 'updated_at': now};
      await db.customUpdate(
        'UPDATE $table SET ${columns.keys.map((c) => '$c = ?').join(', ')} '
        'WHERE id = ?',
        variables: [
          for (final MapEntry(:key, :value) in columns.entries)
            _variable(key, value),
          Variable<Uint8List>(uuidBytes(id)),
        ],
      );
    }
    final hlc = Hlc.format(_hlc.next());
    for (final field in clocked.keys) {
      await db.customInsert(
        'INSERT INTO field_clock (entity, row_id, field, hlc, device) '
        'VALUES (?, ?, ?, ?, ?) ON CONFLICT (entity, row_id, field) '
        'DO UPDATE SET hlc = excluded.hlc, device = excluded.device',
        variables: [
          Variable<String>(entityOf[table]!),
          Variable<Uint8List>(uuidBytes(id)),
          Variable<String>(field),
          Variable<String>(hlc),
          Variable<Uint8List>(_device),
        ],
      );
    }
  }

  // ---------- local settings (this phone only, never synced) ----------

  Future<String?> _setting(String key) async {
    final row = await (db.select(
      db.localSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _setSetting(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.localSettings)..where((t) => t.key.equals(key))).go();
    } else {
      await db
          .into(db.localSettings)
          .insertOnConflictUpdate(
            LocalSettingsCompanion.insert(key: key, value: value),
          );
    }
  }

  // ---------- homes ----------

  /// Every home, active then archived each by name (`homes/current.py:73`).
  Future<List<HomeRow>> homes() async {
    final rows =
        await (db.select(db.homes)
              ..where((h) => h.deletedAt.isNull())
              ..orderBy([
                (h) => OrderingTerm.asc(h.name),
                (h) => OrderingTerm.asc(h.id),
              ]))
            .get();
    return [
      ...rows.where((h) => h.archivedAt == null),
      ...rows.where((h) => h.archivedAt != null),
    ];
  }

  Future<List<HomeRow>> activeHomes() async =>
      (await homes()).where((h) => h.archivedAt == null).toList();

  Future<HomeRow?> home(String id) =>
      (db.select(db.homes)
            ..where((h) => h.id.equalsValue(id) & h.deletedAt.isNull()))
          .getSingleOrNull();

  static String _name(String name, int max) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const Refused(Refusal.titleRequired);
    if (trimmed.length > max) throw const Refused(Refusal.tooLong);
    return trimmed;
  }

  static void _checkHomeFields(String? currency, String? hemisphere) {
    if (currency != null && !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw const Refused(Refusal.currencyInvalid);
    }
    if (hemisphere != null &&
        hemisphere != recurrence.north &&
        hemisphere != recurrence.south) {
      throw ArgumentError.value(hemisphere, 'hemisphere');
    }
  }

  /// Creates a home (`homes/models.py:31-52`); any member may.
  Future<String> createHome({
    required String name,
    String currency = 'EUR',
    String hemisphere = recurrence.north,
  }) async {
    final clean = _name(name, 120);
    _checkHomeFields(currency, hemisphere);
    final id = newId();
    await db.transaction(() async {
      await _put('homes', id, {
        'name': clean,
        'currency': currency,
        'hemisphere': hemisphere,
        'archived_at': null,
        'deleted_at': null,
      }, create: true);
    });
    return id;
  }

  Future<HomeRow> _writableHome(String id) async {
    final found = await home(id);
    if (found == null) throw const Refused(Refusal.notFound);
    if (found.archivedAt != null) throw const Refused(Refusal.homeArchived);
    return found;
  }

  /// Renames a home, or changes its currency or hemisphere; a change of
  /// hemisphere moves the predefined seasons of its tasks
  /// (`homes/services.py:148-152`).
  Future<void> updateHome(
    String id, {
    String? name,
    String? currency,
    String? hemisphere,
  }) async {
    final current = await _writableHome(id);
    _checkHomeFields(currency, hemisphere);
    final changes = <String, Object?>{
      if (name != null && name.trim() != current.name) 'name': _name(name, 120),
      if (currency != null && currency != current.currency)
        'currency': currency,
      if (hemisphere != null && hemisphere != current.hemisphere)
        'hemisphere': hemisphere,
    };
    if (changes.isEmpty) return;
    await db.transaction(() async {
      await _put('homes', id, changes);
      if (changes.containsKey('hemisphere')) {
        final tasks = await (db.select(
          db.tasks,
        )..where((t) => t.homeId.equalsValue(id) & t.deletedAt.isNull())).get();
        for (final task in tasks) {
          final window = recurrence.seasonWindow(task.season, hemisphere!);
          if (window == null) continue;
          await _put('tasks', task.id, {
            'season_start_month': window.$1,
            'season_end_month': window.$2,
          });
        }
      }
    });
  }

  /// Archives a home: out of the selector and of Today, read only; refused
  /// for the last active home.
  Future<void> archiveHome(String id) async {
    await _writableHome(id);
    if ((await activeHomes()).length <= 1) {
      throw const Refused(Refusal.lastActiveHome);
    }
    await db.transaction(() => _put('homes', id, {'archived_at': _now()}));
  }

  /// Brings an archived home back as it was.
  Future<void> unarchiveHome(String id) async {
    final found = await home(id);
    if (found == null) throw const Refused(Refusal.notFound);
    if (found.archivedAt == null) return;
    await db.transaction(() => _put('homes', id, {'archived_at': null}));
  }

  /// The directory of the files of a home.
  Directory homeDirectory(String homeId) =>
      Directory('${files.path}/homes/$homeId');

  /// Deletes a home for good, once [typedName] is its exact name
  /// (`homes/services.py:239-252`): every row of it, their clocks and its
  /// files are erased. Refused for the last active home. Without sync, a
  /// purge is this; with sync, lot 5 adds the `purge` record of the log.
  Future<void> deleteHome(String id, {required String typedName}) async {
    final found = await home(id);
    if (found == null) throw const Refused(Refusal.notFound);
    if (typedName != found.name) throw const Refused(Refusal.nameMismatch);
    final active = await activeHomes();
    if (found.archivedAt == null && active.length <= 1) {
      throw const Refused(Refusal.lastActiveHome);
    }
    final key = Variable<Uint8List>(uuidBytes(id));
    await db.transaction(() async {
      for (final table in homeTables) {
        await db.customStatement(
          'DELETE FROM field_clock WHERE entity = ? AND row_id IN '
          '(SELECT id FROM $table WHERE home_id = ?)',
          [entityOf[table], key.value],
        );
        await db.customStatement('DELETE FROM $table WHERE home_id = ?', [
          key.value,
        ]);
      }
      await db.customStatement(
        "DELETE FROM field_clock WHERE entity = 'homes.home' AND row_id = ?",
        [key.value],
      );
      await db.customStatement('DELETE FROM homes WHERE id = ?', [key.value]);
      if (await _setting('current_home') == id) {
        await _setSetting('current_home', null);
      }
    });
    final directory = homeDirectory(id);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }

  // ---------- current home (this phone, `homes/current.py`) ----------

  /// The current home: the one last chosen, if it is still active; else the
  /// first active home by name (`homes/current.py:73-79`).
  Future<HomeRow?> currentHome() async {
    final active = await activeHomes();
    if (active.isEmpty) return null;
    final stored = await _setting('current_home');
    return active.firstWhere((h) => h.id == stored, orElse: () => active.first);
  }

  /// Chooses the current home; Today then shows that home only.
  Future<void> chooseHome(String id) async {
    await _setSetting('current_home', id);
    await _setSetting('today_all_homes', null);
  }

  /// Whether Today shows every active home: when the person chose it, and
  /// before any home was chosen, from two active homes on
  /// (`homes/current.py:81-82`).
  Future<bool> todayShowsAllHomes() async {
    final active = await activeHomes();
    if (active.length < 2) return false;
    final stored = await _setting('current_home');
    final chosen = active.any((h) => h.id == stored);
    return await _setting('today_all_homes') == '1' || !chosen;
  }

  Future<void> showAllHomesOnToday() => _setSetting('today_all_homes', '1');

  // ---------- rooms, items, contractors, photos ----------

  Future<String> createRoom(
    String homeId, {
    required String name,
    String kind = 'other',
    int position = 0,
  }) async {
    await _writableHome(homeId);
    final id = newId();
    await db.transaction(
      () => _put(
        'rooms',
        id,
        {
          'name': _name(name, 120),
          'kind': kind,
          'position': position,
          'deleted_at': null,
        },
        homeId: homeId,
        create: true,
      ),
    );
    return id;
  }

  Future<String> createItem(
    String homeId, {
    required String roomId,
    required String name,
    String kind = 'equipment',
  }) async {
    await _writableHome(homeId);
    final id = newId();
    await db.transaction(
      () => _put(
        'items',
        id,
        {
          'room_id': roomId,
          'name': _name(name, 120),
          'kind': kind,
          'deleted_at': null,
        },
        homeId: homeId,
        create: true,
      ),
    );
    return id;
  }

  Future<String> createContractor(
    String homeId, {
    required String name,
    String trade = '',
    String phone = '',
  }) async {
    await _writableHome(homeId);
    final id = newId();
    await db.transaction(
      () => _put(
        'contractors',
        id,
        {
          'name': _name(name, 120),
          'trade': trade,
          'phone': phone,
          'deleted_at': null,
        },
        homeId: homeId,
        create: true,
      ),
    );
    return id;
  }

  /// Records a photo row of a room or an item (exactly one). The file is
  /// written by the caller in [homeDirectory] under the returned id; its
  /// re-encoding comes with lot 2b.
  Future<String> createPhotoRow(
    String homeId, {
    String? roomId,
    String? itemId,
    String category = 'general',
    String? image,
  }) async {
    if ((roomId == null) == (itemId == null)) {
      throw ArgumentError('A photo is of one room or one item.');
    }
    await _writableHome(homeId);
    final id = newId();
    await db.transaction(
      () => _put(
        'photos',
        id,
        {
          'room_id': roomId,
          'item_id': itemId,
          'category': category,
          'image': image,
          'deleted_at': null,
        },
        homeId: homeId,
        create: true,
      ),
    );
    return id;
  }

  // ---------- tasks ----------

  Future<TaskRow?> task(String id) =>
      (db.select(db.tasks)
            ..where((t) => t.id.equalsValue(id) & t.deletedAt.isNull()))
          .getSingleOrNull();

  Future<OccurrenceRow?> occurrence(String id) =>
      (db.select(db.occurrences)
            ..where((o) => o.id.equalsValue(id) & o.deletedAt.isNull()))
          .getSingleOrNull();

  /// The open occurrences of a task (one, by the rule of the model).
  Future<List<OccurrenceRow>> openOccurrencesOf(String taskId) =>
      (db.select(db.occurrences)..where(
            (o) =>
                o.taskId.equalsValue(taskId) &
                o.deletedAt.isNull() &
                o.status.isIn(openStatuses),
          ))
          .get();

  /// Every occurrence of a task, the latest due first, as its history.
  Future<List<OccurrenceRow>> occurrencesOf(String taskId) =>
      (db.select(db.occurrences)
            ..where((o) => o.taskId.equalsValue(taskId) & o.deletedAt.isNull())
            ..orderBy([
              (o) => OrderingTerm(
                expression: o.dueOn,
                mode: OrderingMode.desc,
                nulls: NullsOrder.first,
              ),
              (o) => OrderingTerm.desc(o.createdAt),
            ]))
          .get();

  void _checkDate(Day? value) {
    if (value == null) return;
    final today = this.today();
    if (value < today.addYears(-dateSpanYears) ||
        value > today.addYears(dateSpanYears)) {
      throw const Refused(Refusal.dateOutOfRange);
    }
  }

  static recurrence.Rule _ruleOf(TaskRow task) => recurrence.Rule(
    mode: task.repeatMode,
    unit: task.repeatUnit,
    interval: task.repeatInterval,
    seasonStart: task.seasonStartMonth,
    seasonEnd: task.seasonEndMonth,
  );

  static String? _visibleFrom(int hideDaysBefore, Day? dueOn) {
    if (dueOn == null || hideDaysBefore == 0) return null;
    try {
      return dueOn.addDays(-hideDaysBefore).iso;
    } on DayOutOfRange {
      return Day(1, 1, 1).iso;
    }
  }

  /// The fields of a task from [input], checked as the web checks them
  /// (`tasks/models.py:251-276`, `tasks/services.py:312-381`).
  Map<String, Object?> _taskFields(TaskInput input, HomeRow home) {
    final title = _name(input.title, 200);
    var start = input.seasonStartMonth;
    var end = input.seasonEndMonth;
    if (input.season.isEmpty) {
      start = end = null;
    } else if (input.season != recurrence.custom) {
      final window = recurrence.seasonWindow(input.season, home.hemisphere);
      if (window == null) throw const Refused(Refusal.seasonMonthsRequired);
      (start, end) = window;
    }
    final rule = recurrence.Rule(
      mode: input.repeatMode,
      unit: input.repeatUnit,
      interval: input.repeatInterval,
      seasonStart: start,
      seasonEnd: end,
    );
    final found = recurrence.problems(rule);
    if (found.contains('mode') || found.contains('unit')) {
      throw ArgumentError(
        'Unknown repetition ${input.repeatMode}/${input.repeatUnit}',
      );
    }
    if (found.contains('interval')) {
      throw const Refused(Refusal.intervalOutOfRange);
    }
    if (found.contains('season') ||
        (input.season == recurrence.custom && start == null)) {
      throw const Refused(Refusal.seasonMonthsRequired);
    }
    if (input.notes.length > 5000) throw const Refused(Refusal.tooLong);
    return {
      'title': title,
      'room_id': input.roomId,
      'item_id': input.itemId,
      'priority': input.priority,
      'notes': input.notes,
      'repeat_mode': input.repeatMode,
      'repeat_unit': input.repeatUnit,
      'repeat_interval': input.repeatInterval,
      'season': input.season,
      'season_start_month': start,
      'season_end_month': end,
      'hide_days_before': input.hideDaysBefore,
    };
  }

  /// Creates a task and its first occurrence, due on [TaskInput.dueOn] or
  /// with no date (`tasks/services.py:384-404`).
  Future<String> createTask(String homeId, TaskInput input) async {
    final home = await _writableHome(homeId);
    final fields = _taskFields(input, home);
    _checkDate(input.dueOn);
    if (input.dueOn == null && input.repeatMode == recurrence.fixed) {
      throw const Refused(Refusal.fixedNeedsDate);
    }
    final id = newId();
    await db.transaction(() async {
      await _put(
        'tasks',
        id,
        {...fields, 'series_start': input.dueOn, 'deleted_at': null},
        homeId: homeId,
        create: true,
      );
      await _put(
        'occurrences',
        newId(),
        {
          'task_id': id,
          'due_on': input.dueOn,
          'visible_from': _visibleFrom(input.hideDaysBefore, input.dueOn),
          'status': 'planned',
          'status_before': '',
          'postponed_from': null,
          'completed_on': null,
          'completion_note': '',
          'follows': null,
          'deleted_at': null,
        },
        homeId: homeId,
        create: true,
      );
    });
    return id;
  }

  /// Changes a task; [TaskInput.dueOn] moves the open occurrence when it
  /// differs from its date (`tasks/services.py:407-444`).
  Future<void> updateTask(String taskId, TaskInput input) async {
    final current = await task(taskId);
    if (current == null) throw const Refused(Refusal.notFound);
    final home = await _writableHome(current.homeId);
    final fields = _taskFields(input, home);
    final open = await openOccurrencesOf(taskId);
    final occurrence = open.isEmpty ? null : open.first;
    final oldDue = occurrence?.dueOn;
    final dueChanged = input.dueOn?.iso != oldDue;
    if (dueChanged) _checkDate(input.dueOn);
    if (input.dueOn == null && input.repeatMode == recurrence.fixed) {
      throw const Refused(Refusal.fixedNeedsDate);
    }
    const ruleFields = [
      'repeat_mode',
      'repeat_unit',
      'repeat_interval',
      'season_start_month',
      'season_end_month',
    ];
    final before = current.toColumns(false);
    final changes = <String, Object?>{
      for (final MapEntry(:key, :value) in fields.entries)
        if (_differs(before[key], value)) key: value,
    };
    final ruleChanged = ruleFields.any(changes.containsKey);
    if (ruleChanged || dueChanged) changes['series_start'] = input.dueOn;
    await db.transaction(() async {
      if (changes.isNotEmpty) await _put('tasks', taskId, changes);
      if (occurrence == null) {
        final repeats = input.repeatMode != recurrence.once;
        if (input.dueOn != null || repeats) {
          await _reopen(taskId, current.homeId, input);
        }
      } else if (dueChanged || changes.containsKey('hide_days_before')) {
        await _put('occurrences', occurrence.id, {
          'due_on': input.dueOn,
          'visible_from': _visibleFrom(input.hideDaysBefore, input.dueOn),
          if (dueChanged && occurrence.status == 'postponed') ...{
            'status': 'planned',
            'postponed_from': null,
          },
        });
      }
    });
  }

  static bool _differs(Expression<Object>? stored, Object? value) {
    final old = stored is Variable ? stored.value : null;
    final Object? oldValue = old is Uint8List ? Uuid.unparse(old) : old;
    final Object? newValue = value is Day ? value.iso : value;
    return oldValue != newValue;
  }

  /// Gives a task with no open occurrence the one it lacks
  /// (`tasks/services.py:447-473`).
  Future<void> _reopen(String taskId, String homeId, TaskInput input) async {
    final closed =
        await (db.select(db.occurrences)..where(
              (o) =>
                  o.taskId.equalsValue(taskId) &
                  o.deletedAt.isNull() &
                  o.status.isIn(closedStatuses),
            ))
            .get();
    final followed = closed.map((o) => o.follows).whereType<String>().toSet();
    final ends = closed.where((o) => !followed.contains(o.id)).toList()
      ..sort((a, b) {
        final byDate = (b.completedOn ?? '').compareTo(a.completedOn ?? '');
        return byDate != 0 ? byDate : b.updatedAt.compareTo(a.updatedAt);
      });
    final last = ends.isEmpty ? null : ends.first;
    var dueOn = input.dueOn;
    if (dueOn == null && last?.completedOn != null) {
      final rule = recurrence.Rule(
        mode: input.repeatMode,
        unit: input.repeatUnit,
        interval: input.repeatInterval,
      );
      dueOn = recurrence.nextDue(
        rule,
        anchor: null,
        dueOn: last!.dueOn == null ? null : Day.parse(last.dueOn!),
        doneOn: Day.parse(last.completedOn!),
      );
      await _put('tasks', taskId, {'series_start': dueOn});
    }
    await _put(
      'occurrences',
      newId(),
      {
        'task_id': taskId,
        'due_on': dueOn,
        'visible_from': _visibleFrom(input.hideDaysBefore, dueOn),
        'status': 'planned',
        'status_before': '',
        'postponed_from': null,
        'completed_on': null,
        'completion_note': '',
        'follows': last?.id,
        'deleted_at': null,
      },
      homeId: homeId,
      create: true,
    );
  }

  /// Soft-deletes a task with its occurrences.
  Future<void> deleteTask(String taskId) async {
    final current = await task(taskId);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableHome(current.homeId);
    final now = _now();
    await db.transaction(() async {
      for (final o in await occurrencesOf(taskId)) {
        await _put('occurrences', o.id, {'deleted_at': now});
      }
      await _put('tasks', taskId, {'deleted_at': now});
    });
  }

  // ---------- occurrences: done, skip, postpone, undo ----------

  Future<(OccurrenceRow, TaskRow)> _openOccurrence(String id) async {
    final found = await occurrence(id);
    if (found == null) throw const Refused(Refusal.notFound);
    final owner = await task(found.taskId);
    if (owner == null) throw const Refused(Refusal.notFound);
    await _writableHome(found.homeId);
    return (found, owner);
  }

  /// The id of the occurrence that follows [occurrenceId] in [homeId]: the
  /// same on every phone that closes it (docs/adr/0003-sync-protocol.md).
  static String successorId(String homeId, String occurrenceId) =>
      _uuid.v5(homeId, 'next:$occurrenceId');

  Future<Closing> _close(
    String id,
    String status, {
    Day? on,
    String note = '',
  }) async {
    final (found, owner) = await _openOccurrence(id);
    if (!openStatuses.contains(found.status)) {
      throw const Refused(Refusal.alreadyClosed);
    }
    final today = this.today();
    if (on != null && on > today) throw const Refused(Refusal.futureDate);
    _checkDate(on);
    final closedOn = on ?? today;
    String? nextId;
    await db.transaction(() async {
      await _put('occurrences', id, {
        'status_before': found.status,
        'status': status,
        if (status == 'done') 'completed_on': closedOn,
        if (status == 'done') 'completion_note': note,
      });
      final due = recurrence.nextDue(
        _ruleOf(owner),
        anchor: owner.seriesStart == null
            ? null
            : Day.parse(owner.seriesStart!),
        dueOn: found.dueOn == null ? null : Day.parse(found.dueOn!),
        doneOn: closedOn,
      );
      if (due == null) return;
      nextId = successorId(found.homeId, id);
      final existing = await (db.select(
        db.occurrences,
      )..where((o) => o.id.equalsValue(nextId!))).getSingleOrNull();
      await _put(
        'occurrences',
        nextId!,
        {
          'task_id': owner.id,
          'due_on': due,
          'visible_from': _visibleFrom(owner.hideDaysBefore, due),
          'status': 'planned',
          'status_before': '',
          'postponed_from': null,
          'completed_on': null,
          'completion_note': '',
          'follows': id,
          'deleted_at': null,
        },
        homeId: found.homeId,
        create: existing == null,
      );
    });
    return Closing(id, nextId);
  }

  /// Done, today unless [on]; creates the next occurrence of a task that
  /// repeats (`tasks/services.py:563-579`). One gesture; [undo] takes it back.
  Future<Closing> complete(String id, {Day? on, String note = ''}) =>
      _close(id, 'done', on: on, note: note);

  /// Ignore this time: closed without being done; the next one is created as
  /// for done (`tasks/services.py:582-585`).
  Future<Closing> skip(String id) => _close(id, 'skipped');

  /// Moves the open occurrence to [to], which cannot be in the past; the
  /// first date is kept (`tasks/services.py:588-602`).
  Future<void> postpone(String id, Day to) async {
    final (found, owner) = await _openOccurrence(id);
    if (!openStatuses.contains(found.status)) {
      throw const Refused(Refusal.alreadyClosed);
    }
    if (to < today()) throw const Refused(Refusal.pastDate);
    _checkDate(to);
    await db.transaction(
      () => _put('occurrences', id, {
        if (found.postponedFrom == null) 'postponed_from': found.dueOn,
        'due_on': to,
        'status': 'postponed',
        'visible_from': _visibleFrom(owner.hideDaysBefore, to),
      }),
    );
  }

  /// Takes back a done or a skip: the occurrence is open again as it was,
  /// the next one is gone. Refused once the next one was worked on
  /// (`tasks/services.py:605-643`).
  Future<void> undo(String id) async {
    final found = await occurrence(id);
    if (found == null) throw const Refused(Refusal.notFound);
    await _writableHome(found.homeId);
    if (!closedStatuses.contains(found.status)) {
      throw const Refused(Refusal.notClosed);
    }
    final following = await (db.select(
      db.occurrences,
    )..where((o) => o.follows.equalsValue(id) & o.deletedAt.isNull())).get();
    for (final next in following) {
      final untouched =
          next.status == 'planned' &&
          next.postponedFrom == null &&
          next.completionNote.isEmpty;
      if (!untouched) throw const Refused(Refusal.nextChanged);
    }
    await db.transaction(() async {
      for (final next in following) {
        await _put('occurrences', next.id, {'deleted_at': _now()});
      }
      await _put('occurrences', id, {
        'status': found.statusBefore.isEmpty ? 'planned' : found.statusBefore,
        'status_before': '',
        'completed_on': null,
        'completion_note': '',
      });
    });
  }

  // ---------- Today ----------

  /// The open occurrences to show on Today, of [homeId] or of every active
  /// home when it is `null`: overdue, due within [todayHorizonDays], and
  /// without a date, the oldest first and no date last
  /// (`tasks/services.py:158-197`). Hidden ones are left out.
  Future<List<TodayEntry>> todayEntries({String? homeId}) async {
    final homes = {for (final h in await activeHomes()) h.id: h};
    if (homeId != null) homes.removeWhere((id, _) => id != homeId);
    if (homes.isEmpty) return [];
    final today = this.today();
    final horizon = today.addDays(todayHorizonDays).iso;
    final query =
        db.select(db.occurrences).join([
            innerJoin(db.tasks, db.tasks.id.equalsExp(db.occurrences.taskId)),
          ])
          ..where(
            db.occurrences.deletedAt.isNull() &
                db.tasks.deletedAt.isNull() &
                db.occurrences.status.isIn(openStatuses) &
                db.occurrences.homeId.isInValues(homes.keys) &
                (db.occurrences.visibleFrom.isNull() |
                    db.occurrences.visibleFrom.isSmallerOrEqualValue(
                      today.iso,
                    )) &
                (db.occurrences.dueOn.isNull() |
                    db.occurrences.dueOn.isSmallerOrEqualValue(horizon)),
          )
          ..orderBy([
            OrderingTerm(
              expression: db.occurrences.dueOn,
              nulls: NullsOrder.last,
            ),
            OrderingTerm.asc(db.occurrences.createdAt),
            OrderingTerm.asc(db.occurrences.id),
          ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        if (homes[row.readTable(db.tasks).homeId] != null)
          TodayEntry(
            occurrence: row.readTable(db.occurrences),
            task: row.readTable(db.tasks),
            home: homes[row.readTable(db.tasks).homeId]!,
          ),
    ];
  }
}

String _hex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Uint8List _unhex(String text) => Uint8List.fromList([
  for (var i = 0; i < text.length; i += 2)
    int.parse(text.substring(i, i + 2), radix: 16),
]);
