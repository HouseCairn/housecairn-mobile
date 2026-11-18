// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the interactive guide (web ADR 0084, lot A3): the list of
// the scenarios with the card of the example home, the page of a scenario
// with a step done and its buttons, the confirmation of Delete the example
// home, and the banner of the example home on its page; on an iPhone and on
// Android, at 390 px and at the narrow 320 px with text at twice the size, in
// English and French. Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_guide_test.dart
// and review every changed image in the pull request.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/goldens.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final more = {
    'en': AppLocalizationsEn().navMore,
    'fr': AppLocalizationsFr().navMore,
  };

  /// Scenario 1 done and the kitchen of scenario 2 added, in [locale].
  Future<void> openGuide(WidgetTester tester, String locale) async {
    await pumpApp(
      tester,
      locale: locale,
      seed: (r) async {
        await r.createHome(
          name: locale == 'en' ? 'Main house' : 'Maison principale',
        );
        final example = await r.createExampleHome(guide, language: locale);
        await r.tickByHand(guide, example, 'create-home.2');
        await r.tickByHand(guide, example, 'create-home.3');
        final kitchen = guide.rows.firstWhere((x) => x.key == 'room.kitchen');
        await r.createRoom(
          example,
          name: '${guide.text(kitchen.fields['name'], locale)}',
          kind: 'kitchen',
        );
      },
    );
    await tester.tap(destination(more[locale]!));
    await tester.pumpAndSettle();
    final entry = find.byKey(const Key('more-guide'));
    await tester.scrollUntilVisible(
      entry,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(entry);
    await tester.pumpAndSettle();
    await tester.tap(entry);
    await tester.pumpAndSettle();
  }

  Future<void> show(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.2);
    await tester.pumpAndSettle();
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in more.keys) {
      for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0)]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_${width.toInt()}_x${scale.toInt()}';

        Future<void> start(WidgetTester tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await onPhone(tester, textScale: scale, width: width, height: 760);
          await openGuide(tester, locale);
        }

        Future<void> capture(WidgetTester tester, String file) async {
          await precacheImages(tester);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/${file}_$name.png'),
          );
        }

        testWidgets('the guide, $name', (tester) async {
          await start(tester);
          await capture(tester, 'guide');
        });

        testWidgets('the card of the example home, $name', (tester) async {
          await start(tester);
          await show(tester, find.byKey(const Key('example-delete')));
          await capture(tester, 'guide_example');
        });

        testWidgets('a scenario, $name', (tester) async {
          await start(tester);
          await show(
            tester,
            find.byKey(const Key('guide-scenario-rooms-equipment')),
          );
          await tester.tap(
            find.byKey(const Key('guide-scenario-rooms-equipment')),
          );
          await tester.pumpAndSettle();
          await capture(tester, 'guide_scenario');
        });

        testWidgets('Delete the example home, the dialog, $name', (
          tester,
        ) async {
          await start(tester);
          await show(tester, find.byKey(const Key('example-delete')));
          await tester.tap(find.byKey(const Key('example-delete')));
          await tester.pumpAndSettle();
          await capture(tester, 'guide_delete');
        });

        testWidgets('the banner of the example home, $name', (tester) async {
          await start(tester);
          await show(tester, find.byKey(const Key('guide-example-home')));
          await tester.tap(find.byKey(const Key('guide-example-home')));
          await tester.pumpAndSettle();
          await capture(tester, 'example_banner');
        });
      }
    }
  }
}
