// SPDX-License-Identifier: AGPL-3.0-only

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/db.dart';
import 'database.steps.dart';
import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

/// The one SQLite database of the app (docs/adr/0002-local-storage-and-migrations.md).
///
/// Schema 1 had no table. Schema 2 (lot 2a) has the homes, rooms, items,
/// photos, contractors, tasks and occurrences, `field_clock` and the local
/// settings of the phone (lib/data/tables.dart). Schema 3 (lot 3a) adds the
/// stock: articles, their rooms and compatible items, suppliers, movements,
/// the materials of tasks and the draws of done occurrences. Schema 4 (lot 3b)
/// adds projects with their rooms, budget lines, quotes, files, links and
/// tasks, the annual envelopes and the reports, and four nullable columns:
/// the two budgets of a task, the real cost of an occurrence, the paint left
/// of a room. Schema 5 adds the manufacturer's warranty of an item, six
/// columns (web ADR 0080). Schema 6 (lot 4) adds the tables of sync:
/// `op_log`, `extra`, `pending`, `purged_homes` and `other_versions`. Schema 7
/// (lot 4b) adds `server_seen`, the mark of the rows a server has seen.
/// Schema 8 (lot 4c) adds `file_sync`, the files to send and to fetch.
/// Schema 9 (lot 4d) adds `task_attachments`, the photos and files of tasks.
/// Schema 10 (web ADR 0084) adds the mark `homes.is_example` of the example
/// home of the guide and `step_ticks`, the steps of the guide done.
/// Migrations are drift's
/// guided migrations: `dart run drift_dev make-migrations` keeps one schema
/// file per version in `drift_schemas/` and generates the step-by-step code
/// (`database.steps.dart`) and the migration tests under `test/drift/`.
/// Every write goes through the repository (lib/data/repository.dart).
@DriftDatabase(
  tables: [
    Homes,
    Rooms,
    Items,
    Photos,
    Contractors,
    Tasks,
    Occurrences,
    Articles,
    ArticleRooms,
    ArticleItems,
    Suppliers,
    Movements,
    TaskMaterials,
    MaterialDraws,
    Projects,
    ProjectRooms,
    BudgetLines,
    Quotes,
    ProjectFiles,
    ProjectLinks,
    ProjectTasks,
    AnnualEnvelopes,
    Reports,
    FieldClock,
    LocalSettings,
    OpLog,
    Extra,
    Pending,
    PurgedHomes,
    OtherVersions,
    ServerSeen,
    FileSync,
    TaskAttachments,
    StepTicks,
  ],
)
class AppDatabase extends _$AppDatabase implements Db {
  AppDatabase(super.executor);

  /// The database file of the app, `housecairn.sqlite`, in the app's private
  /// directory, opened in a background isolate.
  factory AppDatabase.onPhone() =>
      AppDatabase(driftDatabase(name: 'housecairn'));

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // A file of a newer app (a downgrade is also an upgrade call) is
      // refused, never opened as if it were of this schema.
      if (from > to || to != schemaVersion) {
        throw StateError('No migration from schema $from to $to.');
      }
      await m.runMigrationSteps(
        from: from,
        to: to,
        steps: migrationSteps(
          from1To2: (m, schema) async {
            for (final table
                in schema.entities.whereType<TableInfo<Table, dynamic>>()) {
              await m.createTable(table);
            }
            for (final index in schema.entities.whereType<Index>()) {
              await m.create(index);
            }
          },
          from2To3: (m, schema) async {
            // Only new tables and their indexes: nothing of schema 2 moves.
            for (final table in [
              schema.articles,
              schema.articleRooms,
              schema.articleItems,
              schema.suppliers,
              schema.movements,
              schema.taskMaterials,
              schema.materialDraws,
            ]) {
              await m.createTable(table);
            }
            for (final index in [
              schema.articleHomeName,
              schema.movementArticle,
              schema.materialTask,
              schema.drawOccurrence,
            ]) {
              await m.create(index);
            }
          },
          from3To4: (m, schema) async {
            // Four nullable columns and new tables: no row of schema 3 moves.
            await m.addColumn(schema.rooms, schema.rooms.paintArticleId);
            await m.addColumn(schema.tasks, schema.tasks.materialBudget);
            await m.addColumn(schema.tasks, schema.tasks.labourBudget);
            await m.addColumn(
              schema.occurrences,
              schema.occurrences.actualCost,
            );
            for (final table in [
              schema.projects,
              schema.projectRooms,
              schema.budgetLines,
              schema.quotes,
              schema.projectFiles,
              schema.projectLinks,
              schema.projectTasks,
              schema.annualEnvelopes,
              schema.reports,
            ]) {
              await m.createTable(table);
            }
            for (final index in [
              schema.projectHomeStatus,
              schema.lineProject,
              schema.quoteProject,
              schema.reportHomeStatus,
            ]) {
              await m.create(index);
            }
          },
          from4To5: (m, schema) async {
            // The manufacturer's warranty of an item (web ADR 0080): six
            // columns, nullable or with a default; the end already typed
            // stays as it is.
            for (final column in [
              schema.items.purchasedOn,
              schema.items.warrantyDuration,
              schema.items.warrantyDurationUnit,
              schema.items.warrantyProvider,
              schema.items.warrantyProviderName,
              schema.items.warrantyStartsOn,
            ]) {
              await m.addColumn(schema.items, column);
            }
          },
          from5To6: (m, schema) async {
            // The tables of sync (lot 4), new and empty: no row moves.
            for (final table in [
              schema.opLog,
              schema.extra,
              schema.pending,
              schema.purgedHomes,
              schema.otherVersions,
            ]) {
              await m.createTable(table);
            }
            // The id of an annual envelope becomes the one of ADR 0003 and of
            // the web (`envelope:` and four digits, was
            // `projects.annualenvelope:<year>`): the rows and their clocks
            // take it, nothing else moves. No other phone had them: sync did
            // not exist before this schema.
            final envelopes = await customSelect(
              'SELECT id, home_id, year FROM annual_envelopes',
            ).get();
            for (final row in envelopes) {
              final old = row.data['id'] as Uint8List;
              final home = const UuidConverter().fromSql(
                row.data['home_id'] as Uint8List,
              );
              final String newId;
              try {
                newId = envelopeIdOf(home, row.data['year'] as int);
              } on FormatException {
                // A home id that is not an RFC 4122 UUID (never made by the
                // app): the row keeps the id it has.
                continue;
              }
              final id = uuidBytes(newId);
              await customStatement(
                'UPDATE annual_envelopes SET id = ? WHERE id = ?',
                [id, old],
              );
              await customStatement(
                'UPDATE field_clock SET row_id = ? WHERE entity = '
                "'projects.annualenvelope' AND row_id = ?",
                [id, old],
              );
            }
          },
          from6To7: (m, schema) async {
            // The mark "seen by the server" (lot 4b), a new empty table: no
            // row moves.
            await m.createTable(schema.serverSeen);
          },
          from7To8: (m, schema) async {
            // The files of a server (lot 4c), a new empty table: no row
            // moves.
            await m.createTable(schema.fileSync);
          },
          from8To9: (m, schema) async {
            // The attachments of tasks (lot 4d), a new empty table and its
            // index: no row moves. The operations of attachments a server
            // sent before are in `pending`, applied at the next sync.
            await m.createTable(schema.taskAttachments);
            await m.create(schema.attachmentTask);
          },
          from9To10: (m, schema) async {
            // The example home of the guide (web ADR 0084): one column with
            // a default, so that every home already there reads as a real
            // one, and the ticks of its steps, a new empty table.
            await m.addColumn(schema.homes, schema.homes.isExample);
            await m.createTable(schema.stepTicks);
          },
        ),
      );
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
