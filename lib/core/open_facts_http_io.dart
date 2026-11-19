// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../domain/barcode_lookup.dart';
import '../version.dart';
import 'open_facts.dart';

/// [OpenFactsHttp] on `dart:io`: the one file of `lib/` that opens a
/// connection when the phone is used alone (docs/adr/0015, an exception to
/// \"no network\" of docs/adr/0010 decided by the maintainer on 2026-11-15;
/// test/ways_test.dart lists it). Only `GET`, only `https`, only the hosts
/// of [lookupSources]; redirects are not followed; no cookie, no other
/// header than `Accept` and the `User-Agent` the Open Food Facts project
/// asks of every application; the system's certificate checks apply and no
/// `badCertificateCallback` is ever set.
class IoOpenFactsHttp implements OpenFactsHttp {
  IoOpenFactsHttp({this.timeout = const Duration(seconds: 6)})
    : _client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 6)
        ..findProxy = ((_) => 'DIRECT')
        // The name of the app and where it comes from: nothing of the phone
        // or of the person.
        ..userAgent = 'HouseCairnMobile (+https://$sourceAddress)';

  final Duration timeout;
  final HttpClient _client;

  @override
  Future<Uint8List> get(
    Uri url, {
    required String accept,
    required int maxBytes,
  }) async {
    if (url.scheme != 'https' ||
        url.hasPort && url.port != 443 ||
        url.userInfo.isNotEmpty ||
        !(lookupApiHosts.contains(url.host) ||
            lookupImageHosts.contains(url.host))) {
      throw const OpenFactsUnreachable('other_host');
    }
    try {
      final request = await _client.getUrl(url).timeout(timeout);
      request.followRedirects = false;
      request.persistentConnection = false;
      request.headers.set(HttpHeaders.acceptHeader, accept);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        await response.drain<void>();
        throw const OpenFactsUnreachable('status');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response.timeout(timeout)) {
        bytes.add(chunk);
        if (bytes.length > maxBytes) {
          throw const OpenFactsUnreachable('too_large');
        }
      }
      return bytes.takeBytes();
    } on HandshakeException {
      throw const OpenFactsUnreachable('certificate');
    } on TlsException {
      throw const OpenFactsUnreachable('certificate');
    } on SocketException {
      throw const OpenFactsUnreachable('offline');
    } on TimeoutException {
      throw const OpenFactsUnreachable('offline');
    } on HttpException {
      throw const OpenFactsUnreachable('offline');
    }
  }

  void close() => _client.close(force: true);
}
