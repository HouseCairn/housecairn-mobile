// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/sync/transport.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/ways.dart';

import 'support/fixture.dart';
import 'support/sync_fixture.dart';

/// The moves of docs/plan.md, lot 4b, without merging or losing data: server
/// → alone, alone → server only for a phone with no home; and what the
/// signed-in account may write in a home of the server (read-only members,
/// archiving by owners).
void main() {
  final address = ServerAddress.parse('https://hc.example.com').$1!;

  late Repository repo;
  late _Store store;
  late _Server server;
  late AppState state;
  late String home;

  Future<void> connect({String role = 'owner'}) async {
    home = await repo.createHome(name: 'House');
    await repo.createRoom(home, name: 'Kitchen');
    server.role = role;
    server.home = home;
    await ServerCredential(
      access: 'hca_one',
      refresh: 'hcr_one',
      token: address.resolve('/o/token/'),
      revoke: address.resolve('/o/revoke_token/'),
    ).write(store);
    await repo.setServerAddress(address.display);
    await repo.setSyncMode(SyncMode.server);
    // The phone took the server's home: its rows are acknowledged.
    final out = await repo.outgoing();
    await repo.acknowledge(out.last.seq);
    final transport = ServerTransport(
      address: address,
      http: server,
      store: store,
      state: repo.serverState,
      device: repo.deviceB64,
      schemaVersion: repo.schemaVersion,
    );
    await transport.homes();
    await state.refresh();
  }

  setUp(() async {
    repo = await openRepository();
    addTearDown(repo.db.close);
    store = _Store();
    server = _Server();
    state = AppState(repo, store: store, serverHttp: (_) => server);
    addTearDown(state.dispose);
  });

  group('changes the server refused (decision A)', () {
    test('kept aside out of op_log with their reason; one sent again goes '
        'back to op_log, one dropped is gone, and the row keeps its value '
        'on the phone', () async {
      await connect();
      await repo.createRoom(home, name: 'Hall');
      await repo.createRoom(home, name: 'Cellar');
      final out = await repo.outgoing();
      expect(out, hasLength(2));
      await repo.setAside([
        for (final o in out) RefusedOperation(o.operation, 'forbidden'),
      ]);
      await repo.acknowledge(out.last.seq);
      final refused = await repo.refusedChanges();
      expect(refused.map((r) => r.code), ['forbidden', 'forbidden']);
      expect(await repo.outgoing(), isEmpty);
      await repo.sendAgain(refused.first.id);
      expect((await repo.outgoing()).single.operation, refused.first.operation);
      await repo.dropRefused(refused.last.id);
      expect(await repo.refusedChanges(), isEmpty);
      expect(
        (await repo.rooms(home)).map((r) => r.name),
        containsAll(['Hall', 'Cellar']),
      );
    });

    test('the engine keeps aside what the transport refused, then '
        'acknowledges the push', () async {
      await connect();
      server.rejectNamed = 'Hall';
      await repo.createRoom(home, name: 'Hall');
      await repo.createRoom(home, name: 'Cellar');
      await state.syncWithServer(throwing: true);
      expect(await repo.outgoing(), isEmpty);
      final refused = await repo.refusedChanges();
      expect(refused.single.code, 'forbidden');
      expect((refused.single.operation[Op.fields]! as Map)['name'], 'Hall');
      expect(state.serverSync.refused, hasLength(1));
      expect(server.pushedNames, contains('Cellar'));
    });

    test('leaving the server forgets them; the rows stay', () async {
      await connect();
      server.rejectNamed = 'Hall';
      await repo.createRoom(home, name: 'Hall');
      await state.syncWithServer(throwing: true);
      expect(await repo.refusedChanges(), hasLength(1));
      await state.leaveServer();
      expect(await repo.refusedChanges(), isEmpty);
      expect(state.serverSync.refused, isEmpty);
      expect((await repo.rooms(home)).map((r) => r.name), contains('Hall'));
    });
  });

  group('server → alone', () {
    test('the access is revoked and deleted, the homes stay as they were, '
        'no longer synced', () async {
      await connect();
      await repo.markServerSeen([('rooms.room', home, home)]);
      final before = await dumpOf(repo, tables: ['homes', ...homeTables]);
      final left = await state.leaveServer();
      expect(left, isEmpty);
      expect(server.revoked, ['hcr_one']);
      expect(store.values, isEmpty, reason: 'no credential left in Store');
      expect(await repo.storedSyncMode(), SyncMode.alone);
      expect(await repo.serverAddress(), isNull);
      expect(await repo.serverState.readServerState(), isNull);
      expect(await repo.serverSeenIn(home), isEmpty);
      expect(await dumpOf(repo, tables: ['homes', ...homeTables]), before);
      // The homes are the phone's again: written, not refused.
      await repo.createRoom(home, name: 'Hall');
    });

    test('changes not sent are sent first when the server answers', () async {
      await connect();
      await repo.createRoom(home, name: 'Hall');
      expect(await state.unsentChanges(), isNotEmpty);
      final left = await state.leaveServer();
      expect(left, isEmpty);
      expect(server.pushedNames, contains('Hall'));
      expect(await repo.outgoing(), isEmpty);
      expect(await repo.storedSyncMode(), SyncMode.alone);
    });

    test('with the server out of reach, nothing changes until the person '
        'confirms; the changes then stay on the phone, named first', () async {
      await connect();
      await repo.createRoom(home, name: 'Hall');
      server.offline = true;
      final left = await state.leaveServer();
      expect(unsentNames(left).named, ['Hall']);
      expect(await repo.storedSyncMode(), SyncMode.server);
      expect(await ServerCredential.read(store), isNotNull);
      final before = await dumpOf(repo, tables: ['homes', ...homeTables]);
      expect(await state.leaveServer(keepUnsent: true), isEmpty);
      expect(await repo.storedSyncMode(), SyncMode.alone);
      expect(await ServerCredential.read(store), isNull);
      expect(await repo.outgoing(), isEmpty);
      expect(await dumpOf(repo, tables: ['homes', ...homeTables]), before);
      expect(
        (await repo.rooms(home)).map((r) => r.name),
        containsAll(['Kitchen', 'Hall']),
      );
    });
  });

  group('alone → server', () {
    test('only a phone with no home moves; one with homes is told lot 4c '
        'brings it', () async {
      await state.refresh();
      expect(state.homes, isEmpty);
      expect(state.canMoveToServer, isTrue);
      await repo.createHome(name: 'Mine');
      await state.refresh();
      expect(state.canMoveToServer, isFalse);
    });
  });

  group('roles of the signed-in account', () {
    test('a read-only member writes nothing in the home', () async {
      await connect(role: 'read_only');
      final before = await dumpOf(repo);
      await expectLater(
        repo.createRoom(home, name: 'Hall'),
        throwsA(
          isA<Refused>().having((r) => r.reason, 'r', Refusal.readOnlyHome),
        ),
      );
      final room = (await repo.rooms(home)).single;
      await expectLater(
        repo.updateRoom(room.id, const RoomInput(name: 'Pantry')),
        throwsA(isA<Refused>()),
      );
      expect(await repo.outgoing(), isEmpty);
      expect(await dumpOf(repo), before);
    });

    test('a write of the screens made while a sync applies is still refused '
        'to a read-only member: the exemption is the zone of the apply, not '
        'a state of the repository', () async {
      await connect(role: 'read_only');
      final room = (await repo.rooms(home)).single;
      final before = await repo.outgoing();
      final refused = throwsA(
        isA<Refused>().having((r) => r.reason, 'r', Refusal.readOnlyHome),
      );
      // The screen writes and the sync applies the server's change, all
      // under way at once: the writes of the screen are checked whatever
      // order the database runs them in, since only the zone of the apply
      // is exempt.
      final writes = [
        expectLater(
          repo.updateRoom(room.id, const RoomInput(name: 'Hall')),
          refused,
        ),
        expectLater(repo.createRoom(home, name: 'Cellar'), refused),
      ];
      final applying = repo.applyOperations([
        {
          Op.type: 'rooms.room',
          Op.home: home,
          Op.id: room.id,
          Op.kind: Op.put,
          Op.clock: '7fff000000000000',
          Op.device: 'q2Xh0dVt3kWmYc1bS8fP9A',
          Op.schema: repo.schemaVersion,
          Op.fields: {'name': 'Pantry'},
        },
      ]);
      await Future.wait([...writes, applying]);
      expect((await repo.room(room.id))!.name, 'Pantry');
      expect((await repo.rooms(home)).map((r) => r.name), ['Pantry']);
      expect((await repo.outgoing()).length, before.length);
    });

    test('the server\'s changes still reach a read-only home', () async {
      await connect(role: 'read_only');
      final room = (await repo.rooms(home)).single;
      await repo.applyOperations([
        {
          Op.type: 'rooms.room',
          Op.home: home,
          Op.id: room.id,
          Op.kind: Op.put,
          Op.clock: '7fff000000000000',
          Op.device: 'q2Xh0dVt3kWmYc1bS8fP9A',
          Op.schema: repo.schemaVersion,
          Op.fields: {'name': 'Pantry'},
        },
      ]);
      expect((await repo.room(room.id))!.name, 'Pantry');
    });

    test('an owner archives a home of the server, and it is sent', () async {
      await connect();
      await repo.createHome(name: 'Flat');
      await repo.setSyncMode(SyncMode.server);
      final out = await repo.outgoing();
      await repo.acknowledge(out.last.seq);
      await repo.archiveHome(home);
      final sent = await repo.outgoing();
      expect(
        sent.map((o) => (o.operation[Op.fields]! as Map).keys),
        contains(contains('archived_at')),
      );
      await repo.unarchiveHome(home);
    });

    test('a member who is not an owner cannot archive', () async {
      await connect(role: 'member');
      await repo.createHome(name: 'Flat');
      await expectLater(
        repo.archiveHome(home),
        throwsA(
          isA<Refused>().having((r) => r.reason, 'r', Refusal.ownersOnly),
        ),
      );
      expect((await repo.home(home))!.archivedAt, isNull);
    });

    test('a home of the server is not deleted from the phone', () async {
      await connect();
      await repo.createHome(name: 'Flat');
      await expectLater(
        repo.deleteHome(home, typedName: 'House'),
        throwsA(
          isA<Refused>().having((r) => r.reason, 'r', Refusal.deleteOnServer),
        ),
      );
      expect(await repo.home(home), isNotNull);
    });
  });
}

class _Store implements Store {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Uint8List value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// A server of one home, enough for the moves: the list of homes, an empty
/// feed and snapshot, pushes applied, and the revocation.
class _Server implements ServerHttp {
  String home = '';
  String role = 'owner';
  bool offline = false;

  /// A room of this name is rejected `forbidden` in a push taken.
  String? rejectNamed;
  final revoked = <String>[];
  final pushedNames = <String>[];

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
    final path = url.path;
    if (path == '/o/revoke_token/') {
      revoked.add(Uri.splitQueryString(utf8.decode(body!))['token']!);
      return _json(200, {});
    }
    if (path == '/api/v1/sync/info') {
      return _json(200, {
        'sync': [1],
        'server': '0.4.1',
      });
    }
    if (path == '/api/v1/sync/homes/') {
      return _json(200, {
        'homes': [
          {'id': home, 'name': 'House', 'role': role, 'members': <Object>[]},
        ],
        'gone': <Object>[],
      });
    }
    if (path.endsWith('/snapshot')) {
      return ServerReply(200, utf8.encode('{"covers": 0}\n'));
    }
    if (path.endsWith('/changes')) {
      return _json(200, {'changes': <Object>[], 'head': 0, 'more': false});
    }
    if (path.endsWith('/push')) {
      final ops = (jsonDecode(utf8.decode(body!)) as Map)['ops'] as List;
      final names = [for (final op in ops) ((op as Map)['f'] as Map?)?['name']];
      for (final name in names) {
        if (name is String && name != rejectNamed) pushedNames.add(name);
      }
      return _json(200, {
        'head': 1,
        'results': [
          for (var i = 0; i < ops.length; i++)
            names[i] == rejectNamed
                ? {'i': i, 'status': 'rejected', 'code': 'forbidden'}
                : {'i': i, 'status': 'applied'},
        ],
      });
    }
    return _json(404, {});
  }
}
