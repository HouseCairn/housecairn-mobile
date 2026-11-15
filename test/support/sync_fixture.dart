// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:math';
import 'dart:typed_data';

import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/recurrence.dart' as recurrence;
import 'package:housecairn_mobile/sync/engine.dart';
import 'package:housecairn_mobile/sync/transport.dart';

import 'fixture.dart';

/// The tables compared between phones: the model and what sync keeps of
/// it. `local_settings`, `op_log` and `other_versions` belong to one phone.
const comparedTables = [
  'homes',
  ...homeTables,
  'field_clock',
  'extra',
  'pending',
  'purged_homes',
];

String _text(Object? value) => switch (value) {
  Uint8List() => value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
  _ => '$value',
};

/// Every row of [tables], field by field, in a fixed order: two phones
/// with the same data give the same text.
Future<List<String>> dumpOf(
  Repository repo, {
  List<String> tables = comparedTables,
  bool Function(String table, Map<String, Object?> row)? where,
}) async {
  final lines = <String>[];
  for (final table in tables) {
    for (final row
        in await repo.db.customSelect('SELECT * FROM $table').get()) {
      if (where != null && !where(table, row.data)) continue;
      final keys = row.data.keys.toList()..sort();
      lines.add(
        '$table ${[for (final k in keys) '$k=${_text(row.data[k])}'].join(' ')}',
      );
    }
  }
  return lines..sort();
}

/// A phone: a repository on its own database, clock and device, and the
/// engine on a transport.
class Phone {
  Phone(this.repo, this.clock);

  final Repository repo;
  final FixedClock clock;
  SyncEngine? engine;

  static Future<Phone> open(int seed, {Duration ahead = Duration.zero}) async {
    final clock = FixedClock(testNow.add(ahead));
    final repo = await openRepository(clock: clock, seed: seed);
    return Phone(repo, clock);
  }

  Phone on(SyncTransport transport) {
    engine = SyncEngine(repo, transport);
    return this;
  }

  Future<SyncReport> sync() => engine!.sync();

  /// The operations written on this phone and not sent, taken out of
  /// `op_log` as a transport would take them.
  Future<List<Map<String, Object?>>> takeOutgoing() async {
    final out = await repo.outgoing();
    if (out.isNotEmpty) await repo.acknowledge(out.last.seq);
    return [for (final o in out) o.operation];
  }
}

/// One random change made offline on [phone] in [homes], as a person would
/// through the screens; a change the repository refuses is skipped.
Future<void> randomChange(
  Phone phone,
  List<String> homes,
  Random random,
) async {
  final repo = phone.repo;
  phone.clock.advance(Duration(minutes: 1 + random.nextInt(90)));
  final home = homes[random.nextInt(homes.length)];
  final tasks = await (repo.db.select(
    repo.db.tasks,
  )..where((t) => t.homeId.equalsValue(home))).get();
  tasks.sort((a, b) => a.id.compareTo(b.id));
  final task = tasks.isEmpty ? null : tasks[random.nextInt(tasks.length)];
  final open = task == null
      ? const <OccurrenceRow>[]
      : await repo.openOccurrencesOf(task.id);
  try {
    switch (random.nextInt(11)) {
      case 0 || 1:
        await repo.createTask(
          home,
          TaskInput(
            title: 'Task ${random.nextInt(1000)}',
            dueOn: repo.today(),
            repeatMode: random.nextBool() ? recurrence.fixed : recurrence.once,
          ),
        );
      case 2:
        if (task == null) return;
        await repo.updateTask(
          task.id,
          TaskInput(
            title: 'Renamed ${random.nextInt(1000)}',
            dueOn: task.seriesStart == null
                ? null
                : Day.parse(task.seriesStart!),
            repeatMode: task.repeatMode,
            notes: random.nextBool()
                ? 'Notes ${random.nextInt(1000)}'
                : task.notes,
          ),
        );
      case 3 || 4:
        if (open.isEmpty) return;
        await repo.complete(open.first.id);
      case 5:
        if (open.isEmpty) return;
        await repo.skip(open.first.id);
      case 6:
        if (open.isEmpty) return;
        await repo.postpone(
          open.first.id,
          repo.today().addDays(1 + random.nextInt(9)),
        );
      case 7:
        if (task == null) return;
        final closed = (await repo.occurrencesOf(task.id))
            .where((o) => closedStatuses.contains(o.status))
            .toList();
        if (closed.isEmpty) return;
        await repo.undo(closed.first.id);
      case 8:
        if (task == null) return;
        await repo.deleteTask(task.id);
      case 9:
        await repo.setEnvelope(home, 2027, '${100 + random.nextInt(900)}.00');
      default:
        final h = await repo.home(home);
        if (h == null) return;
        if (h.archivedAt == null) {
          await repo.archiveHome(home);
        } else {
          await repo.unarchiveHome(home);
        }
    }
  } on Refused {
    return;
  }
}

/// [list] in a random order with about a quarter of it twice.
List<T> shuffledWithDuplicates<T>(List<T> list, Random random) {
  final out = [
    ...list,
    for (final x in list)
      if (random.nextInt(4) == 0) x,
  ];
  out.shuffle(random);
  return out;
}
