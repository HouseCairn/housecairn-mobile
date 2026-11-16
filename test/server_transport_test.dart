// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/sync/transport.dart';

/// The server transport against a scripted server (the real one runs in the
/// e2e job, test_e2e/server_e2e_test.dart).
void main() {
  const home = '0b6f2f0e-6c5a-4d33-9a7e-0d6b8f5c1a01';
  const other = '7c1e1d2a-3b4c-4d5e-8f90-a1b2c3d4e5f6';
  const device = 'AAECAwQFBgcICQoLDA0ODw';
  const serverDevice = 'q2Xh0dVt3kWmYc1bS8fP9A';
  final address = ServerAddress.parse('https://hc.example.com').$1!;

  late _Server server;
  late _MemoryStore store;
  late _MemoryState state;
  late ServerTransport transport;

  Future<void> signIn() => ServerCredential(
    access: 'hca_one',
    refresh: 'hcr_one',
    token: address.resolve('/o/token/'),
    revoke: address.resolve('/o/revoke_token/'),
  ).write(store);

  setUp(() async {
    server = _Server();
    store = _MemoryStore();
    state = _MemoryState();
    transport = ServerTransport(
      address: address,
      http: server,
      store: store,
      state: state,
      device: device,
      schemaVersion: 6,
    );
    await signIn();
    server.homes = [
      {
        'id': home,
        'name': 'House',
        'role': 'owner',
        'archived_at': null,
        'head': 0,
        'members': [
          {'id': 'u1', 'name': 'Sam', 'role': 'owner'},
          {'id': 'u2', 'name': 'Robin', 'role': 'read_only'},
        ],
      },
    ];
  });

  SyncOperation op(String id, Map<String, Object?> f, {String h = home}) => {
    Op.type: 'rooms.room',
    Op.home: h,
    Op.id: id,
    Op.kind: Op.put,
    Op.clock: '0193a1b2c3d40001',
    Op.device: device,
    Op.schema: 6,
    Op.fields: f,
  };

  group('capabilities', () {
    test('a server with the sync API gives its version and limits', () async {
      server.info = {
        'sync': [1],
        'server': '0.4.0',
        'oauth': {},
        'limits': {'ops_per_push': 500},
      };
      final c = await transport.capabilities();
      expect(c.version, '0.4.0');
      expect(c.limits['ops_per_push'], 500);
    });

    test('a server too old for the sync API is refused', () async {
      server.info = null; // 404
      await expectLater(
        transport.capabilities(),
        throwsA(
          isA<ServerStopped>().having((e) => e.reason, 'r', ServerStop.tooOld),
        ),
      );
      server.info = {
        'sync': [2],
        'server': '9.0.0',
      };
      await expectLater(
        transport.capabilities(),
        throwsA(
          isA<ServerStopped>().having((e) => e.reason, 'r', ServerStop.tooOld),
        ),
      );
    });
  });

  group('push', () {
    test('one push per home, numbered, with the device and sv of the body '
        'and the keys of section 2.2 only', () async {
      server.homes.add({...server.homes.first, 'id': other});
      await transport.push([
        op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
        op('22222222-2222-4222-8222-222222222222', {'name': 'Hall'}, h: other),
      ]);
      expect(server.pushes, hasLength(2));
      final first = server.pushes.first;
      expect(first.home, home);
      expect(first.body['push'], 1);
      expect(first.body['sv'], 6);
      expect(first.body['device'], device);
      final wire = (first.body['ops'] as List).single as Map;
      expect(wire.keys.toSet(), {'t', 'h', 'id', 'k', 'c', 'f'});
      expect(server.pushes.last.body['push'], 2);
      expect(server.pushes.last.home, other);
    });

    test('a field that lost comes back as the value that won', () async {
      server.pushResults = [
        {
          'i': 0,
          'status': 'applied',
          'lost': {
            'name': ['Kitchen (web)', '0193a1b2c3d40009', serverDevice],
          },
        },
      ];
      final result = await transport.push([
        op('11111111-1111-4111-8111-111111111111', {
          'name': 'Kitchen',
          'floor': 1,
        }),
      ]);
      expect(result.lost, [
        {
          Op.type: 'rooms.room',
          Op.home: home,
          Op.id: '11111111-1111-4111-8111-111111111111',
          Op.kind: Op.put,
          Op.clock: '0193a1b2c3d40009',
          Op.device: serverDevice,
          Op.fields: {'name': 'Kitchen (web)'},
        },
      ]);
      expect(
        transport.seen[('rooms.room', '11111111-1111-4111-8111-111111111111')],
        isTrue,
      );
    });

    test('a rejected operation is listed and not marked seen', () async {
      server.pushResults = [
        {'i': 0, 'status': 'rejected', 'code': 'forbidden'},
      ];
      await transport.push([
        op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
      ]);
      expect(transport.rejections.single.code, 'forbidden');
      expect(
        transport.seen[('rooms.room', '11111111-1111-4111-8111-111111111111')],
        isFalse,
      );
    });

    test('a push whose answer never came is sent again first, same number '
        'and same bytes', () async {
      server.failNextPush = true;
      await expectLater(
        transport.push([
          op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
        ]),
        throwsA(isA<ServerHttpException>()),
      );
      final lostBytes = server.lastPushBytes;
      await transport.push([
        op('22222222-2222-4222-8222-222222222222', {'name': 'Hall'}),
      ]);
      expect(server.pushes.first.body['push'], 1);
      expect(server.pushes.first.raw, lostBytes);
      expect(server.pushes.last.body['push'], 2);
    });

    test('a home erased on the server is gone, and its operations are not '
        'sent again', () async {
      server.erased.add(home);
      await transport.push([
        op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
      ]);
      expect(await state.readServerState(), contains(home));
      server.pushes.clear();
      await transport.push([
        op('22222222-2222-4222-8222-222222222222', {'name': 'Hall'}),
      ]);
      expect(server.pushes, isEmpty);
    });

    test('sync_version stops the push: update the app', () async {
      server.pushError = (400, 'sync_version');
      await expectLater(
        transport.push([
          op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
        ]),
        throwsA(
          isA<ServerStopped>().having(
            (e) => e.reason,
            'r',
            ServerStop.updateApp,
          ),
        ),
      );
    });
  });

  group('a push refused for good (decision A of the maintainer)', () {
    String id(int n) =>
        '${n.toRadixString(16).padLeft(8, '0')}-1111-4111-8111-111111111111';
    List<SyncOperation> rooms(int count) => [
      for (var n = 1; n <= count; n++) op(id(n), {'name': 'Room $n'}),
    ];
    Set<String> idsOf(Map<String, Object?> body) => {
      for (final o in body['ops']! as List) (o as Map)['id']! as String,
    };
    Set<String> applied() => {for (final p in server.pushes) ...idsOf(p.body)};
    bool noUnanswered() =>
        ServerSyncState.decode(state.value).unanswered == null;

    /// The server refuses every push that carries one of [faulty].
    void refuse(Set<String> faulty, int status, String code) => server.judge = (
      body,
    ) => idsOf(body).intersection(faulty).isEmpty ? null : (status, code, null);

    for (final (status, code) in [
      (400, 'malformed'),
      (400, 'too_large'),
      (409, 'push_conflict'),
    ]) {
      test('$status $code: the push is cut in halves until the operations at '
          'fault are alone; the others go, those are kept aside', () async {
        final ops = rooms(9);
        refuse({id(3), id(7)}, status, code);
        final result = await transport.push(ops);
        expect(result.refused.map((r) => r.operation[Op.id]), [id(3), id(7)]);
        expect(result.refused.map((r) => r.code).toSet(), {code});
        expect(applied(), {
          for (var n = 1; n <= 9; n++)
            if (n != 3 && n != 7) id(n),
        });
        expect(noUnanswered(), isTrue, reason: 'nothing is sent again');
        // The next round sends nothing of them again.
        server.tried.clear();
        await transport.push(const []);
        expect(server.tried, isEmpty);
      });
    }

    test('400 malformed with the index of the operation: that one is kept '
        'aside at once, the others go in the next push', () async {
      final ops = rooms(6);
      server.judge = (body) {
        final ids = idsOf(body).toList();
        final at = ids.indexOf(id(4));
        return at < 0 ? null : (400, 'malformed', at);
      };
      final result = await transport.push(ops);
      expect(result.refused.single.operation[Op.id], id(4));
      expect(result.refused.single.detail, 'Refused.');
      expect(server.tried, hasLength(2));
      expect(applied(), hasLength(5));
    });

    test('409 push_conflict on the number only: the same operations go under '
        'the next number, none is kept aside', () async {
      var first = true;
      server.judge = (body) {
        if (!first) return null;
        first = false;
        return (409, 'push_conflict', null);
      };
      final result = await transport.push(rooms(4));
      expect(result.refused, isEmpty);
      expect(server.tried.map((b) => b['push']), [1, 2]);
      expect(applied(), hasLength(4));
    });

    test('409 wrong_device: the device is the push\'s, so every operation is '
        'kept aside at once, with one push', () async {
      server.judge = (_) => (409, 'wrong_device', null);
      final result = await transport.push(rooms(5));
      expect(result.refused, hasLength(5));
      expect(result.refused.map((r) => r.code).toSet(), {'wrong_device'});
      expect(server.tried, hasLength(1));
      expect(noUnanswered(), isTrue);
    });

    test('a refusal of the push sent again only clears it: its operations '
        'still wait in op_log and go through the rule', () async {
      server.failNextPush = true;
      await expectLater(
        transport.push(rooms(2)),
        throwsA(isA<ServerHttpException>()),
      );
      expect(noUnanswered(), isFalse);
      refuse({id(2)}, 400, 'malformed');
      final result = await transport.push(rooms(2));
      expect(result.refused.single.operation[Op.id], id(2));
      expect(applied(), {id(1)});
      expect(noUnanswered(), isTrue);
    });

    for (final status in [429, 500, 502, 503]) {
      test('$status: no operation is kept aside, the same push (number and '
          'bytes) goes again next time', () async {
        server.pushError = (status, '');
        await expectLater(
          transport.push(rooms(2)),
          throwsA(isA<ServerBusy>().having((e) => e.status, 's', status)),
        );
        final sent = server.lastPushBytes;
        expect(noUnanswered(), isFalse);
        server.pushError = null;
        final result = await transport.push(const []);
        expect(result.refused, isEmpty);
        expect(server.pushes.single.raw, sent);
        expect(server.pushes.single.body['push'], 1);
      });
    }

    test(
      'an operation rejected in a push taken is kept aside with its code',
      () async {
        server.pushResults = [
          {'i': 0, 'status': 'applied'},
          {'i': 1, 'status': 'rejected', 'code': 'clock_ahead'},
        ];
        final result = await transport.push(rooms(2));
        expect(result.refused.single.operation[Op.id], id(2));
        expect(result.refused.single.code, 'clock_ahead');
      },
    );

    test('a push stays under 1 MiB of body and 200 operations', () async {
      final notes = 'x' * (300 * 1024);
      final big = [
        for (var n = 1; n <= 7; n++)
          op(id(n), {'name': 'Room $n', 'notes': notes}),
      ];
      await transport.push(big);
      expect(server.pushes.length, greaterThanOrEqualTo(3));
      for (final p in server.pushes) {
        expect(p.raw.length, lessThanOrEqualTo(ServerTransport.pushBytes));
      }
      expect(applied(), hasLength(7));
      server.pushes.clear();
      await transport.push(rooms(450));
      expect(server.pushes.map((p) => (p.body['ops']! as List).length), [
        200,
        200,
        50,
      ]);
    });

    test('one operation larger than 1 MiB is kept aside as too_large, never '
        'sent', () async {
      final result = await transport.push([
        op(id(1), {'notes': 'x' * (ServerTransport.pushBytes + 1)}),
        op(id(2), {'name': 'Hall'}),
      ]);
      expect(result.refused.single.operation[Op.id], id(1));
      expect(result.refused.single.code, 'too_large');
      expect(server.tried.expand(idsOf), [id(2)]);
    });
  });

  group('the operation on the wire', () {
    Map<String, Object?> put(String type, Map<String, Object?> f) => {
      Op.type: type,
      Op.home: home,
      Op.id: '11111111-1111-4111-8111-111111111111',
      Op.kind: Op.put,
      Op.clock: '0193a1b2c3d40001',
      Op.device: device,
      Op.schema: 6,
      Op.fields: f,
    };

    test('deleted_at set is a delete, cleared alone is a restore, cleared '
        'with other fields is left out', () {
      expect(
        ServerTransport.wire(
          put('rooms.room', {'deleted_at': '0193a1b2c3d40001'}),
        ).map((o) => o[Op.kind]),
        [Op.delete],
      );
      expect(
        ServerTransport.wire(put('rooms.room', {'deleted_at': null}))
            .map((o) => o[Op.kind]),
        [Op.restore],
      );
      final created = ServerTransport.wire(
        put('rooms.room', {'name': 'Kitchen', 'deleted_at': null}),
      );
      expect(created.single[Op.fields], {'name': 'Kitchen'});
      final both = ServerTransport.wire(
        put('rooms.room', {'name': 'Old', 'deleted_at': '0193a1b2c3d40001'}),
      );
      expect(both.map((o) => o[Op.kind]), [Op.put, Op.delete]);
      expect(both.last.containsKey(Op.fields), isFalse);
    });

    test('the columns the server keeps are not sent; created_at is, where '
        'the server takes it', () {
      final room = ServerTransport.wire(
        put('rooms.room', {
          'name': 'Kitchen',
          'created_at': '0193a1b2c3d40001',
          'updated_at': '0193a1b2c3d40001',
        }),
      );
      expect(room.single[Op.fields], {'name': 'Kitchen'});
      final movement = ServerTransport.wire(
        put('stock.movement', {
          'quantity': '1',
          'created_at': '0193a1b2c3d40001',
        }),
      );
      expect(
        (movement.single[Op.fields]! as Map).keys,
        unorderedEquals(['quantity', 'created_at']),
      );
      expect(
        ServerTransport.wire(
          put('rooms.room', {'updated_at': '0193a1b2c3d40001'}),
        ),
        isEmpty,
      );
    });

    test('the derived visible_from of an occurrence is not sent (web '
        'SYNC_DERIVED; found by the e2e against v0.4.1)', () {
      final occurrence = ServerTransport.wire(
        put('tasks.occurrence', {
          'due_on': '2026-11-16',
          'visible_from': '2026-11-09',
        }),
      );
      expect(occurrence.single[Op.fields], {'due_on': '2026-11-16'});
    });
  });

  group('the mark seen by the server', () {
    test('rows of the feed, of a snapshot, and of a push applied are marked; '
        'a rejected one is not', () async {
      final marked = _Seen();
      transport = ServerTransport(
        address: address,
        http: server,
        store: store,
        state: state,
        device: device,
        schemaVersion: 6,
        seenStore: marked,
      );
      server.snapshot = [
        {
          't': 'rooms.room',
          'h': home,
          'id': '33333333-3333-4333-8333-333333333333',
          'f': {
            'name': ['Attic', '0193a1b2c3d40001', serverDevice],
          },
        },
        {'covers': 3},
      ];
      final first = await transport.pull();
      expect(first.complete[home], {
        ('rooms.room', '33333333-3333-4333-8333-333333333333'),
      });
      server.changes = [
        {
          'pos': 4,
          'device': serverDevice,
          'op': op('44444444-4444-4444-8444-444444444444', {'name': 'Hall'}),
        },
      ];
      await transport.pull(after: first.position);
      server.pushResults = [
        {'i': 0, 'status': 'applied'},
        {'i': 1, 'status': 'rejected', 'code': 'forbidden'},
      ];
      await transport.push([
        op('55555555-5555-4555-8555-555555555555', {'name': 'Den'}),
        op('66666666-6666-4666-8666-666666666666', {'name': 'Bad'}),
      ]);
      expect(marked.rows, {
        ('rooms.room', home, '33333333-3333-4333-8333-333333333333'),
        ('rooms.room', home, '44444444-4444-4444-8444-444444444444'),
        ('rooms.room', home, '55555555-5555-4555-8555-555555555555'),
      });
    });

    test('a push towards a cursor the server no longer keeps sends nothing '
        'and waits for the rule after 410', () async {
      final first = await transport.pull();
      await transport.pull(after: first.position);
      server.expired = true;
      final result = await transport.push([
        op('77777777-7777-4777-8777-777777777777', {'name': 'Loft'}),
      ]);
      expect(result.held, isTrue);
      expect(server.pushes, isEmpty);
    });
  });

  group('pull', () {
    test(
      'a first pull reads the snapshot, then the feed after covers',
      () async {
        server.snapshot = [
          {
            't': 'rooms.room',
            'h': home,
            'id': '11111111-1111-4111-8111-111111111111',
            'f': {
              'name': ['Kitchen', '0193a1b2c3d40001', serverDevice],
              'floor': [0, '0193a1b2c3d40002', device],
            },
          },
          {
            't': 'rooms.room',
            'h': home,
            'id': '33333333-3333-4333-8333-333333333333',
            'f': {
              'name': ['Old', '0193a1b2c3d40001', serverDevice],
              'deleted_at': [
                '0193a1b2c3d40003',
                '0193a1b2c3d40003',
                serverDevice,
              ],
            },
          },
          {'members': []},
          {'covers': 7},
        ];
        final first = await transport.pull();
        expect(first.restart, isFalse);
        expect(first.operations, hasLength(4));
        expect(first.operations.first[Op.device], serverDevice);
        expect(
          first.operations.any(
            (o) => (o[Op.fields] as Map).containsKey('deleted_at'),
          ),
          isTrue,
        );
        server.changes = [
          {
            'pos': 8,
            'device': serverDevice,
            'op': {
              't': 'rooms.room',
              'h': home,
              'id': '11111111-1111-4111-8111-111111111111',
              'k': 'put',
              'c': '0193a1b2c3d40010',
              'f': {'name': 'Kitchen 2'},
            },
          },
        ];
        final next = await transport.pull(after: first.position);
        expect(server.lastAfter, '7');
        expect(next.operations.single[Op.device], serverDevice);
        expect((next.operations.single[Op.fields] as Map)['name'], 'Kitchen 2');
        await transport.pull(after: next.position);
        expect(server.lastAfter, '8');
      },
    );

    test('a page the engine did not take is read again', () async {
      server.snapshot = [
        {'covers': 3},
      ];
      final first = await transport.pull();
      await transport.pull(after: first.position);
      expect(server.lastAfter, '3');
      // The engine stopped before it took this page: it asks again after
      // the position it stored, so the feed is read from 3 again.
      await transport.pull(after: first.position);
      expect(server.lastAfter, '3');
    });

    test('410 cursor_expired: start again from the snapshot', () async {
      server.snapshot = [
        {'covers': 3},
      ];
      final first = await transport.pull();
      server.expired = true;
      final page = await transport.pull(after: first.position);
      expect(page.restart, isTrue);
      server.expired = false;
      server.snapshot = [
        {'covers': 40},
      ];
      final again = await transport.pull();
      await transport.pull(after: again.position);
      expect(server.lastAfter, '40');
    });

    test('a home erased, or no longer covered, is gone', () async {
      expect(await transport.homesGone(), isEmpty);
      server.homes.clear();
      server.gone = [
        {'id': other, 'at': '2026-11-15T10:00:00Z'},
      ];
      expect(await transport.homesGone(), unorderedEquals([home, other]));
    });

    test('the members of each home are kept, read only', () async {
      final homes = await transport.homes();
      expect(homes.single.members.map((m) => m.name), ['Sam', 'Robin']);
      expect(homes.single.owner, isTrue);
      final kept = ServerSyncState.decode(await state.readServerState());
      expect(kept.homes.single.members.last.role, 'read_only');
    });
  });

  group('the access', () {
    test(
      '401: the access token is refreshed once, then the call goes on',
      () async {
        server.validAccess = 'hca_two';
        await transport.homes();
        expect(server.refreshes, ['hcr_one']);
        final kept = await ServerCredential.read(store);
        expect(kept!.access, 'hca_two');
        expect(kept.refresh, 'hcr_two');
      },
    );

    test(
      'a refused refresh means the access was revoked: the phone says so',
      () async {
        server.validAccess = 'none';
        server.refuseRefresh = true;
        await expectLater(
          transport.homes(),
          throwsA(
            isA<ServerStopped>().having(
              (e) => e.reason,
              'r',
              ServerStop.disconnected,
            ),
          ),
        );
      },
    );

    test('a token endpoint on another host is never called', () async {
      await ServerCredential(
        access: 'hca_one',
        refresh: 'hcr_one',
        token: Uri.parse('https://evil.example/o/token/'),
        revoke: address.resolve('/o/revoke_token/'),
      ).write(store);
      server.validAccess = 'hca_two';
      await expectLater(transport.homes(), throwsA(isA<ServerStopped>()));
      expect(server.hosts, everyElement('hc.example.com'));
    });

    test(
      'disconnect revokes on the server and deletes the credential',
      () async {
        await transport.homes();
        await transport.disconnect();
        expect(server.revoked, ['hcr_one']);
        expect(await ServerCredential.read(store), isNull);
        expect(await state.readServerState(), isNull);
      },
    );

    test('disconnect offline still deletes the credential', () async {
      server.offline = true;
      await transport.disconnect();
      expect(await ServerCredential.read(store), isNull);
    });

    test('the credential is never in the state of local_settings', () async {
      await transport.homes();
      await transport.push([
        op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
      ]);
      final kept = await state.readServerState();
      expect(kept, isNot(contains('hca_')));
      expect(kept, isNot(contains('hcr_')));
      expect('${await ServerCredential.read(store)}', isNot(contains('hca_')));
    });

    test('every request goes to the address typed', () async {
      server.snapshot = [
        {'covers': 0},
      ];
      server.info = {
        'sync': [1],
        'server': '0.4.0',
      };
      await transport.capabilities();
      await transport.pull();
      await transport.push([
        op('11111111-1111-4111-8111-111111111111', {'name': 'Kitchen'}),
      ]);
      expect(server.hosts, isNotEmpty);
      expect(server.hosts, everyElement('hc.example.com'));
    });
  });

  group('sign-in', () {
    test('PKCE S256: base64url of the SHA-256 of the verifier (vector made by Python hashlib)', () {
      final pkce = Pkce.ofVerifier(
        'dBjftJeZ4CVP-mJ92K1RgUZTj0K7lZYmRc9xaZKJrVM',
      );
      expect(pkce.challenge, 'sUINqGArp-opJIM09Yf9sz9IJotF-kGzqOwnBqvZ7KQ');
      final random = Pkce.random();
      expect(random.verifier.length, 43);
      expect(random.verifier, isNot(Pkce.random().verifier));
    });

    Map<String, Object?> info({Object? oauth = 'default'}) => {
      'sync': [1],
      'oauth': oauth == 'default'
          ? {
              'authorize': 'https://hc.example.com/o/authorize/',
              'token': 'https://hc.example.com/o/token/',
              'revoke': 'https://hc.example.com/o/revoke_token/',
              'client_id': 'housecairn-mobile',
            }
          : oauth,
    };

    test('the browser opens the server\'s page with PKCE, state and scope', () {
      final oauth = oauthOfInfo(address, info());
      final request = SignInRequest(
        oauth: oauth,
        createHomes: false,
        deviceName: 'Phone',
      );
      final url = request.authorizeUrl;
      expect(url.host, 'hc.example.com');
      expect(url.path, '/o/authorize/');
      expect(url.queryParameters['response_type'], 'code');
      expect(url.queryParameters['client_id'], 'housecairn-mobile');
      expect(
        url.queryParameters['redirect_uri'],
        'app.housecairn.mobile:/oauth/callback',
      );
      expect(url.queryParameters['code_challenge_method'], 'S256');
      expect(url.queryParameters['code_challenge'], request.pkce.challenge);
      expect(url.queryParameters['scope'], 'sync');
      expect(url.queryParameters['device_name'], 'Phone');
      expect(url.queryParameters, isNot(contains('code_verifier')));
      expect(
        SignInRequest(
          oauth: oauth,
          createHomes: true,
          deviceName: 'Phone',
        ).authorizeUrl.queryParameters['scope'],
        'sync homes.create',
      );
    });

    test('the redirect is checked: state, cancel, code', () {
      final request = SignInRequest(
        oauth: oauthOfInfo(address, info()),
        createHomes: false,
        deviceName: 'Phone',
      );
      final s = request.state;
      expect(
        request.codeOf(
          Uri.parse('app.housecairn.mobile:/oauth/callback?code=abc&state=$s'),
        ),
        'abc',
      );
      expect(
        () => request.codeOf(
          Uri.parse('app.housecairn.mobile:/oauth/callback?code=abc&state=x'),
        ),
        throwsA(isA<SignInException>()),
      );
      expect(
        () => request.codeOf(
          Uri.parse(
            'app.housecairn.mobile:/oauth/callback?error=access_denied&state=$s',
          ),
        ),
        throwsA(
          isA<SignInException>().having(
            (e) => e.error,
            'e',
            SignInError.cancelled,
          ),
        ),
      );
      final form = request.tokenForm('abc');
      expect(form['code_verifier'], request.pkce.verifier);
      expect(form['grant_type'], 'authorization_code');
    });

    test('a server too old, the mobile app off, a foreign endpoint', () {
      expect(
        () => oauthOfInfo(address, {'detail': 'Not found'}),
        throwsA(
          isA<SignInException>().having(
            (e) => e.error,
            'e',
            SignInError.tooOld,
          ),
        ),
      );
      expect(
        () => oauthOfInfo(address, info(oauth: null)),
        throwsA(
          isA<SignInException>().having(
            (e) => e.error,
            'e',
            SignInError.mobileAppOff,
          ),
        ),
      );
      expect(
        () => oauthOfInfo(
          address,
          info(
            oauth: {
              'authorize': 'https://evil.example/o/authorize/',
              'token': 'https://hc.example.com/o/token/',
              'revoke': 'https://hc.example.com/o/revoke_token/',
            },
          ),
        ),
        throwsA(
          isA<SignInException>().having(
            (e) => e.error,
            'e',
            SignInError.foreignEndpoint,
          ),
        ),
      );
    });
  });
}

class _Push {
  _Push(this.home, this.raw)
    : body = (jsonDecode(utf8.decode(raw)) as Map).cast<String, Object?>();

  final String home;
  final Uint8List raw;
  final Map<String, Object?> body;
}

class _Server implements ServerHttp {
  Map<String, Object?>? info;
  List<Map<String, Object?>> homes = [];
  List<Map<String, Object?>> gone = [];
  List<Map<String, Object?>> snapshot = [
    {'covers': 0},
  ];
  List<Map<String, Object?>> changes = [];
  List<Map<String, Object?>>? pushResults;
  (int, String)? pushError;

  /// Decides a push before it is applied: `(status, code, index)` refuses
  /// it as a whole, `null` lets it through.
  (int, String, int?)? Function(Map<String, Object?> body)? judge;

  /// Every push that reached the server, refused ones included.
  final tried = <Map<String, Object?>>[];
  final erased = <String>{};
  final pushes = <_Push>[];
  final refreshes = <String>[];
  final revoked = <String>[];
  final hosts = <String>[];
  String validAccess = 'hca_one';
  bool refuseRefresh = false;
  bool failNextPush = false;
  bool expired = false;
  bool offline = false;
  String? lastAfter;
  Uint8List? lastPushBytes;

  ServerReply _json(int status, Object body) =>
      ServerReply(status, utf8.encode(jsonEncode(body)));

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    hosts.add(url.host);
    if (offline) {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
    final path = url.path;
    if (path == '/o/token/') {
      final form = Uri.splitQueryString(utf8.decode(body!));
      refreshes.add(form['refresh_token']!);
      if (refuseRefresh) return _json(400, {'error': 'invalid_grant'});
      return _json(200, {
        'access_token': 'hca_two',
        'refresh_token': 'hcr_two',
      });
    }
    if (path == '/o/revoke_token/') {
      revoked.add(Uri.splitQueryString(utf8.decode(body!))['token']!);
      return _json(200, {});
    }
    if (headers['authorization'] != 'Bearer $validAccess') {
      return _json(401, {'detail': 'no'});
    }
    if (path == '/api/v1/sync/info') {
      return info == null
          ? _json(404, {'detail': 'Not found'})
          : _json(200, info!);
    }
    if (path == '/api/v1/sync/homes/') {
      return _json(200, {'homes': homes, 'gone': gone});
    }
    final m = RegExp(r'^/api/v1/sync/homes/([^/]+)/(\w+)$').firstMatch(path)!;
    final h = m.group(1)!;
    if (erased.contains(h)) return _json(410, {'code': 'home_gone'});
    switch (m.group(2)) {
      case 'snapshot':
        return ServerReply(
          200,
          utf8.encode(snapshot.map((l) => '${jsonEncode(l)}\n').join()),
        );
      case 'changes':
        lastAfter = url.queryParameters['after'];
        if (expired) return _json(410, {'code': 'cursor_expired'});
        final after = int.parse(lastAfter!);
        return _json(200, {
          'changes': [
            for (final c in changes)
              if ((c['pos']! as int) > after) c,
          ],
          'head': 0,
          'more': false,
        });
      case 'push':
        lastPushBytes = body;
        if (failNextPush) {
          failNextPush = false;
          throw const ServerHttpException(ServerHttpFailure.unreachable);
        }
        if (pushError case (final status, final code)) {
          return _json(status, {'code': code});
        }
        final decoded = (jsonDecode(utf8.decode(body!)) as Map)
            .cast<String, Object?>();
        tried.add(decoded);
        if (judge?.call(decoded) case (final status, final code, final i)) {
          return _json(status, {
            'detail': 'Refused.',
            'code': code,
            'index': ?i,
          });
        }
        final push = _Push(h, body);
        pushes.add(push);
        final ops = push.body['ops'] as List;
        return _json(200, {
          'head': 1,
          'results':
              pushResults ??
              [
                for (var i = 0; i < ops.length; i++)
                  {'i': i, 'status': 'applied'},
              ],
        });
    }
    return _json(404, {});
  }
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

class _MemoryState implements ServerStateStore {
  String? value;

  @override
  Future<String?> readServerState() async => value;

  @override
  Future<void> writeServerState(String? state) async => value = state;
}

class _Seen implements ServerSeenStore {
  final rows = <(String, String, String)>{};

  @override
  Future<void> markSeen(Iterable<(String, String, String)> marked) async =>
      rows.addAll(marked);
}
