// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

/// One answer of the server.
class ServerReply {
  const ServerReply(this.status, this.body, {this.headers = const {}});

  final int status;
  final Uint8List body;

  /// Header names in lower case.
  final Map<String, String> headers;
}

/// The one way the third way reaches the network
/// (docs/adr/0010-three-ways-to-use-the-app.md): requests to the address the
/// person typed, nothing else. The app's implementation is
/// `IoServerHttp` (`server_http_io.dart`); the tests give a fake.
abstract interface class ServerHttp {
  /// Sends one request. Redirects are never followed and a certificate error
  /// is never skipped: both end as a [ServerHttpException].
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  });
}

/// Why a request did not get an answer.
enum ServerHttpFailure {
  /// No connection (offline, refused, a name that does not resolve, a
  /// timeout).
  unreachable,

  /// The certificate of the server was refused by the system; the app never
  /// offers to go on.
  certificate,

  /// The request would leave the address typed (a redirect, or a URL of
  /// another host): refused before it is sent.
  otherHost,

  /// The answer is larger than the app reads.
  tooLarge,
}

class ServerHttpException implements Exception {
  const ServerHttpException(this.failure);

  final ServerHttpFailure failure;

  @override
  String toString() => 'ServerHttpException(${failure.name})';
}
