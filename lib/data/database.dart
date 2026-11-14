// SPDX-License-Identifier: AGPL-3.0-only

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/db.dart';

part 'database.g.dart';

/// The one SQLite database of the app (docs/adr/0002-local-storage-and-migrations.md).
///
/// Schema 1 has no table yet: the tables of homes, rooms, items and tasks,
/// and `field_clock`, come with lot 2. Migrations are drift's guided
/// migrations: `dart run drift_dev make-migrations` keeps one schema file per
/// version in `drift_schemas/` and generates the migration tests under
/// `test/drift/`.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase implements Db {
  AppDatabase(super.executor);

  /// The database file of the app, `housecairn.sqlite`, in the app's private
  /// directory, opened in a background isolate.
  factory AppDatabase.onPhone() =>
      AppDatabase(driftDatabase(name: 'housecairn'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Schema 1 is the first: a file at another version (one written by a
      // newer app, as a downgrade is also an upgrade call) is refused, never
      // opened as if it were schema 1. Lot 2 adds the generated `stepByStep`
      // of database.steps.dart for its own versions.
      throw StateError('No migration from schema $from to $to.');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  @override
  Future<void> open() async {
    // drift opens lazily, on the first statement; this one opens, creates or
    // migrates the database, and runs beforeOpen.
    await customSelect('SELECT 1').get();
  }

  @override
  Future<String> integrityCheck() async {
    final rows = await customSelect('PRAGMA integrity_check').get();
    return rows.map((row) => row.data.values.first.toString()).join('\n');
  }
}
