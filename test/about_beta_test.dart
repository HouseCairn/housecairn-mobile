// SPDX-License-Identifier: AGPL-3.0-only

// The iPhone beta row of the About screen: the address is written once, the
// row offers to open it and to copy it, on both platforms, at large text and
// on the narrowest phone. Golden files: regenerate after a deliberate change
//   flutter test --update-goldens test/about_beta_test.dart
// and review every changed image in the pull request.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/icons.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/version.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/app.dart';
import 'support/goldens.dart';

const _label = {
  'en': (
    title: 'iPhone beta (TestFlight)',
    open: 'Open the link',
    copy: 'Copy the link',
    copied: 'Link copied',
    cannot: 'Nothing on this phone can open this link.',
  ),
  'fr': (
    title: 'Bêta iPhone (TestFlight)',
    open: 'Ouvrir le lien',
    copy: 'Copier le lien',
    copied: 'Lien copié',
    cannot: 'Rien sur ce téléphone ne peut ouvrir ce lien.',
  ),
};

Future<void> _toAbout(
  WidgetTester tester,
  String locale, {
  double width = 360,
  double textScale = 1,
  UrlOpener? openUrl,
}) async {
  await onPhone(tester, width: width, textScale: textScale);
  await pumpApp(tester, locale: locale, openUrl: openUrl);
  await tester.tap(destination(locale == 'en' ? 'More' : 'Plus'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(hcIcon(HcIcons.info), 100);
  await tester.tap(hcIcon(HcIcons.info));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byKey(const Key('about-beta-copy')),
    100,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
}

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

  test('the address of the beta is written in one file of lib/', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    final holders = [
      for (final f in files)
        if (f.readAsStringSync().contains('testflight.apple.com')) f.path,
    ];
    expect(holders, ['lib/version.dart']);
    expect(testFlightAddress, 'https://testflight.apple.com/join/eygTuxTT');
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in _label.keys) {
      final text = _label[locale]!;
      final name = '${platform.name.toLowerCase()}_$locale';

      testWidgets('the row is there, opens and copies ($name)', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final opened = <Uri>[];
        await _toAbout(
          tester,
          locale,
          openUrl: (address) async {
            opened.add(address);
            return true;
          },
        );
        expect(find.text(text.title), findsOneWidget);

        await tester.tap(find.text(text.open));
        await tester.pumpAndSettle();
        expect(opened, [Uri.parse(testFlightAddress)]);

        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tester.tap(find.text(text.copy));
        await tester.pump();
        expect(copied, testFlightAddress);
        expect(find.text(text.copied), findsOneWidget);
      });

      testWidgets('a phone that cannot open the link says so ($name)', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await _toAbout(tester, locale, openUrl: (_) async => false);
        await tester.tap(find.text(text.open));
        await tester.pump();
        expect(find.text(text.cannot), findsOneWidget);
      });

      for (final (suffix, width, scale) in [
        ('x1', 360.0, 1.0),
        ('x2_320', 320.0, 2.0),
      ]) {
        testWidgets('About, the beta row, $name, $suffix', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await _toAbout(tester, locale, width: width, textScale: scale);
          // No overflow, and every word of the row shows inside the screen.
          expect(tester.takeException(), isNull);
          for (final label in [text.title, text.open, text.copy]) {
            final box = tester.getRect(find.text(label));
            expect(box.left, greaterThanOrEqualTo(0), reason: label);
            expect(box.right, lessThanOrEqualTo(width), reason: label);
          }
          await tester.runAsync(() async {
            for (final element in find.byType(Image).evaluate()) {
              await precacheImage((element.widget as Image).image, element);
            }
          });
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/about_beta_${name}_$suffix.png'),
          );
        });
      }
    }
  }
}
