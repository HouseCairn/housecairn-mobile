// SPDX-License-Identifier: AGPL-3.0-only

// Property tests of the sync engine (docs/plan.md, lot 4): random histories
// of 2 to 5 phones over two homes, applied in random orders and with
// duplicates, give identical databases, compared row by row and field by
// field; a purge of one home mixed in at random leaves no row of it and the
// other home unchanged; the same holds through a double of the relay and a
// double of a Housecairn server (docs/adr/0010-three-ways-to-use-the-app.md).

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/recurrence.dart' as recurrence;
import 'package:housecairn_mobile/sync/transport.dart';
import 'package:uuid/uuid.dart';

import 'support/sync_doubles.dart';
import 'support/sync_fixture.dart';

/// Two homes, a task that repeats in each, made on the first phone.
Future<List<String>> seedHomes(Phone first) async {
  final main = await first.repo.createHome(name: 'Main home');
  final second = await first.repo.createHome(
    name: 'Second home',
    currency: 'CHF',
  );
  for (final home in [main, second]) {
    await first.repo.createTask(
      home,
      TaskInput(
        title: 'Gutters',
        dueOn: first.repo.today(),
        repeatMode: recurrence.fixed,
      ),
    );
  }
  return [main, second];
}

class History {
  History(this.phones, this.homes, this.operations);

  final List<Phone> phones;
  final List<String> homes;
  final List<SyncOperation> operations;
}

/// [count] phones that share two homes, then each makes random changes
/// offline; [operations] holds every operation written.
Future<History> randomHistory(int seed, int count) async {
  final random = Random(seed);
  final phones = [
    for (var i = 0; i < count; i++) await Phone.open(seed * 10 + i + 1),
  ];
  final homes = await seedHomes(phones.first);
  final operations = await phones.first.takeOutgoing();
  for (final phone in phones.skip(1)) {
    await phone.repo.applyOperations(operations);
  }
  for (final phone in phones) {
    for (var i = 0; i < 6 + random.nextInt(8); i++) {
      await randomChange(phone, homes, random);
    }
    operations.addAll(await phone.takeOutgoing());
  }
  return History(phones, homes, operations);
}

bool notOf(String home, String table, Map<String, Object?> row) {
  final key = table == 'homes' ? row['id'] : row['home_id'];
  return key is! Uint8List || Uuid.unparse(key) != home;
}

void main() {
  group('random histories over two homes', () {
    for (var seed = 1; seed <= 12; seed++) {
      final count = 2 + seed % 4;
      test('seed $seed: $count phones, random orders and duplicates give '
          'identical databases', () async {
        final history = await randomHistory(seed, count);
        final random = Random(seed);
        final dumps = <List<String>>[];
        // Fresh phones, and the phones of the history, each in its own order.
        final receivers = [
          for (var i = 0; i < 3; i++) await Phone.open(500 + seed * 10 + i),
          ...history.phones,
        ];
        for (final receiver in receivers) {
          final ops = shuffledWithDuplicates(history.operations, random);
          var at = 0;
          while (at < ops.length) {
            final size = 1 + random.nextInt(9);
            await receiver.repo.applyOperations(
              ops.sublist(at, min(at + size, ops.length)),
              repair: false,
            );
            at += size;
          }
          dumps.add(await dumpOf(receiver.repo));
        }
        expect(dumps.first, isNotEmpty);
        expect(dumps.first.where((l) => l.startsWith('homes ')), hasLength(2));
        for (final dump in dumps.skip(1)) {
          expect(dump, dumps.first);
        }
      });
    }

    for (var seed = 1; seed <= 8; seed++) {
      test('seed $seed: a purge of one home mixed in at random leaves no row '
          'of it and the other home unchanged', () async {
        final history = await randomHistory(100 + seed, 2 + seed % 4);
        final random = Random(seed);
        final [kept, purged] = history.homes;
        final whole = await Phone.open(900 + seed);
        await whole.repo.applyOperations(history.operations, repair: false);
        final expected = await dumpOf(
          whole.repo,
          tables: ['homes', ...homeTables],
          where: (t, r) => notOf(purged, t, r),
        );
        final dumps = <List<String>>[];
        for (var i = 0; i < 4; i++) {
          final phone = await Phone.open(950 + seed * 10 + i);
          final ops = shuffledWithDuplicates(history.operations, random);
          final cut = random.nextInt(ops.length + 1);
          await phone.repo.applyOperations(ops.sublist(0, cut), repair: false);
          await phone.repo.purgeHome(purged);
          await phone.repo.applyOperations(ops.sublist(cut), repair: false);
          final rows = await dumpOf(
            phone.repo,
            tables: ['homes', ...homeTables],
          );
          expect(
            rows.where(
              (l) => l.contains(
                Uuid.parse(purged)
                    .map((b) => b.toRadixString(16).padLeft(2, '0'))
                    .join(),
              ),
            ),
            isEmpty,
          );
          expect(
            await dumpOf(
              phone.repo,
              tables: ['homes', ...homeTables],
              where: (t, r) => notOf(purged, t, r),
            ),
            expected,
          );
          expect(await phone.repo.isPurged(purged), isTrue);
          expect(await phone.repo.home(kept), isNotNull);
          dumps.add(await dumpOf(phone.repo));
        }
        for (final dump in dumps.skip(1)) {
          expect(dump, dumps.first);
        }
      });
    }
  });

  group('the engine knows no transport', () {
    for (final kind in ['relay', 'server']) {
      for (var seed = 1; seed <= 6; seed++) {
        test('seed $seed through a double of the $kind: every phone ends with '
            'the same database, repairs included', () async {
          final random = Random(seed);
          final relay = RelayDouble();
          final server = ServerDouble();
          SyncTransport transport() =>
              kind == 'relay' ? relay.transport() : server.transport();
          final count = 2 + seed % 4;
          final phones = [
            for (var i = 0; i < count; i++)
              (await Phone.open(seed * 10 + i + 1)).on(transport()),
          ];
          final homes = await seedHomes(phones.first);
          for (final phone in phones) {
            await phone.sync();
          }
          for (var round = 0; round < 3; round++) {
            for (final phone in phones) {
              for (var i = 0; i < 2 + random.nextInt(5); i++) {
                await randomChange(phone, homes, random);
              }
            }
            final order = [...phones]..shuffle(random);
            for (final phone in order.take(1 + random.nextInt(count))) {
              await phone.sync();
            }
          }
          if (seed.isEven) {
            if (kind == 'relay') {
              relay.purged.add(homes.last);
            } else {
              server.eraseHome(homes.last);
            }
          }
          // Until nothing moves: every phone sends nothing in a round.
          for (var round = 0; round < 12; round++) {
            var sent = 0;
            for (final phone in [...phones]..shuffle(random)) {
              sent += (await phone.sync()).sent;
            }
            if (sent == 0) break;
          }
          for (final phone in phones) {
            await phone.sync();
          }
          final first = await dumpOf(phones.first.repo);
          expect(first, isNotEmpty);
          for (final phone in phones.skip(1)) {
            expect(await dumpOf(phone.repo), first);
          }
          if (seed.isEven) {
            expect(await phones.first.repo.home(homes.last), isNull);
            expect(await phones.first.repo.home(homes.first), isNotNull);
          }
          for (final phone in phones) {
            expect(await phone.repo.outgoing(), isEmpty);
          }
        });
      }
    }
  });
}
