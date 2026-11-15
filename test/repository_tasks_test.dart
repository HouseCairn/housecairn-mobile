// SPDX-License-Identifier: AGPL-3.0-only

// The lists of lot 3c on the repository, as the web computes them
// (`tasks/services.py`, `tasks/agenda.py`): all the open tasks of a home,
// its history with the real cost, the section In season of Today, the details
// of a done occurrence, the contractor of a task. Two homes throughout: what
// is in one is never in the other.

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';

import 'support/fixture.dart';
import 'support/lot3c.dart';

void main() {
  late Repository r;
  late Lot3c data;

  setUp(() async {
    r = await openRepository();
    addTearDown(r.db.close);
    data = await Lot3c.seed(r);
  });

  List<String> titles(Iterable<TodayEntry> rows) => [
    for (final e in rows) e.task.title,
  ];

  group('all the open tasks', () {
    test(
      'are those of the home only, the oldest first and no date last',
      () async {
        final list = await r.openTasks(data.main);
        final names = titles(list.rows);
        expect(names, containsAll(['Main boiler service', 'Main smoke alarm']));
        expect(names.where((n) => n.startsWith('Second')), isEmpty);
        expect(names.first, 'Main boiler service', reason: 'three days late');
        expect(
          names.indexOf('Main gutters'),
          greaterThan(names.indexOf('Treat the terrace')),
          reason: 'no date last',
        );
        expect(list.total, list.rows.length);
      },
    );

    test(
      'a task hidden until its date gets closer is counted, then shown',
      () async {
        final list = await r.openTasks(data.main);
        expect(titles(list.rows), isNot(contains('Sweep the chimney')));
        expect(list.hidden, 1);
        final shown = await r.openTasks(data.main, showHidden: true);
        expect(titles(shown.rows), contains('Sweep the chimney'));
        expect(shown.hidden, 0, reason: 'nothing left to show');
        expect(shown.total, list.total + 1);
      },
    );

    test('a room filters them', () async {
      final list = await r.openTasks(data.main, roomId: data.kitchen);
      expect(titles(list.rows), contains('Main smoke alarm'));
      expect(titles(list.rows), isNot(contains('Main boiler service')));
      expect(list.rows.every((e) => e.task.roomId == data.kitchen), isTrue);
    });

    test('are paged by 30', () async {
      for (var i = 0; i < 35; i++) {
        await r.createTask(
          data.main,
          TaskInput(title: 'Extra $i', dueOn: testToday.addDays(2)),
        );
      }
      final first = await r.openTasks(data.main);
      expect(first.rows, hasLength(taskPageSize));
      expect(first.pages, 2);
      final second = await r.openTasks(data.main, page: 2);
      expect(second.page, 2);
      expect(second.rows.length, first.total - taskPageSize);
      expect(
        {...titles(first.rows), ...titles(second.rows)}.length,
        first.total,
        reason: 'no task on two pages',
      );
      expect((await r.openTasks(data.main, page: 99)).page, 2);
    });
  });

  group('the history', () {
    test(
      'is the done and the skipped, the most recent first, of the home',
      () async {
        final page = await r.history(data.main, const HistoryFilter());
        expect(titles2(page), [
          'Check the extinguishers',
          'Change the smoke alarm battery',
        ]);
        expect(page.rows.first.occurrence.status, 'skipped');
        expect(
          page.rows.first.closedOn,
          testToday,
          reason: 'a skipped one has the day it was closed',
        );
        expect(page.rows.last.closedOn, testToday.addDays(-2));
        expect(page.rows.last.whereAndWho, 'Main kitchen · Main plumber');
      },
    );

    test('adds up the real cost of the selection', () async {
      final page = await r.history(data.main, const HistoryFilter());
      expect(page.cost.count, 2);
      expect(page.cost.withCost, 1);
      expect(page.cost.total, Decimal.parse('12.50'));
      final skipped = await r.history(
        data.main,
        const HistoryFilter(status: 'skipped'),
      );
      expect(skipped.cost.total, Decimal.zero);
      expect(skipped.cost.withCost, 0);
    });

    test('is filtered by outcome, room, contractor, words and days', () async {
      Future<List<String>> found(HistoryFilter f) async =>
          titles2(await r.history(data.main, f));
      expect(await found(const HistoryFilter(status: 'done')), [
        'Change the smoke alarm battery',
      ]);
      expect(await found(HistoryFilter(contractorId: data.plumber)), [
        'Change the smoke alarm battery',
      ]);
      expect(await found(HistoryFilter(roomId: data.kitchen)), hasLength(2));
      expect(
        await found(HistoryFilter(roomId: data.base.base.base.cellar)),
        isEmpty,
      );
      expect(await found(const HistoryFilter(query: 'NEW BATTERY')), [
        'Change the smoke alarm battery',
      ], reason: 'the note counts, whatever the case');
      expect(await found(const HistoryFilter(query: 'extinguishers')), [
        'Check the extinguishers',
      ]);
      expect(await found(HistoryFilter(after: testToday.addDays(-1))), [
        'Check the extinguishers',
      ]);
      expect(await found(HistoryFilter(before: testToday.addDays(-1))), [
        'Change the smoke alarm battery',
      ]);
      expect(const HistoryFilter().active, isFalse);
      expect(const HistoryFilter(query: ' ').active, isFalse);
      expect(const HistoryFilter(status: 'done').active, isTrue);
    });

    test('never shows the other home, nor a deleted task', () async {
      final second = await r.history(data.second, const HistoryFilter());
      expect(titles2(second), ['Second oil check']);
      await r.deleteTask(data.doneTask);
      expect(titles2(await r.history(data.main, const HistoryFilter())), [
        'Check the extinguishers',
      ]);
    });
  });

  group('In season on Today', () {
    test('lists a task of a season that is on, beyond the week', () async {
      final main = await r.seasonEntries(homeId: data.main);
      expect(titles(main), ['Treat the terrace']);
      final all = await r.seasonEntries();
      expect(
        titles(all),
        unorderedEquals(['Treat the terrace', 'Second terrace']),
      );
      expect(
        titles(await r.todayEntries(homeId: data.main)),
        isNot(contains('Treat the terrace')),
        reason: 'due beyond the week: not in the other sections',
      );
    });

    test(
      'leaves out a season that is over, a hidden task, a task in the week',
      () async {
        await r.createTask(
          data.main,
          TaskInput(
            title: 'Out of season',
            dueOn: testToday.addDays(20),
            season: 'custom',
            seasonStartMonth: 6,
            seasonEndMonth: 7,
          ),
        );
        await r.createTask(
          data.main,
          TaskInput(
            title: 'Hidden in season',
            dueOn: testToday.addDays(40),
            hideDaysBefore: 5,
            season: 'custom',
            seasonStartMonth: testToday.month,
            seasonEndMonth: testToday.month,
          ),
        );
        await r.createTask(
          data.main,
          TaskInput(
            title: 'This week in season',
            dueOn: testToday.addDays(3),
            season: 'custom',
            seasonStartMonth: testToday.month,
            seasonEndMonth: testToday.month,
          ),
        );
        expect(titles(await r.seasonEntries(homeId: data.main)), [
          'Treat the terrace',
        ]);
      },
    );

    test('keeps a task in season without a date', () async {
      await r.createTask(
        data.main,
        TaskInput(
          title: 'Whenever',
          season: 'custom',
          seasonStartMonth: testToday.month,
          seasonEndMonth: testToday.month,
        ),
      );
      expect(titles(await r.seasonEntries(homeId: data.main)), [
        'Treat the terrace',
        'Whenever',
      ]);
    });
  });

  group('the details of a done occurrence', () {
    test('the day, the cost and the note are changed', () async {
      await r.updateOccurrence(
        data.doneOccurrence,
        completedOn: testToday.addDays(-3),
        actualCost: '15',
        note: 'Two batteries',
      );
      final o = (await r.occurrence(data.doneOccurrence))!;
      expect(o.completedOn, testToday.addDays(-3).iso);
      expect(o.actualCost, '15.00');
      expect(o.completionNote, 'Two batteries');
      await r.updateOccurrence(data.doneOccurrence, actualCost: '');
      expect((await r.occurrence(data.doneOccurrence))!.actualCost, isNull);
      // Left alone when not given.
      expect(
        (await r.occurrence(data.doneOccurrence))!.completionNote,
        'Two batteries',
      );
    });

    test('are refused in the future, out of range, for a skip, with a wrong amount', () async {
      Future<void> refused(Future<void> call, Refusal reason) => expectLater(
        call,
        throwsA(isA<Refused>().having((e) => e.reason, 'reason', reason)),
      );
      await refused(
        r.updateOccurrence(
          data.doneOccurrence,
          completedOn: testToday.addDays(1),
        ),
        Refusal.futureDate,
      );
      await refused(
        r.updateOccurrence(data.doneOccurrence, completedOn: Day(1800, 1, 1)),
        Refusal.dateOutOfRange,
      );
      await refused(
        r.updateOccurrence(data.doneOccurrence, actualCost: 'twelve'),
        Refusal.moneyInvalid,
      );
      await refused(
        r.updateOccurrence(data.doneOccurrence, note: 'x' * 5001),
        Refusal.tooLong,
      );
      final skipped = (await r.occurrencesOf(data.skippedTask)).single.id;
      await refused(
        r.updateOccurrence(skipped, note: 'later'),
        Refusal.notClosed,
      );
      final open = (await r.openOccurrencesOf(data.hiddenTask)).single.id;
      await refused(
        r.updateOccurrence(open, actualCost: '3'),
        Refusal.notClosed,
      );
      expect(
        (await r.occurrence(data.doneOccurrence))!.actualCost,
        '12.50',
        reason: 'a refusal changes nothing',
      );
    });

    test('are read only in an archived home', () async {
      await r.archiveHome(data.main);
      await expectLater(
        r.updateOccurrence(data.doneOccurrence, note: 'late'),
        throwsA(isA<Refused>()),
      );
    });
  });

  group('undo of a done occurrence', () {
    Future<void> refused(Future<void> call, Refusal reason) => expectLater(
      call,
      throwsA(isA<Refused>().having((e) => e.reason, 'reason', reason)),
    );

    test(
      'empties the real cost, which a new done does not bring back',
      () async {
        final id = await r.createTask(
          data.main,
          TaskInput(title: 'Clean the gutters', dueOn: testToday),
        );
        final occ = (await r.openOccurrencesOf(id)).single.id;
        await r.complete(occ);
        await r.updateOccurrence(occ, actualCost: '50');
        expect((await r.occurrence(occ))!.actualCost, '50.00');

        await r.undo(occ);
        final open = (await r.occurrence(occ))!;
        expect(open.actualCost, isNull, reason: 'as the web: actual_cost=None');
        expect(open.status, 'planned');

        await r.complete(occ);
        final page = await r.history(data.main, const HistoryFilter());
        expect(page.cost.total, Decimal.parse('12.50'), reason: 'not 62.50');
        expect(page.cost.withCost, 1);
      },
    );

    test('is refused when the next occurrence has a real cost', () async {
      final id = await r.createTask(
        data.main,
        TaskInput(
          title: 'Bleed the radiators',
          dueOn: testToday,
          repeatMode: 'after_last',
          repeatUnit: 'week',
        ),
      );
      final first = (await r.openOccurrencesOf(id)).single.id;
      final next = (await r.complete(first)).nextId!;
      await r.db.customUpdate(
        'UPDATE occurrences SET actual_cost = ? WHERE id = ?',
        variables: [
          Variable<String>('5.00'),
          Variable<Object>(uuidBytes(next)),
        ],
        updates: {r.db.occurrences},
      );
      await refused(r.undo(first), Refusal.nextChanged);
      expect((await r.occurrence(first))!.status, 'done');
    });

    test('detaches the withdrawn occurrence before deleting it', () async {
      final id = await r.createTask(
        data.main,
        TaskInput(
          title: 'Check the chimney cap',
          dueOn: testToday,
          repeatMode: 'after_last',
          repeatUnit: 'week',
        ),
      );
      final first = (await r.openOccurrencesOf(id)).single.id;
      final next = (await r.complete(first)).nextId!;
      expect(
        (await r.occurrence(next))!.follows,
        first,
        reason: 'attached while it lives',
      );
      await r.undo(first);
      final row = await (r.db.select(
        r.db.occurrences,
      )..where((o) => o.id.equalsValue(next))).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(row.follows, isNull);
      // Done again: the same successor comes back, attached once more.
      expect((await r.complete(first)).nextId, next);
      expect((await r.occurrence(next))!.follows, first);
    });
  });

  group('the contractor of a task', () {
    test('is kept, changed and removed', () async {
      final id = await r.createTask(
        data.main,
        TaskInput(title: 'Call', contractorId: data.plumber),
      );
      expect((await r.task(id))!.contractorId, data.plumber);
      await r.updateTask(id, const TaskInput(title: 'Call'));
      expect((await r.task(id))!.contractorId, isNull);
    });

    test('is one of the home', () async {
      final other = (await r.contractors(data.second)).first.id;
      await expectLater(
        r.createTask(data.main, TaskInput(title: 'Call', contractorId: other)),
        throwsA(
          isA<Refused>().having((e) => e.reason, 'reason', Refusal.notInHome),
        ),
      );
    });
  });

  test('the priority, the duration, the procedure are kept', () async {
    final id = await r.createTask(
      data.main,
      const TaskInput(
        title: 'Detail',
        priority: 'high',
        estimatedMinutes: 90,
        procedure: '1. Open\n2. Close',
        hideDaysBefore: 3,
      ),
    );
    final task = (await r.task(id))!;
    expect(task.priority, 'high');
    expect(task.estimatedMinutes, 90);
    expect(task.procedure, '1. Open\n2. Close');
    expect(task.hideDaysBefore, 3);
    await expectLater(
      r.createTask(data.main, TaskInput(title: 'Long', procedure: 'x' * 20001)),
      throwsA(isA<Refused>()),
    );
  });

  test(
    'a room, an item and a contractor added with a task: all or none',
    () async {
      final before = (await r.rooms(data.main)).length;
      await expectLater(
        r.atomic(() async {
          await r.createRoom(data.main, name: 'Porch');
          await r.createTask(
            data.main,
            TaskInput(title: 'x' * 201, dueOn: testToday),
          );
        }),
        throwsA(isA<Refused>()),
      );
      expect((await r.rooms(data.main)).length, before, reason: 'rolled back');
    },
  );
}

List<String> titles2(HistoryPage page) => [
  for (final e in page.rows) e.task.title,
];
