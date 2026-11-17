// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens of lot 4d at 320 px, in English and French, at
// text scale 1 and 2, on Android and on iOS: the Photos and files of a task
// (a photo on the phone, one not yet, a PDF), a report whose photo has not
// come yet, an article whose label has not come yet. Regenerate after a
// deliberate change:
//   flutter test --update-goldens test/goldens_4d_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart' show FakeDocuments;
import 'support/lot4d.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final screens = <(String, Widget Function(Lot4d), Key?)>[
    (
      'task_attachments',
      (d) => TaskScreen(homeId: d.home, taskId: d.task),
      const Key('task-attachments'),
    ),
    (
      'report_photo_missing',
      (d) => ReportScreen(homeId: d.home, reportId: d.report),
      null,
    ),
    (
      'article_label_missing',
      (d) => ArticleScreen(homeId: d.home, articleId: d.article),
      null,
    ),
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
              late Lot4d data;
              await pumpApp(
                tester,
                locale: locale,
                seed: (r) async => data = await Lot4d.seed(r),
                photoSource: cameraWith(),
                documentSource: FakeDocuments(),
                notifier: FakeNotifier(),
              );
              if (anchor != null) {
                // The photo of the task is a file of the phone: read and
                // decoded for real before the page asks for it, under the
                // key its tile uses (a width of 360).
                final state = stateOf(tester);
                final photo = (await tester.runAsync(
                  () => state.repository.attachment(data.photo),
                ))!;
                final file = state.repository.attachmentFile(photo);
                final context = tester.element(find.byType(Scaffold).first);
                await tester.runAsync(
                  () => precacheImage(
                    ResizeImage(FileImage(file), width: 360),
                    context,
                  ),
                );
              }
              await openScreen(tester, screen(data));
              if (anchor != null) {
                await tester.scrollUntilVisible(
                  find.byKey(anchor),
                  100,
                  // The page, not a horizontal field of it.
                  scrollable: find
                      .byWidgetPredicate(
                        (w) =>
                            w is Scrollable &&
                            axisDirectionToAxis(w.axisDirection) ==
                                Axis.vertical,
                      )
                      .last,
                );
                await tester.pumpAndSettle();
                await Scrollable.ensureVisible(
                  tester.element(find.byKey(anchor)),
                  alignment: 0.05,
                );
                await tester.pumpAndSettle();
              }
              if (anchor == null) await precacheImages(tester);
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
