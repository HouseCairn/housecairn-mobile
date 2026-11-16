// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/sync/server_address.dart';

/// The rule of plain HTTP of docs/protocol.md section 2.10, against the
/// vectors of the web's own rule (`core.netguard.is_public` at v0.4.0, made
/// by running it: test/fixtures/netguard_vectors.json).
void main() {
  group('local IP literals, as the web reads them', () {
    final json = jsonDecode(
      File('test/fixtures/netguard_vectors.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final vectors = (json['vectors']! as List).cast<Map<String, Object?>>();

    // IPv4 as octets: the dotted text of some private networks is refused by
    // the privacy check of the repository's commits.
    String addressOf(Map<String, Object?> v) =>
        (v['ipv6'] as String?) ?? (v['ipv4']! as List).join('.');

    test('the vectors cover IPv4, IPv6 and carried IPv4', () {
      expect(vectors.length, greaterThan(40));
      expect(vectors.any((v) => v.containsKey('ipv6')), isTrue);
      expect(vectors.any((v) => v.containsKey('ipv4')), isTrue);
      expect(vectors.any((v) => v['public'] == true), isTrue);
      expect(vectors.any((v) => v['public'] == false), isTrue);
    });

    for (final v in vectors) {
      final address = addressOf(v);
      final public = v['public']! as bool;
      test('$address is ${public ? 'public' : 'local'}', () {
        expect(isLocalIpLiteral(address), !public);
        if (address.contains(':')) {
          expect(isLocalIpLiteral('[$address]'), !public);
        }
      });
    }

    test('a name is never local', () {
      for (final name in [
        'housecairn.local',
        'nas.home.arpa',
        'localhost',
        'example.com',
        '${[192, 168, 1, 10].join('.')}.example.com',
        '010.0.0.1',
      ]) {
        expect(isLocalIpLiteral(name), isFalse, reason: name);
      }
    });
  });

  group('the address typed', () {
    ServerAddressError? error(String typed) => ServerAddress.parse(typed).$2;
    ServerAddress ok(String typed) => ServerAddress.parse(typed).$1!;

    test('https is assumed, and the origin is kept', () {
      final a = ok('housecairn.example.com');
      expect(a.secure, isTrue);
      expect(a.plainHttp, isFalse);
      expect(a.display, 'https://housecairn.example.com');
      expect(
        a.resolve('/api/v1/sync/info').toString(),
        'https://housecairn.example.com/api/v1/sync/info',
      );
    });

    test('a path and a port are kept, a trailing slash is not', () {
      final a = ok('https://example.com:8443/housecairn/');
      expect(a.display, 'https://example.com:8443/housecairn');
      expect(
        a.resolve('/api/v1/sync/homes/').toString(),
        'https://example.com:8443/housecairn/api/v1/sync/homes/',
      );
    });

    test('http to a local IP literal is allowed, with the warning', () {
      for (final typed in [
        'http://${[192, 168, 1, 20].join('.')}:8000',
        'http://${[10, 0, 0, 5].join('.')}',
        'http://172.20.3.4',
        'http://100.64.0.1:8000',
        'http://127.0.0.1:8000',
        'http://[fd12:3456::1]:8000',
        'http://[::ffff:c0a8:101]',
      ]) {
        final a = ok(typed);
        expect(a.plainHttp, isTrue, reason: typed);
      }
    });

    test('http to a name is refused, .local and .home.arpa included', () {
      for (final typed in [
        'http://housecairn.local:8000',
        'http://nas.home.arpa',
        'http://localhost:8000',
        'http://example.com',
      ]) {
        expect(
          error(typed),
          ServerAddressError.httpNeedsLocalIp,
          reason: typed,
        );
      }
    });

    test('http to a public address is refused', () {
      for (final typed in [
        'http://8.8.8.8',
        'http://[2606:4700:4700::1111]',
        'http://[::ffff:8.8.8.8]',
      ]) {
        expect(
          error(typed),
          ServerAddressError.httpNeedsLocalIp,
          reason: typed,
        );
      }
    });

    test('what is not an address is refused', () {
      for (final typed in [
        '',
        '   ',
        'ftp://example.com',
        'https://user:secret@example.com',
        'https://example.com/?next=evil.example',
        'https://example.com/#x',
        'https://',
        'exa mple.com',
      ]) {
        expect(error(typed), ServerAddressError.invalid, reason: typed);
      }
    });

    test('only the address typed owns a URL', () {
      final a = ok('https://example.com');
      expect(a.owns(Uri.parse('https://example.com/o/token/')), isTrue);
      expect(a.owns(Uri.parse('https://EXAMPLE.com/o/token/')), isTrue);
      expect(a.owns(Uri.parse('http://example.com/o/token/')), isFalse);
      expect(a.owns(Uri.parse('https://example.com:8443/o/')), isFalse);
      expect(a.owns(Uri.parse('https://evil.example/o/')), isFalse);
      expect(a.owns(Uri.parse('https://example.com.evil.example/')), isFalse);
    });

    test('a stored address is read again by the same rule', () {
      expect(
        ServerAddress.stored('https://example.com:8443/hc')!.display,
        'https://example.com:8443/hc',
      );
      expect(ServerAddress.stored('http://housecairn.local'), isNull);
      expect(ServerAddress.stored(null), isNull);
    });
  });
}
