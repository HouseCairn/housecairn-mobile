// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens of lot 4b (the address of a Housecairn server,
// with the warning of plain HTTP, and the confirmation) at 360 px, in English
// and French, at text scale 1 and 2. Regenerate after a deliberate change:
//   flutter test --update-goldens test/goldens_4b_test.dart
// and review every changed image in the pull request.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/ui/server_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/goldens.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  Future<void> open(WidgetTester tester, Widget screen) async {
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    unawaited(navigator.push(MaterialPageRoute<void>(builder: (_) => screen)));
    await tester.pumpAndSettle();
  }

  const homes = [
    ServerHome(
      id: '0b6f2f0e-6c5a-4d33-9a7e-0d6b8f5c1a01',
      name: 'House',
      role: 'owner',
      members: [
        ServerMember(id: 'u1', name: 'Sam', role: 'owner'),
        ServerMember(id: 'u2', name: 'Alex', role: 'member'),
      ],
    ),
    ServerHome(
      id: '7c1e1d2a-3b4c-4d5e-8f90-a1b2c3d4e5f6',
      name: 'Flat',
      role: 'read_only',
      members: [ServerMember(id: 'u3', name: 'Dominique', role: 'owner')],
    ),
  ];

  for (final locale in ['en', 'fr']) {
    for (final scale in [1.0, 2.0]) {
      final name = '${locale}_x${scale.toInt()}';

      testWidgets('server address, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, firstStart: true);
        await open(tester, const ServerAddressScreen());
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/server_address_$name.png'),
        );
      });

      testWidgets('server address, plain HTTP warning, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, firstStart: true);
        await open(tester, const ServerAddressScreen());
        await tester.enterText(
          find.byKey(const Key('server-address')),
          'http://172.20.3.4:8000',
        );
        await tester.ensureVisible(find.byKey(const Key('server-sign-in')));
        await tester.tap(find.byKey(const Key('server-sign-in')));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/server_address_http_$name.png'),
        );
      });

      testWidgets('server confirmation, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, firstStart: true);
        await open(
          tester,
          ServerConfirmScreen(
            address: ServerAddress.parse('housecairn.example.com').$1!,
            homes: homes,
          ),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/server_confirm_$name.png'),
        );
      });
    }
  }
}
