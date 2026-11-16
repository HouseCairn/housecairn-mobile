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
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'fixture.dart';

/// The secure store of a test: a map.
class MemoryStore implements Store {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Uint8List value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// A Housecairn server of one home, "House", for the screens of the third
/// way: info, the OAuth token and its revocation, the list of homes, the
/// snapshot, an empty feed and pushes applied. [offline] makes every request
/// fail as with no network; [revokeAccess] makes it refuse the tokens given
/// so far (the person revoked the access on the web page "Connected apps"),
/// while those of a new sign-in are good.
class FakeServer implements ServerHttp {
  late ServerAddress address;
  final requests = <Uri>[];

  /// The `authorization` header of each request, in the order of
  /// [requests]; `null` for a request without one.
  final authorizations = <String?>[];

  /// The tokens sent to `/o/revoke_token/`, in order.
  final revoked = <String>[];
  bool offline = false;

  /// The tokens given so far, access and refresh.
  final _given = <String>{};

  /// The tokens the server refuses.
  final _refused = <String>{};

  /// The access is revoked on the server: every token given so far is
  /// refused, as a call (401) or as a refresh (`invalid_grant`).
  void revokeAccess() => _refused.addAll(_given);

  /// Whether the home is in the access of the next sign-in.
  bool homeOffered = true;

  /// The list of homes answers 500.
  bool homesFail = false;

  /// The number of sign-ins: each gives new tokens.
  int signIns = 0;

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
    if (offline) {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
    requests.add(url);
    authorizations.add(headers['authorization']);
    expect(address.owns(url), isTrue, reason: '$url');
    final form = body == null ? const <String, String>{} : _form(body);
    final bearer = headers['authorization']?.replaceFirst('Bearer ', '');
    final refresh = form['grant_type'] == 'refresh_token'
        ? form['refresh_token']
        : null;
    if (_refused.contains(bearer) || _refused.contains(refresh)) {
      return _json(401, {'error': 'invalid_grant'});
    }
    switch (url.path) {
      case '/api/v1/sync/info':
        return _json(200, {
          'sync': [1],
          'oauth': {
            'authorize': address.resolve('/o/authorize/').toString(),
            'token': address.resolve('/o/token/').toString(),
            'revoke': address.resolve('/o/revoke_token/').toString(),
            'client_id': 'housecairn-mobile',
          },
          if (headers['authorization'] != null) 'server': '0.4.1',
        });
      case '/o/token/':
        signIns++;
        _given.addAll(['hca_access_$signIns', 'hcr_refresh_$signIns']);
        return _json(200, {
          'access_token': 'hca_access_$signIns',
          'refresh_token': 'hcr_refresh_$signIns',
        });
      case '/o/revoke_token/':
        revoked.add(form['token']!);
        return _json(200, {});
      case '/api/v1/sync/homes/':
        if (homesFail) return _json(500, {});
        return _json(200, {
          'homes': [
            if (homeOffered)
              {
                'id': home,
                'name': 'House',
                'role': 'owner',
                'archived_at': null,
                'head': 1,
                'members': [
                  {'id': 'u1', 'name': 'Sam', 'role': 'owner'},
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
        final ops = (jsonDecode(utf8.decode(body!)) as Map)['ops'] as List;
        return _json(200, {
          'head': 1,
          'results': [
            for (var i = 0; i < ops.length; i++) {'i': i, 'status': 'applied'},
          ],
        });
    }
    return _json(404, {});
  }

  static Map<String, String> _form(Uint8List body) {
    try {
      return Uri.splitQueryString(utf8.decode(body));
    } on FormatException {
      return const {};
    }
  }
}

/// The app of a test in the third way, and what it talks to.
class OnServer {
  OnServer(this.state, this.server, this.store, this.opened);

  final AppState state;
  final FakeServer server;
  final MemoryStore store;

  /// The addresses opened in the browser.
  final List<Uri> opened;
}

/// Starts the app in [locale] at its first start, then connects it to
/// [FakeServer] at `https://housecairn.example.com` as the person does:
/// My Housecairn server, the address, the sign-in in the browser, Connect.
Future<OnServer> startOnServer(
  WidgetTester tester, {
  String locale = 'en',
}) async {
  final server = FakeServer();
  final store = MemoryStore();
  final callbacks = StreamController<Uri>.broadcast();
  addTearDown(callbacks.close);
  final opened = <Uri>[];
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
    // No sync two seconds after a change: the tests sync when they say so.
    syncDelay: const Duration(days: 1),
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
  await tester.pumpWidget(HousecairnApp(state: state, locale: Locale(locale)));
  await tester.pumpAndSettle();
  // Built only once in view with the largest text: the list is lazy.
  await tester.scrollUntilVisible(
    find.byKey(const Key('way-server')),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('way-server')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('ways-continue')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('server-address')),
    'https://housecairn.example.com',
  );
  await tester.ensureVisible(find.byKey(const Key('server-sign-in')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('server-sign-in')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('server-connect')));
  await tester.pumpAndSettle();
  return OnServer(state, server, store, opened);
}
