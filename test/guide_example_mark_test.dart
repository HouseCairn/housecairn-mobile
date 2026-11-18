// SPDX-License-Identifier: AGPL-3.0-only

// The mark `is_example` is written only when the example home is made
// (`Repository._put`, reached through `putForTest`): refused on a real home,
// on an update, and on a row of another table. Each test fails when its
// guard is taken away or weakened.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/guide.dart';

import 'support/fixture.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

void main() {
  group('the mark is_example', () {
    late Repository repo;
    late String example;

    setUp(() async {
      repo = await openRepository();
      example = await repo.createExampleHome(guide);
    });

    Future<int> marked() async =>
        (await repo.db
                    .customSelect(
                      'SELECT COUNT(*) AS n FROM homes WHERE is_example = 1',
                    )
                    .getSingle())
                .data['n']!
            as int;

    test('a real home is not made with it', () async {
      final id = repo.newId();
      await expectLater(
        repo.putForTest('homes', id, {
          'name': 'Main home',
          'is_example': true,
        }, create: true),
        throwsStateError,
      );
      expect(await repo.home(id), isNull);
      expect(await marked(), 1);
    });

    test('a real home is not marked by an update', () async {
      final real = await repo.createHome(name: 'Main home');
      await expectLater(
        repo.putForTest('homes', real, {'is_example': true}),
        throwsStateError,
      );
      expect((await repo.home(real))!.isExample, isFalse);
      expect(await marked(), 1);
    });

    test('the example home is not written with it after it is made', () async {
      await expectLater(
        repo.putForTest('homes', example, {'is_example': false}),
        throwsStateError,
      );
      await expectLater(
        repo.putForTest('homes', example, {'is_example': true}),
        throwsStateError,
      );
      expect((await repo.home(example))!.isExample, isTrue);
    });

    test('a row of another table does not carry it', () async {
      await expectLater(
        repo.putForTest(
          'rooms',
          repo.newId(),
          {'name': 'Kitchen', 'is_example': true},
          homeId: example,
          create: true,
        ),
        throwsStateError,
      );
      final rooms = await repo.db
          .customSelect('SELECT COUNT(*) AS n FROM rooms')
          .getSingle();
      expect(rooms.data['n'], 0);
    });

    test('the example home itself is made with it, once', () async {
      expect((await repo.home(example))!.isExample, isTrue);
      expect(await marked(), 1);
    });
  });
}
