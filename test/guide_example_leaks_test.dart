// SPDX-License-Identifier: AGPL-3.0-only

// The guards of the example home of the guide (web ADR 0084, lot A2), one
// test for each: two calls at once make one example; a stray row of the
// example planted straight in `op_log`, `field_clock`, `pending` or
// `file_sync` is left out by every way out (`outgoing`, `snapshot`,
// `scanFiles`, `filesDue`); the ticks, the counts and the server rules.
// Each test fails when its guard is taken away.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';

import 'support/fakes.dart';
import 'support/fixture.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

void main() {
  late Repository repo;

  setUp(() async {
    repo = await openRepository();
  });

  group('two calls at once', () {
    test('make one example: the other is refused', () async {
      final results = await Future.wait([
        for (var i = 0; i < 2; i++)
          repo
              .createExampleHome(guide)
              .then<Object>((id) => id)
              .catchError((Object e) => e),
      ]);
      final made = results.whereType<String>().toList();
      final refused = results.whereType<Refused>().toList();
      expect(made, hasLength(1));
      expect(refused.single.reason, Refusal.exampleExists);
      final count = await repo.db
          .customSelect('SELECT COUNT(*) AS n FROM homes WHERE is_example = 1')
          .getSingle();
      expect(count.data['n'], 1);
      expect((await repo.exampleHome())!.id, made.single);
    });

    test('on a repository whose first read of the examples is still going: '
        'the id of the example is not lost, nothing of it is logged', () async {
      final real = repo.createHome(name: 'Main home');
      final example = repo.createExampleHome(guide);
      final id = await example;
      await real;
      expect(await repo.isExampleHome(id), isTrue);
      await repo.createRoom(id, name: 'Kitchen');
      final logged = await repo.db
          .customSelect(
            'SELECT COUNT(*) AS n FROM op_log WHERE home_id = ?',
            variables: [Variable<Uint8List>(uuidBytes(id))],
          )
          .getSingle();
      expect(logged.data['n'], 0);
    });
  });

  group('a stray row of the example, planted straight in the tables, is left '
      'out by every way out', () {
    late String real;
    late String id;
    late String roomId;
    late String realRoom;

    setUp(() async {
      real = await repo.createHome(name: 'Main home');
      realRoom = await repo.createRoom(real, name: 'Hall');
      id = await repo.createExampleHome(guide);
      roomId = await repo.createRoom(id, name: 'Kitchen');
    });

    Map<String, Object?> put(String home, String room, String name) => {
      Op.type: 'rooms.room',
      Op.home: home,
      Op.id: room,
      Op.kind: Op.put,
      Op.clock: '0fffffffffff0001',
      Op.device: b64(Uint8List(16)),
      Op.schema: 10,
      Op.fields: {'name': name},
    };

    Future<void> plantOperation(String home, String room) =>
        repo.db.customStatement(
          'INSERT INTO op_log (device, hlc, home_id, body) VALUES (?, ?, ?, ?)',
          [
            Uint8List(16),
            '0fffffffffff0001',
            uuidBytes(home),
            jsonEncode(put(home, room, 'Stray')),
          ],
        );

    test('outgoing: an op_log row of the example', () async {
      await plantOperation(real, realRoom);
      await plantOperation(id, roomId);
      final out = await repo.outgoing();
      expect(
        [for (final o in out) o.operation[Op.home]],
        contains(real),
        reason: 'the row of the real home is carried',
      );
      expect(out.where((o) => '${o.operation}'.contains(id)), isEmpty);
    });

    test('snapshot: a field_clock row of the example', () async {
      // The real room has its clocks already; the example has none.
      await repo.db.customStatement(
        'INSERT INTO field_clock (entity, row_id, field, hlc, device) '
        "VALUES ('rooms.room', ?, 'name', '0fffffffffff0001', ?)",
        [uuidBytes(roomId), Uint8List(16)],
      );
      final rows = (await repo.snapshot()).rows;
      expect(
        rows.where((r) => r.id == realRoom),
        isNotEmpty,
        reason: 'the row of the real home is carried',
      );
      expect(rows.where((r) => r.home == id || r.id == roomId), isEmpty);
    });

    test('snapshot: a pending row of the example', () async {
      for (final (key, home, room) in [
        ('real', real, realRoom),
        ('example', id, roomId),
      ]) {
        await repo.db.customStatement(
          'INSERT INTO pending (key, entity, home_id, body) '
          'VALUES (?, ?, ?, ?)',
          [
            key,
            'rooms.room',
            uuidBytes(home),
            jsonEncode(put(home, room, key)),
          ],
        );
      }
      final pending = (await repo.snapshot()).pending;
      expect(pending.where((o) => '$o'.contains(real)), isNotEmpty);
      expect(pending.where((o) => '$o'.contains(id)), isEmpty);
    });

    test('scanFiles: a server that names the example', () async {
      final photo = await repo.addPhoto(
        id,
        processPhoto(jpegWithGps(orientation: 1)),
        roomId: roomId,
      );
      expect(photo, isNotEmpty);
      await repo.serverState.writeServerState(
        ServerSyncState(
          homes: [
            ServerHome(id: id, name: 'X', role: 'owner', members: const []),
          ],
        ).encode(),
      );
      await repo.scanFiles();
      final n = await repo.db
          .customSelect('SELECT COUNT(*) AS n FROM file_sync')
          .getSingle();
      expect(n.data['n'], 0);
    });

    test('filesDue: a file_sync row of the example', () async {
      final photo = await repo.addPhoto(
        id,
        processPhoto(jpegWithGps(orientation: 1)),
        roomId: roomId,
      );
      final row = (await repo.photo(photo))!;
      await repo.db.customStatement(
        'INSERT INTO file_sync (file_id, home_id, holder, row_id, direction, '
        "state) VALUES (?, ?, 'photos', ?, 'up', 'waiting')",
        [
          FileReference.parse(row.image, rowId: row.id)!.file,
          uuidBytes(id),
          uuidBytes(row.id),
        ],
      );
      final planted = await repo.db
          .customSelect('SELECT COUNT(*) AS n FROM file_sync')
          .getSingle();
      expect(planted.data['n'], 1);
      expect(await repo.filesDue(FileWay.up), isEmpty);
    });
  });
}
