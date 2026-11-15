// SPDX-License-Identifier: AGPL-3.0-only

// The cases of docs/adr/0003-sync-protocol.md, each by name (docs/plan.md,
// lot 4), each run through a double of the relay and a double of a
// Housecairn server; the rules of homes, snapshots and the clock.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/hlc.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/recurrence.dart' as recurrence;
import 'package:housecairn_mobile/domain/stock.dart' as stock;
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/transport.dart';
import 'package:uuid/uuid.dart';

import 'support/sync_doubles.dart';
import 'support/sync_fixture.dart';

/// Two phones on one transport, sharing two homes and a task that repeats
/// in the first.
class Pair {
  Pair(this.a, this.b, this.homes, this.taskId);

  final Phone a;
  final Phone b;
  final List<String> homes;
  final String taskId;

  Repository get ra => a.repo;
  Repository get rb => b.repo;

  static Future<Pair> open(SyncTransport Function() transport) async {
    final a = (await Phone.open(1)).on(transport());
    final b = (await Phone.open(2)).on(transport());
    final main = await a.repo.createHome(name: 'Main home');
    final second = await a.repo.createHome(name: 'Second home');
    final task = await a.repo.createTask(
      main,
      TaskInput(
        title: 'Gutters',
        dueOn: a.repo.today(),
        repeatMode: recurrence.fixed,
      ),
    );
    await a.sync();
    await b.sync();
    return Pair(a, b, [main, second], task);
  }

  Future<void> later() async {
    a.clock.advance(const Duration(minutes: 5));
    b.clock.advance(const Duration(minutes: 5));
  }

  /// Both phones sync until neither sends anything, then both compare equal.
  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      final sent = (await a.sync()).sent + (await b.sync()).sent;
      if (sent == 0) break;
    }
    await a.sync();
    await b.sync();
    expect(await dumpOf(rb), await dumpOf(ra));
  }

  Future<String> open1() async =>
      (await ra.openOccurrencesOf(taskId)).single.id;
}

void main() {
  for (final kind in ['relay', 'server']) {
    group('the cases of ADR 0003 through a double of the $kind', () {
      late SyncTransport Function() transport;

      setUp(() {
        final relay = RelayDouble();
        final server = ServerDouble();
        transport = kind == 'relay' ? relay.transport : server.transport;
      });

      test('two closings of one occurrence make one next occurrence', () async {
        final p = await Pair.open(transport);
        final first = await p.open1();
        await p.ra.complete(first);
        await p.later();
        await p.rb.skip(first);
        await p.settle();
        final all = await p.ra.occurrencesOf(p.taskId);
        expect(all, hasLength(2));
        final next = all.singleWhere((o) => o.id != first);
        expect(next.id, Repository.successorId(p.homes.first, first));
        expect(next.follows, first);
        expect((await p.ra.openOccurrencesOf(p.taskId)).single.id, next.id);
        // The later closing wins the status of the first one.
        expect((await p.ra.occurrence(first))!.status, 'skipped');
      });

      test(
        'postpone against done: the next stays open, the first is done',
        () async {
          final p = await Pair.open(transport);
          final first = await p.open1();
          await p.rb.complete(first);
          await p.later();
          // A postpones later, offline: two open occurrences after the merge.
          await p.ra.postpone(first, p.ra.today().addDays(3));
          await p.settle();
          final open = await p.ra.openOccurrencesOf(p.taskId);
          expect(open.single.id, Repository.successorId(p.homes.first, first));
          final closed = await p.ra.occurrence(first);
          expect(closed!.status, 'done');
          expect(closed.completedOn, isNotNull);
        },
      );

      test('postpone against skip: the first is closed as skipped', () async {
        final p = await Pair.open(transport);
        final first = await p.open1();
        await p.rb.skip(first);
        await p.later();
        await p.ra.postpone(first, p.ra.today().addDays(3));
        await p.settle();
        expect((await p.ra.occurrence(first))!.status, 'skipped');
        expect(await p.ra.openOccurrencesOf(p.taskId), hasLength(1));
      });

      test('undo against an edit of the successor: the edit wins, the undo is '
          'taken back on the phone that made it, with a notice', () async {
        final p = await Pair.open(transport);
        final first = await p.open1();
        await p.ra.complete(first);
        await p.a.sync();
        await p.b.sync();
        final next = Repository.successorId(p.homes.first, first);
        await p.later();
        await p.rb.postpone(next, p.rb.today().addDays(4));
        await p.later();
        await p.ra.undo(first);
        expect((await p.ra.occurrence(first))!.status, 'planned');
        await p.b.sync();
        final report = await p.a.sync();
        expect(
          report.notices.map((n) => n.kind),
          contains(SyncNoticeKind.undoReverted),
        );
        await p.settle();
        final reverted = await p.ra.occurrence(first);
        expect(reverted!.status, 'done');
        final successor = await p.ra.occurrence(next);
        expect(successor!.status, 'postponed');
        expect(successor.follows, first);
        expect(await p.rb.occurrence(next), isNotNull);
      });

      test(
        'the same article drawn twice: a shortfall shown, nothing changed',
        () async {
          final p = await Pair.open(transport);
          final article = await p.ra.addArticle(
            p.homes.first,
            const ArticleInput(name: 'Filter'),
          );
          await p.ra.recordMovement(
            article,
            kind: stock.entryKind,
            quantity: '1',
          );
          await p.ra.addMaterial(p.taskId, article, '1');
          await p.a.sync();
          await p.b.sync();
          final first = await p.open1();
          await p.ra.complete(first);
          await p.later();
          await p.rb.complete(first);
          await p.settle();
          expect(await p.ra.stockLevel(article), Decimal.parse('-1'));
          expect(await p.rb.stockLevel(article), Decimal.parse('-1'));
          // One draw row (its id is deterministic), two exits in the ledger.
          expect(
            (await p.ra.db.select(p.ra.db.materialDraws).get()),
            hasLength(1),
          );
          expect(await p.ra.outgoing(), isEmpty);
        },
      );

      test(
        'deletion against edit: the edit never brings the row back',
        () async {
          final p = await Pair.open(transport);
          await p.ra.deleteTask(p.taskId);
          await p.later();
          await p.rb.updateTask(
            p.taskId,
            TaskInput(
              title: 'Gutters and drains',
              dueOn: p.rb.today(),
              repeatMode: recurrence.fixed,
            ),
          );
          await p.settle();
          expect(await p.ra.task(p.taskId), isNull);
          final row = await (p.ra.db.select(
            p.ra.db.tasks,
          )..where((t) => t.id.equalsValue(p.taskId))).getSingle();
          expect(row.title, 'Gutters and drains');
          expect(row.deletedAt, isNotNull);
        },
      );

      test('restore: a later restore brings the row back, an older one does '
          'not', () async {
        final p = await Pair.open(transport);
        final device = b64(p.rb.device);
        await p.ra.deleteTask(p.taskId);
        await p.a.sync();
        await p.b.sync();
        final deleted = (await p.ra.db.select(p.ra.db.tasks).get()).single;
        final clock = Hlc.format(deleted.deletedAt! << 16);
        Map<String, Object?> restore(String c) => {
          Op.type: 'tasks.task',
          Op.home: p.homes.first,
          Op.id: p.taskId,
          Op.kind: Op.restore,
          Op.clock: c,
          Op.device: device,
        };
        await p.rb.applyOperations([
          restore(Hlc.format(Hlc.parse(clock) - (1 << 16))),
        ]);
        expect(await p.rb.task(p.taskId), isNull);
        p.b.clock.advance(const Duration(minutes: 5));
        final later = Hlc.format(p.b.clock.now().millisecondsSinceEpoch << 16);
        await p.rb.applyOperations([restore(later)]);
        expect(await p.rb.task(p.taskId), isNotNull);
      });

      test(
        'a device on an older sv keeps the fields it does not know',
        () async {
          final p = await Pair.open(transport);
          // B is "newer": it writes a field that A's schema does not have.
          p.b.clock.advance(const Duration(minutes: 1));
          final newer = {
            Op.type: 'tasks.task',
            Op.home: p.homes.first,
            Op.id: p.taskId,
            Op.kind: Op.put,
            Op.clock: Hlc.format(p.b.clock.now().millisecondsSinceEpoch << 16),
            Op.device: b64(p.rb.device),
            Op.schema: 99,
            Op.fields: {'energy_rating': 'A', 'title': 'Gutters (new app)'},
          };
          await p.ra.applyOperations([newer]);
          expect(await p.ra.extraFields('tasks.task', p.taskId), {
            'energy_rating': 'A',
          });
          // A edits the row; the field it does not know is still there and is
          // in its snapshot, with its clock.
          await p.later();
          await p.ra.updateTask(
            p.taskId,
            TaskInput(
              title: 'Gutters, old app',
              dueOn: p.ra.today(),
              repeatMode: recurrence.fixed,
            ),
          );
          final snapshot = await p.ra.snapshot();
          final row = snapshot.rows.singleWhere((r) => r.id == p.taskId);
          expect(row.fields['energy_rating']![0], 'A');
          expect(row.fields['title']![0], 'Gutters, old app');
          // An unknown type is kept for later, an unknown choice as it is.
          await p.ra.applyOperations([
            {
              ...newer,
              Op.type: 'energy.meter',
              Op.id: const Uuid().v4(),
              Op.fields: {'reading': '12.50'},
            },
            {
              ...newer,
              Op.clock: Hlc.format(Hlc.parse(newer[Op.clock]! as String) + 1),
              Op.fields: {'priority': 'urgent-ish'},
            },
          ]);
          expect(snapshot.pending, isEmpty);
          expect((await p.ra.snapshot()).pending, hasLength(1));
          expect((await p.ra.task(p.taskId))!.priority, 'urgent-ish');
        },
      );
    });
  }

  group('schema versions', () {
    test('min_sv above this app: the phone reads but does not write', () async {
      final relay = RelayDouble();
      final a = (await Phone.open(1)).on(relay.transport());
      final b = (await Phone.open(2)).on(relay.transport());
      await a.repo.createHome(name: 'Main home');
      await a.sync();
      await b.sync();
      final settings = {
        Op.type: 'family.settings',
        Op.id: const Uuid().v4(),
        Op.kind: Op.put,
        Op.clock: Hlc.format(a.clock.now().millisecondsSinceEpoch << 16 | 9),
        Op.device: b64(a.repo.device),
        Op.schema: 99,
        Op.fields: {'min_sv': a.repo.schemaVersion + 1},
      };
      await relay.transport().push([settings]);
      await b.sync();
      await b.repo.createHome(name: 'Second home');
      final report = await b.sync();
      expect(report.readOnly, isTrue);
      expect(
        report.notices.map((n) => n.kind),
        contains(SyncNoticeKind.updateRequired),
      );
      expect(report.sent, 0);
      expect(await b.repo.outgoing(), isNotEmpty);
      await a.sync();
      expect(await a.repo.homes(), hasLength(1));
    });
  });

  group('homes', () {
    test('the same deterministic name in two homes gives two rows', () async {
      final relay = RelayDouble();
      final a = (await Phone.open(1)).on(relay.transport());
      final b = (await Phone.open(2)).on(relay.transport());
      final main = await a.repo.createHome(name: 'Main home');
      final second = await a.repo.createHome(name: 'Second home');
      await a.sync();
      await b.sync();
      await a.repo.setEnvelope(main, 2027, '500.00');
      await b.repo.setEnvelope(second, 2027, '800.00');
      await a.sync();
      await b.sync();
      await a.sync();
      final rows = await a.repo.db.select(a.repo.db.annualEnvelopes).get();
      expect(rows, hasLength(2));
      expect(rows.map((r) => r.id).toSet(), hasLength(2));
      expect(await dumpOf(b.repo), await dumpOf(a.repo));
    });

    test('a reference to a row of another home is read as empty', () async {
      final a = await Phone.open(1);
      final main = await a.repo.createHome(name: 'Main home');
      final second = await a.repo.createHome(name: 'Second home');
      final room = await a.repo.createRoom(second, name: 'Kitchen');
      final task = await a.repo.createTask(
        main,
        const TaskInput(title: 'Descale'),
      );
      final b = await Phone.open(2);
      await b.repo.applyOperations(await a.takeOutgoing());
      b.clock.advance(const Duration(minutes: 1));
      await b.repo.applyOperations([
        {
          Op.type: 'tasks.task',
          Op.home: main,
          Op.id: task,
          Op.kind: Op.put,
          Op.clock: Hlc.format(b.clock.now().millisecondsSinceEpoch << 16),
          Op.device: b64(a.repo.device),
          Op.fields: {'room_id': room},
        },
      ]);
      // Kept as it came, never shown as a room of the other home.
      expect((await b.repo.task(task))!.roomId, room);
      final entries = await b.repo.tasksOf(roomId: room);
      expect(entries, isEmpty);
      expect(await b.repo.referenceIn(main, 'rooms', room), isNull);
      expect(await b.repo.referenceIn(second, 'rooms', room), room);
    });

    test('archived_at merges as last writer wins', () async {
      final relay = RelayDouble();
      final a = (await Phone.open(1)).on(relay.transport());
      final b = (await Phone.open(2)).on(relay.transport());
      final main = await a.repo.createHome(name: 'Main home');
      final second = await a.repo.createHome(name: 'Second home');
      await a.sync();
      await b.sync();
      await a.repo.archiveHome(second);
      b.clock.advance(const Duration(minutes: 3));
      await b.repo.archiveHome(second);
      await b.repo.unarchiveHome(second);
      await a.sync();
      await b.sync();
      await a.sync();
      expect((await a.repo.home(second))!.archivedAt, isNull);
      expect(await dumpOf(b.repo), await dumpOf(a.repo));
      expect((await a.repo.home(main))!.archivedAt, isNull);
    });

    test(
      'a later operation of a purged home is dropped, whatever its clock',
      () async {
        final a = await Phone.open(1);
        final main = await a.repo.createHome(name: 'Main home');
        final second = await a.repo.createHome(name: 'Second home');
        final ops = await a.takeOutgoing();
        final b = await Phone.open(2);
        await b.repo.applyOperations(ops);
        await b.repo.purgeHome(second);
        await b.repo.applyOperations([
          {
            Op.type: 'rooms.room',
            Op.home: second,
            Op.id: const Uuid().v4(),
            Op.kind: Op.put,
            Op.clock: Hlc.format(
              (b.clock.now().millisecondsSinceEpoch + 1000000) << 16,
            ),
            Op.device: b64(a.repo.device),
            Op.fields: {'name': 'Cellar'},
          },
          ...ops,
        ]);
        expect(await b.repo.home(second), isNull);
        expect(await b.repo.home(main), isNotNull);
        expect(await b.repo.db.select(b.repo.db.rooms).get(), isEmpty);
      },
    );
  });

  group('snapshots', () {
    for (final kind in ['relay', 'server']) {
      test('a new phone from the $kind snapshot and the batches after it '
          'equals one that replayed everything', () async {
        final relay = RelayDouble();
        final server = ServerDouble();
        SyncTransport transport() =>
            kind == 'relay' ? relay.transport() : server.transport();
        final a = (await Phone.open(1)).on(transport());
        final replayed = (await Phone.open(2)).on(transport());
        final main = await a.repo.createHome(name: 'Main home');
        await a.repo.createHome(name: 'Second home');
        final task = await a.repo.createTask(
          main,
          TaskInput(
            title: 'Gutters',
            dueOn: a.repo.today(),
            repeatMode: recurrence.fixed,
          ),
        );
        await a.repo.complete((await a.repo.openOccurrencesOf(task)).single.id);
        await a.repo.deleteTask(
          await a.repo.createTask(main, const TaskInput(title: 'Gone')),
        );
        await a.sync();
        await replayed.sync();
        if (kind == 'relay') {
          relay.storeSnapshot(await a.repo.snapshot(), relay.head);
        } else {
          server.expired = server.head;
        }
        a.clock.advance(const Duration(minutes: 5));
        await a.repo.updateTask(
          task,
          TaskInput(
            title: 'Gutters, after the snapshot',
            dueOn: a.repo.today(),
            repeatMode: recurrence.fixed,
            notes: 'Ladder in the shed',
          ),
        );
        await a.sync();
        await replayed.sync();
        final fresh = (await Phone.open(3)).on(transport());
        await fresh.sync();
        expect(await dumpOf(fresh.repo), await dumpOf(replayed.repo));
        expect(await dumpOf(fresh.repo), await dumpOf(a.repo));
        // A cursor older than what is kept starts again from the snapshot.
        await replayed.repo.setSyncCursor(0);
        if (kind == 'relay') {
          await replayed.sync();
        } else {
          server.expired = server.head;
          await replayed.repo.setSyncCursor(server.head - 1);
          await replayed.sync();
        }
        expect(await dumpOf(replayed.repo), await dumpOf(a.repo));
      });
    }

    test('a snapshot is JSON lines, tombstones included', () async {
      final a = await Phone.open(1);
      final main = await a.repo.createHome(name: 'Main home');
      final task = await a.repo.createTask(
        main,
        const TaskInput(title: 'Gone'),
      );
      await a.repo.deleteTask(task);
      final lines = (await a.repo.snapshot()).lines();
      final rows = [for (final l in lines) jsonDecode(l) as Map];
      final row = rows.singleWhere((r) => r['id'] == task);
      expect(row['t'], 'tasks.task');
      expect(row['h'], main);
      expect(((row['f'] as Map)['deleted_at'] as List)[0], isA<String>());
    });
  });

  group('clock', () {
    test('a device whose clock is a day ahead does not move the others\' '
        'clocks', () async {
      final relay = RelayDouble();
      final ahead = (await Phone.open(
        1,
        ahead: const Duration(days: 1, hours: 1),
      )).on(relay.transport());
      final b = (await Phone.open(2)).on(relay.transport());
      final home = await ahead.repo.createHome(name: 'Main home');
      await ahead.sync();
      await b.sync();
      // B's own next write stays at its own time, not a day ahead.
      final room = await b.repo.createRoom(home, name: 'Kitchen');
      final clocks = await b.repo.db
          .customSelect(
            "SELECT hlc FROM field_clock WHERE entity = 'rooms.room'",
          )
          .get();
      final written = Hlc.parse(clocks.first.data['hlc'] as String) >> 16;
      expect(written, b.clock.now().millisecondsSinceEpoch);
      // The other phone's write is kept with its clock.
      expect(await b.repo.home(home), isNotNull);
      expect(await b.repo.room(room), isNotNull);
    });

    test('a clock less than a day ahead is adopted', () async {
      final relay = RelayDouble();
      final ahead = (await Phone.open(
        1,
        ahead: const Duration(hours: 2),
      )).on(relay.transport());
      final b = (await Phone.open(2)).on(relay.transport());
      final home = await ahead.repo.createHome(name: 'Main home');
      await ahead.sync();
      await b.sync();
      await b.repo.createRoom(home, name: 'Kitchen');
      final clocks = await b.repo.db
          .customSelect(
            "SELECT hlc FROM field_clock WHERE entity = 'rooms.room'",
          )
          .get();
      final written = Hlc.parse(clocks.first.data['hlc'] as String) >> 16;
      expect(written, greaterThan(b.clock.now().millisecondsSinceEpoch));
    });
  });
}
