// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the filters and the search of the lists (design lot D13):
// All with a search that finds, one that finds nothing, the sheet "Filters"
// of the history, and the stock under Low stock, on an iPhone and on Android,
// at 390 px and at the narrow 320 px with text at twice the size, in English
// and French. Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_d13_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/filters.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot3a.dart';
import 'support/lot3c.dart';
import 'support/screens_2b.dart';

Future<void> _search(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pump(hcSearchDelay);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final MapEntry(key: locale, value: l) in labels.entries) {
      for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0)]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_${width.toInt()}_x${scale.toInt()}';

        Future<Lot3c> openTasks(WidgetTester tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await onPhone(tester, textScale: scale, width: width, height: 760);
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

        testWidgets('All, a search that finds, $name', (tester) async {
          await openTasks(tester);
          await _search(tester, 'tasks-search', 'boiler');
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/filters_found_$name.png'),
          );
        });

        testWidgets('All, a search that finds nothing, $name', (tester) async {
          await openTasks(tester);
          await _search(tester, 'tasks-search', 'zzz');
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/filters_none_$name.png'),
          );
        });

        testWidgets('Done, the sheet Filters, $name', (tester) async {
          await openTasks(tester);
          await openDoneTab(tester, l.doneFilter);
          await tester.tap(find.byKey(const Key('filters-toggle')));
          await tester.pumpAndSettle();
          // One criterion: the outcome Skipped (the wheel of iOS, the menu of
          // Material), so that the sheet says "Filters (1)".
          await tester.tap(find.byKey(const Key('history-outcome')));
          await tester.pumpAndSettle();
          if (platform == TargetPlatform.iOS) {
            // The wheel's lines are done or skipped, Done, Skipped.
            await tester.drag(
              find.byKey(const Key('hc-select-wheel')),
              const Offset(0, -72),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('hc-sheet-done')));
          } else {
            await tester.tap(
              find.text(locale == 'en' ? 'Skipped' : 'Ignorée').last,
            );
          }
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/filters_sheet_$name.png'),
          );
        });

        testWidgets('Stock, Low stock and a search, $name', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await onPhone(tester, textScale: scale, width: width, height: 760);
          late Lot3a data;
          final state = await pumpApp(
            tester,
            locale: locale,
            seed: (r) async => data = await Lot3a.seed(r),
            notifier: FakeNotifier(),
          );
          await state.choose(data.main);
          await tester.pumpAndSettle();
          await screens3a
              .firstWhere((s) => s.$1 == 'stock')
              .$2(tester, data, l);
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('stock-tabs')),
              matching: find.text(locale == 'en' ? 'Low stock' : 'Stock bas'),
            ),
          );
          await tester.pumpAndSettle();
          await _search(tester, 'stock-search', 'FILT');
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/filters_stock_$name.png'),
          );
        });
      }
    }
  }
}
