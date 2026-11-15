// SPDX-License-Identifier: AGPL-3.0-only

// The third way against a real Housecairn server (docs/plan.md, lot 4b,
// first criterion), started in CI from its released image by the job
// "Sync with a Housecairn server (e2e)" of .github/workflows/ci.yml, and
// prepared by tool/e2e/provision.py. Skipped when HC_E2E_URL is not set, so
// `flutter test test_e2e` does nothing on a machine without the server.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http_io.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';

import '../test/support/sync_fixture.dart';

final _env = Platform.environment;
final _url = _env['HC_E2E_URL'];

void main() {
  final skip = _url == null ? 'HC_E2E_URL is not set' : null;
  late ServerAddress address;
  late _Web web;
  late _MemoryStore store;
  late Phone phone;
  late ServerTransport transport;
  late String home;

  setUpAll(() async {
    if (skip != null) return;
    address = ServerAddress.parse(_url!).$1!;
    home = _env['HC_E2E_HOME']!;
    web = _Web(address, _env['HC_E2E_API_TOKEN']!);
    store = _MemoryStore();
    phone = await Phone.open(1);
    // The real clock of the phone: the server refuses a clock more than a
    // day ahead of its own, and the test fixture's clock is in 2026.
    phone.clock.set(DateTime.now().toUtc());
  });

  tearDownAll(() {
    if (skip == null) web.close();
  });

  test(
    'a server too old or wrong is refused in words; this one is not',
    () async {
      final info = await web.json('GET', '/api/v1/sync/info', auth: false);
      final oauth = oauthOfInfo(address, info);
      expect(oauth.clientId, oauthClientId);
      expect(
        () => oauthOfInfo(address, {'detail': 'Not found.'}),
        throwsA(isA<SignInException>()),
      );
    },
    skip: skip,
  );

  test(
    'sign-in in the browser with PKCE: consent page, code, tokens',
    () async {
      final info = await web.json('GET', '/api/v1/sync/info', auth: false);
      final oauth = oauthOfInfo(address, info);
      final request = SignInRequest(
        oauth: oauth,
        createHomes: false,
        deviceName: 'E2E phone',
      );
      // The system browser, already signed in: it opens the consent page and
      // presses Connect with the first home ticked.
      final callback = await web.consent(
        request.authorizeUrl,
        session: _env['HC_E2E_SESSION']!,
        homes: [home],
      );
      final code = request.codeOf(callback);
      final answer = await web.form(oauth.token, request.tokenForm(code));
      final credential = ServerCredential.fromTokenAnswer(answer, oauth);
      expect(credential.access, startsWith('hca_'));
      expect(credential.refresh, startsWith('hcr_'));
      await credential.write(store);
      transport = ServerTransport(
        address: address,
        http: IoServerHttp(address),
        store: store,
        state: phone.repo.serverState,
        device: phone.repo.deviceB64,
        schemaVersion: phone.repo.schemaVersion,
      );
      phone.on(transport);
      final capabilities = await transport.capabilities();
      expect(capabilities.version, isNotEmpty);
      final homes = await transport.homes();
      expect(homes.map((h) => h.id), [home], reason: 'only the home ticked');
      expect(homes.single.owner, isTrue);
      expect(homes.single.members.single.name, isNotEmpty);
    },
    skip: skip,
  );

  test('the first sync brings the server\'s home to the phone', () async {
    final report = await phone.sync();
    expect(report.received, greaterThan(0));
    final names = (await phone.repo.homes()).map((h) => h.name);
    expect(names, ['E2E house']);
  }, skip: skip);

  test('a change made on the phone is read through the web API', () async {
    phone.clock.set(DateTime.now().toUtc());
    final room = await phone.repo.createRoom(home, name: 'Kitchen');
    await phone.sync();
    final rooms = await web.list('/api/v1/homes/$home/rooms/');
    final found = rooms.where((r) => r['id'] == room).toList();
    expect(found, hasLength(1), reason: 'the server keeps the phone\'s id');
    expect(found.single['name'], 'Kitchen');
  }, skip: skip);

  test('a change made through the web API reaches the phone', () async {
    final created = await web.json(
      'POST',
      '/api/v1/homes/$home/rooms/',
      body: {'name': 'Garage', 'kind': 'other'},
    );
    final id = created['id']! as String;
    await phone.sync();
    final rooms = await phone.repo.rooms(home);
    expect(rooms.map((r) => r.name), contains('Garage'));
    await web.json(
      'PATCH',
      '/api/v1/homes/$home/rooms/$id/',
      body: {'name': 'Workshop'},
    );
    await phone.sync();
    final renamed = await phone.repo.rooms(home);
    expect(renamed.map((r) => r.name), contains('Workshop'));
    expect(renamed.map((r) => r.name), isNot(contains('Garage')));
  }, skip: skip);

  test('a deletion made on the web reaches the phone', () async {
    final room = await phone.repo.createRoom(home, name: 'Attic');
    await phone.sync();
    await web.send('DELETE', '/api/v1/homes/$home/rooms/$room/');
    await phone.sync();
    final rooms = await phone.repo.rooms(home);
    expect(rooms.map((r) => r.id), isNot(contains(room)));
  }, skip: skip);

  test('the same push sent twice runs once: no duplicate', () async {
    final before = await web.list('/api/v1/homes/$home/rooms/');
    final room = await phone.repo.createRoom(home, name: 'Cellar');
    final out = await phone.repo.outgoing();
    final ops = [for (final o in out) o.operation];
    await transport.push(ops);
    await transport.push(ops);
    await phone.sync();
    final after = await web.list('/api/v1/homes/$home/rooms/');
    expect(after.where((r) => r['id'] == room), hasLength(1));
    expect(after.length, before.length + 1);
  }, skip: skip);

  test(
    'disconnect revokes the access: the phone is stopped and says so',
    () async {
      final credential = await ServerCredential.read(store);
      await transport.disconnect();
      expect(await ServerCredential.read(store), isNull);
      // The revoked access token no longer opens the sync API.
      final reply = await web.raw(
        'GET',
        address.resolve('/api/v1/sync/homes/'),
        headers: {'authorization': 'Bearer ${credential!.access}'},
      );
      expect(reply.$1, 401);
      await expectLater(
        transport.homes(),
        throwsA(
          isA<ServerStopped>().having(
            (e) => e.reason,
            'reason',
            ServerStop.disconnected,
          ),
        ),
      );
      // The phone keeps its copy of the homes.
      expect((await phone.repo.homes()).map((h) => h.name), ['E2E house']);
    },
    skip: skip,
  );
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

/// The web side of the test: the resources of the API with an API token,
/// and a browser for the consent page.
class _Web {
  _Web(this.address, this.apiToken);

  final ServerAddress address;
  final String apiToken;
  final _client = HttpClient();

  void close() => _client.close(force: true);

  Future<(int, String, HttpHeaders)> raw(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    String? body,
  }) async {
    final request = await _client.openUrl(method, url);
    request.followRedirects = false;
    headers.forEach(request.headers.set);
    if (body != null) request.write(body);
    final response = await request.close();
    return (
      response.statusCode,
      await utf8.decodeStream(response),
      response.headers,
    );
  }

  Future<(int, String)> send(
    String method,
    String route, {
    Object? body,
    bool auth = true,
  }) async {
    final reply = await raw(
      method,
      address.resolve(route),
      headers: {
        'accept': 'application/json',
        if (body != null) 'content-type': 'application/json',
        if (auth) 'authorization': 'Bearer $apiToken',
      },
      body: body == null ? null : jsonEncode(body),
    );
    if (reply.$1 >= 400) {
      throw StateError('$method $route: ${reply.$1} ${reply.$2}');
    }
    return (reply.$1, reply.$2);
  }

  Future<Map<String, Object?>> json(
    String method,
    String route, {
    Object? body,
    bool auth = true,
  }) async {
    final (_, text) = await send(method, route, body: body, auth: auth);
    return (jsonDecode(text) as Map).cast<String, Object?>();
  }

  Future<List<Map<String, Object?>>> list(String route) async {
    final page = await json('GET', route);
    return [
      for (final r in page['results']! as List)
        (r as Map).cast<String, Object?>(),
    ];
  }

  Future<Map<String, Object?>> form(Uri url, Map<String, String> fields) async {
    final reply = await raw(
      'POST',
      url,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: Uri(queryParameters: fields).query,
    );
    if (reply.$1 != 200) throw StateError('token: ${reply.$1} ${reply.$2}');
    return (jsonDecode(reply.$2) as Map).cast<String, Object?>();
  }

  /// Opens [authorize] as the signed-in browser, ticks [homes] and presses
  /// Connect; gives the redirect to the app's scheme.
  Future<Uri> consent(
    Uri authorize, {
    required String session,
    required List<String> homes,
  }) async {
    var cookies = 'sessionid=$session';
    final page = await raw('GET', authorize, headers: {'cookie': cookies});
    if (page.$1 != 200) {
      throw StateError('consent page: ${page.$1} ${page.$2}');
    }
    final csrf = page.$3[HttpHeaders.setCookieHeader]
        ?.map(Cookie.fromSetCookieValue)
        .where((c) => c.name == 'csrftoken')
        .firstOrNull;
    if (csrf != null) cookies = '$cookies; csrftoken=${csrf.value}';
    final hidden = <String, String>{
      for (final m in RegExp(
        r'<input[^>]*type="hidden"[^>]*>',
      ).allMatches(page.$2))
        if (RegExp(r'name="([^"]+)"').firstMatch(m.group(0)!) case final n?)
          n.group(1)!: _unescape(
            RegExp(r'value="([^"]*)"').firstMatch(m.group(0)!)?.group(1) ?? '',
          ),
    };
    final body = [
      for (final MapEntry(:key, :value) in hidden.entries)
        '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}',
      for (final h in homes) 'homes=$h',
      'allow=1',
    ].join('&');
    final answer = await raw(
      'POST',
      authorize,
      headers: {
        'cookie': cookies,
        'content-type': 'application/x-www-form-urlencoded',
        'referer': authorize.toString(),
      },
      body: body,
    );
    final location = answer.$3.value(HttpHeaders.locationHeader);
    if (answer.$1 != 302 || location == null) {
      throw StateError('consent: ${answer.$1} ${answer.$2}');
    }
    return Uri.parse(location);
  }

  static String _unescape(String text) => text
      .replaceAll('&quot;', '"')
      .replaceAll('&#x27;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}
