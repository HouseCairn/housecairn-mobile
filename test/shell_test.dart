// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/version.dart';
import 'package:material_ui/material_ui.dart';

/// A phone of 360 logical pixels by 760, the narrowest width of the spec.
Future<void> onPhone(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(360 * 3, 760 * 3);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Finder destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  const sections = {
    'en': ['Today', 'Rooms', 'Projects', 'Budget', 'More'],
    'fr': ["Aujourd'hui", 'Pièces', 'Projets', 'Budget', 'Plus'],
  };

  for (final MapEntry(key: locale, value: labels) in sections.entries) {
    testWidgets('five sections in the order of the design guide ($locale)', (
      tester,
    ) async {
      await onPhone(tester);
      await tester.pumpWidget(HousecairnApp(locale: Locale(locale)));
      await tester.pumpAndSettle();
      final shown = tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .map((d) => d.label)
          .toList();
      expect(shown, labels);
      // Today opens first.
      expect(find.widgetWithText(AppBar, labels.first), findsOneWidget);
      for (final label in labels) {
        await tester.tap(destination(label));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(AppBar, label), findsOneWidget);
      }
    });

    for (final scale in [1.0, 2.0]) {
      testWidgets('every screen fits 360 px at text scale $scale ($locale)', (
        tester,
      ) async {
        await onPhone(tester, textScale: scale);
        await tester.pumpWidget(HousecairnApp(locale: Locale(locale)));
        await tester.pumpAndSettle();
        for (final label in labels) {
          await tester.tap(destination(label));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
        }
        await tester.tap(find.byIcon(Icons.info_outline));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'About');
      });
    }
  }

  testWidgets(
    'About shows the attribution of NOTICE, the version and the licences',
    (tester) async {
      await onPhone(tester);
      await tester.pumpWidget(const HousecairnApp(locale: Locale('en')));
      await tester.pumpAndSettle();
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(find.text('Housecairn, by Robvred'), findsOneWidget);
      expect(find.text('version $appVersion'), findsOneWidget);
      expect(
        find.text('Free software under the AGPL-3.0 licence.'),
        findsOneWidget,
      );
      expect(
        find.text('Source code and security reports: $sourceAddress'),
        findsOneWidget,
      );
      await tester.tap(find.text('Open source licences'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
      expect(find.text('Housecairn, by Robvred'), findsOneWidget);
    },
  );

  testWidgets('a section keeps its screen when another one is opened', (
    tester,
  ) async {
    await onPhone(tester);
    await tester.pumpWidget(const HousecairnApp(locale: Locale('en')));
    await tester.pumpAndSettle();
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    await tester.tap(destination('Today'));
    await tester.pumpAndSettle();
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'About'), findsOneWidget);
    // A second tap on the current section goes back to its root.
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'More'), findsOneWidget);
  });
}
