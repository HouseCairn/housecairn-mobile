// SPDX-License-Identifier: AGPL-3.0-only

// The screens of the interactive guide on the phone (web ADR 0084, lot A3):
// the list of the five scenarios and their progress, the page of a scenario
// with Open, Fill in for me and Mark as done, the catching up of the earlier
// scenarios, the banner of the example home, its deletion in one dialog, the
// entries (More, Help, Guide and the card of an empty Today), the mark in
// My homes and the selector without it; a walk of scenario 1 to Done, in
// English and in French.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/ui/guide_screens.dart';
import 'package:housecairn_mobile/ui/homes_screen.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());
final glossary = parseGlossary(File('design/glossary.json').readAsStringSync());

final Map<String, AppLocalizations> words = {
  'en': AppLocalizationsEn(),
  'fr': AppLocalizationsFr(),
};

/// A text of the file in [language], its terms written from the glossary.
String said(Object? value, String language) => [
  for (final p in guidePieces(
    '${guide.text(value, language)}',
    glossary,
    language,
  ))
    p.text,
].join();

GuideScenario scenario(String id) =>
    guide.scenarios.firstWhere((s) => s.id == id);

/// The list of the screen, scrolled from its top until [finder] shows whole.
Future<void> see(WidgetTester tester, Finder finder) async {
  if (finder.hitTestable().evaluate().isEmpty) {
    final list = find.byType(Scrollable).last;
    await tester.drag(list, const Offset(0, 4000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(finder, 200, scrollable: list);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// The text of the field of key [key].
String fieldText(WidgetTester tester, String key) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

Future<void> tapSeen(WidgetTester tester, Finder finder) async {
  await see(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// More, then Help, Guide.
Future<void> openGuideFromMore(WidgetTester tester, String locale) async {
  await tester.tap(destination(words[locale]!.navMore));
  await tester.pumpAndSettle();
  await tapSeen(tester, find.byKey(const Key('more-guide')));
}

/// The pill of progress of the scenario [id] in the list of the guide.
Finder progressOf(String id, String label) => find.descendant(
  of: find.byKey(Key('guide-scenario-$id')),
  matching: find.text(label),
);

void main() {
  for (final locale in ['en', 'fr']) {
    final l = words[locale]!;
    final language = guide.languageFor(locale);

    group('The guide ($locale)', () {
      testWidgets('More, Help, Guide lists the five scenarios at 0', (
        tester,
      ) async {
        await onPhone(tester);
        await pumpApp(tester, locale: locale);
        await openGuideFromMore(tester, locale);
        expect(find.text(l.guide), findsWidgets);
        expect(find.text(l.guideLead), findsOneWidget);
        for (final (i, s) in guide.scenarios.indexed) {
          final row = find.byKey(Key('guide-scenario-${s.id}'));
          await see(tester, row);
          expect(
            find.descendant(
              of: row,
              matching: find.text(
                l.guideNumbered(i + 1, said(s.raw['title'], language)),
              ),
            ),
            findsOneWidget,
          );
          final counted = s.steps.where((st) => st.raw['optional'] != true);
          expect(
            progressOf(s.id, l.guideProgress(0, counted.length)),
            findsOneWidget,
            reason: s.id,
          );
        }
        // No example home: no card, no delete.
        expect(find.byKey(const Key('guide-example-home')), findsNothing);
        expect(find.byKey(const Key('example-delete')), findsNothing);
      });

      testWidgets('an optional step does not count in the progress', (
        tester,
      ) async {
        // Scenario 3 has four steps, one optional: three count.
        final s = scenario('recurring-task');
        expect(s.steps, hasLength(4));
        await onPhone(tester);
        await pumpApp(tester, locale: locale);
        await openGuideFromMore(tester, locale);
        await see(
          tester,
          find.byKey(const Key('guide-scenario-recurring-task')),
        );
        expect(progressOf(s.id, l.guideProgress(0, 3)), findsOneWidget);
      });

      testWidgets('scenario 1, from Open to Done, the texts of the file', (
        tester,
      ) async {
        await onPhone(tester);
        final state = await pumpApp(tester, locale: locale);
        await openGuideFromMore(tester, locale);
        await tapSeen(
          tester,
          find.byKey(const Key('guide-scenario-create-home')),
        );
        final first = scenario('create-home');
        expect(
          find.text(l.guideNumbered(1, said(first.raw['title'], language))),
          findsWidgets,
        );
        expect(find.text(said(first.raw['summary'], language)), findsOneWidget);
        for (final step in first.steps) {
          await see(tester, find.byKey(Key('guide-step-${step.id}')));
          expect(
            find.text(said(step.raw['explain'], language), findRichText: true),
            findsOneWidget,
            reason: step.id,
          );
        }
        // Before the example home: only the first step has a button; the
        // others say to add the home first.
        expect(find.byKey(const Key('guide-open-create-home.2')), findsNothing);
        expect(find.text(l.guideNeedsHome), findsNWidgets(2));

        // Step 1: the form of a new home, filled in with the example.
        await tapSeen(
          tester,
          find.byKey(const Key('guide-open-create-home.1')),
        );
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byKey(const Key('home-guide-notice')), findsOneWidget);
        final name = '${guide.text(guide.home['name'], language)}';
        expect(fieldText(tester, 'home-name'), name);
        await tester.tap(find.text(l.save));
        await tester.pumpAndSettle();

        // Back on the scenario: step 1 ticked, the example home made.
        expect(find.byType(HomeScreen), findsNothing);
        expect(state.exampleHome?.name, name);
        expect(
          state.homes.map((h) => h.id),
          isNot(contains(state.exampleHome!.id)),
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('guide-step-create-home.1')),
            matching: find.text(l.guideStepDone),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('guide-open-create-home.1')), findsNothing);

        // Step 2 opens the page of the example home, with its banner.
        await tapSeen(
          tester,
          find.byKey(const Key('guide-open-create-home.2')),
        );
        expect(find.byKey(const Key('example-banner')), findsOneWidget);
        await back(tester);

        // Steps 2 and 3 are ticked by hand.
        await tapSeen(
          tester,
          find.byKey(const Key('guide-tick-create-home.2')),
        );
        await tapSeen(
          tester,
          find.byKey(const Key('guide-tick-create-home.3')),
        );
        for (final step in first.steps) {
          await see(tester, find.byKey(Key('guide-step-${step.id}')));
          expect(
            find.descendant(
              of: find.byKey(Key('guide-step-${step.id}')),
              matching: find.text(l.guideStepDone),
            ),
            findsOneWidget,
            reason: step.id,
          );
        }
        expect(find.byKey(const Key('guide-tick-create-home.2')), findsNothing);
        await back(tester);
        expect(progressOf('create-home', l.guideScenarioDone), findsOneWidget);
        await see(tester, find.byKey(const Key('guide-example-home')));
        expect(find.byKey(const Key('guide-example-home')), findsOneWidget);
      });
    });
  }

  group('Fill in for me', () {
    testWidgets('fills the room of step 2.1, which ticks once saved', (
      tester,
    ) async {
      await onPhone(tester);
      late String example;
      final state = await pumpApp(
        tester,
        seed: (r) async =>
            example = await r.createExampleHome(guide, language: 'en'),
      );
      await openGuideFromMore(tester, 'en');
      await tapSeen(
        tester,
        find.byKey(const Key('guide-scenario-rooms-equipment')),
      );
      await tapSeen(
        tester,
        find.byKey(const Key('guide-fill-rooms-equipment.1')),
      );
      expect(find.byType(RoomFormScreen), findsOneWidget);
      expect(find.byKey(const Key('example-banner')), findsOneWidget);
      expect(fieldText(tester, 'room-name'), 'Kitchen');
      // Nothing is saved until the button is pressed.
      expect(await state.repository.rooms(example), isEmpty);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final rooms = await state.repository.rooms(example);
      expect(
        [for (final r in rooms) (r.name, r.kind)],
        [('Kitchen', 'kitchen')],
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('guide-step-rooms-equipment.1')),
          matching: find.text('Done'),
        ),
        findsOneWidget,
      );
      // Open leaves the same form empty.
      await tapSeen(
        tester,
        find.byKey(const Key('guide-open-rooms-equipment.2')),
      );
      expect(fieldText(tester, 'room-name'), isEmpty);
    });

    testWidgets('a form of a real home ignores the values', (tester) async {
      await onPhone(tester);
      final state = await pumpApp(tester);
      final real = state.current!.id;
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).last,
      );
      navigator.push(
        hcRoute(
          RoomFormScreen(
            homeId: real,
            fill: const {'name': 'Kitchen', 'kind': 'kitchen'},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'room-name'), isEmpty);
      expect(find.byKey(const Key('example-banner')), findsNothing);
    });

    testWidgets('a step on a row already there opens the form of that row', (
      tester,
    ) async {
      await onPhone(tester);
      late String example;
      final state = await pumpApp(
        tester,
        seed: (r) async {
          example = await r.createExampleHome(guide, language: 'en');
          await r.fillExample(guide, example, upTo: 3, language: 'en');
        },
      );
      final links = await stepLinks(
        state.repository,
        guide,
        state.exampleHome,
        'en',
      );
      // 2.4, the brand: the machine is there, its form is the one opened.
      final machine = (await state.repository.itemsOfHome(example)).single;
      final brand = links['rooms-equipment.4']!.fill!();
      expect(brand, isA<Widget>());
      expect((brand as dynamic).itemId, machine.id);
      expect((brand as dynamic).fill, {'brand': 'Brewmark', 'model': 'BM-200'});
      // 5.2, a budget line, waits for its project.
      expect(links['project-budget.2']!.open, isNull);
      expect(links['project-budget.2']!.fill, isNull);
    });

    testWidgets('the quote of step 5.3 adds its contractor with it', (
      tester,
    ) async {
      await onPhone(tester);
      late String example;
      final state = await pumpApp(
        tester,
        seed: (r) async {
          example = await r.createExampleHome(guide, language: 'en');
          await r.fillExample(guide, example, upTo: 5, language: 'en');
          final project = await r.createProject(
            example,
            const ProjectInput(title: 'Redo the bathroom'),
          );
          await r.createLine(
            project,
            const LineInput(label: 'Plumber (shower)', planned: '3000'),
          );
        },
      );
      await openGuideFromMore(tester, 'en');
      await tapSeen(
        tester,
        find.byKey(const Key('guide-scenario-project-budget')),
      );
      await tapSeen(
        tester,
        find.byKey(const Key('guide-fill-project-budget.3')),
      );
      expect(find.text('Bath Services'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final contractors = await state.repository.contractors(example);
      expect([for (final c in contractors) c.name], ['Bath Services']);
      expect(contractors, hasLength(1));
    });
  });

  group('Add what the earlier scenarios make', () {
    testWidgets('makes the example home and ticks nothing ahead', (
      tester,
    ) async {
      await onPhone(tester);
      final state = await pumpApp(tester);
      await openGuideFromMore(tester, 'en');
      await tapSeen(
        tester,
        find.byKey(const Key('guide-scenario-recurring-task')),
      );
      expect(
        find.text(AppLocalizationsEn().guideCatchUpNoHome),
        findsOneWidget,
      );
      await tapSeen(tester, find.byKey(const Key('guide-catch-up')));
      final example = state.exampleHome!;
      final ticks = await state.repository.guideTicks(example.id);
      expect(ticks, containsAll(['create-home.1', 'rooms-equipment.4']));
      expect(ticks.where((t) => t.startsWith('recurring-task')), isEmpty);
      expect(find.byKey(const Key('guide-catch-up')), findsNothing);
      expect(find.text(AppLocalizationsEn().guideCaughtUp), findsOneWidget);
    });
  });

  group('The example home', () {
    Future<AppState> withExample(WidgetTester tester, {String? second}) =>
        pumpApp(
          tester,
          seed: (r) async {
            await r.createHome(name: 'Main house');
            if (second != null) await r.createHome(name: second);
            await r.createExampleHome(guide, language: 'en');
          },
        );

    testWidgets('Delete the example home: one dialog, Cancel keeps it', (
      tester,
    ) async {
      await onPhone(tester);
      final state = await withExample(tester);
      await openGuideFromMore(tester, 'en');
      await tapSeen(tester, find.byKey(const Key('example-delete')));
      final l = AppLocalizationsEn();
      expect(find.text(l.exampleDeleteTitle), findsOneWidget);
      expect(find.text(l.exampleDeleteBody), findsOneWidget);
      // No name to type.
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();
      expect(state.exampleHome, isNotNull);
      await tapSeen(tester, find.byKey(const Key('example-delete')));
      await tester.tap(find.text(l.delete));
      await tester.pumpAndSettle();
      expect(state.exampleHome, isNull);
      expect(await state.repository.exampleHome(), isNull);
      expect(find.text(l.exampleDeleted), findsOneWidget);
      expect(find.byKey(const Key('guide-example-home')), findsNothing);
      expect(state.homes.map((h) => h.name), ['Main house']);
    });

    testWidgets(
      'its banner, on its screens only, deletes it back to the guide',
      (tester) async {
        await onPhone(tester);
        final state = await withExample(tester);
        await openGuideFromMore(tester, 'en');
        await tapSeen(tester, find.byKey(const Key('guide-example-home')));
        expect(find.byKey(const Key('example-banner')), findsOneWidget);
        // No Archive nor Delete at the bottom: the banner deletes it.
        expect(find.byKey(const Key('home-archive')), findsNothing);
        expect(find.byKey(const Key('home-delete')), findsNothing);
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('example-banner')),
            matching: find.byKey(const Key('example-delete')),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(state.exampleHome, isNull);
        expect(find.byType(GuideScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);

        // The page of a real home has no banner.
        await back(tester);
        await tapSeen(tester, find.byKey(const Key('more-homes')));
        await tester.tap(find.text('Main house'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('example-banner')), findsNothing);
        expect(find.byKey(const Key('home-delete')), findsOneWidget);
      },
    );

    testWidgets('My homes marks it, the selector does not list it', (
      tester,
    ) async {
      await onPhone(tester);
      final state = await withExample(tester, second: 'Cabin');
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      await tapSeen(tester, find.byKey(const Key('more-homes')));
      final row = find.byKey(const Key('homes-example'));
      expect(
        find.descendant(of: row, matching: find.text('Example house')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text('Example')),
        findsOneWidget,
      );
      await back(tester);
      await tester.tap(destination('Today'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-selector')));
      await tester.pumpAndSettle();
      expect(find.text('Cabin'), findsWidgets);
      expect(find.text('Example house'), findsNothing);
      expect(state.activeHomes, hasLength(2));
    });
  });

  group('Entries', () {
    testWidgets('an empty Today offers the guide', (tester) async {
      await onPhone(tester);
      await pumpApp(tester);
      final l = AppLocalizationsEn();
      await see(tester, find.byKey(const Key('today-guide')));
      expect(find.text(l.todayGuideText), findsOneWidget);
      await tester.tap(find.byKey(const Key('today-guide-open')));
      await tester.pumpAndSettle();
      expect(find.byType(GuideScreen), findsOneWidget);
    });

    testWidgets('the card goes as soon as Today shows a task', (tester) async {
      await onPhone(tester);
      await pumpApp(
        tester,
        seed: (r) async {
          final home = await r.createHome(name: 'Main house');
          await r.createTask(home, const TaskInput(title: 'Bleed radiators'));
        },
      );
      expect(find.text('Bleed radiators'), findsOneWidget);
      expect(find.byKey(const Key('today-guide')), findsNothing);
    });
  });
}
