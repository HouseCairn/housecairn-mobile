// SPDX-License-Identifier: AGPL-3.0-only

// Migration tests of drift's guided migrations
// (docs/adr/0002-local-storage-and-migrations.md): from every schema version
// in drift_schemas/housecairn/ to the current one (schema 3): 1 to 3 runs the
// migrations of lots 2a and 3a, 2 to 3 the one of lot 3a (the stock), and 3 to
// 3 checks that the schema of AppDatabase is the one of drift_schema_v3.json.
// The step from schema 2, that of the lots 2a and 2b, also runs on a file with
// data: every row of schema 2 is there after it, unchanged. Regenerate `generated/` with:
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

  test('migrates a schema 2 file with data to schema 3, keeping every row', () async {
    final schema = await verifier.schemaAt(2);
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
      'INSERT INTO tasks (id, created_at, updated_at, home_id, title) '
      'VALUES (?, 2, 2, ?, ?), (?, 2, 2, ?, ?)',
      [id(3), id(1), 'Main gutters', id(4), id(2), 'Second gutters'],
    );
    raw.execute(
      'INSERT INTO occurrences (id, created_at, updated_at, home_id, task_id, '
      'due_on) VALUES (?, 3, 3, ?, ?, ?)',
      [id(5), id(1), id(3), '2026-11-14'],
    );
    String dump(List<String> tables) => [
      for (final table in tables)
        for (final row in raw.select('SELECT * FROM $table ORDER BY id'))
          '$table $row',
    ].join('\n');

    const before = ['homes', 'tasks', 'occurrences'];
    final dumped = dump(before);
    expect(dumped, contains('Second gutters'));

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    expect(dump(before), dumped);
    for (final table in [
      'articles',
      'article_rooms',
      'article_items',
      'suppliers',
      'movements',
      'task_materials',
      'material_draws',
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
