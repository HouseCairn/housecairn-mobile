// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show Variable, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';

/// 2026-11-14 at noon UTC: the day of the tests.
DateTime get testNow => DateTime.utc(2026, 11, 14, 12);

Day get testToday => Day(2026, 11, 14);

/// A repository on a database in memory (or in [file]) and a directory of
/// files of its own, removed after the test.
Future<Repository> openRepository({
  FixedClock? clock,
  File? file,
  Directory? files,
  int seed = 1,
}) async {
  // Tests open a new database for each repository, on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final dir =
      files ?? await Directory.systemTemp.createTemp('housecairn-files-');
  if (files == null) addTearDown(() => dir.delete(recursive: true));
  final db = AppDatabase(
    file == null ? NativeDatabase.memory() : NativeDatabase(file),
  );
  final repo = Repository(
    db,
    clock: clock ?? FixedClock(testNow),
    files: dir,
    random: Random(seed),
  );
  await repo.open();
  return repo;
}

/// The two homes of the plan's fixture (docs/plan.md, lot 2, "Two homes"):
/// each with rooms, an item, a contractor, tasks and photos (rows and files).
class TwoHomes {
  TwoHomes(this.main, this.second);

  final String main;
  final String second;

  static Future<TwoHomes> create(Repository repo) async {
    final main = await repo.createHome(name: 'Main home');
    final second = await repo.createHome(
      name: 'Second home',
      currency: 'CHF',
      hemisphere: 'south',
    );
    for (final (home, prefix) in [(main, 'Main'), (second, 'Second')]) {
      final kitchen = await repo.createRoom(home, name: '$prefix kitchen');
      final cellar = await repo.createRoom(home, name: '$prefix cellar');
      final boiler = await repo.createItem(
        home,
        roomId: cellar,
        name: '$prefix boiler',
      );
      await repo.createContractor(home, name: '$prefix plumber');
      await repo.createTask(
        home,
        TaskInput(
          title: '$prefix smoke alarm',
          dueOn: testToday,
          roomId: kitchen,
        ),
      );
      await repo.createTask(
        home,
        TaskInput(
          title: '$prefix boiler service',
          dueOn: testToday.addDays(-3),
          repeatMode: 'fixed',
          repeatUnit: 'year',
          itemId: boiler,
        ),
      );
      await repo.createTask(home, TaskInput(title: '$prefix gutters'));
      for (final room in [kitchen, cellar]) {
        final photo = await repo.createPhotoRow(home, roomId: room);
        final dir = repo.homeDirectory(home)..createSync(recursive: true);
        File('${dir.path}/$photo.jpg').writeAsBytesSync([0xff, 0xd8, 0xff]);
      }
    }
    return TwoHomes(main, second);
  }
}

/// Every row of [homeId] in every table, with the clocks of their fields,
/// as bytes: two dumps are equal when nothing of that home changed.
Future<List<int>> dumpHome(
  Repository repo,
  String homeId, {
  bool homeRow = true,
}) async {
  final db = repo.db;
  final key = uuidBytes(homeId);
  final out = StringBuffer();
  Future<void> rows(String sql, List<Object?> args) async {
    final result = await db
        .customSelect(
          sql,
          variables: [for (final a in args) Variable<Object>(a)],
        )
        .get();
    for (final row in result) {
      out.writeln(
        jsonEncode(
          row.data.map(
            (k, v) => MapEntry(k, v is List<int> ? base64.encode(v) : v),
          ),
        ),
      );
    }
  }

  if (homeRow) {
    await rows('SELECT * FROM homes WHERE id = ?', [key]);
    await rows(
      "SELECT * FROM field_clock WHERE entity = 'homes.home' AND row_id = ? "
      'ORDER BY field',
      [key],
    );
  }
  for (final table in homeTables) {
    await rows('SELECT * FROM $table WHERE home_id = ? ORDER BY id', [key]);
    await rows(
      'SELECT * FROM field_clock WHERE entity = ? AND row_id IN '
      '(SELECT id FROM $table WHERE home_id = ?) ORDER BY row_id, field',
      [entityOf[table], key],
    );
  }
  final dir = repo.homeDirectory(homeId);
  if (dir.existsSync()) {
    final names = dir.listSync().map((f) => f.path).toList()..sort();
    for (final name in names) {
      out.writeln('$name ${base64.encode(File(name).readAsBytesSync())}');
    }
  }
  return utf8.encode(out.toString());
}
