// SPDX-License-Identifier: AGPL-3.0-only

// The repository of lot 2a (docs/plan.md, lot 2): field clocks, tasks and
// occurrences, done, skip, postpone, undo, and several homes, always with
// two homes.

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';

import 'support/fixture.dart';

Matcher refused(Refusal reason) =>
    throwsA(isA<Refused>().having((r) => r.reason, 'reason', reason));

Future<Map<String, String>> clocksOf(
  Repository repo,
  String entity,
  String id,
) async {
  final rows = await repo.db
      .customSelect(
        'SELECT field, hlc FROM field_clock WHERE entity = ? AND row_id = ?',
        variables: [Variable<String>(entity), Variable<Object>(uuidBytes(id))],
      )
      .get();
  return {
    for (final r in rows) r.data['field'] as String: r.data['hlc'] as String,
  };
}

/// The fields of an occurrence that undo must restore: all but the instant
/// of the last change.
Map<String, Object?> fieldsOf(OccurrenceRow row) {
  final json = row.toJson()..remove('updatedAt');
  return json;
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

/// The key of a row in [changedClocks]: entity and id.
String rowKey(String entity, String id) => '$entity/${_hex(uuidBytes(id))}';

/// Every clock of the database: `entity/row/field` to the clock.
Future<Map<String, String>> allClocks(Repository repo) async {
  final rows = await repo.db
      .customSelect('SELECT entity, row_id, field, hlc FROM field_clock')
      .get();
  return {
    for (final r in rows)
      '${r.data['entity']}/${_hex(r.data['row_id'] as List<int>)}/${r.data['field']}':
          r.data['hlc'] as String,
  };
}

/// The fields whose clock is new or moved between two snapshots, by row.
Map<String, Set<String>> changedClocks(
  Map<String, String> before,
  Map<String, String> after,
) {
  final out = <String, Set<String>>{};
  for (final MapEntry(:key, :value) in after.entries) {
    if (before[key] == value) continue;
    final cut = key.lastIndexOf('/');
    out
        .putIfAbsent(key.substring(0, cut), () => {})
        .add(key.substring(cut + 1));
  }
  return out;
}

/// What a change must have clocked, exactly: the clock of each field it
/// wrote moved, and no other clock of the database did.
Future<void> expectClocked(
  Repository repo,
  Future<void> Function() change,
  Map<String, Set<String>> expected,
) async {
  final before = await allClocks(repo);
  await change();
  final after = await allClocks(repo);
  expect(after.keys.toSet().containsAll(before.keys), isTrue);
  expect(changedClocks(before, after), expected);
}

/// The fields every new occurrence is created with.
const newOccurrenceFields = {
  'task_id',
  'due_on',
  'visible_from',
  'status',
  'status_before',
  'postponed_from',
  'completed_on',
  'completion_note',
  'follows',
  'deleted_at',
  'created_at',
};

void main() {
  group('field_clock', () {
    test('every field of a new row has a clock, one per change', () async {
      final repo = await openRepository();
      final home = await repo.createHome(name: 'Main home');
      final task = await repo.createTask(home, const TaskInput(title: 'Paint'));
      final clocks = await clocksOf(repo, 'tasks.task', task);
      expect(
        clocks.keys,
        containsAll(['title', 'repeat_mode', 'created_at', 'deleted_at']),
      );
      expect(
        clocks.values.toSet(),
        hasLength(1),
        reason: 'one clock per change',
      );
      expect(clocks.values.first, matches(RegExp(r'^[0-9a-f]{16}$')));
      final home1 = await clocksOf(repo, 'homes.home', home);
      expect(
        home1.keys,
        containsAll(['name', 'currency', 'hemisphere', 'archived_at']),
      );
      expect(home1['name']!.compareTo(clocks['title']!), lessThan(0));

      await repo.updateTask(task, const TaskInput(title: 'Paint the hall'));
      final after = await clocksOf(repo, 'tasks.task', task);
      expect(after['title']!.compareTo(clocks['title']!), greaterThan(0));
      expect(
        after['notes'],
        clocks['notes'],
        reason: 'an unchanged field keeps its clock',
      );
    });

    test('every change clocks the fields it writes and no others', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      String occ(String id) => rowKey('tasks.occurrence', id);

      final repeating = await repo.createTask(
        homes.main,
        TaskInput(
          title: 'Filter',
          dueOn: testToday,
          repeatMode: 'after_last',
          repeatUnit: 'week',
        ),
      );
      final first = (await repo.openOccurrencesOf(repeating)).single.id;
      final second = Repository.successorId(homes.main, first);

      // complete: the occurrence, and the successor in full.
      await expectClocked(repo, () => repo.complete(first, note: 'Done'), {
        occ(first): {
          'status_before',
          'status',
          'completed_on',
          'completion_note',
        },
        occ(second): newOccurrenceFields,
      });
      // undo: the occurrence is open again, the successor is deleted.
      await expectClocked(repo, () => repo.undo(first), {
        occ(first): {
          'status',
          'status_before',
          'completed_on',
          'actual_cost',
          'completion_note',
        },
        occ(second): {'follows', 'deleted_at'},
      });
      // skip: the status and its former value; the successor, deleted by the
      // undo, is written again in full (all but created_at).
      await expectClocked(repo, () => repo.skip(first), {
        occ(first): {'status_before', 'status'},
        occ(second): newOccurrenceFields.difference({'created_at'}),
      });
      await repo.undo(first);

      // postpone: the first date is kept the first time only.
      await expectClocked(
        repo,
        () => repo.postpone(first, testToday.addDays(2)),
        {
          occ(first): {'postponed_from', 'due_on', 'status', 'visible_from'},
        },
      );
      await expectClocked(
        repo,
        () => repo.postpone(first, testToday.addDays(4)),
        {
          occ(first): {'due_on', 'status', 'visible_from'},
        },
      );

      // archive and unarchive: the one field of the home.
      await expectClocked(repo, () => repo.archiveHome(homes.second), {
        rowKey('homes.home', homes.second): {'archived_at'},
      });
      await expectClocked(repo, () => repo.unarchiveHome(homes.second), {
        rowKey('homes.home', homes.second): {'archived_at'},
      });

      // delete: the deleted_at of the task and of each of its occurrences.
      final doomed = (await repo.occurrencesOf(repeating)).map((o) => o.id);
      await expectClocked(repo, () => repo.deleteTask(repeating), {
        for (final id in doomed) occ(id): {'deleted_at'},
        rowKey('tasks.task', repeating): {'deleted_at'},
      });
    });

    test(
      'a change of hemisphere clocks the seasons of its tasks only',
      () async {
        final repo = await openRepository();
        final home = await repo.createHome(name: 'Main home');
        final autumn = await repo.createTask(
          home,
          const TaskInput(title: 'Gutters', season: 'autumn'),
        );
        await repo.createTask(
          home,
          const TaskInput(
            title: 'Own',
            season: 'custom',
            seasonStartMonth: 2,
            seasonEndMonth: 4,
          ),
        );
        await repo.createTask(home, const TaskInput(title: 'All year'));
        await expectClocked(
          repo,
          () => repo.updateHome(home, hemisphere: 'south'),
          {
            rowKey('homes.home', home): {'hemisphere'},
            rowKey('tasks.task', autumn): {
              'season_start_month',
              'season_end_month',
            },
          },
        );
      },
    );

    test(
      'clocks only grow, even when the time of the phone goes back',
      () async {
        final clock = FixedClock(testNow);
        final repo = await openRepository(clock: clock);
        final home = await repo.createHome(name: 'Main home');
        final first = (await clocksOf(repo, 'homes.home', home))['name']!;
        clock.advance(const Duration(days: -2));
        await repo.updateHome(home, name: 'Home');
        final second = (await clocksOf(repo, 'homes.home', home))['name']!;
        expect(second.compareTo(first), greaterThan(0));
      },
    );

    test('the clock goes on after a restart', () async {
      final dir = await Directory.systemTemp.createTemp('housecairn-db-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/housecairn.sqlite');
      final clock = FixedClock(testNow);
      final first = await openRepository(clock: clock, file: file, files: dir);
      final home = await first.createHome(name: 'Main home');
      final before = (await clocksOf(first, 'homes.home', home))['name']!;
      await first.db.close();
      clock.advance(const Duration(hours: -5));
      final second = await openRepository(clock: clock, file: file, files: dir);
      expect(second.device, first.device, reason: 'the same phone');
      await second.updateHome(home, name: 'Home');
      final after = (await clocksOf(second, 'homes.home', home))['name']!;
      expect(after.compareTo(before), greaterThan(0));
      await second.db.close();
    });
  });

  group('tasks', () {
    test(
      'a task with only a title is saved, with one open occurrence',
      () async {
        final repo = await openRepository();
        final home = await repo.createHome(name: 'Main home');
        final id = await repo.createTask(
          home,
          const TaskInput(title: '  Fix the tap '),
        );
        final task = (await repo.task(id))!;
        expect(task.title, 'Fix the tap');
        expect(task.homeId, home);
        final open = await repo.openOccurrencesOf(id);
        expect(open, hasLength(1));
        expect(open.single.homeId, home);
        expect(open.single.dueOn, isNull);
      },
    );

    test('the checks of the web', () async {
      final repo = await openRepository();
      final home = await repo.createHome(name: 'Main home');
      await expectLater(
        repo.createTask(home, const TaskInput(title: '  ')),
        refused(Refusal.titleRequired),
      );
      await expectLater(
        repo.createTask(
          home,
          const TaskInput(title: 'Boiler', repeatMode: 'fixed'),
        ),
        refused(Refusal.fixedNeedsDate),
      );
      await expectLater(
        repo.createTask(
          home,
          const TaskInput(
            title: 'Boiler',
            repeatMode: 'after_last',
            repeatUnit: 'year',
            repeatInterval: 51,
          ),
        ),
        refused(Refusal.intervalOutOfRange),
      );
      await expectLater(
        repo.createTask(home, TaskInput(title: 'Far', dueOn: Day(2200, 1, 1))),
        refused(Refusal.dateOutOfRange),
      );
      await expectLater(
        repo.createTask(home, const TaskInput(title: 'Own', season: 'custom')),
        refused(Refusal.seasonMonthsRequired),
      );
    });

    test('a predefined season follows the hemisphere of the home', () async {
      final repo = await openRepository();
      final home = await repo.createHome(name: 'Main home');
      final id = await repo.createTask(
        home,
        const TaskInput(title: 'Gutters', season: 'autumn'),
      );
      var task = (await repo.task(id))!;
      expect((task.seasonStartMonth, task.seasonEndMonth), (9, 11));
      await repo.updateHome(home, hemisphere: 'south');
      task = (await repo.task(id))!;
      expect((task.seasonStartMonth, task.seasonEndMonth), (3, 5));
    });

    test(
      'done creates the deterministic successor, undo takes it back',
      () async {
        final repo = await openRepository();
        final home = await repo.createHome(name: 'Main home');
        final id = await repo.createTask(
          home,
          TaskInput(
            title: 'Filter',
            dueOn: Day(2026, 10, 31),
            repeatMode: 'fixed',
            repeatUnit: 'month',
          ),
        );
        final first = (await repo.openOccurrencesOf(id)).single;
        final closing = await repo.complete(first.id);
        expect(closing.nextId, Repository.successorId(home, first.id));
        final next = (await repo.openOccurrencesOf(id)).single;
        expect(next.id, closing.nextId);
        expect(next.dueOn, '2026-11-30', reason: 'the month end of the series');
        expect(next.follows, first.id);
        expect((await repo.occurrence(first.id))!.completedOn, '2026-11-14');

        await repo.undo(first.id);
        expect((await repo.openOccurrencesOf(id)).single.id, first.id);
        // Done again: the same successor comes back.
        final again = await repo.complete(first.id);
        expect(again.nextId, closing.nextId);
        expect((await repo.openOccurrencesOf(id)).single.id, closing.nextId);
      },
    );

    test('postpone keeps the first date; past dates and future completions are refused', () async {
      final repo = await openRepository();
      final home = await repo.createHome(name: 'Main home');
      final id = await repo.createTask(
        home,
        TaskInput(title: 'Tap', dueOn: testToday),
      );
      final occ = (await repo.openOccurrencesOf(id)).single;
      await repo.postpone(occ.id, testToday.addDays(3));
      await repo.postpone(occ.id, testToday.addDays(5));
      final moved = (await repo.occurrence(occ.id))!;
      expect(moved.status, 'postponed');
      expect(moved.postponedFrom, '2026-11-14');
      expect(moved.dueOn, '2026-11-19');
      await expectLater(
        repo.postpone(occ.id, testToday.addDays(-1)),
        refused(Refusal.pastDate),
      );
      await expectLater(
        repo.complete(occ.id, on: testToday.addDays(1)),
        refused(Refusal.futureDate),
      );
    });

    test('undo is refused once the next occurrence was worked on', () async {
      final repo = await openRepository();
      final home = await repo.createHome(name: 'Main home');
      final id = await repo.createTask(
        home,
        TaskInput(
          title: 'Bins',
          dueOn: testToday,
          repeatMode: 'after_last',
          repeatUnit: 'week',
        ),
      );
      final first = (await repo.openOccurrencesOf(id)).single;
      final closing = await repo.complete(first.id);
      await repo.postpone(closing.nextId!, testToday.addDays(10));
      await expectLater(repo.undo(first.id), refused(Refusal.nextChanged));
      await expectLater(repo.undo(closing.nextId!), refused(Refusal.notClosed));
    });
  });

  group('property tests', () {
    // docs/plan.md, lot 2: "a task that repeats always has exactly one open
    // occurrence after any sequence of done, skip, postpone, undo; undo
    // restores the occurrence field by field".
    for (var seed = 1; seed <= 40; seed++) {
      test('random sequence $seed over two homes', () async {
        final rng = Random(seed);
        final clock = FixedClock(testNow);
        final repo = await openRepository(clock: clock, seed: seed);
        final homes = await TwoHomes.create(repo);
        final tasks = <String>[];
        for (final home in [homes.main, homes.second]) {
          for (final (mode, unit) in [
            ('fixed', 'month'),
            ('after_last', 'week'),
            ('fixed', 'year'),
            ('after_last', 'day'),
          ]) {
            tasks.add(
              await repo.createTask(
                home,
                TaskInput(
                  title: 'Task $mode $unit',
                  dueOn: testToday.addDays(rng.nextInt(90) - 60),
                  repeatMode: mode,
                  repeatUnit: unit,
                  repeatInterval: 1 + rng.nextInt(3),
                  season: rng.nextInt(4) == 0 ? 'winter' : '',
                ),
              ),
            );
          }
        }
        // The state of each occurrence just before it was closed.
        final beforeClose = <String, Map<String, Object?>>{};
        final closedStack = <String>[];
        for (var step = 0; step < 60; step++) {
          final taskId = tasks[rng.nextInt(tasks.length)];
          final open = (await repo.openOccurrencesOf(taskId)).single;
          final roll = rng.nextInt(10);
          if (roll < 3) {
            beforeClose[open.id] = fieldsOf(open);
            // Half of the completions carry a note: undo must clear it.
            await repo.complete(
              open.id,
              note: rng.nextBool() ? 'Note of step $step' : '',
            );
            closedStack.add(open.id);
          } else if (roll < 5) {
            beforeClose[open.id] = fieldsOf(open);
            await repo.skip(open.id);
            closedStack.add(open.id);
          } else if (roll < 7) {
            await repo.postpone(open.id, repo.today().addDays(rng.nextInt(30)));
          } else if (closedStack.isNotEmpty) {
            final target = closedStack[rng.nextInt(closedStack.length)];
            try {
              await repo.undo(target);
              closedStack.remove(target);
              final restored = (await repo.occurrence(target))!;
              expect(
                fieldsOf(restored),
                beforeClose[target],
                reason: 'undo of $target',
              );
            } on Refused catch (e) {
              expect(e.reason, anyOf(Refusal.nextChanged, Refusal.notClosed));
            }
          }
          if (rng.nextInt(8) == 0) clock.advance(const Duration(days: 1));
          for (final t in tasks) {
            expect(
              await repo.openOccurrencesOf(t),
              hasLength(1),
              reason: 'task $t, step $step',
            );
          }
        }
        await repo.db.close();
      });
    }
  });

  group('two homes', () {
    test('every row names its home; Today lists both or one', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      final all = await repo.todayEntries();
      expect(all.map((e) => e.home.id).toSet(), {homes.main, homes.second});
      expect(all.every((e) => e.task.homeId == e.home.id), isTrue);
      expect(all.every((e) => e.occurrence.homeId == e.home.id), isTrue);
      final one = await repo.todayEntries(homeId: homes.second);
      expect(one, isNotEmpty);
      expect(one.every((e) => e.home.id == homes.second), isTrue);
      // Overdue first, no date last.
      expect(all.first.occurrence.dueOn, '2026-11-11');
      expect(all.last.occurrence.dueOn, isNull);
    });

    test('Today shows All homes until a home is chosen, and not with one active home', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      expect(await repo.todayShowsAllHomes(), isTrue);
      await repo.chooseHome(homes.second);
      expect(await repo.todayShowsAllHomes(), isFalse);
      expect((await repo.currentHome())!.id, homes.second);
      await repo.showAllHomesOnToday();
      expect(await repo.todayShowsAllHomes(), isTrue);
      await repo.archiveHome(homes.main);
      expect(await repo.todayShowsAllHomes(), isFalse);
    });

    test('the current home survives a restart; archived or deleted, the first active by name', () async {
      final dir = await Directory.systemTemp.createTemp('housecairn-db-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/housecairn.sqlite');
      var repo = await openRepository(file: file, files: dir);
      final homes = await TwoHomes.create(repo);
      final third = await repo.createHome(name: 'A flat');
      await repo.chooseHome(homes.second);
      await repo.db.close();

      repo = await openRepository(file: file, files: dir);
      expect((await repo.currentHome())!.id, homes.second);
      await repo.archiveHome(homes.second);
      expect(
        (await repo.currentHome())!.id,
        third,
        reason: 'first active by name',
      );
      await repo.chooseHome(homes.main);
      await repo.deleteHome(homes.main, typedName: 'Main home');
      await repo.db.close();

      repo = await openRepository(file: file, files: dir);
      expect((await repo.currentHome())!.id, third);
      await repo.db.close();
    });

    test(
      'an archived home is read only, out of Today, and back as it was',
      () async {
        final repo = await openRepository();
        final homes = await TwoHomes.create(repo);
        final before = await dumpHome(repo, homes.second, homeRow: false);
        await repo.archiveHome(homes.second);
        expect((await repo.activeHomes()).map((h) => h.id), [homes.main]);
        expect(
          (await repo.todayEntries()).any((e) => e.home.id == homes.second),
          isFalse,
        );
        final occurrence = (await repo.db.select(repo.db.occurrences).get())
            .firstWhere((o) => o.homeId == homes.second);
        await expectLater(
          repo.complete(occurrence.id),
          refused(Refusal.homeArchived),
        );
        await expectLater(
          repo.createTask(homes.second, const TaskInput(title: 'New')),
          refused(Refusal.homeArchived),
        );
        await expectLater(
          repo.updateHome(homes.second, name: 'X'),
          refused(Refusal.homeArchived),
        );
        await expectLater(
          repo.archiveHome(homes.main),
          refused(Refusal.lastActiveHome),
        );
        await repo.unarchiveHome(homes.second);
        // Back as it was: every row of it unchanged, byte for byte; only the
        // field archived_at of the home moved.
        expect(await dumpHome(repo, homes.second, homeRow: false), before);
        expect((await repo.home(homes.second))!.archivedAt, isNull);
      },
    );

    test('delete: the exact name, never the last active home, nothing left, the other home unchanged byte for byte', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      final other = await dumpHome(repo, homes.main);
      await expectLater(
        repo.homeDirectory(homes.second).listSync(),
        hasLength(2),
      );

      await expectLater(
        repo.deleteHome(homes.second, typedName: 'second home'),
        refused(Refusal.nameMismatch),
      );
      await expectLater(
        repo.deleteHome(homes.second, typedName: 'Second home '),
        refused(Refusal.nameMismatch),
      );
      await repo.deleteHome(homes.second, typedName: 'Second home');

      final key = uuidBytes(homes.second);
      // The tables come from the schema, not from the code under test.
      final owned = homeOwnedTables(repo);
      expect(owned, isNotEmpty);
      expect(
        homeTables.toSet(),
        owned.toSet(),
        reason: 'deleteHome must visit every table with a home_id',
      );
      for (final table in owned) {
        final left = await repo.db
            .customSelect(
              'SELECT COUNT(*) AS n FROM $table WHERE home_id = ?',
              variables: [Variable<Object>(key)],
            )
            .getSingle();
        expect(left.data['n'], 0, reason: table);
      }
      final homesLeft = await repo.db.select(repo.db.homes).get();
      expect(homesLeft.map((h) => h.id), [homes.main]);
      // No clock of a row that no longer exists.
      final orphans = await repo.db
          .customSelect(
            'SELECT COUNT(*) AS n FROM field_clock f WHERE NOT EXISTS ('
            "${[
              for (final t in ['homes', ...owned]) 'SELECT 1 FROM $t WHERE $t.id = f.row_id',
            ].join(' UNION ALL ')})",
          )
          .getSingle();
      expect(orphans.data['n'], 0);
      await expectLater(repo.homeDirectory(homes.second).existsSync(), isFalse);
      expect(await dumpHome(repo, homes.main), other);

      await expectLater(
        repo.deleteHome(homes.main, typedName: 'Main home'),
        refused(Refusal.lastActiveHome),
      );
    });

    test('an archived home may be deleted while another is active', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      await repo.archiveHome(homes.main);
      await repo.deleteHome(homes.main, typedName: 'Main home');
      expect((await repo.homes()).map((h) => h.id), [homes.second]);
    });
  });
}
