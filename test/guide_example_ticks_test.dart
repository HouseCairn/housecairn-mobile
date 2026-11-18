// SPDX-License-Identifier: AGPL-3.0-only

// Ticks written by two calls at once on the example home of the guide (web
// ADR 0084, lot A2): one row for each step, no error, the time of the first
// call kept, and only the call that wrote a tick reports it (`INSERT OR
// IGNORE` in `_storeTicks`, and the count of rows inserted). Each test fails
// when its guard is taken away.

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/guide.dart';

import 'support/fixture.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

/// A clock that moves one minute forward each time it is read, and keeps the
/// instants it gave: the first one read while two calls run is the time that
/// the first tick written must keep.
class _MovingClock extends FixedClock {
  _MovingClock(super.instant);

  final reads = <DateTime>[];

  @override
  DateTime now() {
    advance(const Duration(minutes: 1));
    final instant = super.now();
    reads.add(instant);
    return instant;
  }
}

void main() {
  group('two ticks at once', () {
    late _MovingClock clock;
    late Repository repo;
    late String id;

    setUp(() async {
      clock = _MovingClock(testNow);
      repo = await openRepository(clock: clock);
      id = await repo.createExampleHome(guide);
    });

    Future<List<Map<String, Object?>>> ticks() async => [
      for (final r
          in await repo.db
              .customSelect(
                'SELECT step_id, ticked_at FROM step_ticks '
                'WHERE home_id = ? ORDER BY step_id',
                variables: [Variable<Uint8List>(uuidBytes(id))],
              )
              .get())
        r.data,
    ];

    test('tickGuide: one row for each step, the first time kept, and each '
        'step reported by one call', () async {
      await repo.createRoom(id, name: 'Kitchen');
      final before = clock.reads.length;
      final results = await Future.wait([
        repo.tickGuide(guide, id),
        repo.tickGuide(guide, id),
      ]);
      final reads = clock.reads.sublist(before);
      expect(reads, hasLength(2));
      final rows = await ticks();
      expect(rows.map((r) => r['step_id']), [
        'create-home.1',
        'rooms-equipment.1',
      ]);
      final first = reads.first.millisecondsSinceEpoch;
      expect(rows.map((r) => r['ticked_at']), [first, first]);
      // Each step is told once, whichever call wrote it.
      final told = [...results[0], ...results[1]]..sort();
      expect(told, ['create-home.1', 'rooms-equipment.1']);
      expect(await repo.tickGuide(guide, id), isEmpty);
    });

    test(
      'tickByHand: one row, the first time kept, one call says true',
      () async {
        final before = clock.reads.length;
        final results = await Future.wait([
          repo.tickByHand(guide, id, 'create-home.2'),
          repo.tickByHand(guide, id, 'create-home.2'),
        ]);
        final reads = clock.reads.sublist(before);
        expect(reads, hasLength(2));
        expect(results.where((made) => made), hasLength(1));
        final rows = await ticks();
        expect(rows, hasLength(1));
        expect(rows.single['step_id'], 'create-home.2');
        expect(rows.single['ticked_at'], reads.first.millisecondsSinceEpoch);
      },
    );

    test('tickGuide and tickByHand at once on different steps', () async {
      await repo.createRoom(id, name: 'Kitchen');
      final results = await Future.wait<Object>([
        repo.tickGuide(guide, id),
        repo.tickByHand(guide, id, 'create-home.2'),
      ]);
      expect(results[0], ['create-home.1', 'rooms-equipment.1']);
      expect(results[1], isTrue);
      expect(await ticks(), hasLength(3));
    });
  });
}
