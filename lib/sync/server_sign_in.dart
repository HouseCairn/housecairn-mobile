// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../core/store.dart';
import 'server_address.dart';

/// The sign-in of the third way (web ADR 0078): OAuth 2, authorization code
/// with PKCE `S256`, in the system browser, the public client
/// `housecairn-mobile` and the redirect URI of the app's private-use scheme.
/// No token is ever typed or pasted.
const oauthClientId = 'housecairn-mobile';
const oauthRedirectUri = 'app.housecairn.mobile:/oauth/callback';

/// The scopes of web ADR 0078: `sync` always, `homes.create` only when the
/// person chose to send this phone's homes to the server.
String oauthScope({required bool createHomes}) =>
    createHomes ? 'sync homes.create' : 'sync';

/// The sync protocol versions this app speaks (`sync` of `info`).
const supportedSyncVersions = {1};

/// The first web release with the sync API of web ADR 0077, named by the
/// message of a server too old.
const minimumServerVersion = '0.4.0';

String _b64url(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

/// A PKCE verifier and its `S256` challenge (RFC 7636).
class Pkce {
  Pkce._(this.verifier)
    : challenge = _b64url(sha256.convert(ascii.encode(verifier)).bytes);

  /// A verifier of 32 random bytes (43 characters).
  factory Pkce.random([Random? random]) {
    final r = random ?? Random.secure();
    return Pkce._(_b64url([for (var i = 0; i < 32; i++) r.nextInt(256)]));
  }

  /// A known verifier, for the tests.
  factory Pkce.ofVerifier(String verifier) => Pkce._(verifier);

  final String verifier;
  final String challenge;
}

/// What `GET /api/v1/sync/info` says without a token.
class ServerOAuth {
  const ServerOAuth({
    required this.authorize,
    required this.token,
    required this.revoke,
    required this.clientId,
  });

  final Uri authorize;
  final Uri token;
  final Uri revoke;
  final String clientId;
}

/// Why a sign-in did not end with a connection.
enum SignInError {
  /// The server is not a Housecairn with the sync API (too old, or not
  /// Housecairn at all).
  tooOld,

  /// The instance turned the mobile app off (`"oauth": null`).
  mobileAppOff,

  /// An endpoint `info` gave is not on the address typed.
  foreignEndpoint,

  /// The person cancelled in the browser (`access_denied`).
  cancelled,

  /// The answer does not match the request (`state`, missing code).
  mismatch,

  /// The server refused the code or the refresh.
  refused,
}

class SignInException implements Exception {
  const SignInException(this.error, [this.serverVersion]);

  final SignInError error;

  /// The version the server gave, if any.
  final String? serverVersion;

  @override
  String toString() => 'SignInException(${error.name})';
}

/// Reads the OAuth endpoints of `info`; refuses a server too old for the
/// sync API, and any endpoint not on [address].
ServerOAuth oauthOfInfo(ServerAddress address, Map<String, Object?> info) {
  final versions = info['sync'];
  if (versions is! List || !versions.any(supportedSyncVersions.contains)) {
    throw const SignInException(SignInError.tooOld);
  }
  if (!info.containsKey('oauth')) {
    throw const SignInException(SignInError.tooOld);
  }
  final oauth = info['oauth'];
  if (oauth == null) throw const SignInException(SignInError.mobileAppOff);
  if (oauth is! Map) throw const SignInException(SignInError.tooOld);
  Uri endpoint(String name) {
    final value = oauth[name];
    final url = value is String ? Uri.tryParse(value) : null;
    if (url == null || !address.owns(url)) {
      throw const SignInException(SignInError.foreignEndpoint);
    }
    return url;
  }

  return ServerOAuth(
    authorize: endpoint('authorize'),
    token: endpoint('token'),
    revoke: endpoint('revoke'),
    clientId: oauth['client_id'] as String? ?? oauthClientId,
  );
}

/// One sign-in in progress: what the app keeps between opening the browser
/// and the redirect back.
class SignInRequest {
  SignInRequest({
    required this.oauth,
    required this.createHomes,
    required this.deviceName,
    Random? random,
  }) : pkce = Pkce.random(random),
       state = _b64url([
         for (var i = 0; i < 16; i++) (random ?? Random.secure()).nextInt(256),
       ]);

  final ServerOAuth oauth;
  final bool createHomes;
  final String deviceName;
  final Pkce pkce;
  final String state;

  /// The address the system browser opens (`/o/authorize/`).
  Uri get authorizeUrl => oauth.authorize.replace(
    queryParameters: {
      ...oauth.authorize.queryParameters,
      'response_type': 'code',
      'client_id': oauth.clientId,
      'redirect_uri': oauthRedirectUri,
      'scope': oauthScope(createHomes: createHomes),
      'state': state,
      'code_challenge': pkce.challenge,
      'code_challenge_method': 'S256',
      'device_name': deviceName,
    },
  );

  /// The code of the redirect [callback]; throws when it is not the answer
  /// to this request.
  String codeOf(Uri callback) {
    final expected = Uri.parse(oauthRedirectUri);
    if (callback.scheme != expected.scheme || callback.path != expected.path) {
      throw const SignInException(SignInError.mismatch);
    }
    final query = callback.queryParameters;
    if (query['state'] != state) {
      throw const SignInException(SignInError.mismatch);
    }
    if (query['error'] == 'access_denied') {
      throw const SignInException(SignInError.cancelled);
    }
    final code = query['code'];
    if (code == null || code.isEmpty) {
      throw const SignInException(SignInError.mismatch);
    }
    return code;
  }

  /// The form of the token request for [code].
  Map<String, String> tokenForm(String code) => {
    'grant_type': 'authorization_code',
    'code': code,
    'redirect_uri': oauthRedirectUri,
    'client_id': oauth.clientId,
    'code_verifier': pkce.verifier,
  };
}

/// The credential of the access: kept in `Store` only (Keychain or Android
/// Keystore), never in the database, an export or a log.
class ServerCredential {
  const ServerCredential({
    required this.access,
    required this.refresh,
    required this.token,
    required this.revoke,
  });

  final String access;
  final String refresh;
  final Uri token;
  final Uri revoke;

  /// The key of `Store` that holds it.
  static const storeKey = 'server_credential';

  static ServerCredential fromTokenAnswer(
    Map<String, Object?> answer,
    ServerOAuth oauth,
  ) {
    final access = answer['access_token'];
    final refresh = answer['refresh_token'];
    if (access is! String || refresh is! String) {
      throw const SignInException(SignInError.refused);
    }
    return ServerCredential(
      access: access,
      refresh: refresh,
      token: oauth.token,
      revoke: oauth.revoke,
    );
  }

  ServerCredential refreshed(Map<String, Object?> answer) {
    final access = answer['access_token'];
    final refresh = answer['refresh_token'];
    if (access is! String || refresh is! String) {
      throw const SignInException(SignInError.refused);
    }
    return ServerCredential(
      access: access,
      refresh: refresh,
      token: token,
      revoke: revoke,
    );
  }

  Uint8List encode() => utf8.encode(
    jsonEncode({
      'access': access,
      'refresh': refresh,
      'token': token.toString(),
      'revoke': revoke.toString(),
    }),
  );

  static ServerCredential? decode(Uint8List? bytes) {
    if (bytes == null) return null;
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    return ServerCredential(
      access: json['access']! as String,
      refresh: json['refresh']! as String,
      token: Uri.parse(json['token']! as String),
      revoke: Uri.parse(json['revoke']! as String),
    );
  }

  static Future<ServerCredential?> read(Store store) async =>
      decode(await store.read(storeKey));

  Future<void> write(Store store) => store.write(storeKey, encode());

  static Future<void> forget(Store store) => store.delete(storeKey);

  /// Never the tokens.
  @override
  String toString() => 'ServerCredential(…)';
}
