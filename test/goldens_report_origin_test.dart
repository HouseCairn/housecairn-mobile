// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens that show the report a task was made from, at
// 320 px, in English and French, at text scale 1 and 2, on Android and on
// iOS: the page of a task with the photo of its report, the same with the
// photo not on the phone yet, All and Today with the pill Photo. Regenerate
// after a deliberate change:
//   flutter test --update-goldens test/goldens_report_origin_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/ui/task_list_screen.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:housecairn_mobile/ui/today.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/report_origin.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final screens =
      <(String, Widget Function(ReportOrigin), Key? Function(ReportOrigin))>[
        (
          'task_report_photo',
          (d) => TaskScreen(homeId: d.home, taskId: d.withPhoto),
          (d) => Key('task-report-${d.reportWithPhoto}'),
        ),
        (
          'task_report_missing',
          (d) => TaskScreen(homeId: d.home, taskId: d.photoMissing),
          (d) => Key('task-report-${d.reportMissing}'),
        ),
        (
          'tasks_photo_pill',
          (d) => TaskListScreen(homeId: d.home),
          (d) => null,
        ),
        ('today_photo_pill', (d) => const TodayScreen(), (d) => null),
      ];

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in ['en', 'fr']) {
      for (final scale in [1.0, 2.0]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_x${scale.toInt()}';
        for (final (page, screen, anchor) in screens) {
          testWidgets('$page, $name', (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            try {
              await onPhone(tester, width: 320, textScale: scale);
              late ReportOrigin data;
              await pumpApp(
                tester,
                locale: locale,
                seed: (r) async => data = await ReportOrigin.seed(r),
              );
              // The photo of the report is a file of the phone: read and
              // decoded for real before the page asks for it, at the width
              // its widget decodes it.
              final repository = stateOf(tester).repository;
              final report = (await tester.runAsync(
                () => repository.report(data.reportWithPhoto),
              ))!;
              await tester.runAsync(
                () => precacheImage(
                  ResizeImage(
                    FileImage(repository.reportPhoto(report)),
                    width: 1080,
                  ),
                  tester.element(find.byType(Scaffold).first),
                ),
              );
              await openScreen(tester, screen(data));
              final key = anchor(data);
              await tester.pumpAndSettle();
              // A page of the lists is scrolled to its first pill Photo.
              final target = key != null
                  ? find.byKey(key)
                  : find
                        .byWidgetPredicate(
                          (w) => '${w.key}'.contains('today-photo-'),
                        )
                        .first;
              await Scrollable.ensureVisible(
                tester.element(target),
                alignment: key != null ? 0.05 : 0.3,
              );
              await tester.pumpAndSettle();
              // The lists show no photo, only the images of the header.
              if (key == null) await precacheImages(tester);
              expect(tester.takeException(), isNull);
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile('goldens/${page}_$name.png'),
              );
            } finally {
              debugDefaultTargetPlatformOverride = null;
            }
          });
        }
      }
    }
  }
}
