// SPDX-License-Identifier: AGPL-3.0-only

// The tabs, the search and the sheet "Filters (n)" of the lists (design lot
// D13): All, Done (the history) and Stock, with the one component they share.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/filters.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/search.dart';
import 'package:housecairn_mobile/ui/task_list_screen.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'adaptive_test.dart' show harness;
import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3a.dart';
import 'support/lot3c.dart';
import 'support/screens_2b.dart';

Finder _tab(String key, String label) =>
    find.descendant(of: find.byKey(Key(key)), matching: find.text(label));

String _typed(WidgetTester tester, String key) => tester
    .widget<TextField>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(TextField),
      ),
    )
    .controller!
    .text;

Future<void> _search(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pump(hcSearchDelay);
  await tester.pumpAndSettle();
}

void main() {
  group('the text a search compares', () {
    test('has no case and no accents, as a person types without them', () {
      expect(
        foldForSearch('École ÉTÉ Œuvre Straße'),
        'ecole ete oeuvre strasse',
      );
      expect(foldForSearch('Plain text 42'), 'plain text 42');
      expect(
        matchesSearch(foldForSearch('ecole'), [foldForSearch('École')]),
        isTrue,
      );
      expect(matchesSearch('', ['anything']), isTrue);
      expect(matchesSearch('xyz', ['anything']), isFalse);
    });
  });

  group('the search field', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('on ${platform.name} searches after a pause, at once on '
          'Enter and when emptied, and the sheet counts', (tester) async {
        final semantics = tester.ensureSemantics();
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final asked = <String>[];
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        var criteria = 0;
        await tester.pumpWidget(
          harness(
            StatefulBuilder(
              builder: (context, setState) => HcFilterBar(
                tabLabels: const ['One', 'Two'],
                currentTab: 0,
                onTab: (_) {},
                searchController: controller,
                searchKey: const Key('field'),
                searchLabel: 'Search by name',
                onSearch: asked.add,
                filterCount: criteria,
                filtersKey: const Key('open'),
                onFilters: () => showHcFilterSheet(
                  context,
                  count: () => criteria,
                  onClear: () => setState(() => criteria = 0),
                  builder: (context, refresh) => TextButton(
                    key: const Key('one-more'),
                    onPressed: () {
                      setState(() => criteria++);
                      refresh();
                    },
                    child: const Text('One more'),
                  ),
                ),
              ),
            ),
          ),
        );
        // Typed: nothing asked before the pause, one search after it.
        await tester.enterText(find.byKey(const Key('field')), 'bo');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(find.byKey(const Key('field')), 'boi');
        await tester.pump(hcSearchDelay - const Duration(milliseconds: 10));
        expect(asked, isEmpty);
        await tester.pump(const Duration(milliseconds: 20));
        expect(asked, ['boi']);
        // Enter: at once.
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(asked, ['boi', 'boi']);
        // The button of the field empties it and searches again.
        await tester.tap(find.byKey(const Key('search-clear')));
        await tester.pump();
        expect(controller.text, isEmpty);
        expect(asked.last, '');
        // What a screen reader says of the field, and no Search button.
        expect(find.bySemanticsLabel(RegExp('Search by name')), findsWidgets);
        expect(find.widgetWithText(FilledButton, 'Search'), findsNothing);
        expect(find.widgetWithText(OutlinedButton, 'Search'), findsNothing);
        expect(find.widgetWithText(TextButton, 'Search'), findsNothing);

        // The sheet counts, clears, and the button follows.
        expect(find.text('Filters'), findsOneWidget);
        await tester.tap(find.byKey(const Key('open')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('one-more')));
        await tester.tap(find.byKey(const Key('one-more')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const Key('filters-sheet-title')))
              .data,
          'Filters (2)',
        );
        await tester.tap(find.byKey(const Key('filters-sheet-done')));
        await tester.pumpAndSettle();
        expect(find.text('Filters (2)'), findsOneWidget);
        semantics.dispose();
      });
    }
  });

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    group('All and Done, $locale', () {
      Future<Lot3c> start(WidgetTester tester, {double scale = 1}) async {
        await onPhone(tester, textScale: scale);
        late Lot3c data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot3c.seed(r),
          notifier: FakeNotifier(),
        );
        await state.choose(data.main);
        await tester.pumpAndSettle();
        await openTaskList(tester, data);
        return data;
      }

      testWidgets('the tabs are To do and Done, and neither is a list box', (
        tester,
      ) async {
        await start(tester);
        expect(find.byType(DropdownButtonFormField<bool>), findsNothing);
        expect(_tab('tasks-status', t('To do', 'À faire')), findsOneWidget);
        expect(_tab('tasks-status', l.doneFilter), findsOneWidget);
        // The room is no longer a field of the head of the list.
        expect(find.byKey(const Key('tasks-room')), findsNothing);
        await openDoneTab(tester, l.doneFilter);
        expect(find.byKey(const Key('history-total')), findsOneWidget);
        await tester.tap(_tab('tasks-status', t('To do', 'À faire')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('history-total')), findsNothing);
      });

      testWidgets('the search finds by title, room and item without case or '
          'accents', (tester) async {
        final data = await start(tester);
        final repository = stateOf(tester).repository;
        final room = await repository.createRoom(data.main, name: 'Véranda');
        final item = await repository.createItem(
          data.main,
          roomId: room,
          name: 'Poêle à bois',
        );
        await repository.createTask(
          data.main,
          TaskInput(
            title: 'Réviser le conduit',
            dueOn: repository.today(),
            roomId: room,
          ),
        );
        await repository.createTask(
          data.main,
          TaskInput(
            title: 'Ramoner',
            dueOn: repository.today(),
            roomId: room,
            itemId: item,
          ),
        );
        await stateOf(tester).refresh();
        await tester.pumpAndSettle();
        expect(find.text('Réviser le conduit'), findsOneWidget);

        // The title, without the accents and in capitals.
        await _search(tester, 'tasks-search', 'REVISER');
        expect(find.text('Réviser le conduit'), findsOneWidget);
        expect(find.text('Ramoner'), findsNothing);
        expect(find.text('Main boiler service'), findsNothing);
        // The room, both tasks of it.
        await _search(tester, 'tasks-search', 'veranda');
        expect(find.text('Réviser le conduit'), findsOneWidget);
        expect(find.text('Ramoner'), findsOneWidget);
        // The item only the second one has.
        await _search(tester, 'tasks-search', 'poele a bois');
        expect(find.text('Réviser le conduit'), findsNothing);
        expect(find.text('Ramoner'), findsOneWidget);
        // Emptied: everything again.
        await _search(tester, 'tasks-search', '');
        expect(find.text('Main boiler service'), findsOneWidget);
        expect(find.text('Ramoner'), findsOneWidget);
      });

      testWidgets('nothing found says so and offers to clear the filters, '
          'which show everything again', (tester) async {
        await start(tester);
        await _search(tester, 'tasks-search', 'zzz');
        expect(
          find.text(t('Nothing matches.', 'Rien ne correspond.')),
          findsOneWidget,
        );
        expect(find.text('Main boiler service'), findsNothing);
        await tester.tap(find.byKey(const Key('filters-clear-all')));
        await tester.pumpAndSettle();
        expect(find.text('Main boiler service'), findsOneWidget);
        expect(_typed(tester, 'tasks-search'), isEmpty);
      });

      testWidgets('the button counts the criteria that apply, and the sheet '
          'clears them', (tester) async {
        await start(tester);
        final button = find.byKey(const Key('filters-toggle'));
        expect(
          find.descendant(
            of: button,
            matching: find.text(t('Filters', 'Filtres')),
          ),
          findsOneWidget,
        );
        await openDoneTab(tester, l.doneFilter);

        await tester.tap(button);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('history-room')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Main kitchen').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('history-outcome')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t('Skipped', 'Ignorée')).last);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const Key('filters-sheet-title')))
              .data,
          t('Filters (2)', 'Filtres (2)'),
        );
        await tester.tap(find.byKey(const Key('filters-sheet-done')));
        await tester.pumpAndSettle();
        // The count is on the button, the search is not one of the criteria.
        expect(
          find.descendant(
            of: button,
            matching: find.text(t('Filters (2)', 'Filtres (2)')),
          ),
          findsOneWidget,
        );
        await _search(tester, 'tasks-search', 'extinguishers');
        expect(
          find.descendant(
            of: button,
            matching: find.text(t('Filters (2)', 'Filtres (2)')),
          ),
          findsOneWidget,
        );
        expect(find.text('Check the extinguishers'), findsOneWidget);
        expect(find.text('Change the smoke alarm battery'), findsNothing);

        await tester.tap(button);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('filters-sheet-clear')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('filters-sheet-done')));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: button,
            matching: find.text(t('Filters', 'Filtres')),
          ),
          findsOneWidget,
        );
        // The criteria are gone and the search stays: it is not in the sheet.
        expect(find.text('Check the extinguishers'), findsOneWidget);
        expect(find.text('Change the smoke alarm battery'), findsNothing);
      });

      testWidgets('what was chosen survives a visit to a task and is gone on '
          'coming back from outside', (tester) async {
        final data = await start(tester);
        await _search(tester, 'tasks-search', 'boiler');
        await tester.tap(find.text('Main boiler service'));
        await tester.pumpAndSettle();
        expect(find.byType(TaskListScreen), findsNothing);
        Navigator.of(tester.element(find.byType(TaskScreen))).pop();
        await tester.pumpAndSettle();
        expect(find.byType(TaskListScreen), findsOneWidget);
        expect(_typed(tester, 'tasks-search'), 'boiler');
        expect(find.text('Main boiler service'), findsOneWidget);
        expect(find.text('Descale the kettle'), findsNothing);

        // Out of the list (its tab on Today) and in again: from zero.
        Navigator.of(tester.element(find.byType(TaskListScreen))).pop();
        await tester.pumpAndSettle();
        await openTaskList(tester, data);
        expect(_typed(tester, 'tasks-search'), isEmpty);
      });

      testWidgets('a long list is searched at once, 30 to a page', (
        tester,
      ) async {
        final data = await start(tester);
        final repository = stateOf(tester).repository;
        await tester.runAsync(() async {
          for (var i = 0; i < 1500; i++) {
            await repository.createTask(
              data.main,
              TaskInput(
                title: 'Contrôle numéro $i',
                dueOn: Day(2030, 1, 1 + i % 28),
              ),
            );
          }
        });
        final watch = Stopwatch()..start();
        final page = await tester.runAsync(
          () => repository.openTasks(data.main, query: 'CONTROLE NUMERO 14'),
        );
        watch.stop();
        // 14, 140 to 149 and 1400 to 1499: 111 of 1500, 4 pages.
        expect(page!.total, 111);
        expect(page.rows, hasLength(taskPageSize));
        expect(page.pages, 4);
        expect(watch.elapsedMilliseconds, lessThan(3000));
      });
    });
  }

  group('Stock', () {
    for (final MapEntry(key: locale, value: l) in labels.entries) {
      String t(String en, String fr) => locale == 'en' ? en : fr;

      testWidgets('tabs All and Low stock, one label for what is low, a '
          'search without a button, $locale', (tester) async {
        await onPhone(tester);
        late Lot3a data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot3a.seed(r),
          notifier: FakeNotifier(),
        );
        await state.choose(data.main);
        await tester.pumpAndSettle();
        await screens3a.firstWhere((s) => s.$1 == 'stock').$2(tester, data, l);

        expect(find.byKey(const Key('stock-low')), findsNothing);
        expect(find.byType(CheckboxListTile), findsNothing);
        final low = t('Low stock', 'Stock bas');
        // The tab and the pill of the list say the same, as the article does.
        expect(_tab('stock-tabs', low), findsOneWidget);
        expect(_tab('stock-tabs', t('All', 'Tous')), findsOneWidget);
        expect(find.text(t('Low', 'Basse')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(Key('article-${data.filter}')),
            matching: find.text(low),
          ),
          findsOneWidget,
        );
        await tester.tap(_tab('stock-tabs', low));
        await tester.pumpAndSettle();
        expect(find.text('White paint'), findsNothing);
        expect(find.text('Main filter'), findsOneWidget);
        // The search is kept when the tab changes, without accents.
        await _search(tester, 'stock-search', 'MAIN SHOP');
        expect(find.text('Main filter'), findsOneWidget);
        await _search(tester, 'stock-search', 'zzz');
        expect(
          find.text(
            t('No stock item matches.', 'Aucun article ne correspond.'),
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('filters-clear-all')));
        await tester.pumpAndSettle();
        expect(find.text('Main filter'), findsOneWidget);
        await tester.tap(_tab('stock-tabs', t('All', 'Tous')));
        await tester.pumpAndSettle();
        expect(find.text('White paint'), findsOneWidget);
      });
    }
  });

  group('the component on both platforms, at large text', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final (width, scale) in [(320.0, 1.0), (320.0, 2.0), (390.0, 2.0)]) {
        testWidgets('${platform.name}, $width px, text x$scale: no overflow, '
            'targets of 44 px, the sheet opens', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await onPhone(tester, textScale: scale, width: width);
          late Lot3c data;
          final state = await pumpApp(
            tester,
            seed: (r) async => data = await Lot3c.seed(r),
            notifier: FakeNotifier(),
          );
          await state.choose(data.main);
          await tester.pumpAndSettle();
          await openTaskList(tester, data);
          await openDoneTab(tester, 'Done');
          expect(tester.takeException(), isNull);
          final button = tester.getSize(
            find.byKey(const Key('filters-toggle')),
          );
          expect(button.height, greaterThanOrEqualTo(44));
          await tester.tap(find.byKey(const Key('filters-toggle')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('filters-sheet-done')), findsOneWidget);
          expect(tester.takeException(), isNull);
          // Focus: the field of the search takes it and gives it back.
          await tester.tap(find.byKey(const Key('filters-sheet-done')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('tasks-search')));
          await tester.pump();
          expect(FocusManager.instance.primaryFocus, isNotNull);
        });
      }
    }
  });
}
