// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../core/store.dart';
import 'server_address.dart';
import 'server_http.dart';
import 'server_sign_in.dart';
import 'server_transport.dart';

/// The redirects of the browser back to the app
/// (`app.housecairn.mobile:/oauth/callback`), as the system gives them to
/// Flutter. Registered before the app starts, so that it sees them before
/// the navigator, which would take them for a route.
class SignInCallbacks with WidgetsBindingObserver {
  SignInCallbacks._();

  static final instance = SignInCallbacks._();

  final _controller = StreamController<Uri>.broadcast();

  Stream<Uri> get stream => _controller.stream;

  void listen() => WidgetsBinding.instance.addObserver(this);

  /// Gives [uri] to the sign-in waiting for it; `true` when it was one.
  bool deliver(Uri uri) {
    final expected = Uri.parse(oauthRedirectUri);
    final path = uri.path;
    final isCallback =
        (uri.scheme == expected.scheme || uri.scheme.isEmpty) &&
        path == expected.path;
    if (isCallback) {
      _controller.add(
        uri.scheme.isEmpty ? expected.replace(query: uri.query) : uri,
      );
    }
    return isCallback;
  }

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async => deliver(routeInformation.uri);
}

/// The steps of connecting this phone to a server (docs/adr/0010, \"What the
/// screen says\"): the address, the sign-in in the browser, then what the
/// access covers, before anything of the homes is sent or received.
class ServerConnector {
  ServerConnector({
    required this.http,
    required this.store,
    required this.openBrowser,
    required this.deviceName,
    Stream<Uri>? callbacks,
  }) : callbacks = callbacks ?? SignInCallbacks.instance.stream;

  /// The connection to the address typed (`IoServerHttp` in the app).
  final ServerHttp Function(ServerAddress address) http;
  final Store store;
  final Future<bool> Function(Uri url) openBrowser;
  final String deviceName;
  final Stream<Uri> callbacks;

  /// Reads `info` without a token, then opens the server's sign-in page in
  /// the system browser, and waits for its answer; the credential is then
  /// in [store]. Throws [SignInException], [ServerStopped] or
  /// [ServerHttpException].
  Future<void> signIn(ServerAddress address, {bool createHomes = false}) async {
    final client = http(address);
    final reply = await client.send(
      'GET',
      address.resolve('/api/v1/sync/info'),
      headers: {'accept': 'application/json'},
    );
    if (reply.status == 403) {
      throw const ServerStopped(ServerStop.insecureTransport);
    }
    if (reply.status != 200) {
      throw const SignInException(SignInError.tooOld);
    }
    final Map<String, Object?> info;
    try {
      info = (jsonDecode(utf8.decode(reply.body)) as Map)
          .cast<String, Object?>();
    } on FormatException {
      throw const SignInException(SignInError.tooOld);
    }
    final oauth = oauthOfInfo(address, info);
    final request = SignInRequest(
      oauth: oauth,
      createHomes: createHomes,
      deviceName: deviceName,
    );
    final answer = callbacks.first;
    if (!await openBrowser(request.authorizeUrl)) {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
    final code = request.codeOf(await answer);
    final token = await client.send(
      'POST',
      oauth.token,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: utf8.encode(Uri(queryParameters: request.tokenForm(code)).query),
    );
    if (token.status != 200) throw const SignInException(SignInError.refused);
    final credential = ServerCredential.fromTokenAnswer(
      (jsonDecode(utf8.decode(token.body)) as Map).cast<String, Object?>(),
      oauth,
    );
    await credential.write(store);
  }
}
