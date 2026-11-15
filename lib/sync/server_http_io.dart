// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'server_address.dart';
import 'server_http.dart';

/// [ServerHttp] on `dart:io`: the only file of `lib/` that opens a
/// connection (test/ways_test.dart lists it). Every request must be on
/// [address]; redirects are not followed; the system's certificate checks
/// apply and no `badCertificateCallback` is ever set.
class IoServerHttp implements ServerHttp {
  IoServerHttp(this.address, {this.timeout = const Duration(seconds: 30)})
    : _client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15)
        // Straight to the address typed, never through a proxy of the
        // environment.
        ..findProxy = ((_) => 'DIRECT')
        ..userAgent = 'Housecairn mobile';

  final ServerAddress address;
  final Duration timeout;
  final HttpClient _client;

  /// The most bytes read from one answer (a snapshot included).
  static const maxAnswerBytes = 64 * 1024 * 1024;

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    if (!address.owns(url)) {
      throw const ServerHttpException(ServerHttpFailure.otherHost);
    }
    try {
      final request = await _client.openUrl(method, url).timeout(timeout);
      request.followRedirects = false;
      headers.forEach(request.headers.set);
      if (body != null) {
        request.contentLength = body.length;
        request.add(body);
      }
      final response = await request.close().timeout(timeout);
      if (response.isRedirect || (response.statusCode ~/ 100) == 3) {
        await response.drain<void>();
        throw const ServerHttpException(ServerHttpFailure.otherHost);
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response.timeout(timeout)) {
        bytes.add(chunk);
        if (bytes.length > maxAnswerBytes) {
          throw const ServerHttpException(ServerHttpFailure.tooLarge);
        }
      }
      final answerHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        answerHeaders[name.toLowerCase()] = values.join(', ');
      });
      return ServerReply(
        response.statusCode,
        bytes.takeBytes(),
        headers: answerHeaders,
      );
    } on HandshakeException {
      throw const ServerHttpException(ServerHttpFailure.certificate);
    } on TlsException {
      throw const ServerHttpException(ServerHttpFailure.certificate);
    } on SocketException {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    } on TimeoutException {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    } on HttpException {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
  }

  void close() => _client.close(force: true);
}
