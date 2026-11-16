// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/sync/engine.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';

import 'support/fixture.dart';

/// An Android backup carries the database but never the secure store
/// (maintainer's decision, 2026-11-16, android/app/src/main/res/xml): a
/// database restored on a phone finds no copy of its device id there, takes
/// a new one, and sends nothing under the old one; a home of a server asks
/// for a new sign-in first.
void main() {
  final address = ServerAddress.parse('https://hc.example.com').$1!;
  late Directory dir;
  late File file;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    dir = Directory.systemTemp.createTempSync('housecairn-restore-');
    file = File('${dir.path}/housecairn.sqlite');
    addTearDown(() => dir.deleteSync(recursive: true));
  });

  /// The app's database in [file], opened as the app opens it, with the
  /// secure store [secrets].
  Future<Repository> openOn(Store secrets, {int seed = 1}) async {
    final repo = Repository(
      AppDatabase(NativeDatabase(file)),
      clock: FixedClock(testNow),
      files: dir,
      random: Random(seed),
    );
    await repo.open(secrets: secrets);
    return repo;
  }

  /// The copy of [file] a backup restores on another phone (or on this one
  /// after a reset): the database, and a secure store left empty.
  Future<Repository> restored({int seed = 2}) => openOn(_Store(), seed: seed);

  test('the same phone opened again keeps its id', () async {
    final secrets = _Store();
    final first = await openOn(secrets);
    final id = first.deviceB64;
    await first.db.close();
    final again = await openOn(secrets, seed: 9);
    addTearDown(again.db.close);
    expect(again.deviceB64, id);
    expect(again.restoredFromBackup, isFalse);
  });

  test('a database of an older version, never bound, keeps its id and is '
      'bound', () async {
    final old = Repository(
      AppDatabase(NativeDatabase(file)),
      clock: FixedClock(testNow),
      files: dir,
      random: Random(1),
    );
    await old.open();
    final id = old.deviceB64;
    await old.db.close();
    final secrets = _Store();
    final now = await openOn(secrets, seed: 9);
    addTearDown(now.db.close);
    expect(now.deviceB64, id);
    expect(now.restoredFromBackup, isFalse);
    expect(secrets.values[Repository.deviceMarkerKey], isNotNull);
  });

  test('alone on this phone: restored, the phone has a new id and keeps its '
      'homes and their changes', () async {
    final before = await openOn(_Store());
    final home = await before.createHome(name: 'House');
    await before.createRoom(home, name: 'Kitchen');
    final old = before.deviceB64;
    await before.db.close();
    final after = await restored();
    addTearDown(after.db.close);
    expect(after.restoredFromBackup, isTrue);
    expect(after.deviceB64, isNot(old));
    expect((await after.homes()).map((h) => h.name), ['House']);
    expect((await after.rooms(home)).map((r) => r.name), ['Kitchen']);
    final waiting = await after.outgoing();
    expect(waiting, isNotEmpty);
    expect(waiting.map((o) => o.operation[Op.device]).toSet(), {
      after.deviceB64,
    }, reason: 'the changes waiting are this phone\'s, under its new id');
    // Written after the restore: under the new id.
    await after.createRoom(home, name: 'Hall');
    expect((await after.outgoing()).last.operation[Op.device], after.deviceB64);
  });

  test('with a server: restored, nothing is sent until a new sign-in, then '
      'only under the new id', () async {
    final secrets = _Store();
    final before = await openOn(secrets);
    final home = await before.createHome(name: 'House');
    final server = _Server(home);
    await before.setServerAddress(address.display);
    await ServerCredential(
      access: 'hca_one',
      refresh: 'hcr_one',
      token: address.resolve('/o/token/'),
      revoke: address.resolve('/o/revoke_token/'),
    ).write(secrets);
    ServerTransport transportOf(Repository repo, Store store) =>
        ServerTransport(
          address: address,
          http: server,
          store: store,
          state: repo.serverState,
          device: repo.deviceB64,
          schemaVersion: repo.schemaVersion,
          seenStore: repo.serverSeen,
        );
    await SyncEngine(before, transportOf(before, secrets)).sync();
    final old = before.deviceB64;
    expect(server.devices, {old});
    // A change whose push gets no answer: it would be sent again first,
    // with its bytes, which name the old id.
    await before.createRoom(home, name: 'Kitchen');
    server.failPush = true;
    await expectLater(
      SyncEngine(before, transportOf(before, secrets)).sync(),
      throwsA(isA<ServerHttpException>()),
    );
    expect(
      ServerSyncState.decode(await before.serverState.readServerState())
          .unanswered,
      isNotNull,
    );
    await before.db.close();
    server.failPush = false;

    // The backup restored on another phone: no secure store.
    final phone = _Store();
    final after = await openOn(phone, seed: 2);
    addTearDown(after.db.close);
    expect(after.restoredFromBackup, isTrue);
    expect(after.deviceB64, isNot(old));
    expect(await after.homes(), hasLength(1));
    expect(
      ServerSyncState.decode(await after.serverState.readServerState())
          .unanswered,
      isNull,
      reason: 'the push carrying the old id is forgotten',
    );
    final pushes = server.pushes.length;
    await expectLater(
      SyncEngine(after, transportOf(after, phone)).sync(),
      throwsA(
        isA<ServerStopped>().having(
          (e) => e.reason,
          'reason',
          ServerStop.disconnected,
        ),
      ),
    );
    expect(server.pushes, hasLength(pushes), reason: 'sign in first');
    // Signed in again on this phone: its changes go under its own id.
    await ServerCredential(
      access: 'hca_one',
      refresh: 'hcr_two',
      token: address.resolve('/o/token/'),
      revoke: address.resolve('/o/revoke_token/'),
    ).write(phone);
    await SyncEngine(after, transportOf(after, phone)).sync();
    final sent = server.pushes.sublist(pushes);
    expect(sent, isNotEmpty);
    expect({for (final p in sent) p['device']}, {after.deviceB64});
    expect([
      for (final p in sent)
        for (final o in p['ops']! as List) ((o as Map)['f'] as Map?)?['name'],
    ], contains('Kitchen'));
    expect(await after.outgoing(), isEmpty);
  });

  test('a restore forgets whatever access came with it', () async {
    final first = await openOn(_Store());
    await first.db.close();
    final phone = _Store();
    await ServerCredential(
      access: 'hca_one',
      refresh: 'hcr_one',
      token: address.resolve('/o/token/'),
      revoke: address.resolve('/o/revoke_token/'),
    ).write(phone);
    final after = await openOn(phone, seed: 2);
    addTearDown(after.db.close);
    expect(after.restoredFromBackup, isTrue);
    expect(await ServerCredential.read(phone), isNull);
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

/// A server of one home, empty: the list of homes, its snapshot and feed,
/// and pushes, kept with their device.
class _Server implements ServerHttp {
  _Server(this.home);

  final String home;
  bool failPush = false;
  final pushes = <Map<String, Object?>>[];

  Set<String> get devices => {for (final p in pushes) p['device']! as String};

  ServerReply _json(int status, Object body) =>
      ServerReply(status, utf8.encode(jsonEncode(body)));

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    final path = url.path;
    if (path == '/o/token/') return _json(400, {'error': 'invalid_grant'});
    if (headers['authorization'] != 'Bearer hca_one') {
      return _json(401, {'detail': 'no'});
    }
    if (path == '/api/v1/sync/homes/') {
      return _json(200, {
        'homes': [
          {'id': home, 'name': 'House', 'role': 'owner', 'members': <Object>[]},
        ],
        'gone': <Object>[],
      });
    }
    if (path.endsWith('/snapshot')) {
      return ServerReply(200, utf8.encode('${jsonEncode({'covers': 0})}\n'));
    }
    if (path.endsWith('/changes')) {
      return _json(200, {'changes': <Object>[], 'head': 0, 'more': false});
    }
    if (path.endsWith('/push')) {
      if (failPush) {
        throw const ServerHttpException(ServerHttpFailure.unreachable);
      }
      final push = (jsonDecode(utf8.decode(body!)) as Map)
          .cast<String, Object?>();
      pushes.add(push);
      final ops = push['ops']! as List;
      return _json(200, {
        'head': 1,
        'results': [
          for (var i = 0; i < ops.length; i++) {'i': i, 'status': 'applied'},
        ],
      });
    }
    return _json(404, {});
  }
}
