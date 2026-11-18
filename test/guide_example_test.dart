// SPDX-License-Identifier: AGPL-3.0-only

// The example home of the guide on the phone (web ADR 0084, lot A2): made,
// filled scenario after scenario, ticked, deleted in one gesture, one per
// phone, left out of the count of active homes, and never out of the phone:
// no row of it writes `op_log` or `field_clock`, and the engine, the relay,
// a server and the snapshot of an export never see it, in every way of the
// app. The property test runs random changes on an example home and a real
// one, through a relay and through a server.

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/domain/recurrence.dart' as recurrence;
import 'package:housecairn_mobile/sync/engine.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/transport.dart';
import 'package:uuid/uuid.dart';

import 'support/fixture.dart';
import 'support/sync_doubles.dart';
import 'support/sync_fixture.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

/// The steps of [guide] that have a state, of the scenarios before [upTo]
/// (scenarios are numbered from 1).
Set<String> statedBefore(int upTo) => {
  for (final (i, scenario) in guide.scenarios.indexed)
    if (i + 1 < upTo)
      for (final step in scenario.steps)
        if (step.doneWhen != null) step.id,
};

/// How many rows of [homeId] each table of the model holds, the home
/// itself included.
Future<Map<String, int>> countsOf(Repository repo, String homeId) async {
  final key = uuidBytes(homeId);
  return {
    for (final table in ['homes', ...homeTables])
      table:
          (await repo.db
                      .customSelect(
                        'SELECT COUNT(*) AS n FROM $table WHERE '
                        '${table == 'homes' ? 'id' : 'home_id'} = ?',
                        variables: [Variable<Uint8List>(key)],
                      )
                      .getSingle())
                  .data['n']
              as int,
  };
}

/// Everything of [homeId] that could leave the phone: its operations in
/// `op_log`, the clocks of its rows, its rows in the snapshot (of the relay
/// and of an export), in `outgoing`, in `pending`, `extra` and `file_sync`.
Future<List<String>> traces(Repository repo, String homeId) async {
  final key = uuidBytes(homeId);
  final found = <String>[];
  for (final r
      in await repo.db.customSelect('SELECT home_id, body FROM op_log').get()) {
    final home = r.data['home_id'] as Uint8List?;
    final body = r.data['body'] as String;
    if ((home != null && Uuid.unparse(home) == homeId) ||
        body.contains(homeId)) {
      found.add('op_log $body');
    }
  }
  for (final table in ['homes', ...homeTables]) {
    final clocks = await repo.db
        .customSelect(
          'SELECT COUNT(*) AS n FROM field_clock WHERE entity = ? AND row_id IN '
          '(SELECT id FROM $table WHERE '
          '${table == 'homes' ? 'id' : 'home_id'} = ?)',
          variables: [
            Variable<String>(entityOf[table]!),
            Variable<Uint8List>(key),
          ],
        )
        .getSingle();
    if (clocks.data['n'] != 0) found.add('field_clock of $table');
  }
  for (final table in [
    'extra',
    'pending',
    'file_sync',
    'server_seen',
    'other_versions',
  ]) {
    final n = await repo.db
        .customSelect(
          'SELECT COUNT(*) AS n FROM $table WHERE home_id = ?',
          variables: [Variable<Uint8List>(key)],
        )
        .getSingle();
    if (n.data['n'] != 0) found.add(table);
  }
  for (final row in (await repo.snapshot()).rows) {
    if (row.home == homeId || row.id == homeId) {
      found.add('snapshot ${row.type}');
    }
  }
  for (final o in await repo.outgoing()) {
    if (o.operation[Op.home] == homeId) found.add('outgoing ${o.operation}');
  }
  return found;
}

/// The operations a transport holds, read back by a pull from the start.
Future<List<SyncOperation>> heldBy(SyncTransport transport) async {
  final held = <SyncOperation>[];
  SyncPosition? cursor;
  while (true) {
    final page = await transport.pull(after: cursor);
    held.addAll(page.operations);
    cursor = page.position;
    if (!page.more) return held;
  }
}

bool names(SyncOperation op, String homeId) =>
    op[Op.home] == homeId || op[Op.id] == homeId || '$op'.contains(homeId);

void main() {
  late Repository repo;

  setUp(() async {
    repo = await openRepository();
  });

  group('making it', () {
    test('step 1 makes an empty home with the mark and the values of the '
        'file, in the language of the phone', () async {
      final id = await repo.createExampleHome(guide, language: 'fr-FR');
      final home = (await repo.home(id))!;
      expect(home.isExample, isTrue);
      expect(home.name, "Maison d'exemple");
      expect(home.currency, 'EUR');
      expect(home.hemisphere, 'north');
      final counts = await countsOf(repo, id);
      expect(counts['homes'], 1);
      expect(
        counts.entries
            .where((e) => e.key != 'homes')
            .every((e) => e.value == 0),
        isTrue,
      );
      expect(await repo.tickGuide(guide, id), ['create-home.1']);
    });

    test('the values typed in the form of step 1 are kept', () async {
      final id = await repo.createExampleHome(
        guide,
        language: 'en',
        name: 'Practice house',
        currency: 'CHF',
        hemisphere: recurrence.south,
      );
      final home = (await repo.home(id))!;
      expect(
        [home.name, home.currency, home.hemisphere],
        ['Practice house', 'CHF', 'south'],
      );
    });

    test('one example home per phone: a second is refused until the first is '
        'deleted', () async {
      final first = await repo.createExampleHome(guide);
      await expectLater(
        repo.createExampleHome(guide),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.exampleExists,
          ),
        ),
      );
      await repo.removeExample(first);
      final second = await repo.createExampleHome(guide);
      expect(second, isNot(first));
      expect((await repo.exampleHome())!.id, second);
    });

    test(
      'a real home is never made an example, nor by a form nor by sync',
      () async {
        final real = await repo.createHome(name: 'Main home');
        expect((await repo.home(real))!.isExample, isFalse);
        // An operation that brings the mark to a real home is not applied.
        await repo.applyOperations([
          {
            Op.type: 'homes.home',
            Op.home: real,
            Op.id: real,
            Op.kind: Op.put,
            Op.clock: '0fffffffffff0001',
            Op.device: b64(Uint8List(16)),
            Op.schema: 10,
            Op.fields: {'is_example': true, 'name': 'Renamed'},
          },
        ]);
        final after = (await repo.home(real))!;
        expect(after.isExample, isFalse);
        expect(after.name, 'Renamed');
        expect(await repo.extraFields('homes.home', real), isEmpty);
        // And an example made a real one by an operation neither.
        final example = await repo.createExampleHome(guide);
        await repo.applyOperations([
          {
            Op.type: 'homes.home',
            Op.home: example,
            Op.id: example,
            Op.kind: Op.put,
            Op.clock: '0fffffffffff0002',
            Op.device: b64(Uint8List(16)),
            Op.schema: 10,
            Op.fields: {'is_example': false, 'name': 'Taken'},
          },
        ]);
        final kept = (await repo.home(example))!;
        expect([kept.isExample, kept.name], [true, 'Example house']);
      },
    );
  });

  group('catching up (fillExample)', () {
    test('up to scenario 6 makes every row of the file and ticks every step '
        'that has a state', () async {
      final id = await repo.createExampleHome(guide);
      final ticked = await repo.fillExample(guide, id, upTo: 6);
      expect(ticked.toSet(), statedBefore(6));
      expect(await repo.guideTicks(id), statedBefore(6));
      final counts = await countsOf(repo, id);
      expect(counts['rooms'], 2);
      expect(counts['items'], 1);
      expect(counts['tasks'], 1);
      // The done occurrence and the next one, planned by the repository.
      expect(counts['occurrences'], 2);
      expect(counts['reports'], 1);
      expect(counts['projects'], 1);
      expect(counts['budget_lines'], 2);
      expect(counts['contractors'], 2);
      expect(counts['quotes'], 2);
      expect(counts['annual_envelopes'], 1);
      expect(counts['project_rooms'], 1);
      final quotes = await repo.db.select(repo.db.quotes).get();
      final accepted = quotes.singleWhere((q) => q.status == 'accepted');
      final line = (await repo.budgetLine(accepted.budgetLineId!))!;
      expect(
        [line.label, line.planned, accepted.amount],
        ['Plumber (shower)', '3000.00', '2850.00'],
      );
      final report = (await repo.db.select(repo.db.reports).get()).single;
      expect(
        [report.title, report.status, report.place],
        ['The kitchen tap drips', 'resolved', 'Kitchen'],
      );
      final envelope = (await repo.envelopesOf(id));
      expect(envelope.keys, [repo.today().year]);
      expect(await traces(repo, id), isEmpty);
    });

    for (var upTo = 1; upTo <= 6; upTo++) {
      test('up to scenario $upTo makes no row of stage $upTo or later and '
          'ticks nothing ahead', () async {
        final id = await repo.createExampleHome(guide);
        await repo.fillExample(guide, id, upTo: upTo);
        final ticks = await repo.guideTicks(id);
        expect(ticks, statedBefore(upTo).union({'create-home.1'}));
        final counts = await countsOf(repo, id);
        bool made(String table) => counts[table]! > 0;
        expect(made('rooms'), upTo > 2);
        expect(made('tasks'), upTo > 3);
        expect(made('reports'), upTo > 4);
        expect(made('projects'), upTo > 5);
      });
    }

    test(
      'twice is once: the rows already there are kept as they are',
      () async {
        final id = await repo.createExampleHome(guide);
        await repo.fillExample(guide, id, upTo: 6);
        final once = await countsOf(repo, id);
        expect(await repo.fillExample(guide, id, upTo: 6), isEmpty);
        expect(await countsOf(repo, id), once);
      },
    );

    test('in French, the texts of the rows are French', () async {
      final id = await repo.createExampleHome(guide, language: 'fr');
      await repo.fillExample(guide, id, upTo: 3, language: 'fr');
      expect([for (final r in await repo.rooms(id)) r.name]..sort(), [
        'Cuisine',
        'Salle de bain',
      ]);
    });

    test('a real home is never filled in', () async {
      final real = await repo.createHome(name: 'Main home');
      await expectLater(
        repo.fillExample(guide, real, upTo: 6),
        throwsArgumentError,
      );
      expect((await countsOf(repo, real))['rooms'], 0);
    });
  });

  group('ticks', () {
    test('a tick stays when its state goes away', () async {
      final id = await repo.createExampleHome(guide);
      final room = await repo.createRoom(id, name: 'Kitchen');
      expect(await repo.tickGuide(guide, id), [
        'create-home.1',
        'rooms-equipment.1',
      ]);
      await repo.deleteRoom(room);
      expect(await repo.tickGuide(guide, id), isEmpty);
      expect(await repo.guideTicks(id), {'create-home.1', 'rooms-equipment.1'});
    });

    test('a task marked done then undone keeps step 3.3 ticked', () async {
      final id = await repo.createExampleHome(guide);
      final task = await repo.createTask(
        id,
        TaskInput(
          title: 'Descaling',
          dueOn: repo.today(),
          repeatMode: recurrence.afterLast,
        ),
      );
      final open = (await repo.openOccurrencesOf(task)).single;
      await repo.complete(open.id);
      await repo.tickGuide(guide, id);
      await repo.undo(open.id);
      await repo.tickGuide(guide, id);
      expect(await repo.guideTicks(id), contains('recurring-task.3'));
      // The undo of the example keeps nothing for a sync to take back.
      final undos = await (repo.db.select(
        repo.db.localSettings,
      )..where((s) => s.key.like('undo:%'))).get();
      expect(undos, isEmpty);
    });

    test(
      'a step ticked by hand is one marked manual, on the example home only',
      () async {
        final id = await repo.createExampleHome(guide);
        expect(await repo.tickByHand(guide, id, 'create-home.2'), isTrue);
        expect(await repo.tickByHand(guide, id, 'create-home.2'), isFalse);
        await expectLater(
          repo.tickByHand(guide, id, 'rooms-equipment.1'),
          throwsArgumentError,
        );
        final real = await repo.createHome(name: 'Main home');
        await expectLater(
          repo.tickByHand(guide, real, 'create-home.2'),
          throwsArgumentError,
        );
        expect(await repo.tickGuide(guide, real), isEmpty);
        expect(await repo.guideTicks(real), isEmpty);
      },
    );

    test('a state is read on the rows of the example home only', () async {
      final real = await repo.createHome(name: 'Main home');
      await repo.createRoom(real, name: 'Kitchen');
      await repo.createRoom(real, name: 'Hall');
      final id = await repo.createExampleHome(guide);
      expect(await repo.tickGuide(guide, id), ['create-home.1']);
    });
  });

  group('deleting it in one gesture', () {
    test(
      'rows, files and ticks go; no name typed, no purged home kept',
      () async {
        final real = await repo.createHome(name: 'Main home');
        final id = await repo.createExampleHome(guide);
        await repo.fillExample(guide, id, upTo: 6);
        await repo.tickByHand(guide, id, 'create-home.2');
        final file = File('${repo.homeDirectory(id).path}/note.txt')
          ..createSync(recursive: true)
          ..writeAsStringSync('x');
        await repo.chooseHome(id);
        await repo.deleteHome(id, typedName: '');
        expect(await repo.home(id), isNull);
        expect((await countsOf(repo, id)).values.every((n) => n == 0), isTrue);
        expect(await repo.guideTicks(id), isEmpty);
        expect(file.existsSync(), isFalse);
        expect(await repo.isPurged(id), isFalse);
        expect(await repo.exampleHome(), isNull);
        expect((await repo.currentHome())!.id, real);
        // The real home is whole.
        expect((await countsOf(repo, real))['homes'], 1);
      },
    );

    test('a real home still needs its exact name', () async {
      await repo.createHome(name: 'Main home');
      final second = await repo.createHome(name: 'Second home');
      await repo.createExampleHome(guide);
      await expectLater(
        repo.deleteHome(second, typedName: ''),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.nameMismatch,
          ),
        ),
      );
      await expectLater(repo.removeExample(second), throwsArgumentError);
      expect(await repo.home(second), isNotNull);
    });
  });

  group('left out of the counts', () {
    test('the example home is not a home for "the last active home"', () async {
      final real = await repo.createHome(name: 'Main home');
      final id = await repo.createExampleHome(guide);
      await expectLater(
        repo.archiveHome(real),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.lastActiveHome,
          ),
        ),
      );
      await expectLater(
        repo.deleteHome(real, typedName: 'Main home'),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.lastActiveHome,
          ),
        ),
      );
      expect([for (final h in await repo.activeHomes()) h.id], [real]);
      // The example itself goes whenever asked, even beside one real home.
      await repo.removeExample(id);
      expect(await repo.home(id), isNull);
    });

    test('with only the example home, the phone has no active home', () async {
      final id = await repo.createExampleHome(guide);
      expect(await repo.homes(), isEmpty);
      expect(await repo.activeHomes(), isEmpty);
      expect(await repo.currentHome(), isNull);
      expect(
        [for (final h in await repo.homes(includeExample: true)) h.id],
        [id],
      );
      await repo.archiveHome(id);
      expect((await repo.home(id))!.archivedAt, isNotNull);
    });

    test('Today of every home and the reminders leave it out; its own Today '
        'shows it', () async {
      final real = await repo.createHome(name: 'Main home');
      final id = await repo.createExampleHome(guide);
      await repo.createTask(
        real,
        TaskInput(title: 'Gutters', dueOn: repo.today()),
      );
      await repo.createTask(
        id,
        TaskInput(title: 'Descaling', dueOn: repo.today()),
      );
      expect(
        [for (final e in await repo.todayEntries()) e.task.title],
        ['Gutters'],
      );
      expect(
        [for (final e in await repo.todayEntries(homeId: id)) e.task.title],
        ['Descaling'],
      );
      expect(
        [for (final r in await repo.reminderSources()) r.taskTitle],
        ['Gutters'],
      );
      expect(await repo.todayShowsAllHomes(), isFalse);
    });
  });

  group('the example never leaves the phone', () {
    test('no write of it writes op_log or field_clock', () async {
      final real = await repo.createHome(name: 'Main home');
      final id = await repo.createExampleHome(guide);
      await repo.fillExample(guide, id, upTo: 6);
      await repo.updateHome(id, name: 'Renamed', hemisphere: recurrence.south);
      expect(await traces(repo, id), isEmpty);
      // A real home still writes both, as before.
      await repo.createRoom(real, name: 'Hall');
      expect(await traces(repo, real), isNotEmpty);
      final logged = await repo.db
          .customSelect('SELECT body FROM op_log')
          .get();
      expect(
        logged.any((r) => (r.data['body'] as String).contains('is_example')),
        isFalse,
      );
    });

    test('the repairs of a sync write nothing of it either', () async {
      final id = await repo.createExampleHome(guide);
      final task = await repo.createTask(
        id,
        TaskInput(
          title: 'Descaling',
          dueOn: repo.today(),
          repeatMode: recurrence.fixed,
        ),
      );
      // Two open occurrences of one task, the second following the first:
      // the repair closes the first, through the same path as a screen.
      final first = (await repo.openOccurrencesOf(task)).single;
      await repo.db.customStatement(
        'INSERT INTO occurrences (id, created_at, updated_at, home_id, task_id, '
        "due_on, status, follows) VALUES (?, 1, 1, ?, ?, '2030-01-01', 'planned', ?)",
        [
          uuidBytes(repo.newId()),
          uuidBytes(id),
          uuidBytes(task),
          uuidBytes(first.id),
        ],
      );
      await repo.applyOperations(const []);
      expect((await repo.occurrence(first.id))!.status, 'skipped');
      expect(await traces(repo, id), isEmpty);
    });

    test('an operation that names the example home is not applied', () async {
      final id = await repo.createExampleHome(guide);
      await repo.applyOperations([
        {
          Op.type: 'rooms.room',
          Op.home: id,
          Op.id: repo.newId(),
          Op.kind: Op.put,
          Op.clock: '0fffffffffff0001',
          Op.device: b64(Uint8List(16)),
          Op.schema: 10,
          Op.fields: {'name': 'Pushed', 'kind': 'other', 'position': 0},
        },
      ]);
      expect(await repo.rooms(id), isEmpty);
      expect(await traces(repo, id), isEmpty);
    });

    test('alone, through a relay and with a server: the other side holds '
        'nothing of it, and a server mode phone keeps it beside the server '
        'homes', () async {
      for (final way in ['relay', 'server']) {
        final phone = await Phone.open(way == 'relay' ? 3 : 4);
        final r = phone.repo;
        final real = await r.createHome(name: 'Main home');
        final id = await r.createExampleHome(guide);
        await r.fillExample(guide, id, upTo: 6);
        await r.createTask(real, TaskInput(title: 'Gutters', dueOn: r.today()));
        final SyncTransport transport;
        if (way == 'relay') {
          transport = RelayDouble().transport();
        } else {
          transport = ServerDouble().transport();
        }
        await SyncEngine(r, transport).sync();
        final held = await heldBy(transport);
        expect(held.where((op) => names(op, id)), isEmpty, reason: way);
        expect(
          held.where((op) => op[Op.home] == real),
          isNotEmpty,
          reason: way,
        );
        // Another phone that takes everything gets the real home only.
        final other = await Phone.open(way == 'relay' ? 5 : 6);
        await SyncEngine(other.repo, transport).sync();
        expect(
          [for (final h in await other.repo.homes(includeExample: true)) h.id],
          [real],
        );
        expect(await other.repo.exampleHome(), isNull);
        if (way == 'server') {
          final server = (transport as ServerTransport).server;
          // The server erases its home; the example stays on the phone.
          server.eraseHome(real);
          // A state of the transport that names the example as gone (it
          // never had it) leaves it too.
          server.gone.add(id);
          await SyncEngine(r, transport).sync();
          expect(await r.home(real), isNull);
          expect((await r.home(id))!.isExample, isTrue);
          expect((await countsOf(r, id))['rooms'], 2);
        }
        expect(await traces(r, id), isEmpty, reason: way);
      }
    });

    group('property: whatever is done on the example home, nothing of it '
        'leaves the phone', () {
      for (var seed = 1; seed <= 8; seed++) {
        test('seed $seed', () async {
          final random = Random(seed);
          final phone = await Phone.open(seed + 40);
          final r = phone.repo;
          final real = await r.createHome(name: 'Main home');
          var id = await r.createExampleHome(guide);
          final relay = RelayDouble();
          final server = ServerDouble();
          for (var i = 0; i < 30; i++) {
            final roll = random.nextInt(12);
            if (roll == 0) {
              try {
                await r.fillExample(guide, id, upTo: 1 + random.nextInt(6));
              } on Refused {
                // An archived example is read only, as any archived home.
              }
            } else if (roll == 1) {
              await r.tickGuide(guide, id);
            } else if (roll == 2 && random.nextInt(3) == 0) {
              // Deleted and made again: a new example, the same rule.
              await r.removeExample(id);
              id = await r.createExampleHome(guide);
            } else if (roll == 3) {
              final rooms = await r.rooms(id);
              try {
                if (rooms.isEmpty) {
                  await r.createRoom(id, name: 'Room ${random.nextInt(99)}');
                } else {
                  final room = rooms[random.nextInt(rooms.length)];
                  await r.addItem(
                    room.id,
                    ItemInput(name: 'Item ${random.nextInt(99)}', brand: 'B'),
                  );
                }
              } on Refused {
                // A refusal is a write that did not happen.
              }
            } else {
              await randomChange(phone, [id, real], random);
            }
            if (random.nextInt(4) == 0) {
              await SyncEngine(
                r,
                random.nextBool() ? relay.transport() : server.transport(),
              ).sync();
            }
            expect(await traces(r, id), isEmpty, reason: 'step $i');
          }
          for (final transport in [relay.transport(), server.transport()]) {
            await SyncEngine(r, transport).sync();
            final held = await heldBy(transport);
            expect(held.where((op) => names(op, id)), isEmpty);
          }
          // The op_log holds rows of the real home only, if any.
          final homesInLog = {
            for (final row
                in await r.db.customSelect('SELECT home_id FROM op_log').get())
              if (row.data['home_id'] case final Uint8List h) Uuid.unparse(h),
          };
          expect(homesInLog.difference({real}), isEmpty);
          expect((await r.home(id))!.isExample, isTrue);
        });
      }
    });
  });
}
