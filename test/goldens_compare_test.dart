// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the comparison of projects: the list in its mode of
// comparison with one row ticked, and the comparison of two projects, on an
// iPhone and on Android, at 390 px and at the narrow 320 px with text at
// twice the size, in English and French. Regenerate after a deliberate
// change:
//   flutter test --update-goldens test/goldens_compare_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'projects_compare_test.dart' show Compared, reveal, tapKey;
import 'support/app.dart';
import 'support/goldens.dart';
import 'support/lot3b.dart' show openSection;
import 'support/screens_2b.dart' show labels;

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final screens = <(String, Future<void> Function(WidgetTester, Compared))>[
    (
      'projects_compare',
      (tester, data) async {
        await tapKey(tester, 'projects-compare');
        await tapKey(tester, 'project-${data.planned}');
        // The rows and the buttons of the mode on the screen.
        await reveal(tester, find.byKey(const Key('projects-compare-cancel')));
      },
    ),
    (
      'project_compare',
      (tester, data) async {
        await tapKey(tester, 'projects-compare');
        await tapKey(tester, 'project-${data.planned}');
        await tapKey(tester, 'project-${data.base.project}');
        await tapKey(tester, 'projects-compare-ticked');
      },
    ),
  ];

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in ['en', 'fr']) {
      for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0)]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_${width.toInt()}_x${scale.toInt()}';
        for (final (page, open) in screens) {
          testWidgets('$page, $name', (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            addTearDown(() => debugDefaultTargetPlatformOverride = null);
            await onPhone(tester, textScale: scale, width: width, height: 844);
            late Compared data;
            final state = await pumpApp(
              tester,
              locale: locale,
              seed: (r) async => data = await Compared.seed(r),
            );
            await state.choose(data.main);
            await tester.pumpAndSettle();
            await openSection(tester, labels[locale]!.projects);
            await open(tester, data);
            await precacheImages(tester);
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/compare_${page}_$name.png'),
            );
          });
        }
      }
    }
  }
}
