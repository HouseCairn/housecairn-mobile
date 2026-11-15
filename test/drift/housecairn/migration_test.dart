// SPDX-License-Identifier: AGPL-3.0-only

// Migration tests of drift's guided migrations
// (docs/adr/0002-local-storage-and-migrations.md): from every schema version
// in drift_schemas/housecairn/ to the current one (schema 4): 1 to 4 runs the
// migrations of lots 2a, 3a and 3b, 2 to 4 those of the stock and of the
// projects, 3 to 4 the one of lot 3b (projects, budget, reports), and 4 to 4
// checks that the schema of AppDatabase is the one of drift_schema_v4.json.
// The steps from schemas 2 and 3 also run on a file with data: every row is
// there after them, every column it had unchanged, the four new columns empty
// and the new tables empty. Regenerate `generated/` with:
//   dart run drift_dev make-migrations
//   dart run drift_dev schema generate drift_schemas/housecairn/ test/drift/housecairn/generated/

import 'dart:typed_data';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  for (final from in GeneratedHelper.versions) {
    test('migrates from schema $from to the current schema', () async {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, db.schemaVersion);
      expect(await db.integrityCheck(), 'ok');
      await db.close();
    });
  }

  for (final from in [2, 3]) {
    test('migrates a schema $from file with data to schema 4, keeping every '
        'row', () async {
      final schema = await verifier.schemaAt(from);
      final raw = schema.rawDatabase;
      Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
      raw.execute(
        'INSERT INTO homes (id, created_at, updated_at, name, currency, '
        'hemisphere) VALUES (?, 1, 1, ?, ?, ?), (?, 1, 1, ?, ?, ?)',
        [
          id(1),
          'Main home',
          'EUR',
          'north',
          id(2),
          'Second home',
          'CHF',
          'south',
        ],
      );
      raw.execute(
        'INSERT INTO rooms (id, created_at, updated_at, home_id, name) '
        'VALUES (?, 1, 1, ?, ?)',
        [id(6), id(1), 'Main kitchen'],
      );
      raw.execute(
        'INSERT INTO tasks (id, created_at, updated_at, home_id, title) '
        'VALUES (?, 2, 2, ?, ?), (?, 2, 2, ?, ?)',
        [id(3), id(1), 'Main gutters', id(4), id(2), 'Second gutters'],
      );
      raw.execute(
        'INSERT INTO occurrences (id, created_at, updated_at, home_id, '
        'task_id, due_on) VALUES (?, 3, 3, ?, ?, ?)',
        [id(5), id(1), id(3), '2026-11-14'],
      );
      final before = ['homes', 'rooms', 'tasks', 'occurrences'];
      if (from == 3) {
        raw.execute(
          'INSERT INTO articles (id, created_at, updated_at, home_id, name, '
          'unit_price) VALUES (?, 4, 4, ?, ?, ?)',
          [id(7), id(2), 'Second filter', '12.50'],
        );
        before.add('articles');
      }
      final columns = {
        for (final table in before)
          table: [
            for (final c in raw.select('PRAGMA table_info($table)'))
              c['name'] as String,
          ],
      };
      String dump() => [
        for (final table in before)
          for (final row in raw.select(
            'SELECT ${columns[table]!.join(', ')} FROM $table ORDER BY id',
          ))
            '$table $row',
      ].join('\n');
      final dumped = dump();
      expect(dumped, contains('Second gutters'));

      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 4);
      expect(dump(), dumped);
      for (final (table, column) in [
        ('rooms', 'paint_article_id'),
        ('tasks', 'material_budget'),
        ('tasks', 'labour_budget'),
        ('occurrences', 'actual_cost'),
      ]) {
        expect(
          raw
              .select('SELECT COUNT(*) AS n FROM $table WHERE $column IS NULL')
              .first['n'],
          raw.select('SELECT COUNT(*) AS n FROM $table').first['n'],
          reason: '$table.$column',
        );
      }
      for (final table in [
        if (from == 2) ...['articles', 'movements', 'task_materials'],
        'projects',
        'project_rooms',
        'budget_lines',
        'quotes',
        'project_files',
        'project_links',
        'project_tasks',
        'annual_envelopes',
        'reports',
      ]) {
        expect(
          raw.select('SELECT COUNT(*) AS n FROM $table').first['n'],
          0,
          reason: table,
        );
      }
      expect(await db.integrityCheck(), 'ok');
      await db.close();
    });
  }
}
