// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/icons.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/version.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';

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
      await pumpApp(tester, locale: locale);
      final shown = tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .map((d) => d.label)
          .toList();
      expect(shown, labels);
      // Today opens first.
      expect(find.widgetWithText(HcLargeTitle, labels.first), findsOneWidget);
      for (final label in labels) {
        await tester.tap(destination(label));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(HcLargeTitle, label), findsOneWidget);
      }
    });

    for (final scale in [1.0, 2.0]) {
      testWidgets('every screen fits 360 px at text scale $scale ($locale)', (
        tester,
      ) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale);
        for (final label in labels) {
          await tester.tap(destination(label));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
        }
        await tester.scrollUntilVisible(hcIcon(HcIcons.info), 100);
        await tester.ensureVisible(hcIcon(HcIcons.info));
        await tester.pumpAndSettle();
        await tester.tap(hcIcon(HcIcons.info));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'About');
      });
    }
  }

  testWidgets(
    'About shows the attribution of NOTICE, the version and the licences',
    (tester) async {
      await onPhone(tester);
      await pumpApp(tester);
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
    await pumpApp(tester);
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    await tester.tap(destination('Today'));
    await tester.pumpAndSettle();
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(HcLargeTitle, 'About'), findsOneWidget);
    // A second tap on the current section goes back to its root.
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(HcLargeTitle, 'More'), findsOneWidget);
  });
}
