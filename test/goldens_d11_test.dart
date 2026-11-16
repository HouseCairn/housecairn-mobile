// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the forms of design lot D11 (the order of the fields, the
// help of the web, the title of the home, the one Delete, the folded sections
// of the project and of the task), at 360 px, in English and French, at text
// scale 1 and 2, on Android and on iOS, and each refused as well. The forms
// whose Android capture already is in a file of lot 2b or 3b are captured here
// on iOS only. Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_d11_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/ui/homes_screen.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/task_form_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';

typedef _Open = Future<void> Function(
  WidgetTester,
  Lot3b,
  Map<String, String> m,
);

Future<void> _save(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

/// (page, android too, opens it).
final _pages = <(String, bool, _Open)>[
  (
    'room_form',
    false,
    (tester, d, m) => openScreen(
      tester,
      RoomFormScreen(homeId: d.main, roomId: d.base.base.kitchen),
    ),
  ),
  (
    'room_form_new',
    true,
    (tester, d, m) => openScreen(tester, RoomFormScreen(homeId: d.main)),
  ),
  (
    'room_form_error',
    true,
    (tester, d, m) async {
      await openScreen(tester, RoomFormScreen(homeId: d.main));
      await _save(tester, m['save']!);
    },
  ),
  (
    'item_form',
    false,
    (tester, d, m) => openScreen(
      tester,
      ItemFormScreen(
        homeId: d.main,
        roomId: d.base.base.cellar,
        itemId: d.base.base.boiler,
      ),
    ),
  ),
  (
    'item_form_new',
    true,
    (tester, d, m) => openScreen(
      tester,
      ItemFormScreen(
        homeId: d.main,
        roomId: d.base.base.cellar,
        chooseRoom: true,
      ),
    ),
  ),
  (
    'item_form_error',
    true,
    (tester, d, m) async {
      await openScreen(
        tester,
        ItemFormScreen(
          homeId: d.main,
          roomId: d.base.base.cellar,
          chooseRoom: true,
        ),
      );
      await _save(tester, m['save']!);
    },
  ),
  (
    'home_form',
    true,
    (tester, d, m) async {
      await openScreen(tester, HomeScreen(homeId: d.main));
      // To the end: Archive and Delete.
      await tester.drag(
        find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .hitTestable()
            .last,
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();
    },
  ),
  (
    'home_form_error',
    true,
    (tester, d, m) async {
      await openScreen(tester, HomeScreen(homeId: d.main));
      await tester.enterText(find.byKey(const Key('home-currency')), 'EU');
      await _save(tester, m['save']!);
    },
  ),
  (
    'report_form',
    false,
    (tester, d, m) => openScreen(tester, ReportFormScreen(homeId: d.main)),
  ),
  (
    'report_form_error',
    true,
    (tester, d, m) async {
      await openScreen(tester, ReportFormScreen(homeId: d.main));
      await _save(tester, m['sendReport']!);
    },
  ),
  (
    'project_form_new',
    true,
    (tester, d, m) => openScreen(tester, ProjectFormScreen(homeId: d.main)),
  ),
  (
    'project_form',
    false,
    (tester, d, m) => openScreen(
      tester,
      ProjectFormScreen(homeId: d.main, projectId: d.project),
    ),
  ),
  (
    'project_form_error',
    true,
    (tester, d, m) async {
      await openScreen(tester, ProjectFormScreen(homeId: d.main));
      await _save(tester, m['save']!);
    },
  ),
  (
    'line_form',
    false,
    (tester, d, m) => openScreen(
      tester,
      LineFormScreen(homeId: d.main, projectId: d.project, lineId: d.line),
    ),
  ),
  (
    'task_form_materials',
    true,
    (tester, d, m) async {
      await openScreen(
        tester,
        TaskFormScreen(homeId: d.main, taskId: d.base.service),
      );
      await seeInTaskForm(
        tester,
        find.byKey(const Key('task-material-article-0')),
      );
    },
  ),
  (
    'task_form_error',
    true,
    (tester, d, m) async {
      await openScreen(tester, TaskFormScreen(homeId: d.main));
      await saveTask(tester);
    },
  ),
];

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
        for (final (page, android, open) in _pages) {
          if (platform == TargetPlatform.android && !android) continue;
          testWidgets('$page, $name', (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            addTearDown(() => debugDefaultTargetPlatformOverride = null);
            await onPhone(tester, textScale: scale);
            late Lot3b data;
            final state = await pumpApp(
              tester,
              locale: locale,
              seed: (r) async => data = await Lot3b.seed(r),
              photoSource: cameraWith(),
            );
            await state.choose(data.main);
            await tester.pumpAndSettle();
            await open(tester, data, arbMessages(locale));
            await precacheImages(tester);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/d11_${page}_$name.png'),
            );
            // The tree is taken down and the timers of a refused form (the
            // error of a field on iOS) run out before the test ends.
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump(const Duration(seconds: 10));
          });
        }
      }
    }
  }
}
