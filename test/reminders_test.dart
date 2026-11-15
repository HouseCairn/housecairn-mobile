// SPDX-License-Identifier: AGPL-3.0-only

// Reminders (docs/spec.md, "Reminders"): the plan the phone makes from its own
// data, and the notifications it schedules. Nothing leaves the phone.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/reminders.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/ui/state.dart';

import 'support/fakes.dart';
import 'support/fixture.dart';

class Words implements ReminderTexts {
  @override
  String title(String task, String? homeName) =>
      homeName == null ? task : '$homeName: $task';

  @override
  String due(Day dueOn) => 'due ${dueOn.iso}';

  @override
  String summaryTitle(int count) => 'more: $count';

  @override
  String summaryLine(String? homeName, int count) =>
      homeName == null ? '$count' : '$homeName $count';
}

ReminderSource source(
  int n, {
  String home = 'h1',
  String homeName = 'Main home',
  Day? due,
  String priority = 'normal',
}) => ReminderSource(
  occurrenceId: 'o${n.toString().padLeft(3, '0')}',
  taskId: 't$n',
  taskTitle: 'Task $n',
  homeId: home,
  homeName: homeName,
  dueOn: due ?? Day(2026, 11, 20),
  priority: priority,
);

ReminderPlan plan(
  List<ReminderSource> sources, {
  bool namesHomes = false,
  DateTime? now,
}) => planReminders(
  sources: sources,
  now: now ?? DateTime(2026, 11, 14, 12),
  namesHomes: namesHomes,
  texts: Words(),
);

void main() {
  group('the web rules, carried over', () {
    test('the first reminder is the day before at 8:00', () {
      final p = plan([source(1)]);
      expect(p.reminders.first.at, DateTime(2026, 11, 19, 8));
      expect(p.reminders.first.title, 'Task 1');
      expect(p.reminders.first.body, 'due 2026-11-20');
    });

    test('follow-ups every 3 days when the priority is normal', () {
      final p = plan([source(1)]);
      expect(p.reminders.take(3).map((r) => r.at), [
        DateTime(2026, 11, 19, 8),
        DateTime(2026, 11, 22, 8),
        DateTime(2026, 11, 25, 8),
      ]);
    });

    test('every day when high, every 7 days when low', () {
      final high = plan([source(1, priority: 'high')]);
      expect(high.reminders[1].at.difference(high.reminders[0].at).inDays, 1);
      final low = plan([source(1, priority: 'low')]);
      expect(low.reminders[1].at.difference(low.reminders[0].at).inDays, 7);
    });

    test(
      'nothing before now: an overdue task is reminded at the next follow-up',
      () {
        // Due on the 1st: reminders on 31 Oct, 3, 6, 9, 12 Nov (08:00, past at
        // 12:00), then 15 Nov...
        final p = plan([source(1, due: Day(2026, 11, 1))]);
        expect(p.reminders.first.at, DateTime(2026, 11, 15, 8));
        expect(
          p.reminders.every((r) => r.at.isAfter(DateTime(2026, 11, 14, 12))),
          isTrue,
        );
      },
    );

    test('a task with no due date has no reminder', () {
      // The repository leaves them out; the planner only reads dated ones.
      expect(plan([]).all, isEmpty);
    });

    test('a postponed task is reminded from its new date', () {
      final before = plan([source(1)]).reminders.first.at;
      final after = plan([source(1, due: Day(2026, 12, 5))]).reminders.first.at;
      expect(before, DateTime(2026, 11, 19, 8));
      expect(after, DateTime(2026, 12, 4, 8));
    });
  });

  group('at most 60 notifications, the rest in the daily summary', () {
    List<ReminderSource> many(int count) => [
      for (var n = 0; n < count; n++)
        source(
          n,
          home: n.isEven ? 'h1' : 'h2',
          homeName: n.isEven ? 'Main home' : 'Second home',
          due: Day(2026, 11, 20).addDays(n % 30),
        ),
    ];

    test(
      '100 open occurrences over two homes: 60 pending, 41 in the summary',
      () {
        final p = plan(many(100), namesHomes: true);
        expect(p.all, hasLength(60));
        expect(p.reminders, hasLength(59));
        expect(p.summary, isNotNull);
        // One reminder per task first: the 59 nearest tasks, not follow-ups.
        expect({for (final r in p.reminders) r.payload}, hasLength(59));
        expect(p.summary!.title, 'more: 41');
        // Grouped by home, the homes by name.
        expect(p.summary!.body, 'Main home 20\nSecond home 21');
        expect({for (final r in p.all) r.id}, hasLength(60));
      },
    );

    test('exactly 60 tasks: all have a reminder, no summary', () {
      final p = plan(many(60));
      expect(p.reminders, hasLength(60));
      expect(p.summary, isNull);
    });

    test('61 tasks: 59 reminders and a summary of 2', () {
      final p = plan(many(61));
      expect(p.reminders, hasLength(59));
      expect(p.summary!.title, 'more: 2');
    });

    test('follow-ups fill what is left, a task never crowds out another', () {
      final p = plan(many(10));
      expect(p.all.length, greaterThan(10));
      expect(p.all.length, lessThanOrEqualTo(maxPending));
      expect({for (final r in p.reminders) r.payload}, hasLength(10));
    });

    test('the summary goes out at the next 8:00', () {
      final before = plan(many(100), now: DateTime(2026, 11, 14, 7));
      expect(before.summary!.at, DateTime(2026, 11, 14, 8));
      final after = plan(many(100), now: DateTime(2026, 11, 14, 12));
      expect(after.summary!.at, DateTime(2026, 11, 15, 8));
    });

    test('the summary does not name a home when there is one', () {
      final p = plan(many(100), namesHomes: false);
      expect(p.summary!.body, '41');
    });
  });

  group('the home in the title', () {
    test('named with two active homes, not with one', () {
      final two = plan([source(1, homeName: 'Second home')], namesHomes: true);
      expect(two.reminders.first.title, 'Second home: Task 1');
      final one = plan([source(1, homeName: 'Second home')]);
      expect(one.reminders.first.title, 'Task 1');
    });

    test('the payload opens the home of the task', () {
      final p = plan([source(1, home: 'h2')]);
      expect(p.reminders.first.payload, 'h2/t1');
    });
  });

  group('scheduled from the data of the phone', () {
    late Repository repository;
    late AppState state;
    late FakeNotifier notifier;
    late TwoHomes homes;

    Future<void> start({bool allowed = true}) async {
      await initializeDateFormatting('en');
      repository = await openRepository();
      homes = await TwoHomes.create(repository);
      notifier = FakeNotifier(allowed: allowed);
      state = AppState(repository, notifier: notifier);
      state.l10n = AppLocalizationsEn();
      await state.refresh();
    }

    // Titles scheduled.
    List<String> titles() =>
        notifier.scheduled.values.map((n) => n.title).toList()..sort();

    test('nothing is scheduled, and no permission asked, until reminders are turned on', () async {
      await start();
      expect(notifier.asked, 0);
      expect(notifier.scheduled, isEmpty);
      expect(state.remindersOn, isFalse);
    });

    test('turned on: the permission is asked once, and every task with a date is reminded', () async {
      await start();
      expect(await state.setReminders(true), isTrue);
      expect(notifier.asked, 1);
      expect(state.remindersOn, isTrue);
      // Two active homes: each title names its home. The tasks with a date:
      // smoke alarm (today) and boiler service (3 days ago, yearly).
      expect(
        titles(),
        everyElement(
          anyOf(startsWith('Main home: '), startsWith('Second home: ')),
        ),
      );
      expect(titles().where((t) => t.contains('smoke alarm')), isNotEmpty);
      expect(
        titles().any((t) => t.contains('gutters')),
        isFalse,
        reason: 'no date, no reminder',
      );
      expect(notifier.scheduled.length, lessThanOrEqualTo(maxPending));
    });

    test('refused: reminders stay off and nothing is scheduled', () async {
      await start(allowed: false);
      expect(await state.setReminders(true), isFalse);
      expect(state.remindersOn, isFalse);
      expect(await repository.remindersEnabled(), isFalse);
      expect(notifier.scheduled, isEmpty);
    });

    test('a task done is no longer reminded; undone, it is again', () async {
      await start();
      await state.setReminders(true);
      final entry = (await repository.todayEntries(homeId: homes.main))
          .firstWhere((e) => e.task.title == 'Main smoke alarm');
      // Due today: reminded from a follow-up on.
      final before = titles()
          .where((t) => t.endsWith('Main smoke alarm'))
          .length;
      expect(before, greaterThan(0));
      await repository.complete(entry.occurrence.id);
      await state.refresh();
      expect(titles().where((t) => t.endsWith('Main smoke alarm')), isEmpty);
      await repository.undo(entry.occurrence.id);
      await state.refresh();
      expect(titles().where((t) => t.endsWith('Main smoke alarm')), isNotEmpty);
    });

    test('a task postponed is reminded from its new date', () async {
      await start();
      await state.setReminders(true);
      final entry = (await repository.todayEntries(homeId: homes.main))
          .firstWhere((e) => e.task.title == 'Main smoke alarm');
      final to = repository.today().addDays(40);
      await repository.postpone(entry.occurrence.id, to);
      await state.refresh();
      final mine = notifier.scheduled.values.where(
        (n) => n.title.endsWith('Main smoke alarm'),
      );
      expect(mine, isNotEmpty);
      final first = mine
          .map((n) => n.at)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      expect(first, DateTime(to.year, to.month, to.day - 1, 8));
    });

    test('a task deleted is no longer reminded', () async {
      await start();
      await state.setReminders(true);
      final entry = (await repository.todayEntries(homeId: homes.main))
          .firstWhere((e) => e.task.title == 'Main boiler service');
      await repository.deleteTask(entry.task.id);
      await state.refresh();
      expect(titles().where((t) => t.contains('Main boiler service')), isEmpty);
    });

    test(
      'an archived home has no pending notification; unarchived, it is back',
      () async {
        await start();
        await state.setReminders(true);
        expect(titles().any((t) => t.startsWith('Second home: ')), isTrue);
        await repository.archiveHome(homes.second);
        await state.refresh();
        expect(titles().any((t) => t.startsWith('Second home: ')), isFalse);
        // One active home left: no title names its home.
        expect(titles().any((t) => t.startsWith('Main home: ')), isFalse);
        await repository.unarchiveHome(homes.second);
        await state.refresh();
        expect(titles().any((t) => t.startsWith('Second home: ')), isTrue);
      },
    );

    test('turned off: everything pending is cancelled', () async {
      await start();
      await state.setReminders(true);
      expect(notifier.scheduled, isNotEmpty);
      await state.setReminders(false);
      expect(notifier.scheduled, isEmpty);
      await state.refresh();
      expect(notifier.scheduled, isEmpty);
    });

    test('the permission taken back in the settings of the phone turns reminders off', () async {
      await start();
      await state.setReminders(true);
      notifier.granted = false;
      await state.refresh();
      expect(state.remindersOn, isFalse);
      expect(await repository.remindersEnabled(), isFalse);
    });

    test('the Android channel is named in the language of the app', () async {
      await start();
      await state.setReminders(true);
      expect(notifier.channels, {'Reminders'});
      state.l10n = AppLocalizationsFr();
      await state.reschedule();
      expect(notifier.channels, {'Reminders', 'Rappels'});
    });

    test('the tap that started the app on a reminder opens its home', () async {
      await start();
      await state.choose(homes.main);
      notifier.launch = '${homes.second}/some-task';
      await state.openLaunchReminder();
      expect(state.current!.id, homes.second);
      // Once per start: a later choice is not undone.
      await state.choose(homes.main);
      await state.openLaunchReminder();
      expect(state.current!.id, homes.main);
    });

    test('an app started otherwise opens nothing', () async {
      await start();
      await state.choose(homes.main);
      await state.openLaunchReminder();
      expect(state.current!.id, homes.main);
    });

    test('a launch tap on a home that is gone opens nothing', () async {
      await start();
      await state.choose(homes.second);
      notifier.launch = 'unknown-home/some-task';
      await state.openLaunchReminder();
      expect(state.current!.id, homes.second);
    });

    test('opening a reminder makes its home the current one', () async {
      await start();
      await state.choose(homes.main);
      await state.openReminder('${homes.second}/some-task');
      expect(state.current!.id, homes.second);
    });
  });

  group('nothing leaves the phone', () {
    test('lib/ opens no socket and no HTTP client but the transport of a '
        'Housecairn server, which only the third way uses (lot 4b)', () {
      final offences = <String>[];
      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        if (RegExp(
          r'\bHttpClient\b|\bSocket\b|\bWebSocket\b|package:http/|package:dio/',
        ).hasMatch(source)) {
          offences.add(file.path);
        }
      }
      expect(offences, ['lib/sync/server_http_io.dart']);
    });
  });
}
