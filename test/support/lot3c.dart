// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/occurrence_screen.dart';
import 'package:housecairn_mobile/ui/task_list_screen.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'lot2b.dart' show openScreen;
import 'lot3b.dart';
import 'screens_2b.dart';

/// The data of the screens of lot 3c: the homes of lot 3b, and in the main
/// home a task done two days ago with its cost, its note and its contractor,
/// one skipped, one in season beyond the week, one hidden until its date gets
/// closer; in the second home a task done and one in season, so that nothing
/// of one home is ever in the other. Neutral names only.
class Lot3c {
  late Lot3b base;
  late String doneTask;
  late String doneOccurrence;
  late String skippedTask;
  late String seasonTask;
  late String hiddenTask;
  late String secondDoneTask;

  String get main => base.main;
  String get second => base.second;
  String get kitchen => base.base.base.kitchen;
  String get plumber => base.base.base.plumber;

  static Future<Lot3c> seed(Repository r) async {
    final data = Lot3c()..base = await Lot3b.seed(r);
    final main = data.main;
    final today = r.today();
    // Two tasks of the fixture are due today and were made at the same
    // instant: the web breaks such a tie by the id, which is random here. One
    // moves to tomorrow, so that the list and its golden file have one order.
    final sand = (await r.db.select(r.db.tasks).get()).firstWhere(
      (t) => t.title == 'Sand the walls',
    );
    await r.updateTask(
      sand.id,
      TaskInput(title: sand.title, dueOn: today.addDays(1)),
    );
    // The same for the task without a date that was made at the same instant.
    await r.updateTask(
      data.base.base.service,
      TaskInput(
        title: 'Service the boiler',
        itemId: data.base.base.base.boiler,
        dueOn: today.addDays(9),
      ),
    );
    data.doneTask = await r.createTask(
      main,
      TaskInput(
        title: 'Change the smoke alarm battery',
        dueOn: today.addDays(-4),
        roomId: data.kitchen,
        contractorId: data.plumber,
      ),
    );
    data.doneOccurrence = (await r.openOccurrencesOf(data.doneTask)).single.id;
    await r.complete(data.doneOccurrence, on: today.addDays(-2));
    await r.updateOccurrence(
      data.doneOccurrence,
      actualCost: '12.50',
      note: 'New battery',
    );
    data.skippedTask = await r.createTask(
      main,
      TaskInput(
        title: 'Check the extinguishers',
        dueOn: today.addDays(-9),
        roomId: data.kitchen,
      ),
    );
    await r.skip((await r.openOccurrencesOf(data.skippedTask)).single.id);
    // In season in November, whatever the hemisphere (the months are typed).
    data.seasonTask = await r.createTask(
      main,
      TaskInput(
        title: 'Treat the terrace',
        dueOn: today.addDays(20),
        season: 'custom',
        seasonStartMonth: today.month,
        seasonEndMonth: today.month,
      ),
    );
    data.hiddenTask = await r.createTask(
      main,
      TaskInput(
        title: 'Sweep the chimney',
        dueOn: today.addDays(30),
        hideDaysBefore: 10,
      ),
    );
    data.secondDoneTask = await r.createTask(
      data.second,
      TaskInput(title: 'Second oil check', dueOn: today.addDays(-1)),
    );
    await r.complete(
      (await r.openOccurrencesOf(data.secondDoneTask)).single.id,
    );
    await r.createTask(
      data.second,
      TaskInput(
        title: 'Second terrace',
        dueOn: today.addDays(25),
        season: 'custom',
        seasonStartMonth: today.month,
        seasonEndMonth: today.month,
      ),
    );
    return data;
  }
}

/// Opens the list of all the tasks, as the tab All of Today does.
Future<void> openTaskList(WidgetTester tester, Lot3c data) =>
    openScreen(tester, TaskListScreen(homeId: data.main));

/// The screens of lot 3c, each opened as the app opens it. `page` is the name
/// of the golden file.
final screens3c =
    <(String page, Future<void> Function(WidgetTester, Lot3c, Labels))>[
      ('tasks', (tester, data, l) => openTaskList(tester, data)),
      (
        'history',
        (tester, data, l) async {
          await openTaskList(tester, data);
          await tester.tap(find.byKey(const Key('tasks-status')));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l.doneFilter).last);
          await tester.pumpAndSettle();
        },
      ),
      (
        'occurrence',
        (tester, data, l) => openScreen(
          tester,
          OccurrenceScreen(
            homeId: data.main,
            occurrenceId: data.doneOccurrence,
          ),
        ),
      ),
      (
        'task_page',
        (tester, data, l) => openScreen(
          tester,
          TaskScreen(homeId: data.main, taskId: data.doneTask),
        ),
      ),
      (
        // The form of an existing task, opened by Edit the task (lot D2).
        'task_edit',
        (tester, data, l) async {
          await openScreen(
            tester,
            TaskScreen(homeId: data.main, taskId: data.doneTask),
          );
          await tester.ensureVisible(find.byKey(const Key('task-edit')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('task-edit')));
          await tester.pumpAndSettle();
        },
      ),
      (
        'task_new',
        (tester, data, l) => openScreen(tester, TaskScreen(homeId: data.main)),
      ),
    ];
