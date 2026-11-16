// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of Settings in the third way (the address of the server, the
// sentence of ADR 0010, Disconnect) and of the confirmation of Disconnect,
// at 360 px, in English and French, on Android and on iOS (ADR 0011: the
// dialog of each platform). Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_settings_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/goldens.dart';
import 'support/server_fake.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final more = {
    'en': AppLocalizationsEn().navMore,
    'fr': AppLocalizationsFr().navMore,
  };

  Future<void> toServerRows(WidgetTester tester, String locale) async {
    await startOnServer(tester, locale: locale);
    await tester.tap(destination(more[locale]!));
    await tester.pumpAndSettle();
    const address = Key('settings-server-address');
    await tester.scrollUntilVisible(
      find.byKey(address),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    // The address at the top: the sentence and Disconnect under it.
    await Scrollable.ensureVisible(
      tester.element(find.byKey(address)),
      alignment: 0.05,
    );
    await tester.pumpAndSettle();
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in more.keys) {
      final name = '${platform.name.toLowerCase()}_$locale';

      testWidgets('Settings on a server, $name', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await onPhone(tester);
          await toServerRows(tester, locale);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/settings_server_$name.png'),
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });

      testWidgets('Disconnect, the confirmation, $name', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await onPhone(tester);
          await toServerRows(tester, locale);
          await tester.tap(find.byKey(const Key('settings-server-disconnect')));
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/settings_disconnect_$name.png'),
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }
}
