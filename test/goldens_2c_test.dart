// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens of lot 2c (the first start with the three ways,
// and the ways in More) at 360 px, in English and French, at text scale 1 and
// 2, light only, as the other screens. Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_2c_test.dart
// and review every changed image in the pull request.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/goldens.dart';

/// Scrolls the list of the screen to its end; a list builds lazily, so its
/// extent is read again after each jump until it stops growing.
Future<void> toEnd(WidgetTester tester) async {
  final position = tester
      .state<ScrollableState>(find.byType(Scrollable).hitTestable().first)
      .position;
  double last;
  do {
    last = position.maxScrollExtent;
    position.jumpTo(last);
    await tester.pumpAndSettle();
  } while (position.maxScrollExtent != last);
}

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  const more = {'en': 'More', 'fr': 'Plus'};

  for (final locale in more.keys) {
    for (final scale in [1.0, 2.0]) {
      final name = '${locale}_x${scale.toInt()}';

      testWidgets('ways, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, firstStart: true);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/ways_$name.png'),
        );
      });

      testWidgets('ways end, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, firstStart: true);
        await toEnd(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/ways_end_$name.png'),
        );
      });

      testWidgets('ways in More, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale);
        await tester.tap(destination(more[locale]!));
        await tester.pumpAndSettle();
        await toEnd(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/ways_settings_$name.png'),
        );
      });
    }
  }
}
