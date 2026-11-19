// SPDX-License-Identifier: AGPL-3.0-only

// The one connection of the phone alone (docs/adr/0015-barcode-lookup.md):
// IoOpenFactsHttp against a socket on this machine. HttpOverrides gives the
// real HttpClient a connection factory that opens the local socket instead
// of the host of the address, so that the request is read as it leaves,
// byte for byte, and no test reaches a real host.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/open_facts.dart';
import 'package:housecairn_mobile/core/open_facts_http_io.dart';

/// A server on the loopback that answers each connection with the next of
/// [replies] (raw HTTP), and keeps what each request sent.
class _LocalServer {
  _LocalServer._(this._socket, this.replies) {
    _socket.listen((client) {
      final index = requests.length;
      requests.add(BytesBuilder());
      client.listen((chunk) {
        requests[index].add(chunk);
        final text = latin1.decode(requests[index].toBytes());
        if (text.contains('\r\n\r\n') && !_answered.contains(index)) {
          _answered.add(index);
          client.add(
            index < replies.length ? replies[index] : _reply(500, const []),
          );
          unawaited(client.flush().then((_) => client.close()));
        }
      }, onError: (_) {});
    });
  }

  static Future<_LocalServer> start(List<List<int>> replies) async =>
      _LocalServer._(
        await ServerSocket.bind(InternetAddress.loopbackIPv4, 0),
        replies,
      );

  final ServerSocket _socket;
  final List<List<int>> replies;
  final requests = <BytesBuilder>[];
  final _answered = <int>{};

  int get port => _socket.port;

  /// The request [index] as it was sent: its first line and its headers.
  (String, Map<String, String>) request(int index) {
    final text = latin1.decode(requests[index].toBytes());
    final lines = text.split('\r\n\r\n').first.split('\r\n');
    return (
      lines.first,
      {
        for (final line in lines.skip(1))
          line.substring(0, line.indexOf(':')).toLowerCase(): line
              .substring(line.indexOf(':') + 1)
              .trim(),
      },
    );
  }

  Future<void> close() => _socket.close();
}

List<int> _reply(int status, List<int> body, {Map<String, String>? headers}) {
  final head = StringBuffer('HTTP/1.1 $status X\r\n');
  for (final MapEntry(:key, :value) in {
    'content-length': '${body.length}',
    'connection': 'close',
    ...?headers,
  }.entries) {
    head.write('$key: $value\r\n');
  }
  head.write('\r\n');
  return [...latin1.encode(head.toString()), ...body];
}

/// Every connection of the HttpClient goes to [server]; [opened] counts
/// the connections asked.
class _ToLocal extends HttpOverrides {
  _ToLocal(this.server);

  final _LocalServer server;
  int opened = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..connectionFactory = (url, proxyHost, proxyPort) {
          opened++;
          return Socket.startConnect(InternetAddress.loopbackIPv4, server.port);
        };
}

/// [body] with the connections of the client sent to a local server that
/// answers [replies].
Future<void> _withServer(
  List<List<int>> replies,
  Future<void> Function(IoOpenFactsHttp http, _LocalServer server, _ToLocal o)
  body,
) async {
  final server = await _LocalServer.start(replies);
  final overrides = _ToLocal(server);
  try {
    await HttpOverrides.runWithHttpOverrides(() async {
      final http = IoOpenFactsHttp();
      try {
        await body(http, server, overrides);
      } finally {
        http.close();
      }
    }, overrides);
  } finally {
    await server.close();
  }
}

final _api = Uri.parse(
  'https://world.openproductsfacts.org/api/v2/product/4006381333931.json'
  '?fields=code%2Cproduct_name',
);

Matcher _unreachable(String reason) => throwsA(
  isA<OpenFactsUnreachable>().having((e) => e.reason, 'reason', reason),
);

void main() {
  test('the request carries these headers and no other', () async {
    await _withServer([_reply(200, utf8.encode('{"status":1}'))], (
      http,
      server,
      overrides,
    ) async {
      final body = await http.get(
        _api,
        accept: 'application/json',
        maxBytes: 1024,
      );
      expect(utf8.decode(body), '{"status":1}');
      expect(overrides.opened, 1);
      final (line, headers) = server.request(0);
      expect(
        line,
        'GET /api/v2/product/4006381333931.json?fields=code%2Cproduct_name '
        'HTTP/1.1',
      );
      // Nothing of the phone or of the person: the name of the app and
      // where its code is, what is accepted, and the host.
      expect(headers, {
        'user-agent': 'HouseCairnMobile (+https://github.com/HouseCairn/housecairn-mobile)',
        'accept': 'application/json',
        'accept-encoding': 'gzip',
        'connection': 'close',
        'host': 'world.openproductsfacts.org',
      });
    });
  });

  test('another host, http, another port, a user: refused before any '
      'connection', () async {
    await _withServer([], (http, server, overrides) async {
      for (final url in [
        'https://example.com/api/v2/product/4006381333931.json',
        'https://world.openproductsfacts.org.example.com/a.json',
        'http://world.openproductsfacts.org/api/v2/product/4006381333931.json',
        'https://world.openproductsfacts.org:8443/api/v2/product/1.json',
        'https://world.openproductsfacts.org:80/api/v2/product/1.json',
        'https://someone@world.openproductsfacts.org/api/v2/product/1.json',
      ]) {
        await expectLater(
          http.get(Uri.parse(url), accept: 'application/json', maxBytes: 1024),
          _unreachable('other_host'),
          reason: url,
        );
      }
      expect(overrides.opened, 0);
      expect(server.requests, isEmpty);
    });
  });

  test('the photo hosts are allowed, and port 443 written out', () async {
    await _withServer(
      [
        _reply(200, [1, 2, 3]),
        _reply(200, [4]),
      ],
      (http, server, overrides) async {
        expect(
          await http.get(
            Uri.parse('https://images.openproductsfacts.org/a.jpg'),
            accept: 'image/jpeg',
            maxBytes: 1024,
          ),
          [1, 2, 3],
        );
        expect(
          await http.get(
            Uri.parse('https://world.openfoodfacts.org:443/a.json'),
            accept: 'application/json',
            maxBytes: 1024,
          ),
          [4],
        );
        expect(overrides.opened, 2);
      },
    );
  });

  test('a redirect is not followed: status', () async {
    await _withServer(
      [
        _reply(
          301,
          const [],
          headers: {'location': 'https://images.openproductsfacts.org/b.jpg'},
        ),
        _reply(200, utf8.encode('followed')),
      ],
      (http, server, overrides) async {
        await expectLater(
          http.get(_api, accept: 'application/json', maxBytes: 1024),
          _unreachable('status'),
        );
        expect(overrides.opened, 1);
        expect(server.requests, hasLength(1));
      },
    );
  });

  test('a 404 is status', () async {
    await _withServer([_reply(404, utf8.encode('{}'))], (http, _, _) async {
      await expectLater(
        http.get(_api, accept: 'application/json', maxBytes: 1024),
        _unreachable('status'),
      );
    });
  });

  test('more than maxBytes is too_large; maxBytes exactly is read', () async {
    final body = List<int>.filled(4096, 0x61);
    await _withServer([_reply(200, body), _reply(200, body)], (
      http,
      _,
      _,
    ) async {
      await expectLater(
        http.get(_api, accept: 'application/json', maxBytes: 4095),
        _unreachable('too_large'),
      );
      expect(
        await http.get(_api, accept: 'application/json', maxBytes: 4096),
        hasLength(4096),
      );
    });
  });
}
