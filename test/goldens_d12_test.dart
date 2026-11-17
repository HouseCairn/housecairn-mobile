// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of design lot D12: Budget (the summary with the details of
// the year open, and the upkeep), Projects in groups by status, the
// templates, More, the reports line of Today, the first start and About, on
// an iPhone and on Android, at 390 px and at the narrow 320 px with text at
// twice the size, in English and French. Regenerate after a deliberate
// change:
//   flutter test --update-goldens test/goldens_d12_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/templates_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/app.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';
import 'support/screens_2b.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Housecairn',
      packageName: 'app.example',
      version: '0.5.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  // Each screen, opened as the app opens it, on the data of lot 3b with a
  // planned project, so that Projects has two groups.
  final aboutRow = find.byKey(const Key('more-about'));

  // About, opened from More as a person does, and checked to be About: the
  // golden of a screen that is not it would pass in silence otherwise.
  Future<void> openAbout(WidgetTester tester, Labels l) async {
    await openSection(tester, l.more);
    await tester.scrollUntilVisible(aboutRow, 100);
    await tester.ensureVisible(aboutRow);
    await tester.pumpAndSettle();
    await tester.tap(aboutRow);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-card')), findsOneWidget);
  }

  final screens = <(String, Future<void> Function(WidgetTester, Labels))>[
    (
      'budget',
      (tester, l) async {
        await budgetTab(tester, l, 0);
        final details = find.byKey(const Key('envelope-details'));
        await tester.ensureVisible(details);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(of: details, matching: find.byType(InkWell)).first,
        );
        await tester.pumpAndSettle();
      },
    ),
    ('budget_upkeep', (tester, l) => budgetTab(tester, l, 3)),
    ('projects', (tester, l) => openSection(tester, l.projects)),
    ('templates', (tester, l) => openScreen(tester, const TemplatesScreen())),
    ('more', (tester, l) => openSection(tester, l.more)),
    ('about', (tester, l) => openAbout(tester, l)),
    // The card of Links, scrolled to, only where it is tight.
    (
      'about_links',
      (tester, l) async {
        await openAbout(tester, l);
        await tester.scrollUntilVisible(
          find.byKey(const Key('about-links')),
          100,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
      },
    ),
  ];

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final MapEntry(key: locale, value: l) in labels.entries) {
      for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0)]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_${width.toInt()}_x${scale.toInt()}';

        void phone() => debugDefaultTargetPlatformOverride = platform;

        for (final (page, open) in screens) {
          if (page == 'about_links' && width != 320) continue;
          testWidgets('$page, $name', (tester) async {
            phone();
            addTearDown(() => debugDefaultTargetPlatformOverride = null);
            await onPhone(tester, textScale: scale, width: width, height: 844);
            late Lot3b data;
            final state = await pumpApp(
              tester,
              locale: locale,
              seed: (r) async {
                data = await Lot3b.seed(r);
                await r.createProject(
                  data.main,
                  const ProjectInput(title: 'New windows', status: 'planned'),
                );
              },
            );
            await state.choose(data.main);
            await tester.pumpAndSettle();
            await open(tester, l);
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/d12_${page}_$name.png'),
            );
          });
        }

        // One home with one open report and no task: the line of the
        // reports alone, with no date that moves with the day of the run.
        testWidgets('today, $name', (tester) async {
          phone();
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await onPhone(tester, textScale: scale, width: width, height: 844);
          await pumpApp(
            tester,
            locale: locale,
            seed: (r) async {
              final home = await r.createHome(name: 'Main home');
              await r.createReport(home, title: 'The tap drips');
            },
          );
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/d12_today_$name.png'),
          );
        });

        testWidgets('first start, $name', (tester) async {
          phone();
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await onPhone(tester, textScale: scale, width: width, height: 844);
          await pumpApp(tester, locale: locale, firstStart: true);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/d12_ways_$name.png'),
          );
        });
      }
    }
  }
}
