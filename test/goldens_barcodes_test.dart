// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the barcode lookup (docs/adr/0015-barcode-lookup.md), at
// 360 px, in English and French, at text scale 1 and 2, on Android and on
// iOS: the question of the first scan when the phone is alone, and what a
// lookup found under the field of an item, with its photo and its credit.
// The fixture is the neutral home of lot 2b and a fake of the open
// databases. Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_barcodes_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/domain/scanned_code.dart';
import 'package:housecairn_mobile/ui/barcode_field.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'barcodes_test.dart' show FakeOpenFacts, foundOpenFacts;
import 'labels_test.dart' show FakeCodeCamera;
import 'support/app.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in ['en', 'fr']) {
      for (final scale in [1.0, 2.0]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_x${scale.toInt()}';

        testWidgets('consent, $name', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await onPhone(tester, textScale: scale);
            await pumpApp(tester, locale: locale, seed: Lot2b.seed);
            await openScreen(tester, const BarcodeConsentScreen());
            await precacheImages(tester);
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/barcodes_consent_$name.png'),
            );
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });

        testWidgets('found, $name', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await onPhone(tester, textScale: scale);
            late Lot2b data;
            final FakeOpenFacts http = foundOpenFacts();
            await pumpApp(
              tester,
              locale: locale,
              seed: (r) async {
                data = await Lot2b.seed(r);
                await r.setBarcodeLookupAllowed(true);
              },
              codeCamera: () => FakeCodeCamera(
                code: const ScannedCode(CodeFormat.ean13, '4006381333931'),
              ),
              openFactsHttp: () => http,
            );
            await openScreen(
              tester,
              ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
            );
            await tester.ensureVisible(find.byKey(const Key('ean-scan')));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('ean-scan')));
            await tester.pumpAndSettle();
            await tester.ensureVisible(
              find.byKey(const Key('ean-answer-done')),
            );
            await tester.pumpAndSettle();
            await precacheImages(tester);
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/barcodes_found_$name.png'),
            );
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });
      }
    }
  }
}
