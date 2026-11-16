// SPDX-License-Identifier: AGPL-3.0-only

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoAlertDialog;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/ui/server_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/server_fake.dart';

/// Settings in the third way (docs/adr/0010, "What the screen says"; the
/// card of Settings after D5): the address of the server, read only, with
/// the sentence of the confirmation; Disconnect, which revokes the access
/// at `/o/revoke_token/`, empties the secure store and goes back to the
/// choice of the ways, alone, with the homes kept; "Sign in again" after the
/// server revoked the access.
void main() {
  final words = <String, AppLocalizations>{
    'en': AppLocalizationsEn(),
    'fr': AppLocalizationsFr(),
  };

  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  Future<void> openMore(WidgetTester tester, AppLocalizations l10n) async {
    await tester.tap(destination(l10n.navMore));
    await tester.pumpAndSettle();
  }

  Future<void> tapRow(WidgetTester tester, String key) async {
    await tester.scrollUntilVisible(
      find.byKey(Key(key)),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<bool> storeEmpty(MemoryStore store) async =>
      await ServerCredential.read(store) == null && store.values.isEmpty;

  for (final MapEntry(key: locale, value: l10n) in words.entries) {
    group('in the third way ($locale)', () {
      testWidgets('More shows the address of the server, read only, with '
          'the sentence of ADR 0010 word for word, and Disconnect', (
        tester,
      ) async {
        await onPhone(tester, height: 1600);
        final run = await startOnServer(tester, locale: locale);
        expect(run.state.syncMode, SyncMode.server);
        await openMore(tester, l10n);
        final address = find.byKey(const Key('settings-server-address'));
        expect(address, findsOneWidget);
        expect(
          find.descendant(
            of: address,
            matching: find.text(l10n.settingsServerAddress),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: address,
            matching: find.text('https://housecairn.example.com'),
          ),
          findsOneWidget,
        );
        // Read only: no action, no chevron, nothing opens.
        final row = tester.widget<HcRow>(address);
        expect(row.onTap, isNull);
        expect(
          find.descendant(
            of: address,
            matching: find.text(l10n.serverSeesEverything),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('settings-server-disconnect')),
          findsOneWidget,
        );
        // Nothing to sign in again to while the access works.
        expect(
          find.byKey(const Key('settings-server-sign-in-again')),
          findsNothing,
        );
      });
    });
  }

  test('the sentence is the one of ADR 0010, word for word, in both '
      'languages', () {
    expect(
      AppLocalizationsEn().serverSeesEverything,
      'This server will see everything in these homes: tasks, rooms, notes, '
      'amounts and photos. So can the people who run it, the people who are '
      'members of these homes on it, and its backups. Continue only with a '
      'server you trust.',
    );
    expect(
      AppLocalizationsFr().serverSeesEverything,
      'Ce serveur verra tout de ces logements : tâches, pièces, notes, '
      "montants et photos. Tout comme les personnes qui l'administrent, les "
      'membres de ces logements sur ce serveur, et ses sauvegardes. Ne '
      "continuez qu'avec un serveur de confiance.",
    );
  });

  group('Disconnect', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final ios = platform == TargetPlatform.iOS;

      testWidgets('asks in the dialog of ${platform.name}; Cancel changes '
          'nothing', (tester) async {
        await onPlatform(platform, () async {
          await onPhone(tester, height: 1600);
          final run = await startOnServer(tester);
          final l10n = words['en']!;
          await openMore(tester, l10n);
          await tapRow(tester, 'settings-server-disconnect');
          expect(find.byKey(const Key('way-leave-server')), findsOneWidget);
          expect(find.text(l10n.settingsServerDisconnectTitle), findsOneWidget);
          expect(
            find.byType(CupertinoAlertDialog),
            ios ? findsOneWidget : findsNothing,
          );
          expect(find.byType(AlertDialog), ios ? findsNothing : findsOneWidget);
          await tester.tap(find.byKey(const Key('way-cancel')));
          await tester.pumpAndSettle();
          expect(run.state.syncMode, SyncMode.server);
          expect(run.server.revoked, isEmpty);
          expect(await ServerCredential.read(run.store), isNotNull);
        });
      });

      testWidgets('revokes the access at /o/revoke_token/, empties the '
          'secure store and goes back to the ways, alone, with the homes '
          '(${platform.name})', (tester) async {
        await onPlatform(platform, () async {
          await onPhone(tester, height: 1600);
          final run = await startOnServer(tester);
          final l10n = words['en']!;
          final homes = [for (final h in run.state.homes) (h.id, h.name)];
          expect(homes, [(FakeServer.home, 'House')]);
          final refresh = (await ServerCredential.read(run.store))!.refresh;
          await openMore(tester, l10n);
          await tapRow(tester, 'settings-server-disconnect');
          await tester.tap(find.byKey(const Key('way-confirm')));
          await tester.pumpAndSettle();
          expect(run.server.revoked, [refresh]);
          expect(
            run.server.requests.last.path,
            '/o/revoke_token/',
            reason: 'nothing after the revocation',
          );
          expect(await storeEmpty(run.store), isTrue);
          expect(run.state.syncMode, SyncMode.alone);
          expect(await run.state.repository.serverAddress(), isNull);
          expect([for (final h in run.state.homes) (h.id, h.name)], homes);
          // Back to the choice of the ways: Alone in use, no server rows.
          expect(
            find.byKey(const Key('settings-server-address')),
            findsNothing,
          );
          expect(find.byKey(const Key('way-row-sync')), findsNothing);
          expect(
            find.descendant(
              of: find.byKey(const Key('way-row-alone')),
              matching: find.text(l10n.wayInUse),
            ),
            findsOneWidget,
          );
        });
      });
    }

    testWidgets('with no network and nothing unsent: the store is emptied '
        'all the same, the phone is alone, the homes stay', (tester) async {
      await onPhone(tester, height: 1600);
      final run = await startOnServer(tester);
      final l10n = words['en']!;
      await openMore(tester, l10n);
      run.server.offline = true;
      await tapRow(tester, 'settings-server-disconnect');
      await tester.tap(find.byKey(const Key('way-confirm')));
      await tester.pumpAndSettle();
      expect(run.server.revoked, isEmpty, reason: 'the server was not reached');
      expect(await storeEmpty(run.store), isTrue);
      expect(run.state.syncMode, SyncMode.alone);
      expect([for (final h in run.state.homes) h.name], ['House']);
    });

    testWidgets('with no network and a change unsent: it is named, and '
        'leaving keeps it on the phone only; Cancel stays on the server', (
      tester,
    ) async {
      await onPhone(tester, height: 1600);
      final run = await startOnServer(tester);
      final l10n = words['en']!;
      await run.state.repository.createRoom(FakeServer.home, name: 'Attic');
      await run.state.refresh();
      run.server.offline = true;
      await openMore(tester, l10n);
      await tapRow(tester, 'settings-server-disconnect');
      expect(find.text(l10n.wayLeaveServerUnsent(1)), findsOneWidget);
      await tester.tap(find.byKey(const Key('way-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('way-leave-server-unsent')), findsOneWidget);
      expect(find.text('• Attic'), findsOneWidget);
      // Cancel: still on the server, the access kept.
      await tester.tap(find.byKey(const Key('way-cancel')));
      await tester.pumpAndSettle();
      expect(run.state.syncMode, SyncMode.server);
      expect(await ServerCredential.read(run.store), isNotNull);
      // Again, and leave with the change on this phone only.
      await tapRow(tester, 'settings-server-disconnect');
      await tester.tap(find.byKey(const Key('way-confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('way-confirm')));
      await tester.pumpAndSettle();
      expect(run.state.syncMode, SyncMode.alone);
      expect(await storeEmpty(run.store), isTrue);
      final rooms = await run.state.repository.rooms(FakeServer.home);
      expect([for (final r in rooms) r.name], contains('Attic'));
      expect(await run.state.unsentChanges(), isEmpty);
    });

    testWidgets('the access revoked on the server: Disconnect still '
        'empties the store and keeps the homes', (tester) async {
      await onPhone(tester, height: 1600);
      final run = await startOnServer(tester);
      final l10n = words['en']!;
      run.server.revokeAccess();
      await run.state.syncWithServer();
      await tester.pumpAndSettle();
      expect(run.state.serverSync.stopped, ServerStop.disconnected);
      await openMore(tester, l10n);
      await tapRow(tester, 'settings-server-disconnect');
      await tester.tap(find.byKey(const Key('way-confirm')));
      await tester.pumpAndSettle();
      expect(await storeEmpty(run.store), isTrue);
      expect(run.state.syncMode, SyncMode.alone);
      expect([for (final h in run.state.homes) h.name], ['House']);
    });
  });

  group('the access revoked on the server', () {
    /// The phone stopped by the server: the access of the first sign-in
    /// (`hca_access_1`) is revoked, and a round of sync found it so.
    Future<OnServer> stopped(WidgetTester tester) async {
      await onPhone(tester, height: 1600);
      final run = await startOnServer(tester);
      run.server.revokeAccess();
      await run.state.syncWithServer();
      await tester.pumpAndSettle();
      expect(run.state.serverSync.stopped, ServerStop.disconnected);
      return run;
    }

    /// What the phone keeps of the server, to compare byte for byte.
    /// A list, which `expect` compares deeply.
    Future<List<Object?>> kept(OnServer run) async => [
      {for (final e in run.store.values.entries) e.key: e.value.toList()},
      await run.state.repository.serverState.readServerState(),
    ];

    testWidgets('Settings offers to sign in again; the new access, '
        'confirmed, resumes the sync where it was, and every request '
        'after Connect carries it, none the old one', (tester) async {
      final run = await stopped(tester);
      final l10n = words['en']!;
      await openMore(tester, l10n);
      expect(
        find.byKey(const Key('settings-server-sign-in-again')),
        findsOneWidget,
      );
      // A change made while stopped: it goes with the first round after
      // Connect.
      await run.state.repository.createRoom(FakeServer.home, name: 'Attic');
      final before = run.opened.length;
      await tapRow(tester, 'settings-server-sign-in-again');
      expect(run.opened, hasLength(before + 1), reason: 'the browser');
      expect(find.byType(ServerConfirmScreen), findsOneWidget);
      expect(find.text(l10n.serverSeesEverything), findsOneWidget);
      expect(find.byKey(const Key('server-reconnect-dropped')), findsNothing);
      expect(
        (await ServerCredential.read(run.store))!.access,
        'hca_access_1',
        reason: 'the new access is in memory only until Connect',
      );
      final atConnect = run.server.requests.length;
      await tester.tap(find.byKey(const Key('server-connect')));
      await tester.pumpAndSettle();
      // The token each request carried, as the server saw it: the new one
      // on every request after Connect, never the old one.
      final after = [
        for (var i = atConnect; i < run.server.requests.length; i++)
          (run.server.requests[i].path, run.server.authorizations[i]),
      ];
      expect(
        [for (final (_, authorization) in after) authorization],
        isNot(contains('Bearer hca_access_1')),
        reason: 'no request under the old access',
      );
      for (final (path, authorization) in after) {
        if (path == '/o/revoke_token/') continue;
        expect(authorization, 'Bearer hca_access_2', reason: path);
      }
      expect([
        for (final (path, _) in after) path,
      ], contains('/api/v1/sync/homes/${FakeServer.home}/push'));
      expect(run.state.serverSync.stopped, isNull);
      expect(run.state.serverSync.lastSync, isNotNull);
      expect(run.state.syncMode, SyncMode.server);
      expect((await ServerCredential.read(run.store))!.access, 'hca_access_2');
      expect([for (final h in run.state.homes) h.name], ['House']);
      expect(await run.state.unsentChanges(), isEmpty, reason: 'Attic sent');
      expect(run.server.revoked, [
        'hcr_refresh_1',
      ], reason: 'the old access is revoked at best: it may only be expired');
      await openMore(tester, l10n);
      expect(
        find.byKey(const Key('settings-server-sign-in-again')),
        findsNothing,
      );
    });

    testWidgets('a new access without a home of the phone names it before '
        'Connect; Cancel revokes the new access and keeps the phone as it '
        'was', (tester) async {
      final run = await stopped(tester);
      final l10n = words['en']!;
      run.server.homeOffered = false;
      final was = await kept(run);
      await openMore(tester, l10n);
      await tapRow(tester, 'settings-server-sign-in-again');
      expect(
        find.text(l10n.settingsServerReconnectDropped('House')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byKey(const Key('server-cancel')));
      await tester.tap(find.byKey(const Key('server-cancel')));
      await tester.pumpAndSettle();
      expect(run.server.revoked, ['hcr_refresh_2'], reason: 'the new access');
      expect(
        await kept(run),
        was,
        reason: 'store and server state as they were',
      );
      expect(run.state.syncMode, SyncMode.server);
      expect(run.state.serverSync.stopped, ServerStop.disconnected);
      expect([for (final h in run.state.homes) h.name], ['House']);
    });

    testWidgets('the system back on the confirmation drops the new access; '
        'the next sync sends nothing and loses no home', (tester) async {
      final run = await stopped(tester);
      final l10n = words['en']!;
      // A sync under the new access would take House off the phone.
      run.server.homeOffered = false;
      final was = await kept(run);
      await openMore(tester, l10n);
      await tapRow(tester, 'settings-server-sign-in-again');
      expect(find.byType(ServerConfirmScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ServerConfirmScreen), findsNothing);
      expect(run.server.revoked, ['hcr_refresh_2'], reason: 'the new access');
      expect(
        await kept(run),
        was,
        reason: 'store and server state as they were',
      );
      final sent = run.server.requests.length;
      // What "Sync now" and the opening of the app call.
      await run.state.syncWithServer();
      await tester.pumpAndSettle();
      expect(run.server.requests, hasLength(sent), reason: 'no request');
      expect(run.state.serverSync.stopped, ServerStop.disconnected);
      expect([for (final h in run.state.homes) h.name], ['House']);
      expect(await kept(run), was);
    });

    testWidgets('the homes of the new access cannot be read: it is revoked '
        'and forgotten, the phone stays as it was', (tester) async {
      final run = await stopped(tester);
      final l10n = words['en']!;
      run.server.homesFail = true;
      final was = await kept(run);
      await openMore(tester, l10n);
      await tapRow(tester, 'settings-server-sign-in-again');
      expect(find.byType(ServerConfirmScreen), findsNothing);
      expect(run.server.revoked, ['hcr_refresh_2'], reason: 'the new access');
      expect(
        await kept(run),
        was,
        reason: 'store and server state as they were',
      );
      run.server.homesFail = false;
      final sent = run.server.requests.length;
      await run.state.syncWithServer();
      expect(run.server.requests, hasLength(sent), reason: 'no request');
      expect([for (final h in run.state.homes) h.name], ['House']);
    });
  });

  group('alone on this phone', () {
    testWidgets('no server rows; with no home, My Housecairn server opens '
        'the address screen of lot 4b', (tester) async {
      await onPhone(tester, height: 1600);
      final state = await pumpApp(tester);
      for (final h in state.homes) {
        await state.repository.purgeHome(h.id);
      }
      await state.refresh();
      expect(state.homes, isEmpty);
      final l10n = words['en']!;
      await openMore(tester, l10n);
      expect(find.byKey(const Key('settings-server-address')), findsNothing);
      expect(find.byKey(const Key('settings-server-disconnect')), findsNothing);
      await tapRow(tester, 'way-row-server');
      expect(find.byType(ServerAddressScreen), findsOneWidget);
    });
  });

  group('accessibility', () {
    for (final scale in [1.0, 2.0]) {
      testWidgets('the rows of the server meet the guidelines at text '
          'scale $scale', (tester) async {
        final handle = tester.ensureSemantics();
        await onPhone(tester, height: 1600, textScale: scale);
        await startOnServer(tester);
        await openMore(tester, words['en']!);
        await tester.scrollUntilVisible(
          find.byKey(const Key('settings-server-disconnect')),
          100,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        // The address is read, not a button; Disconnect is a button that
        // says what it does.
        final address = tester.getSemantics(
          find.byKey(const Key('settings-server-address')),
        );
        expect(address.flagsCollection.isButton, isFalse);
        expect(
          address.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        final disconnect = tester
            .getSemantics(find.byKey(const Key('settings-server-disconnect')))
            .getSemanticsData();
        expect(disconnect.hasAction(SemanticsAction.tap), isTrue);
        expect(disconnect.label, contains('Disconnect'));
        expect(disconnect.label, contains('Your homes stay on it.'));
        handle.dispose();
      });
    }
  });
}
