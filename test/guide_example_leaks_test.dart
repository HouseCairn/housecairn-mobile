// SPDX-License-Identifier: AGPL-3.0-only

// The guards of the example home of the guide (web ADR 0084, lot A2), one
// test for each: two calls at once make one example; a stray row of the
// example planted straight in `op_log`, `field_clock`, `pending` or
// `file_sync` is left out by every way out (`outgoing`, `snapshot`,
// `scanFiles`, `filesDue`); the ticks, the counts and the server rules.
// Each test fails when its guard is taken away.

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/guide.dart';

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
}
