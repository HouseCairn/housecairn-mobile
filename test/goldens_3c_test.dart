// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens of lot 3c (the list of all the tasks, the
// history with its cost, the details of what was done, the page of a task
// and its form) at 360 px, in English and French, at text scale 1 and 2, as
// lot 3b did. The same screens are checked for the guidelines of Flutter
// (`accessibility_test.dart`). Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_3c_test.dart
// and review every changed image in the pull request.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart' show FakeDocuments;
import 'support/lot3c.dart';
import 'support/screens_2b.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    for (final scale in [1.0, 2.0]) {
      final name = '${locale}_x${scale.toInt()}';
      for (final (page, open) in screens3c) {
        testWidgets('$page, $name', (tester) async {
          await onPhone(tester, textScale: scale);
          late Lot3c data;
          final state = await pumpApp(
            tester,
            locale: locale,
            seed: (r) async => data = await Lot3c.seed(r),
            photoSource: cameraWith(),
            documentSource: FakeDocuments(),
            notifier: FakeNotifier(),
          );
          await state.choose(data.main);
          await tester.pumpAndSettle();
          await open(tester, data, l);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/${page}_$name.png'),
          );
        });
      }
    }
  }
}
