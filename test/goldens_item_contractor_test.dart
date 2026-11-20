// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of Add a contractor… in the maintenance contract of an item
// (`contract_contractor` of the web's item form): the fields of the new
// contractor open under the list, the name refused when it is empty, on
// Android and on iOS, in English and French, at 360 px at text scale 1 and
// 2, and at the narrow 320 px at scale 2, where no word of the card is cut.
// Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_item_contractor_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/adaptive.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/new_contractor.dart';
import 'package:material_ui/material_ui.dart';

import 'screens_2b_test.dart' show reveal;
import 'support/app.dart';
import 'support/arb.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'whole_words_bar_tabs_test.dart' show expectWholeWords;

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in ['en', 'fr']) {
      for (final (suffix, width, scale) in [
        ('x1', 360.0, 1.0),
        ('x2', 360.0, 2.0),
        ('x2_320', 320.0, 2.0),
      ]) {
        final name = '${platform.name.toLowerCase()}_${locale}_$suffix';
        testWidgets('Add a contractor…, $name', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          final m = arbMessages(locale);
          await onPhone(tester, textScale: scale, width: width);
          late Lot2b data;
          await pumpApp(
            tester,
            locale: locale,
            seed: (r) async => data = await Lot2b.seed(r),
          );
          await openScreen(
            tester,
            ItemFormScreen(
              homeId: data.homes.main,
              roomId: data.cellar,
              itemId: data.boiler,
            ),
          );
          // The menu of Android, the wheel of iOS: the choice as either
          // gives it.
          await reveal(tester, find.byKey(const Key('item-contractor')));
          tester
              .widget<HcSelect<String?>>(
                find.byKey(const Key('item-contractor')),
              )
              .onChanged(newContractorChoice);
          await tester.pumpAndSettle();
          // Saved with no name: the error of the web, under the field.
          await tester.tap(find.text(m['save']!).first);
          await tester.pumpAndSettle();
          final field = find.byKey(const Key('item-new-contractor-name'));
          await Scrollable.ensureVisible(
            tester.element(find.byKey(const Key('item-contractor'))),
            alignment: 0.05,
          );
          await tester.pumpAndSettle();
          expect(find.text(m['errNewContractorName']!), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (width < 360) {
            expectWholeWords(
              tester,
              find.ancestor(of: field, matching: find.byType(HcCard)).first,
              'the contract, $name',
            );
          }
          await precacheImages(tester);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/item_contractor_add_$name.png'),
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 10));
        });
      }
    }
  }
}
