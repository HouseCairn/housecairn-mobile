// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoAlertDialog;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';

/// The sync with the server in the app (lot 4b, review of PR #32): when it
/// runs (opening, back to the front, a moment after a change, one round at
/// a time), and what the screens say of it (the server stopped the phone,
/// changes it refused, notices), in English and in French.
void main() {
  final address = ServerAddress.parse('https://hc.example.com').$1!;
  const delay = Duration(seconds: 1);

  late _Server server;
  late _Store store;
  late String home;

  /// A phone in the third way, with the server's home and its room Kitchen,
  /// nothing waiting to be sent.
  Future<Repository> serverPhone() async {
    final repo = await openRepository();
    addTearDown(repo.db.close);
    home = await repo.createHome(name: 'House');
    final kitchen = await repo.createRoom(home, name: 'Kitchen');
    final out = await repo.outgoing();
    await repo.acknowledge(out.last.seq);
    server = _Server(home, kitchen);
    store = _Store();
    await ServerCredential(
      access: 'hca_one',
      refresh: 'hcr_one',
      token: address.resolve('/o/token/'),
      revoke: address.resolve('/o/revoke_token/'),
    ).write(store);
    await repo.setServerAddress(address.display);
    await repo.setSyncMode(SyncMode.server);
    return repo;
  }

  AppState stateOf(Repository repo) => AppState(
    repo,
    store: store,
    serverHttp: (_) => server,
    syncDelay: delay,
    photoProcessor: (bytes) async => processPhoto(bytes),
    loadTemplates: () async =>
        parseTemplates(File('assets/task_templates.yaml').readAsStringSync()),
    openUrl: (_) async => true,
  );

  Future<AppState> start(WidgetTester tester, String locale) async {
    await onPhone(tester, height: 1200);
    final state = stateOf(await serverPhone());
    await tester.pumpWidget(
      HousecairnApp(state: state, locale: Locale(locale)),
    );
    await tester.pumpAndSettle();
    return state;
  }

  /// The delay after a change, and the round it starts.
  Future<void> afterDelay(WidgetTester tester) async {
    await tester.pump(delay);
    await tester.pumpAndSettle();
  }

  Finder inBanner(String text) => find.descendant(
    of: find.byKey(const Key('sync-banner')),
    matching: find.text(text),
  );

  group('when the phone syncs', () {
    testWidgets('at the opening, a moment after the last change, and when the '
        'app comes back to the front', (tester) async {
      final state = await start(tester, 'en');
      expect(server.pulls, 1, reason: 'the opening');
      await state.repository.createRoom(home, name: 'Hall');
      await tester.pump(delay * 0.6);
      // Another change before the delay: one round after the last one.
      await state.repository.createRoom(home, name: 'Cellar');
      await tester.pump(delay * 0.6);
      expect(server.pulls, 1);
      expect(server.pushedNames, isEmpty);
      await afterDelay(tester);
      expect(server.pulls, 2);
      expect(server.pushedNames, ['Hall', 'Cellar']);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(server.pulls, 3, reason: 'back to the front');
      expect(find.byKey(const Key('sync-banner')), findsNothing);
    });

    test('one round at a time: asked while one runs, one more follows it, '
        'never two together', () async {
      final state = stateOf(await serverPhone());
      addTearDown(state.dispose);
      await state.refresh();
      server.gate = Completer<void>();
      final asked = [
        state.syncWithServer(),
        state.syncWithServer(),
        state.syncWithServer(),
      ];
      await pumpEventQueue();
      expect(server.pulls, 0, reason: 'held at the first call');
      server.gate!.complete();
      await Future.wait(asked);
      expect(server.mostAtOnce, 1);
      expect(server.pulls, 2, reason: 'the round, then one for the asks');
    });

    test('a refused change dropped: the field shows the server\'s value at '
        'once, and nothing waits (maintainer\'s decision)', () async {
      final repo = await serverPhone();
      final state = stateOf(repo);
      addTearDown(state.dispose);
      await state.refresh();
      await state.syncWithServer();
      final kitchen = server.kitchen;
      server.rejectNamed = 'Pantry';
      await repo.updateRoom(kitchen, const RoomInput(name: 'Pantry'));
      await state.syncWithServer();
      expect(state.serverSync.refused, hasLength(1));
      expect((await repo.room(kitchen))!.name, 'Pantry');
      final snapshots = server.pulls;
      await state.dropRefused(state.serverSync.refused.single.id);
      expect((await repo.room(kitchen))!.name, 'Kitchen');
      expect(server.pulls, greaterThan(snapshots), reason: 'read again');
      expect(state.serverSync.refused, isEmpty);
      expect(await repo.outgoing(), isEmpty);
      expect(await repo.serverRereads(), isEmpty);
      expect(server.pushedNames, isNot(contains('Pantry')));
      // Another sync changes nothing more.
      await state.syncWithServer();
      expect((await repo.room(kitchen))!.name, 'Kitchen');
    });

    test('a refused change dropped out of reach of the server: the value '
        'comes back with the next sync', () async {
      final repo = await serverPhone();
      final state = stateOf(repo);
      addTearDown(state.dispose);
      await state.refresh();
      await state.syncWithServer();
      final kitchen = server.kitchen;
      server.rejectNamed = 'Pantry';
      await repo.updateRoom(kitchen, const RoomInput(name: 'Pantry'));
      await state.syncWithServer();
      server.offline = true;
      await state.dropRefused(state.serverSync.refused.single.id);
      expect(state.serverSync.refused, isEmpty);
      expect(await repo.serverRereads(), isNotEmpty);
      server.offline = false;
      await state.syncWithServer();
      expect((await repo.room(kitchen))!.name, 'Kitchen');
      expect(await repo.serverRereads(), isEmpty);
      expect(await repo.outgoing(), isEmpty);
    });

    test('not in the other ways', () async {
      final repo = await openRepository();
      addTearDown(repo.db.close);
      await repo.setSyncMode(SyncMode.alone);
      final state = AppState(repo, serverHttp: (_) => throw StateError('net'));
      addTearDown(state.dispose);
      await state.open(firstHomeName: 'Home');
      await repo.createRoom(state.homes.single.id, name: 'Hall');
      state.syncSoon();
      expect(await state.syncWithServer(), isNull);
    });
  });

  for (final (locale, AppLocalizations l10n) in [
    ('en', AppLocalizationsEn()),
    ('fr', AppLocalizationsFr()),
  ]) {
    group('what the app says ($locale)', () {
      testWidgets('the revocation stops the phone at its next call, and it '
          'says so; it then waits for the person', (tester) async {
        final state = await start(tester, locale);
        server.revoke();
        await state.repository.createRoom(home, name: 'Hall');
        await afterDelay(tester);
        expect(inBanner(l10n.serverDisconnected), findsOneWidget);
        expect(state.serverSync.stoppedForGood, isTrue);
        // No more rounds by itself: a sign-in is needed.
        final calls = server.calls;
        await state.repository.createRoom(home, name: 'Cellar');
        await afterDelay(tester);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(server.calls, calls);
        // The homes stay on the phone; the screen of the sync says why.
        expect(
          (await state.repository.homes()).map((h) => h.name),
          contains('House'),
        );
        await tester.tap(find.byKey(const Key('sync-banner')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const Key('sync-problem'))).data,
          l10n.serverDisconnected,
        );
      });

      testWidgets('a change the server refused is on its line with its '
          'reason; it is sent again, or no longer sent', (tester) async {
        final state = await start(tester, locale);
        server.rejectNamed = 'Hall';
        await state.repository.createRoom(home, name: 'Hall');
        await afterDelay(tester);
        expect(inBanner(l10n.syncRefusedCount(1)), findsOneWidget);
        await tester.tap(find.byKey(const Key('sync-banner')));
        await tester.pumpAndSettle();
        final line = find.byKey(
          Key('refused-${state.serverSync.refused[0].id}'),
        );
        expect(
          find.descendant(of: line, matching: find.text('Hall')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: line,
            matching: find.text(l10n.syncRefusedForbidden),
          ),
          findsOneWidget,
        );
        // The cause is fixed on the server: sent again, taken.
        server.rejectNamed = null;
        await tester.tap(find.text(l10n.syncSendAgain));
        await tester.pumpAndSettle();
        expect(state.serverSync.refused, isEmpty);
        expect(server.pushedNames, contains('Hall'));
        // Another refused, no longer sent: the phone takes back what the
        // server has, and the server has no room Attic.
        server.rejectNamed = 'Attic';
        await state.repository.createRoom(home, name: 'Attic');
        await afterDelay(tester);
        expect(find.text('Attic'), findsOneWidget);
        await tester.tap(find.text(l10n.syncStopSending));
        await tester.pumpAndSettle();
        expect(state.serverSync.refused, isEmpty);
        expect(await state.repository.outgoing(), isEmpty);
        expect(
          (await state.repository.rooms(home)).map((r) => r.name),
          isNot(contains('Attic')),
        );
        expect(server.pushedNames, isNot(contains('Attic')));
      });

      testWidgets('a row deleted and purged on the server is dropped after a '
          '410, and the app says so until it is read', (tester) async {
        final state = await start(tester, locale);
        expect(await state.repository.serverSeenIn(home), isNotEmpty);
        server
          ..expired = true
          ..withKitchen = false;
        await state.syncWithServer();
        await tester.pumpAndSettle();
        expect(inBanner(l10n.syncNoticesCount(1)), findsOneWidget);
        await tester.tap(find.byKey(const Key('sync-banner')));
        await tester.pumpAndSettle();
        expect(find.text(l10n.syncNoticeDropped), findsOneWidget);
        await tester.tap(find.byKey(const Key('sync-notices-read')));
        await tester.pumpAndSettle();
        expect(find.text(l10n.syncNoticeDropped), findsNothing);
        expect(state.serverSync.notices, isEmpty);
      });

      testWidgets('the server out of reach: the banner says the changes stay '
          'and go later', (tester) async {
        final state = await start(tester, locale);
        server.offline = true;
        await state.repository.createRoom(home, name: 'Hall');
        await afterDelay(tester);
        expect(inBanner(l10n.syncUnreachable), findsOneWidget);
        expect(await state.repository.outgoing(), hasLength(1));
        server.offline = false;
        await state.repository.createRoom(home, name: 'Cellar');
        await afterDelay(tester);
        expect(find.byKey(const Key('sync-banner')), findsNothing);
        expect(server.pushedNames, ['Hall', 'Cellar']);
      });
    });
  }

  group('the dialogs of the moves follow the platform (ADR 0011)', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('leaving the server asks with the dialog of '
          '${platform.name}', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          final state = await start(tester, 'en');
          final l10n = AppLocalizationsEn();
          await tester.tap(find.text(l10n.navMore));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.byKey(const Key('way-row-alone')),
            100,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('way-row-alone')));
          await tester.pumpAndSettle();
          final ios = platform == TargetPlatform.iOS;
          expect(find.byKey(const Key('way-leave-server')), findsOneWidget);
          expect(
            find.byType(CupertinoAlertDialog),
            ios ? findsOneWidget : findsNothing,
          );
          expect(find.byType(AlertDialog), ios ? findsNothing : findsOneWidget);
          await tester.tap(find.byKey(const Key('way-cancel')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('way-leave-server')), findsNothing);
          expect(state.syncMode, SyncMode.server);
          // Server out of reach: the second dialog names the changes.
          server.offline = true;
          await state.repository.createRoom(home, name: 'Hall');
          await tester.tap(find.byKey(const Key('way-row-alone')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('way-confirm')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('way-leave-server-unsent')),
            findsOneWidget,
          );
          expect(
            find.byType(CupertinoAlertDialog),
            ios ? findsOneWidget : findsNothing,
          );
          expect(find.textContaining('Hall'), findsOneWidget);
          await tester.tap(find.byKey(const Key('way-cancel')));
          await tester.pumpAndSettle();
          expect(state.syncMode, SyncMode.server);
          expect(await state.repository.outgoing(), hasLength(1));
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  });
}

class _Store implements Store {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Uint8List value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// A server of one home with the room Kitchen: the list of homes, the
/// snapshot, the feed, pushes, the refresh and the revocation of the access.
class _Server implements ServerHttp {
  _Server(this.home, this.kitchen);

  final String home;
  final String kitchen;
  static const device = 'q2Xh0dVt3kWmYc1bS8fP9A';

  bool offline = false;
  bool expired = false;
  bool withKitchen = true;
  bool _revoked = false;
  String? rejectNamed;
  Completer<void>? gate;

  int calls = 0;
  int pulls = 0;
  int _active = 0;
  int mostAtOnce = 0;
  final pushedNames = <String>[];

  void revoke() => _revoked = true;

  ServerReply _json(int status, Object body) =>
      ServerReply(status, utf8.encode(jsonEncode(body)));

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    calls++;
    _active++;
    mostAtOnce = max(mostAtOnce, _active);
    try {
      if (gate case final g?) await g.future;
      return _answer(url, headers, body);
    } finally {
      _active--;
    }
  }

  ServerReply _answer(Uri url, Map<String, String> headers, Uint8List? body) {
    if (offline) {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
    final path = url.path;
    if (path == '/o/token/') {
      if (_revoked) return _json(400, {'error': 'invalid_grant'});
      return _json(200, {'access_token': 'hca_one', 'refresh_token': 'hcr_x'});
    }
    if (path == '/o/revoke_token/') return _json(200, {});
    if (_revoked) return _json(401, {'detail': 'Revoked.'});
    if (path == '/api/v1/sync/homes/') {
      return _json(200, {
        'homes': [
          {'id': home, 'name': 'House', 'role': 'owner', 'members': <Object>[]},
        ],
        'gone': <Object>[],
      });
    }
    if (path.endsWith('/snapshot')) {
      pulls++;
      Map<String, Object?> row(String t, String id, String name) => {
        't': t,
        'h': home,
        'id': id,
        'f': {
          'name': [name, '0193a1b2c3d40001', device],
        },
      };
      return ServerReply(
        200,
        utf8.encode(
          [
            row('homes.home', home, 'House'),
            if (withKitchen) row('rooms.room', kitchen, 'Kitchen'),
            {'covers': 5},
          ].map((l) => '${jsonEncode(l)}\n').join(),
        ),
      );
    }
    if (path.endsWith('/changes')) {
      if (expired) {
        expired = false;
        return _json(410, {'code': 'cursor_expired'});
      }
      if (url.queryParameters['limit'] != '1') pulls++;
      return _json(200, {'changes': <Object>[], 'head': 5, 'more': false});
    }
    if (path.endsWith('/push')) {
      final ops = (jsonDecode(utf8.decode(body!)) as Map)['ops'] as List;
      final names = [for (final op in ops) ((op as Map)['f'] as Map?)?['name']];
      for (final name in names) {
        if (name is String && name != rejectNamed) pushedNames.add(name);
      }
      return _json(200, {
        'head': 6,
        'results': [
          for (var i = 0; i < ops.length; i++)
            names[i] == rejectNamed
                ? {'i': i, 'status': 'rejected', 'code': 'forbidden'}
                : {'i': i, 'status': 'applied'},
        ],
      });
    }
    return _json(404, {});
  }
}
