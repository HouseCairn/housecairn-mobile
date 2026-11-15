// SPDX-License-Identifier: AGPL-3.0-only

// The page of a task (design lot D2, `tasks/task_detail.html`): it opens to
// read, in the order of the web, and each action of its row follows the rules
// of the web (`tasks/services.py`): Done and Skip this time close the
// occurrence and make the next one by the repetition; Postpone moves the open
// one and keeps its first date; Edit the task opens the form.

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3c.dart';
import 'support/screens_2b.dart';

void main() {
  for (final MapEntry(key: locale, value: _) in labels.entries) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<(Lot3c, Repository)> start(WidgetTester tester) async {
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
      return (data, state.repository);
    }

    /// A task every month on fixed dates, due today, opened on its page.
    Future<(String, Repository, Day)> monthly(
      WidgetTester tester, {
      String mode = 'fixed',
    }) async {
      final (data, repository) = await start(tester);
      final today = repository.today();
      final id = await repository.createTask(
        data.main,
        TaskInput(
          title: 'Clean the filter',
          dueOn: today,
          repeatMode: mode,
          repeatUnit: 'month',
          roomId: data.kitchen,
          procedure: 'Rinse it under the tap.',
          estimatedMinutes: 90,
          hideDaysBefore: 2,
        ),
      );
      await openScreen(tester, TaskScreen(homeId: data.main, taskId: id));
      return (id, repository, today);
    }

    testWidgets('a task opens to read, in the order of the web, $locale', (
      tester,
    ) async {
      await monthly(tester);
      // No field: the page is not a form.
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const Key('task-save')), findsNothing);
      // The pills, the title, the place as a link, the actions in order.
      expect(find.text(t('Every month', 'Tous les mois')), findsWidgets);
      expect(find.text('Clean the filter'), findsOneWidget);
      expect(find.byKey(const Key('task-room-link')), findsOneWidget);
      final order = [
        'task-done',
        'task-postpone',
        'task-skip',
        'task-edit',
      ].map((k) => tester.getTopLeft(find.byKey(Key(k))));
      final xs = [for (final o in order) o.dx + o.dy * 10000];
      expect(xs, [...xs]..sort(), reason: 'Done, Postpone, Skip, Edit');
      expect(
        tester.widget(find.byKey(const Key('task-done'))),
        isA<FilledButton>(),
        reason: 'Done is the primary action',
      );
      expect(find.text(t('Edit the task', 'Modifier la tâche')), findsOne);
      // The values of When and Details, as label and value rows.
      expect(find.text(t('Due on', 'Échéance')), findsOneWidget);
      expect(find.text(t('Then', 'Ensuite')), findsOneWidget);
      expect(
        find.text(t('2 days before the date', '2 jours avant la date')),
        findsOneWidget,
      );
      // The sections, in the order of the web.
      // The list is built as it scrolls: the headings are read on the way.
      final list = find
          .descendant(
            of: find.byType(TaskPage),
            matching: find.byType(Scrollable),
          )
          .first;
      final headings = <String>[];
      var sawDuration = false;
      for (var i = 0; i < 20; i++) {
        for (final h in tester.widgetList<HcSectionHeading>(
          find.byType(HcSectionHeading),
        )) {
          if (!headings.contains(h.text)) headings.add(h.text);
        }
        sawDuration |= find.text('1 h 30').evaluate().isNotEmpty;
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      expect(headings.take(4), [
        t('When', 'Quand'),
        t('How to do it', 'Comment faire'),
        t('Details', 'Détails'),
        t('Materials', 'Fournitures'),
      ]);
      expect(sawDuration, isTrue, reason: 'the duration as the web says it');
    });

    testWidgets('Done closes the occurrence and makes the next one, counted '
        'from the day it is done, $locale', (tester) async {
      final (id, repository, today) = await monthly(tester, mode: 'after_last');
      await tester.tap(find.byKey(const Key('task-done')));
      await tester.pumpAndSettle();
      final all = await repository.occurrencesOf(id);
      final done = all.firstWhere((o) => o.status == 'done');
      expect(done.completedOn, today.iso);
      final next = (await repository.openOccurrencesOf(id)).single;
      expect(next.dueOn, today.addMonths(1).iso);
      // The page follows: the next one is open, Done is there again.
      expect(find.byKey(const Key('task-done')), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget, reason: 'with Undo');
    });

    testWidgets('Skip this time closes it without doing it, and the next one '
        'comes as for Done, $locale', (tester) async {
      final (id, repository, today) = await monthly(tester);
      await tester.tap(find.byKey(const Key('task-skip')));
      await tester.pumpAndSettle();
      final all = await repository.occurrencesOf(id);
      final skipped = all.firstWhere((o) => o.status == 'skipped');
      expect(skipped.completedOn, isNull, reason: 'not done');
      final next = (await repository.openOccurrencesOf(id)).single;
      expect(next.dueOn, today.addMonths(1).iso, reason: 'fixed: due + 1');
      expect(find.byKey(const Key('task-done')), findsOneWidget);
    });

    testWidgets('Postpone moves the date and keeps the first one, $locale', (
      tester,
    ) async {
      final (id, repository, today) = await monthly(tester);
      await tester.tap(find.byKey(const Key('task-postpone')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      var open = (await repository.openOccurrencesOf(id)).single;
      expect(open.status, 'postponed');
      expect(open.dueOn, today.addDays(1).iso, reason: 'tomorrow by default');
      expect(open.postponedFrom, today.iso);
      // Postponed again: the first date stays (`postponed_from`).
      await repository.postpone(open.id, today.addDays(5));
      await stateOf(tester).refresh();
      await tester.pumpAndSettle();
      open = (await repository.openOccurrencesOf(id)).single;
      expect(open.postponedFrom, today.iso);
      expect(
        find.text(t('Postponed from', 'Reportée depuis le')),
        findsOneWidget,
      );
      // A date in the past is refused, as on the web.
      await expectLater(
        repository.postpone(open.id, today.addDays(-1)),
        throwsA(isA<Refused>()),
      );
    });

    testWidgets('Edit the task opens the form, whose title is not cut, and '
        'Save comes back to the page, $locale', (tester) async {
      final (id, repository, _) = await monthly(tester);
      await tester.tap(find.byKey(const Key('task-edit')));
      await tester.pumpAndSettle();
      expect(find.byType(TaskFormScreen), findsOneWidget);
      expect(find.text(t('Edit the task', 'Modifier la tâche')), findsOne);
      await tester.enterText(find.byKey(const Key('task-title')), 'Wash it');
      await saveTask(tester);
      expect(find.byType(TaskFormScreen), findsNothing);
      expect(find.text('Wash it'), findsOneWidget, reason: 'the page, read');
      expect((await repository.task(id))!.title, 'Wash it');
    });

    testWidgets('the form opens its sections on what the task holds, '
        '$locale', (tester) async {
      await monthly(tester);
      await tester.tap(find.byKey(const Key('task-edit')));
      await tester.pumpAndSettle();
      // Repeat holds a rule, How to do it a procedure: open. Who: folded.
      await seeInTaskForm(tester, find.byKey(const Key('task-interval')));
      expect(find.byKey(const Key('task-interval')), findsOneWidget);
      expect(find.byKey(const Key('task-priority')), findsNothing);
      await unfoldTaskSection(tester, 'task-section-who');
      expect(find.byKey(const Key('task-priority')), findsOneWidget);
      await seeInTaskForm(tester, find.byKey(const Key('task-cancel')));
      await tester.tap(find.byKey(const Key('task-cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(TaskFormScreen), findsNothing);
      expect(find.byKey(const Key('task-done')), findsOneWidget);
    });
  }
}
