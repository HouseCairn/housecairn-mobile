// SPDX-License-Identifier: AGPL-3.0-only

// The accessibility guidelines of Flutter on every screen of the app, at
// 360 px, in English and French: tap targets of 48 dp on Android and 44 pt on
// iOS (the app draws 48 for both), every target labelled, and text contrast
// (docs/spec.md, accessibility; docs/adr/0011-design-from-the-web-app.md).

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/ui/homes_screen.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/screens_2b.dart';

void main() {
  const labels = {
    'en': (rooms: 'Rooms', more: 'More'),
    'fr': (rooms: 'Pièces', more: 'Plus'),
  };

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    final pages = <(String, Future<void> Function(WidgetTester, Lot2b))>[
      ('today', (tester, data) async {}),
      ('homes', (tester, data) => openScreen(tester, const HomesScreen())),
      for (final (page, open) in screens2b)
        (page, (tester, data) => open(tester, data, l)),
    ];
    for (final (page, open) in pages) {
      testWidgets('$page meets the guidelines, $locale', (tester) async {
        final semantics = tester.ensureSemantics();
        await onPhone(tester);
        late Lot2b data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
          photoSource: cameraWith(),
          notifier: FakeNotifier(),
        );
        await state.choose(data.homes.main);
        await tester.pumpAndSettle();
        await open(tester, data);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }
}
