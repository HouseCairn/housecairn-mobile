// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens of lot 2b (Rooms, Room, Room form, Item, Item
// form, Contractors, Contractor, Contractor form, Photo, Add from a template,
// Reminders) at 360 px, in English and
// French, at text scale 1 and 2, as lot 2d did for the screens of lot 2a. The
// same screens are checked for the tap target and contrast guidelines of
// Flutter (`accessibility_test.dart`). Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_2b_test.dart
// and review every changed image in the pull request.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/screens_2b.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    for (final scale in [1.0, 2.0]) {
      final name = '${locale}_x${scale.toInt()}';
      for (final (page, open) in screens2b) {
        testWidgets('$page, $name', (tester) async {
          await onPhone(tester, textScale: scale);
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
          await open(tester, data, l);
          // The cairn of the header of the first golden of the file, whose
          // image would not be decoded yet. Not on every page: the photo
          // page never settles once its images are precached.
          if (page == screens2b.first.$1) await precacheImages(tester);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/${page}_$name.png'),
          );
        });
      }
    }
  }
}
