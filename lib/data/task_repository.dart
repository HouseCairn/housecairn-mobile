// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// Rows on a page of the list of tasks and of the history (`PAGE_SIZE` of
/// `tasks/views.py`).
const taskPageSize = 30;

/// How many rows the section In season takes at most (`ROW_LIMIT` of
/// `tasks/agenda.py`).
const seasonRowLimit = 200;

/// A page of open occurrences, and what is not on it.
class TaskListPage {
  const TaskListPage({
    required this.rows,
    required this.total,
    required this.hidden,
    required this.page,
  });

  final List<TodayEntry> rows;

  /// Open occurrences matching the filter, on every page.
  final int total;

  /// Open occurrences hidden until their date gets closer, when they are not
  /// shown (`hidden_count` of `TaskListView`).
  final int hidden;

  /// The page shown, from 1.
  final int page;

  int get pages => total == 0 ? 1 : (total + taskPageSize - 1) ~/ taskPageSize;
}

/// Which closed occurrences to look at (`HistoryFilter` of
/// `tasks/agenda.py`); every field is optional. Who did it comes with the
/// members of the family (lot 5).
class HistoryFilter {
  const HistoryFilter({
    this.roomId,
    this.itemId,
    this.contractorId,
    this.query = '',
    this.status = '',
    this.after,
    this.before,
  });

  final String? roomId;
  final String? itemId;
  final String? contractorId;
  final String query;

  /// `''` (done or skipped), `done` or `skipped`.
  final String status;
  final Day? after;
  final Day? before;

  bool get active => criteria > 0 || query.trim().isNotEmpty;

  /// How many criteria of the sheet Filters apply (the search field is not
  /// one of them), the count of "Filters (2)".
  int get criteria => [
    roomId,
    itemId,
    contractorId,
    status.isEmpty ? null : status,
    after,
    before,
  ].nonNulls.length;
}

/// A closed occurrence of the history, with where it happened and who was
/// involved (`where_and_who` of `tasks/templatetags/tasks_extras.py`).
class HistoryEntry {
  const HistoryEntry({
    required this.occurrence,
    required this.task,
    required this.closedOn,
    this.roomName,
    this.itemName,
    this.contractorName,
  });

  final OccurrenceRow occurrence;
  final TaskRow task;

  /// The day it was done; a skipped one has none, the day it was closed
  /// stands for it (`closed_on`).
  final Day closedOn;
  final String? roomName;
  final String? itemName;
  final String? contractorName;

  String get whereAndWho => [
    ?roomName,
    ?itemName,
    ?contractorName,
  ].where((p) => p.isNotEmpty).join(' · ');
}

/// The real cost of a selection, over the occurrences where one was typed
/// (`Cost` of `tasks/agenda.py`).
class HistoryCost {
  const HistoryCost(this.total, this.withCost, this.count);

  final Decimal total;
  final int withCost;
  final int count;
}

/// A page of the history and the cost of the whole selection.
class HistoryPage {
  const HistoryPage({
    required this.rows,
    required this.cost,
    required this.page,
  });

  final List<HistoryEntry> rows;
  final HistoryCost cost;
  final int page;

  int get pages =>
      cost.count == 0 ? 1 : (cost.count + taskPageSize - 1) ~/ taskPageSize;
}

extension TaskListsRepository on Repository {
  /// Runs [body] in one transaction: all or none.
  Future<T> atomic<T>(Future<T> Function() body) => db.transaction(body);

  Future<Map<String, String>> _roomNames(Iterable<String> homeIds) async => {
    for (final r in await (db.select(
      db.rooms,
    )..where((t) => t.homeId.isInValues(homeIds) & t.deletedAt.isNull())).get())
      r.id: r.name,
  };

  Future<Map<String, String>> _itemNames(Iterable<String> homeIds) async => {
    for (final i in await (db.select(
      db.items,
    )..where((t) => t.homeId.isInValues(homeIds) & t.deletedAt.isNull())).get())
      i.id: i.name,
  };

  /// The open occurrences of [homeId], the oldest due date first and no date
  /// last, 30 to a page; the hidden ones only with [showHidden], and only
  /// those of [roomId] when it is given (`TaskListView`, status open).
  Future<TaskListPage> openTasks(
    String homeId, {
    String? roomId,
    bool showHidden = false,
    int page = 1,
    String query = '',
  }) async {
    final home = await this.home(homeId);
    if (home == null) throw const Refused(Refusal.notFound);
    final today = this.today();
    Expression<bool> open(AppDatabase db) =>
        db.occurrences.deletedAt.isNull() &
        db.tasks.deletedAt.isNull() &
        db.occurrences.status.isIn(openStatuses) &
        db.occurrences.homeId.equalsValue(homeId);
    Expression<bool> shown(AppDatabase db) =>
        db.occurrences.visibleFrom.isNull() |
        db.occurrences.visibleFrom.isSmallerOrEqualValue(today.iso);
    JoinedSelectStatement<HasResultSet, dynamic> select() =>
        db.select(db.occurrences).join([
          innerJoin(db.tasks, db.tasks.id.equalsExp(db.occurrences.taskId)),
        ]);
    Expression<bool> filter(AppDatabase db) {
      var where = open(db);
      if (!showHidden) where = where & shown(db);
      if (roomId != null) where = where & db.tasks.roomId.equalsValue(roomId);
      return where;
    }

    Future<int> count(Expression<bool> where) async {
      final total = countAll();
      final row =
          await (db.selectOnly(db.occurrences).join([
                  innerJoin(
                    db.tasks,
                    db.tasks.id.equalsExp(db.occurrences.taskId),
                  ),
                ])
                ..addColumns([total])
                ..where(where))
              .getSingle();
      return row.read(total)!;
    }

    final needle = foldForSearch(query.trim());
    var hidden = 0;
    if (!showHidden) {
      hidden = await count(open(db)) - await count(open(db) & shown(db));
    }
    final rooms = await _roomNames([homeId]);
    final items = await _itemNames([homeId]);
    final order = [
      OrderingTerm(expression: db.occurrences.dueOn, nulls: NullsOrder.last),
      OrderingTerm.asc(db.occurrences.createdAt),
      OrderingTerm.asc(db.occurrences.id),
    ];
    TodayEntry entry(TypedResult row) => TodayEntry(
      occurrence: row.readTable(db.occurrences),
      task: row.readTable(db.tasks),
      home: home,
      roomName: rooms[row.readTable(db.tasks).roomId],
      itemName: items[row.readTable(db.tasks).itemId],
    );

    if (needle.isNotEmpty) {
      // A search compares the folded title, room and item: the rows are read
      // once, ordered, and kept in memory for the page.
      final all =
          await (select()
                ..where(filter(db))
                ..orderBy(order))
              .get();
      final found = <TypedResult>[
        for (final row in all)
          if (matchesSearch(needle, [
            foldForSearch(row.readTable(db.tasks).title),
            foldForSearch(rooms[row.readTable(db.tasks).roomId] ?? ''),
            foldForSearch(items[row.readTable(db.tasks).itemId] ?? ''),
          ]))
            row,
      ];
      final pages = found.isEmpty
          ? 1
          : (found.length + taskPageSize - 1) ~/ taskPageSize;
      final shownPage = page.clamp(1, pages);
      return TaskListPage(
        rows: [
          for (final row
              in found.skip((shownPage - 1) * taskPageSize).take(taskPageSize))
            entry(row),
        ],
        total: found.length,
        hidden: hidden,
        page: shownPage,
      );
    }

    final total = await count(filter(db));
    final pages = total == 0 ? 1 : (total + taskPageSize - 1) ~/ taskPageSize;
    final shownPage = page.clamp(1, pages);
    final rows =
        await (select()
              ..where(filter(db))
              ..orderBy(order)
              ..limit(taskPageSize, offset: (shownPage - 1) * taskPageSize))
            .get();
    return TaskListPage(
      rows: [for (final row in rows) entry(row)],
      total: total,
      hidden: hidden,
      page: shownPage,
    );
  }

  /// The section In season of Today: the open occurrences of a task limited
  /// to a season that is on, due beyond the horizon of Today or without a
  /// date (`today_sections` of `tasks/agenda.py`).
  Future<List<TodayEntry>> seasonEntries({String? homeId}) async {
    final homes = {for (final h in await activeHomes()) h.id: h};
    if (homeId != null) homes.removeWhere((id, _) => id != homeId);
    if (homes.isEmpty) return [];
    final today = this.today();
    final horizon = today.addDays(todayHorizonDays).iso;
    final rows =
        await (db.select(db.occurrences).join([
                innerJoin(
                  db.tasks,
                  db.tasks.id.equalsExp(db.occurrences.taskId),
                ),
              ])
              ..where(
                db.occurrences.deletedAt.isNull() &
                    db.tasks.deletedAt.isNull() &
                    db.occurrences.status.isIn(openStatuses) &
                    db.occurrences.homeId.isInValues(homes.keys) &
                    db.tasks.seasonStartMonth.isNotNull() &
                    (db.occurrences.visibleFrom.isNull() |
                        db.occurrences.visibleFrom.isSmallerOrEqualValue(
                          today.iso,
                        )) &
                    (db.occurrences.dueOn.isNull() |
                        db.occurrences.dueOn.isBiggerThanValue(horizon)),
              )
              ..orderBy([
                OrderingTerm(
                  expression: db.occurrences.dueOn,
                  nulls: NullsOrder.last,
                ),
                OrderingTerm.asc(db.occurrences.createdAt),
                OrderingTerm.asc(db.occurrences.id),
              ]))
            .get();
    final rooms = await _roomNames(homes.keys);
    final items = await _itemNames(homes.keys);
    return [
      for (final row in rows)
        if (homes[row.readTable(db.tasks).homeId] != null &&
            recurrence.inSeason(
              Repository._ruleOf(row.readTable(db.tasks)),
              today,
            ))
          TodayEntry(
            occurrence: row.readTable(db.occurrences),
            task: row.readTable(db.tasks),
            home: homes[row.readTable(db.tasks).homeId]!,
            roomName: rooms[row.readTable(db.tasks).roomId],
            itemName: items[row.readTable(db.tasks).itemId],
          ),
    ].take(seasonRowLimit).toList();
  }

  /// The done and skipped occurrences of [homeId], the most recent first,
  /// filtered, 30 to a page, with the real cost of the whole selection
  /// (`history` and `cost_of` of `tasks/agenda.py`).
  Future<HistoryPage> history(
    String homeId,
    HistoryFilter selection, {
    int page = 1,
  }) async {
    final rows =
        await (db.select(db.occurrences).join([
              innerJoin(db.tasks, db.tasks.id.equalsExp(db.occurrences.taskId)),
            ])..where(
              db.occurrences.deletedAt.isNull() &
                  db.tasks.deletedAt.isNull() &
                  db.occurrences.homeId.equalsValue(homeId) &
                  db.occurrences.status.isIn(closedStatuses),
            ))
            .get();
    final rooms = await _roomNames([homeId]);
    final items = await _itemNames([homeId]);
    final names = {for (final c in await contractors(homeId)) c.id: c.name};
    final query = foldForSearch(selection.query.trim());
    final entries = <HistoryEntry>[];
    for (final row in rows) {
      final occurrence = row.readTable(db.occurrences);
      final task = row.readTable(db.tasks);
      if (selection.status.isNotEmpty &&
          occurrence.status != selection.status) {
        continue;
      }
      if (selection.roomId != null && task.roomId != selection.roomId) continue;
      if (selection.itemId != null && task.itemId != selection.itemId) continue;
      if (selection.contractorId != null &&
          task.contractorId != selection.contractorId) {
        continue;
      }
      if (!matchesSearch(query, [
        foldForSearch(task.title),
        foldForSearch(occurrence.completionNote),
        foldForSearch(rooms[task.roomId] ?? ''),
        foldForSearch(items[task.itemId] ?? ''),
      ])) {
        continue;
      }
      final closedOn = occurrence.completedOn != null
          ? Day.parse(occurrence.completedOn!)
          : Day.of(
              DateTime.fromMillisecondsSinceEpoch(
                occurrence.updatedAt,
                isUtc: true,
              ).toLocal(),
            );
      if (selection.after != null && closedOn < selection.after!) continue;
      if (selection.before != null && closedOn > selection.before!) continue;
      entries.add(
        HistoryEntry(
          occurrence: occurrence,
          task: task,
          closedOn: closedOn,
          roomName: rooms[task.roomId],
          itemName: items[task.itemId],
          contractorName: names[task.contractorId],
        ),
      );
    }
    entries.sort((a, b) {
      final byDay = b.closedOn.compareTo(a.closedOn);
      if (byDay != 0) return byDay;
      final byUpdate = b.occurrence.updatedAt.compareTo(a.occurrence.updatedAt);
      return byUpdate != 0
          ? byUpdate
          : b.occurrence.id.compareTo(a.occurrence.id);
    });
    var total = Decimal.zero;
    var withCost = 0;
    for (final e in entries) {
      final cost = e.occurrence.actualCost;
      if (cost == null) continue;
      total += budget.readMoney(cost);
      withCost++;
    }
    final pages = entries.isEmpty
        ? 1
        : (entries.length + taskPageSize - 1) ~/ taskPageSize;
    final shown = page.clamp(1, pages);
    return HistoryPage(
      rows: entries
          .skip((shown - 1) * taskPageSize)
          .take(taskPageSize)
          .toList(),
      cost: HistoryCost(total, withCost, entries.length),
      page: shown,
    );
  }

  /// Completes what is known of a done occurrence: the day it was done, what
  /// it really cost, a note (`update_occurrence` of `tasks/services.py`). Only
  /// a done occurrence has details; a null argument leaves its field alone.
  Future<void> updateOccurrence(
    String id, {
    Day? completedOn,
    String? actualCost,
    String? note,
  }) async {
    final current = await occurrence(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableHome(current.homeId);
    if (current.status != 'done') throw const Refused(Refusal.notClosed);
    final changes = <String, Object?>{};
    if (completedOn != null && completedOn.iso != current.completedOn) {
      if (completedOn > today()) throw const Refused(Refusal.futureDate);
      _checkDate(completedOn);
      changes['completed_on'] = completedOn;
    }
    if (actualCost != null) {
      final value = BudgetRepository._optionalMoney(actualCost);
      if (value != current.actualCost) changes['actual_cost'] = value;
    }
    if (note != null && note != current.completionNote) {
      if (note.length > 5000) throw const Refused(Refusal.tooLong);
      changes['completion_note'] = note;
    }
    if (changes.isEmpty) return;
    await db.transaction(() => _put('occurrences', id, changes));
  }
}
