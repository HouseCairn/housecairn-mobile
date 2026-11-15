// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/ui/server_screens.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';

/// The screens of the third way (docs/plan.md, lot 4b): address, plain HTTP
/// warning, sign-in in the browser, confirmation, against a scripted server.
void main() {
  final l10n = AppLocalizationsEn();

  late _Server server;
  late _MemoryStore store;
  late StreamController<Uri> callbacks;
  late List<Uri> opened;

  Future<AppState> start(WidgetTester tester) async {
    await onPhone(tester, height: 1600);
    server = _Server();
    store = _MemoryStore();
    callbacks = StreamController<Uri>.broadcast();
    addTearDown(callbacks.close);
    opened = [];
    final repository = await openRepository();
    addTearDown(repository.db.close);
    final state = AppState(
      repository,
      photoProcessor: (bytes) async => processPhoto(bytes),
      loadTemplates: () async =>
          parseTemplates(File('assets/task_templates.yaml').readAsStringSync()),
      store: store,
      serverHttp: (address) => server..address = address,
      signInCallbacks: callbacks.stream,
      openUrl: (url) async {
        opened.add(url);
        // The browser: the person signs in and presses Connect.
        final q = url.queryParameters;
        scheduleMicrotask(
          () => callbacks.add(
            Uri.parse('$oauthRedirectUri?code=the-code&state=${q['state']}'),
          ),
        );
        return true;
      },
    );
    await tester.pumpWidget(
      HousecairnApp(state: state, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('way-server')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ways-continue')));
    await tester.pumpAndSettle();
    return state;
  }

  Future<void> type(WidgetTester tester, String address) async {
    await tester.enterText(find.byKey(const Key('server-address')), address);
    await tester.ensureVisible(find.byKey(const Key('server-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('server-sign-in')));
    await tester.pumpAndSettle();
  }

  testWidgets('http:// to a name is refused, .local included, before any '
      'request', (tester) async {
    await start(tester);
    for (final typed in [
      'http://housecairn.local:8000',
      'http://example.com',
    ]) {
      await type(tester, typed);
      expect(find.text(l10n.serverHttpNeedsLocalIp), findsOneWidget);
    }
    await type(tester, 'ftp://example.com');
    expect(find.text(l10n.serverAddressInvalid), findsOneWidget);
    expect(server.requests, isEmpty);
    expect(opened, isEmpty);
  });

  testWidgets('http:// to a local IP literal shows the warning first', (
    tester,
  ) async {
    await start(tester);
    await type(tester, 'http://172.20.3.4:8000');
    expect(find.byKey(const Key('server-http-warning')), findsOneWidget);
    expect(server.requests, isEmpty, reason: 'nothing before the warning');
    await tester.tap(find.byKey(const Key('server-http-continue')));
    await tester.pumpAndSettle();
    expect(server.requests, isNotEmpty);
    expect(find.byType(ServerConfirmScreen), findsOneWidget);
    expect(find.text(l10n.serverNotEncrypted), findsOneWidget);
  });

  testWidgets('a server too old is refused with the version needed', (
    tester,
  ) async {
    await start(tester);
    server.tooOld = true;
    await type(tester, 'https://housecairn.example.com');
    expect(find.text(l10n.serverTooOld(minimumServerVersion)), findsOneWidget);
    expect(opened, isEmpty);
  });

  testWidgets('sign-in in the browser with PKCE, then the confirmation names '
      'the server, says what it sees and lists the homes; Connect brings '
      'them', (tester) async {
    final state = await start(tester);
    await type(tester, 'https://housecairn.example.com');
    expect(opened.single.host, 'housecairn.example.com');
    expect(opened.single.queryParameters['code_challenge_method'], 'S256');
    expect(server.tokenForm['code'], 'the-code');
    expect(server.tokenForm['code_verifier'], isNotEmpty);
    expect(find.byType(ServerConfirmScreen), findsOneWidget);
    expect(find.text('https://housecairn.example.com'), findsOneWidget);
    expect(find.text(l10n.serverSeesEverything), findsOneWidget);
    expect(find.text('House'), findsOneWidget);
    expect(find.text(l10n.serverReadOnly), findsNothing);
    expect(
      await state.repository.storedSyncMode(),
      isNull,
      reason: 'nothing stored before Connect',
    );
    expect(state.homes, isEmpty, reason: 'nothing received before Connect');
    await tester.tap(find.byKey(const Key('server-connect')));
    await tester.pumpAndSettle();
    expect(await state.repository.storedSyncMode(), SyncMode.server);
    expect(state.homes.map((h) => h.name), ['House']);
    expect(find.byType(ServerConfirmScreen), findsNothing);
    // The credential is in Store, never in the database.
    expect(store.values.keys, [ServerCredential.storeKey]);
    final dump = await state.repository.db
        .customSelect('SELECT key, value FROM local_settings')
        .get();
    expect(
      dump.map((r) => '${r.data['value']}').join(),
      isNot(contains('hca_')),
    );
    expect(
      dump.map((r) => '${r.data['value']}').join(),
      isNot(contains('hcr_')),
    );
  });

  testWidgets('a read-only home is marked; Cancel forgets the access', (
    tester,
  ) async {
    final state = await start(tester);
    server.role = 'read_only';
    await type(tester, 'https://housecairn.example.com');
    expect(find.text(l10n.serverReadOnly), findsOneWidget);
    await tester.tap(find.byKey(const Key('server-cancel')));
    await tester.pumpAndSettle();
    expect(store.values, isEmpty);
    expect(server.revoked, isTrue);
    expect(await state.repository.storedSyncMode(), isNull);
  });

  testWidgets('the screens fit 360 px with the largest text', (tester) async {
    await start(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    await type(tester, 'http://172.20.3.4:8000');
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('server-http-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('server-http-continue')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ServerConfirmScreen), findsOneWidget);
  });
}

class _MemoryStore implements Store {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Uint8List value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _Server implements ServerHttp {
  late ServerAddress address;
  final requests = <Uri>[];
  bool tooOld = false;
  bool revoked = false;
  String role = 'owner';
  Map<String, String> tokenForm = {};

  static const home = '0b6f2f0e-6c5a-4d33-9a7e-0d6b8f5c1a01';
  static const device = 'q2Xh0dVt3kWmYc1bS8fP9A';

  ServerReply _json(int status, Object body) =>
      ServerReply(status, utf8.encode(jsonEncode(body)));

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    requests.add(url);
    expect(address.owns(url), isTrue, reason: '$url');
    switch (url.path) {
      case '/api/v1/sync/info':
        if (tooOld) return _json(404, {'detail': 'Not found.'});
        return _json(200, {
          'sync': [1],
          'oauth': {
            'authorize': address.resolve('/o/authorize/').toString(),
            'token': address.resolve('/o/token/').toString(),
            'revoke': address.resolve('/o/revoke_token/').toString(),
            'client_id': 'housecairn-mobile',
          },
          if (headers['authorization'] != null) 'server': '0.4.0',
        });
      case '/o/token/':
        tokenForm = Uri.splitQueryString(utf8.decode(body!));
        return _json(200, {
          'access_token': 'hca_access',
          'refresh_token': 'hcr_refresh',
        });
      case '/o/revoke_token/':
        revoked = true;
        return _json(200, {});
      case '/api/v1/sync/homes/':
        return _json(200, {
          'homes': [
            {
              'id': home,
              'name': 'House',
              'role': role,
              'archived_at': null,
              'head': 1,
              'members': [
                {'id': 'u1', 'name': 'Sam', 'role': role},
              ],
            },
          ],
          'gone': <Object>[],
        });
      case '/api/v1/sync/homes/$home/snapshot':
        final lines = [
          {
            't': 'homes.home',
            'h': home,
            'id': home,
            'f': {
              'name': ['House', '0193a1b2c3d40001', device],
              'currency': ['EUR', '0193a1b2c3d40001', device],
              'hemisphere': ['north', '0193a1b2c3d40001', device],
            },
          },
          {'members': <Object>[]},
          {'covers': 1},
        ];
        return ServerReply(
          200,
          utf8.encode(lines.map((l) => '${jsonEncode(l)}\n').join()),
        );
      case '/api/v1/sync/homes/$home/changes':
        return _json(200, {'changes': <Object>[], 'head': 1, 'more': false});
      case '/api/v1/sync/homes/$home/push':
        return _json(200, {'head': 1, 'results': <Object>[]});
    }
    return _json(404, {});
  }
}
