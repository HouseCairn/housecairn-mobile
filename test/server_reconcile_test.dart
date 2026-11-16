// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/transport.dart';

import 'support/sync_fixture.dart';

/// The mark "seen by the server" and the rule after 410 of docs/protocol.md
/// section 2.10 (docs/plan.md, lot 4b: "each case a named test"), through
/// the engine and a server that answers the phone's old cursor with 410.
void main() {
  const serverDevice = 'q2Xh0dVt3kWmYc1bS8fP9A';

  late Phone phone;
  late String home;
  late String kept; // seen, in the snapshot
  late String purged; // seen, deleted and purged on the server
  late String waitingPurged; // seen, purged there, changed here offline
  late String mine; // made here offline, never seen
  late String waitingKept; // seen, in the snapshot, changed here offline
  late _Restarting server;

  /// The operations of the server's snapshot for [ids]: each row as the
  /// phone sent it, then what the web changed since.
  Future<List<SyncOperation>> snapshotOf(
    List<SyncOperation> sent,
    Set<String> ids,
  ) async => [
    for (final op in sent)
      if (ids.contains(op[Op.id])) {...op, Op.device: serverDevice},
  ];

  setUp(() async {
    phone = await Phone.open(1);
    final repo = phone.repo;
    home = await repo.createHome(name: 'House');
    kept = await repo.createRoom(home, name: 'Kitchen');
    purged = await repo.createRoom(home, name: 'Attic');
    waitingPurged = await repo.createRoom(home, name: 'Cellar');
    waitingKept = await repo.createRoom(home, name: 'Hall');
    // The first sync: the server took all of it.
    final sent = await phone.takeOutgoing();
    await repo.markServerSeen([
      for (final op in sent)
        (op[Op.type]! as String, home, op[Op.id]! as String),
    ]);
    await repo.setSyncCursor(7);
    // Offline for more than 400 days.
    phone.clock.advance(const Duration(days: 401));
    mine = await repo.createRoom(home, name: 'Garage');
    await repo.updateRoom(
      waitingPurged,
      const RoomInput(name: 'Wine cellar', notes: 'Racks on the north wall'),
    );
    await repo.updateRoom(waitingKept, const RoomInput(name: 'Entrance'));
    final snapshot = await snapshotOf(sent, {home, kept, waitingKept});
    server = _Restarting(home, snapshot);
    phone.on(server);
  });

  Future<Set<String>> roomIds() async => {
    for (final r in await phone.repo.rooms(home)) r.id,
  };

  test('410: nothing is pushed before the rule has run', () async {
    await phone.sync();
    expect(server.pushesBeforeRestart, 0);
    expect(server.restarts, 1);
  });

  test('rule 1: a row in the snapshot is merged and keeps the mark', () async {
    await phone.sync();
    expect(await roomIds(), contains(kept));
    expect(await phone.repo.serverSeenIn(home), contains(('rooms.room', kept)));
  });

  test('rule 2: a row deleted by someone else during the absence and purged is '
      'deleted on the phone, and listed', () async {
    final report = await phone.sync();
    expect(await roomIds(), isNot(contains(purged)));
    expect(await phone.repo.room(purged), isNull);
    expect(
      report.notices.where(
        (n) =>
            n.kind == SyncNoticeKind.droppedAfterRestart && n.rowId == purged,
      ),
      hasLength(1),
    );
    expect(
      await phone.repo.serverSeenIn(home),
      isNot(contains(('rooms.room', purged))),
    );
  });

  test(
    'rule 2: a waiting change to a purged row is dropped and listed; its long '
    'text is kept as an other version',
    () async {
      final report = await phone.sync();
      expect(await phone.repo.room(waitingPurged), isNull);
      expect(
        server.pushed.where((op) => op[Op.id] == waitingPurged),
        isEmpty,
        reason: 'never sent to the server',
      );
      expect(report.notices.map((n) => n.rowId), contains(waitingPurged));
      final versions = await phone.repo.otherVersions(
        'rooms.room',
        waitingPurged,
      );
      expect(versions.map((v) => v.value), ['Racks on the north wall']);
    },
  );

  test('rule 3: a row created offline and never seen by the server is kept and '
      'sent again, every field with its clock', () async {
    await phone.sync();
    expect(await roomIds(), contains(mine));
    final sent = server.pushed.where((op) => op[Op.id] == mine).toList();
    expect(sent, isNotEmpty);
    final fields = {
      for (final op in sent) ...(op[Op.fields]! as Map).cast<String, Object?>(),
    };
    expect(fields['name'], 'Garage');
    // Every field the phone has a clock of, as made by createRoom.
    final made = (await phone.repo.snapshot()).rows.singleWhere(
      (r) => r.id == mine,
    );
    expect(fields.keys.toSet(), made.fields.keys.toSet());
  });

  test('rule 4: a waiting change to a row still there is sent, and the server '
      'decides field by field', () async {
    await phone.sync();
    final sent = server.pushed.where((op) => op[Op.id] == waitingKept).toList();
    expect(sent, isNotEmpty);
    expect(
      sent.map((op) => (op[Op.fields]! as Map)['name']),
      contains('Entrance'),
    );
    expect((await phone.repo.room(waitingKept))!.name, 'Entrance');
  });

  test(
    'rule 5: a row of the snapshot the phone did not have is added',
    () async {
      final other = await Phone.open(2);
      await other.repo.applyOperations(server.snapshot);
      final cellar = await other.repo.createRoom(home, name: 'Workshop');
      server.snapshot.addAll([
        for (final op in await other.takeOutgoing())
          if (op[Op.id] == cellar) {...op, Op.device: serverDevice},
      ]);
      await phone.sync();
      expect(await roomIds(), contains(cellar));
      expect(
        await phone.repo.serverSeenIn(home),
        contains(('rooms.room', cellar)),
      );
    },
  );

  test('the mark is not set without a 410: the first sync of a phone never '
      'deletes a row', () async {
    final fresh = await Phone.open(3);
    final h = await fresh.repo.createHome(name: 'Flat');
    final room = await fresh.repo.createRoom(h, name: 'Bedroom');
    fresh.on(_Restarting(h, const [], restartFirst: false));
    await fresh.sync();
    expect(await fresh.repo.room(room), isNotNull);
  });

  test('a purge of the home takes its marks with it', () async {
    await phone.repo.purgeHome(home);
    expect(await phone.repo.serverSeenIn(home), isEmpty);
  });
}

/// A server whose feed no longer reaches the phone's cursor: the first pull
/// after a cursor, and every push before it, answer 410; a pull from the
/// start gives [snapshot], complete.
class _Restarting implements SyncTransport {
  _Restarting(
    this.home,
    List<SyncOperation> snapshot, {
    this.restartFirst = true,
  }) : snapshot = [...snapshot];

  final String home;
  final List<SyncOperation> snapshot;
  final bool restartFirst;
  final pushed = <SyncOperation>[];
  int restarts = 0;
  int pushesBeforeRestart = 0;

  bool get _expired => restartFirst && restarts == 0;

  @override
  Future<SyncCapabilities> capabilities() async =>
      const SyncCapabilities(version: '0.4.1');

  @override
  Future<PushResult> push(List<SyncOperation> operations) async {
    if (_expired) return const PushResult(held: true);
    pushed.addAll(operations);
    return const PushResult();
  }

  @override
  Future<PullResult> pull({SyncPosition? after}) async {
    if (after != null && _expired) {
      restarts++;
      return const PullResult(position: 0, restart: true);
    }
    if (after == null) {
      return PullResult(
        operations: snapshot,
        position: 1,
        complete: {
          home: {
            for (final op in snapshot)
              (op[Op.type]! as String, op[Op.id]! as String),
          },
        },
      );
    }
    return PullResult(position: after);
  }

  @override
  Future<List<String>> homesGone() async => const [];

  @override
  Future<void> putFile(
    String home,
    String id,
    Uint8List bytes, {
    required String sha256,
    required String type,
  }) async {}

  @override
  Future<Uint8List> getFile(String home, String id) async => Uint8List(0);

  @override
  Future<void> deleteFile(String home, String id) async {}
}
