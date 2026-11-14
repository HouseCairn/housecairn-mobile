// SPDX-License-Identifier: AGPL-3.0-only

// Screens of lot 2a: Today, Task, Homes (docs/plan.md, lot 2), at 360 px, in
// English and French, without golden files, with the fixture of two homes.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:housecairn_mobile/ui/today.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';
import 'support/fixture.dart';

late TwoHomes homes;

Future<void> twoHomes(Repository repository) async {
  homes = await TwoHomes.create(repository);
}

/// The two homes, and a task of every week, due today: done, it stays on
/// Today (due in a week), with a history and a preview of its next dates.
Future<void> twoHomesAndBins(Repository repository) async {
  await twoHomes(repository);
  await repository.createTask(
    homes.main,
    TaskInput(
      title: 'Put the bins out',
      dueOn: repository.today(),
      repeatMode: 'after_last',
      repeatUnit: 'week',
    ),
  );
}

/// The texts of the fixture, typed by a person, not by the code.
const fixtureTexts = [
  'Main home',
  'Second home',
  'Main smoke alarm',
  'Main boiler service',
  'Main gutters',
  'Second smoke alarm',
  'Second boiler service',
  'Second gutters',
  'Fix the tap',
  'Put the bins out',
  'EUR',
  'CHF',
  '1',
];

Finder selector() => find.byKey(const Key('home-selector'));

/// The scrollable of the list of [screen] (not one of its text fields).
Finder scrollableOf(Finder screen) => find
    .descendant(
      of: find.descendant(of: screen, matching: find.byType(ListView)).first,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> openMore(WidgetTester tester, String label, String entry) async {
  await tester.tap(destination(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(entry));
  await tester.pumpAndSettle();
}

void main() {
  const labels = {
    'en': (today: 'Today', more: 'More', homes: 'Homes'),
    'fr': (today: "Aujourd'hui", more: 'Plus', homes: 'Logements'),
  };

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    final en = locale == 'en';
    String t(String english, String french) => en ? english : french;

    testWidgets(
      'a task with only a title is saved, done in one tap, undone ($locale)',
      (tester) async {
        await onPhone(tester);
        final state = await pumpApp(tester, locale: locale);
        expect(
          state.homes,
          hasLength(1),
          reason: 'the first home, made at start',
        );
        expect(state.homes.single.name, t('My home', 'Ma maison'));
        expect(selector(), findsNothing);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('task-title')),
          'Fix the tap',
        );
        await tester.tap(find.text(t('Save', 'Enregistrer')));
        await tester.pumpAndSettle();
        expect(find.text('Fix the tap'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.check_circle_outline));
        await tester.pumpAndSettle();
        expect(find.text('Fix the tap'), findsNothing);
        final undo = find.descendant(
          of: find.byType(SnackBar),
          matching: find.text(t('Undo', 'Annuler')),
        );
        expect(undo, findsOneWidget);
        await tester.tap(undo);
        await tester.pumpAndSettle();
        expect(find.text('Fix the tap'), findsOneWidget);
      },
    );

    testWidgets('a task without a title is not saved ($locale)', (
      tester,
    ) async {
      await onPhone(tester);
      final state = await pumpApp(tester, locale: locale);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          t('Give it a name or a title.', 'Donnez-lui un nom ou un titre.'),
        ),
        findsOneWidget,
      );
      expect(await state.repository.todayEntries(), isEmpty);
    });

    testWidgets(
      'Today on All homes names the home of each row; on one home, only its tasks ($locale)',
      (tester) async {
        await onPhone(tester);
        final state = await pumpApp(tester, locale: locale, seed: twoHomes);
        expect(selector(), findsOneWidget);
        expect(state.todayAllHomes, isTrue, reason: 'until a home is chosen');
        expect(find.text('Main smoke alarm'), findsOneWidget);
        expect(find.text('Second smoke alarm'), findsOneWidget);
        // Every row shown names its home; both homes have rows.
        final subtitles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .map((tile) => (tile.subtitle! as Text).data!)
            .toList();
        expect(subtitles, isNotEmpty);
        expect(
          subtitles.every(
            (s) =>
                s.startsWith('Main home · ') || s.startsWith('Second home · '),
          ),
          isTrue,
          reason: '$subtitles',
        );
        expect(subtitles.any((s) => s.startsWith('Main home · ')), isTrue);
        expect(subtitles.any((s) => s.startsWith('Second home · ')), isTrue);
        final rows = await state.repository.todayEntries();
        expect(rows, hasLength(6));
        expect(rows.where((e) => e.home.id == homes.second), hasLength(3));

        await tester.tap(selector());
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(CheckedPopupMenuItem<String>, 'Second home'),
        );
        await tester.pumpAndSettle();
        expect(find.text('Main smoke alarm'), findsNothing);
        expect(find.text('Second smoke alarm'), findsOneWidget);
        expect(find.textContaining('Second home · '), findsNothing);
        expect(state.current!.id, homes.second);
      },
    );

    testWidgets(
      'the selector hides with one active home; archive, unarchive, delete ($locale)',
      (tester) async {
        await onPhone(tester);
        final state = await pumpApp(tester, locale: locale, seed: twoHomes);
        await openMore(tester, l.more, l.homes);
        await tester.tap(find.text('Second home'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t('Archive', 'Archiver')));
        await tester.pumpAndSettle();
        expect(state.activeHomes, hasLength(1));
        expect(find.text(t('Archived', 'Archivés')), findsOneWidget);
        await tester.tap(destination(l.today));
        await tester.pumpAndSettle();
        expect(selector(), findsNothing);
        expect(find.text('Second smoke alarm'), findsNothing);

        await tester.tap(destination(l.more));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Second home'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t('Unarchive', 'Désarchiver')));
        await tester.pumpAndSettle();
        expect(state.activeHomes, hasLength(2));

        await tester.tap(find.text('Second home'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t('Delete', 'Supprimer')));
        await tester.pumpAndSettle();
        final confirm = find.widgetWithText(
          TextButton,
          t('Delete for good', 'Supprimer définitivement'),
        );
        expect(tester.widget<TextButton>(confirm).onPressed, isNull);
        final typed = find.byKey(const Key('home-delete-name'));
        await tester.enterText(typed, 'second home');
        await tester.pump();
        expect(tester.widget<TextButton>(confirm).onPressed, isNull);
        await tester.enterText(typed, 'Second home');
        await tester.pump();
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(state.homes.map((h) => h.id), [homes.main]);
        expect(find.text('Second home'), findsNothing);
      },
    );

    testWidgets('a new home, then renamed ($locale)', (tester) async {
      await onPhone(tester);
      final state = await pumpApp(tester, locale: locale);
      await openMore(tester, l.more, l.homes);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('home-name')), 'Second home');
      await tester.enterText(find.byKey(const Key('home-currency')), 'chf');
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      expect(state.activeHomes, hasLength(2));
      expect(
        state.homes.firstWhere((h) => h.name == 'Second home').currency,
        'CHF',
      );
      await tester.tap(find.text('Second home'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('home-name')), 'Flat');
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      expect(find.text('Flat'), findsOneWidget);
    });

    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'every screen of lot 2a fits 360 px at text scale $scale, its strings in the ARB file ($locale)',
        (tester) async {
          await onPhone(tester, textScale: scale);
          final state = await pumpApp(
            tester,
            locale: locale,
            seed: twoHomesAndBins,
          );
          final offending = <String>[];
          void check(String screen) {
            expect(tester.takeException(), isNull, reason: screen);
            offending.addAll(
              textsNotInArb(
                tester,
                locale,
                data: fixtureTexts,
              ).map((text) => '$screen: $text'),
            );
          }

          check('Today');
          await tester.tap(selector());
          await tester.pumpAndSettle();
          check('home selector');
          await tester.tap(
            find.widgetWithText(
              CheckedPopupMenuItem<String>,
              t('All homes', 'Tous les logements'),
            ),
          );
          await tester.pumpAndSettle();

          // A repeating task, done once: its screen has a history and a
          // preview of the next dates. Done through the repository here (the
          // one tap is tested above); the screen is opened as Today opens it.
          final repository = state.repository;
          final binsRow = (await repository.todayEntries()).firstWhere(
            (e) => e.task.title == 'Put the bins out',
          );
          await repository.complete(binsRow.occurrence.id);
          await state.refresh();
          await tester.pumpAndSettle();
          unawaited(
            Navigator.of(tester.element(find.byType(TodayScreen))).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    TaskScreen(homeId: homes.main, taskId: binsRow.task.id),
              ),
            ),
          );
          await tester.pumpAndSettle();
          check('Task');
          final list = find
              .descendant(
                of: find.byType(TaskScreen),
                matching: find.byType(ListView),
              )
              .first;
          final history = find.text(t('History', 'Historique'));
          final nextDates = find.text(t('Next dates', 'Prochaines dates'));
          var sawNextDates = nextDates.evaluate().isNotEmpty;
          for (var i = 0; i < 12 && history.evaluate().isEmpty; i++) {
            await tester.drag(list, const Offset(0, -250));
            await tester.pumpAndSettle();
            sawNextDates |= nextDates.evaluate().isNotEmpty;
          }
          expect(history, findsOneWidget);
          check('Task, history');
          expect(sawNextDates, isTrue, reason: 'the preview of five dates');
          await back(tester);

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          check('New task');
          await back(tester);
          await tester.pumpAndSettle();

          await tester.tap(
            find
                .byTooltip(t('More actions', 'Autres actions'))
                .hitTestable()
                .first,
          );
          await tester.pumpAndSettle();
          check('row menu');
          await tester.tap(
            find.text(t('Skip this time', 'Ignorer cette fois')),
          );
          await tester.pumpAndSettle();
          check('after skip');

          await openMore(tester, l.more, l.homes);
          check('Homes');
          await tester.tap(find.text('Second home'));
          await tester.pumpAndSettle();
          check('Home');
          await tester.tap(find.text(t('Delete', 'Supprimer')));
          await tester.pumpAndSettle();
          check('Delete a home');
          expect(offending, isEmpty);
        },
      );
    }
  }
}
