// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/task_list_screen.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3c.dart';
import 'support/screens_2b.dart';

/// The scrollable of the screen's list (not the one inside a text field).
Finder _vertical() => find
    .descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _see(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _vertical());
  await tester.pumpAndSettle();
}

/// The screens of lot 3c used as a person would, on the two homes of the
/// fixture (EUR and CHF): all the tasks, the history, In season, the fields
/// of the form, what can be done to a task, its deletion.
void main() {
  for (final MapEntry(key: locale, value: l) in labels.entries) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<Lot3c> start(WidgetTester tester) async {
      await onPhone(tester);
      late Lot3c data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot3c.seed(r),
        photoSource: cameraWith(),
        notifier: FakeNotifier(),
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      return data;
    }

    testWidgets('Today has its tabs and the section In season, $locale', (
      tester,
    ) async {
      final data = await start(tester);
      expect(find.byKey(const Key('today-tabs')), findsOneWidget);
      await _see(tester, heading(t('In season (1)', 'De saison (1)')));
      expect(find.text('Treat the terrace'), findsOneWidget);
      expect(find.text('Second terrace'), findsNothing, reason: 'other home');
      // On All homes there is no list of all the tasks, and the section
      // names the home of each row.
      await stateOf(tester).showAllHomes();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('today-tabs')), findsNothing);
      await _see(tester, heading(t('In season (2)', 'De saison (2)')));
      expect(find.text('Second terrace'), findsOneWidget);
      expect(data.second, isNotEmpty);
    });

    testWidgets('All opens the list: a room filters it, the hidden ones show '
        'on demand, $locale', (tester) async {
      await start(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('today-tabs')),
          matching: find.text(t('All', 'Toutes')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TaskListScreen), findsOneWidget);
      expect(find.text('Main boiler service'), findsOneWidget);
      expect(find.text('Sweep the chimney'), findsNothing);
      expect(
        find.text(
          t(
            '1 task is hidden until its date gets closer.',
            '1 tâche est masquée jusqu\'à ce que sa date approche.',
          ),
        ),
        findsOneWidget,
      );
      await _see(tester, find.byKey(const Key('tasks-show-hidden')));
      await tester.tap(find.byKey(const Key('tasks-show-hidden')));
      await tester.pumpAndSettle();
      expect(find.text('Sweep the chimney'), findsOneWidget);
      expect(find.byKey(const Key('tasks-show-hidden')), findsNothing);

      await tester.drag(_vertical(), const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tasks-room')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main kitchen').last);
      await tester.pumpAndSettle();
      expect(find.text('Main smoke alarm'), findsOneWidget);
      expect(find.text('Main boiler service'), findsNothing);
    });

    testWidgets('a task of the list is done in one tap, with an undo bar, '
        '$locale', (tester) async {
      final data = await start(tester);
      await openTaskList(tester, data);
      final alarm = find.byKey(
        Key(
          'today-${(await stateOf(tester).repository.openTasks(data.main)).rows.firstWhere((e) => e.task.title == 'Main smoke alarm').occurrence.id}',
        ),
      );
      await tester.tap(
        find.descendant(of: alarm, matching: find.byType(FilledButton)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Main smoke alarm'), findsNothing);
      await tester.tap(find.text(t('Undo', 'Annuler')));
      await tester.pumpAndSettle();
      expect(find.text('Main smoke alarm'), findsOneWidget);
    });

    testWidgets('Done shows the history with the real cost, filtered, '
        '$locale', (tester) async {
      final data = await start(tester);
      await openTaskList(tester, data);
      await tester.tap(find.byKey(const Key('tasks-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.doneFilter).last);
      await tester.pumpAndSettle();
      expect(find.text('Change the smoke alarm battery'), findsOneWidget);
      expect(find.text('Check the extinguishers'), findsOneWidget);
      expect(find.text('Second oil check'), findsNothing, reason: 'other home');
      final total = tester.widget<Text>(find.byKey(const Key('history-total')));
      expect(total.data, startsWith(t('2 entries', '2 entrées')));
      expect(total.data, contains(t('real cost: €12.50', 'coût réel : 12,50')));
      expect(
        total.data,
        endsWith(t('entered on 1 entry', 'saisi sur 1 entrée')),
      );
      // The line says where and who, the pill what and when, then the cost.
      expect(
        find.text(
          t('Main kitchen · Main plumber', 'Main kitchen · Main plumber'),
        ),
        findsOneWidget,
      );
      expect(find.text(t('€12.50', '12,50\u00a0€')), findsOneWidget);

      await _see(tester, find.byKey(const Key('filters-toggle')));
      await tester.tap(find.byKey(const Key('filters-toggle')));
      await tester.pumpAndSettle();
      await _see(tester, find.byKey(const Key('history-outcome')));
      await tester.tap(find.byKey(const Key('history-outcome')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('Skipped', 'Ignorée')).last);
      await tester.pumpAndSettle();
      expect(find.text('Change the smoke alarm battery'), findsNothing);
      expect(find.text('Check the extinguishers'), findsOneWidget);
      await _see(tester, find.byKey(const Key('history-clear')));
      await tester.tap(find.byKey(const Key('history-clear')));
      await tester.pumpAndSettle();
      expect(find.text('Change the smoke alarm battery'), findsOneWidget);

      await _see(tester, find.byKey(const Key('history-query')));
      await tester.enterText(find.byKey(const Key('history-query')), 'battery');
      await _see(tester, find.byKey(const Key('history-apply')));
      await tester.tap(find.byKey(const Key('history-apply')));
      await tester.pumpAndSettle();
      expect(find.text('Check the extinguishers'), findsNothing);
      expect(find.text('Change the smoke alarm battery'), findsOneWidget);
      await _see(tester, find.byKey(const Key('history-query')));
      await tester.enterText(find.byKey(const Key('history-query')), 'zzz');
      await _see(tester, find.byKey(const Key('history-apply')));
      await tester.tap(find.byKey(const Key('history-apply')));
      await tester.pumpAndSettle();
      expect(
        find.text(t('Nothing matches.', 'Rien ne correspond.')),
        findsOneWidget,
      );
    });

    testWidgets('the page of a task: Done, Skip, Postpone and Undo, $locale', (
      tester,
    ) async {
      final data = await start(tester);
      final repository = stateOf(tester).repository;
      final id = await repository.createTask(
        data.main,
        TaskInput(title: 'Oil the hinges', dueOn: repository.today()),
      );
      await openScreen(tester, TaskScreen(homeId: data.main, taskId: id));
      await tester.tap(find.byKey(const Key('task-postpone')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      var open = (await repository.openOccurrencesOf(id)).single;
      expect(open.status, 'postponed');
      expect(open.dueOn, repository.today().addDays(1).iso);

      await tester.tap(find.byKey(const Key('task-skip')));
      await tester.pumpAndSettle();
      expect(await repository.openOccurrencesOf(id), isEmpty);
      expect(find.byKey(const Key('task-undo')), findsOneWidget);
      expect(find.byKey(const Key('task-done')), findsNothing);
      await tester.tap(find.byKey(const Key('task-undo')));
      await tester.pumpAndSettle();
      open = (await repository.openOccurrencesOf(id)).single;
      expect(open.status, 'postponed', reason: 'as it was');

      await tester.tap(find.byKey(const Key('task-done')));
      await tester.pumpAndSettle();
      expect(await repository.openOccurrencesOf(id), isEmpty);
      final closed = (await repository.occurrencesOf(id)).single;
      expect(closed.status, 'done');
      expect(find.byKey(const Key('task-undo')), findsOneWidget);
    });

    testWidgets('a done line opens its details: the day, the cost and the '
        'note are changed, $locale', (tester) async {
      final data = await start(tester);
      await openScreen(
        tester,
        TaskScreen(homeId: data.main, taskId: data.doneTask),
      );
      await _see(tester, find.byKey(Key('history-${data.doneOccurrence}')));
      await tester.tap(find.byKey(Key('history-${data.doneOccurrence}')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('cost-amount')), '20.5');
      await tester.enterText(
        find.byKey(const Key('occurrence-note')),
        'Two batteries',
      );
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      final o = (await stateOf(tester).repository
          .occurrence(data.doneOccurrence))!;
      expect(o.actualCost, '20.50');
      expect(o.completionNote, 'Two batteries');
      await _see(tester, find.text('Two batteries'));
      expect(find.text('Two batteries'), findsOneWidget);
    });

    testWidgets('the photos of the room of a task are shown, read only, '
        '$locale', (tester) async {
      final data = await start(tester);
      await openScreen(
        tester,
        TaskScreen(homeId: data.main, taskId: data.doneTask),
      );
      await _see(
        tester,
        heading(t('Photos of the room', 'Photos de la pièce')),
      );
      expect(find.byKey(const Key('photo-add')), findsNothing);
      expect(
        find.text(t('All photos of the room', 'Toutes les photos de la pièce')),
        findsOneWidget,
      );
      // A task without a room has no such heading.
      final bare = (await stateOf(tester).repository.openTasks(data.main)).rows
          .firstWhere((e) => e.task.title == 'Main gutters');
      await openScreen(
        tester,
        TaskScreen(homeId: data.main, taskId: bare.task.id),
      );
      expect(
        heading(t('Photos of the room', 'Photos de la pièce')),
        findsNothing,
      );
    });

    testWidgets('the new fields of the form are saved, $locale', (
      tester,
    ) async {
      final data = await start(tester);
      await openScreen(tester, TaskScreen(homeId: data.main));
      await tester.enterText(find.byKey(const Key('task-title')), 'Paint');
      await _see(tester, find.byKey(const Key('task-hide-days')));
      await tester.enterText(find.byKey(const Key('task-hide-days')), '7');
      await _see(tester, find.byKey(const Key('task-priority')));
      await tester.tap(find.byKey(const Key('task-priority')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('High', 'Haute')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('task-contractor')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main plumber').last);
      await tester.pumpAndSettle();
      await _see(tester, find.byKey(const Key('task-duration')));
      await tester.enterText(find.byKey(const Key('task-duration')), '2');
      await _see(tester, find.byKey(const Key('task-procedure')));
      await tester.enterText(
        find.byKey(const Key('task-procedure')),
        '1. Sand\n2. Paint',
      );
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      final task =
          (await stateOf(tester).repository.db
                  .select(stateOf(tester).repository.db.tasks)
                  .get())
              .firstWhere((x) => x.title == 'Paint');
      expect(task.priority, 'high');
      expect(task.contractorId, data.plumber);
      expect(task.estimatedMinutes, 120, reason: '2, in hours by default');
      expect(task.hideDaysBefore, 7);
      expect(task.procedure, '1. Sand\n2. Paint');
    });

    testWidgets('a room, an item and a contractor are added with the task, '
        '$locale', (tester) async {
      final data = await start(tester);
      await openScreen(tester, TaskScreen(homeId: data.main));
      await tester.enterText(find.byKey(const Key('task-title')), 'Grease');
      await tester.tap(find.byKey(const Key('task-room')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('Add a room…', 'Ajouter une pièce…')).last);
      await tester.pumpAndSettle();
      // Without a name for the new room, nothing is saved.
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          t('Give it a name or a title.', 'Donnez-lui un nom ou un titre.'),
        ),
        findsWidgets,
      );
      await tester.enterText(
        find.byKey(const Key('task-new-room-name')),
        'Porch',
      );
      await _see(tester, find.byKey(const Key('task-item')));
      await tester.tap(find.byKey(const Key('task-item')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(t('Add an item…', 'Ajouter un élément…')).last,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('task-new-item-name')),
        'Gate',
      );
      await _see(tester, find.byKey(const Key('task-contractor')));
      await tester.tap(find.byKey(const Key('task-contractor')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(t('Add a contractor…', 'Ajouter un intervenant…')).last,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('task-new-contractor-name')),
        'Fencer',
      );
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      final repository = stateOf(tester).repository;
      final room = (await repository.rooms(data.main))
          .firstWhere((r) => r.name == 'Porch');
      final item = (await repository.itemsOf(room.id)).single;
      final contractor = (await repository.contractors(data.main))
          .firstWhere((c) => c.name == 'Fencer');
      final task = (await repository.db.select(repository.db.tasks).get())
          .firstWhere((x) => x.title == 'Grease');
      expect(item.name, 'Gate');
      expect(task.roomId, room.id);
      expect(task.itemId, item.id);
      expect(task.contractorId, contractor.id);
      expect(task.homeId, data.main);
      expect(room.homeId, data.main);
      expect(contractor.homeId, data.main);
    });

    testWidgets('a task is deleted after a confirmation, $locale', (
      tester,
    ) async {
      final data = await start(tester);
      await openScreen(
        tester,
        TaskScreen(homeId: data.main, taskId: data.hiddenTask),
      );
      await _see(tester, find.byKey(const Key('task-delete')));
      await tester.tap(find.byKey(const Key('task-delete')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          t(
            'The task, its history and its files disappear from the screens.',
            'La tâche, son historique et ses fichiers disparaissent des écrans.',
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(t('Cancel', 'Annuler')));
      await tester.pumpAndSettle();
      expect(
        await stateOf(tester).repository.task(data.hiddenTask),
        isNotNull,
        reason: 'cancelled',
      );
      await tester.tap(find.byKey(const Key('task-delete')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, t('Delete', 'Supprimer')),
      );
      await tester.pumpAndSettle();
      expect(await stateOf(tester).repository.task(data.hiddenTask), isNull);
      expect(find.byType(TaskScreen), findsNothing);
    });

    testWidgets('a home that is archived is read only: no action, no delete, '
        '$locale', (tester) async {
      final data = await start(tester);
      await stateOf(tester).repository.archiveHome(data.second);
      await stateOf(tester).refresh();
      await openScreen(
        tester,
        TaskScreen(homeId: data.second, taskId: data.secondDoneTask),
      );
      expect(find.byKey(const Key('task-delete')), findsNothing);
      expect(find.byKey(const Key('task-done')), findsNothing);
      expect(find.byKey(const Key('task-undo')), findsNothing);
    });
  }
}
