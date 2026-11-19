// SPDX-License-Identifier: AGPL-3.0-only

// Migration tests of drift's guided migrations
// (docs/adr/0002-local-storage-and-migrations.md): from every schema version
// in drift_schemas/housecairn/ to the current one (schema 11). Each step runs
// in turn: 1 to 2 (lot 2a), 2 to 3 (stock), 3 to 4 (lot 3b: projects, budget,
// reports), 4 to 5 (the manufacturer's warranty, six columns of `items`) and
// 5 to 6 (the tables of sync of lot 4, new and empty) and 6 to 7
// (`server_seen` of lot 4b, new and empty) and 7 to 8 (`file_sync` of lot 4c, new
// and empty) and 8 to 9 (`task_attachments` of lot 4d, new and empty) and 9 to
// 10 (`homes.is_example` and `step_ticks` of the guide, web ADR 0084) and 10
// to 11 (`labels`, the QR labels, new and empty; a schema 10 file with data
// is migrated in test/labels_test.dart); 11 to 11 checks that the schema of
// AppDatabase is the one of drift_schema_v11.json.
// The steps from
// schemas 2, 3, 4, 5, 7, 8 and 9 also run on a file with data: every row is there
// after them, every column it had unchanged, the new columns empty or at
// their default and the new tables empty. Regenerate `generated/` with:
//   dart run drift_dev make-migrations
//   dart run drift_dev schema generate drift_schemas/housecairn/ test/drift/housecairn/generated/

import 'dart:typed_data';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:uuid/uuid.dart';

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
    test('migrates a schema $from file with data to schema 11, keeping every '
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
      await verifier.migrateAndValidate(db, 11);
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

  test('migrates a schema 4 file with items to schema 11: the end of a '
      'warranty typed before stays, the new columns are empty', () async {
    final schema = await verifier.schemaAt(4);
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
      'VALUES (?, 1, 1, ?, ?), (?, 1, 1, ?, ?)',
      [id(3), id(1), 'Main kitchen', id(4), id(2), 'Second kitchen'],
    );
    raw.execute(
      'INSERT INTO items (id, created_at, updated_at, home_id, room_id, name, '
      'warranty_ends_on) VALUES (?, 2, 2, ?, ?, ?, ?), (?, 2, 2, ?, ?, ?, ?)',
      [
        id(5),
        id(1),
        id(3),
        'Main coffee machine',
        '2027-03-01',
        id(6),
        id(2),
        id(4),
        'Second fridge',
        null,
      ],
    );
    final columns = [
      for (final c in raw.select('PRAGMA table_info(items)'))
        c['name'] as String,
    ];
    // The columns the file has now: a column a later schema adds is not
    // part of the comparison.
    final had = {
      for (final table in ['homes', 'rooms'])
        table: [
          for (final c in raw.select('PRAGMA table_info($table)'))
            c['name'] as String,
        ].join(', '),
    };
    String dump() => [
      for (final table in ['homes', 'rooms'])
        for (final row in raw.select(
          'SELECT ${had[table]} FROM $table ORDER BY id',
        ))
          '$table $row',
      for (final row in raw.select(
        'SELECT ${columns.join(', ')} FROM items ORDER BY id',
      ))
        'items $row',
    ].join('\n');
    final dumped = dump();
    expect(dumped, contains('2027-03-01'));

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    expect(dump(), dumped);
    final rows = raw.select(
      'SELECT purchased_on, warranty_duration, warranty_duration_unit, '
      'warranty_provider, warranty_provider_name, warranty_starts_on, '
      'warranty_ends_on FROM items ORDER BY id',
    );
    expect(rows.map((r) => r.values).toList(), [
      [null, null, 'year', '', '', null, '2027-03-01'],
      [null, null, 'year', '', '', null, null],
    ]);
    expect(await db.integrityCheck(), 'ok');
    await db.close();
  });

  test('migrates a schema 5 file with data to schema 11: every row and clock '
      'stays, the tables of sync are new and empty', () async {
    final schema = await verifier.schemaAt(5);
    final raw = schema.rawDatabase;
    Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
    raw.execute(
      'INSERT INTO homes (id, created_at, updated_at, name, currency, '
      'hemisphere, archived_at) VALUES (?, 1, 1, ?, ?, ?, NULL), '
      '(?, 1, 1, ?, ?, ?, 9)',
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
      'INSERT INTO tasks (id, created_at, updated_at, home_id, title, '
      'material_budget) VALUES (?, 2, 2, ?, ?, ?), (?, 2, 2, ?, ?, NULL)',
      [id(3), id(1), 'Main gutters', '12.50', id(4), id(2), 'Second gutters'],
    );
    raw.execute(
      'INSERT INTO occurrences (id, created_at, updated_at, home_id, '
      'task_id, due_on, follows) VALUES (?, 3, 3, ?, ?, ?, NULL)',
      [id(5), id(1), id(3), '2026-11-14'],
    );
    raw.execute(
      'INSERT INTO field_clock (entity, row_id, field, hlc, device) '
      'VALUES (?, ?, ?, ?, ?), (?, ?, ?, ?, ?)',
      [
        'tasks.task',
        id(3),
        'title',
        '0193a1b2c3d40001',
        id(9),
        'homes.home',
        id(2),
        'archived_at',
        '0193a1b2c3d40002',
        id(9),
      ],
    );
    raw.execute(
      "INSERT INTO local_settings (key, value) VALUES ('device_id', ?)",
      ['09090909090909090909090909090909'],
    );
    // An envelope under the id of schema 5, and its clock.
    const home1 = '6f1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
    raw.execute(
      'INSERT INTO homes (id, created_at, updated_at, name, currency, '
      'hemisphere) VALUES (?, 1, 1, ?, ?, ?)',
      [Uint8List.fromList(Uuid.parse(home1)), 'Third home', 'EUR', 'north'],
    );
    final oldEnvelope = Uint8List.fromList(
      Uuid.parse(const Uuid().v5(home1, 'projects.annualenvelope:2027')),
    );
    raw.execute(
      'INSERT INTO annual_envelopes (id, created_at, updated_at, home_id, '
      'year, amount) VALUES (?, 4, 4, ?, 2027, ?)',
      [oldEnvelope, Uint8List.fromList(Uuid.parse(home1)), '1250.50'],
    );
    raw.execute(
      'INSERT INTO field_clock (entity, row_id, field, hlc, device) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        'projects.annualenvelope',
        oldEnvelope,
        'amount',
        '0193a1b2c3d40003',
        id(9),
      ],
    );
    const before = [
      'homes',
      'tasks',
      'occurrences',
      'field_clock',
      'local_settings',
    ];
    // The columns the file has now: a column a later schema adds is not
    // part of the comparison.
    final had = {
      for (final table in before)
        table: [
          for (final c in raw.select('PRAGMA table_info($table)'))
            c['name'] as String,
        ].join(', '),
    };
    String dump() => [
      for (final table in before)
        for (final row in raw.select(
          'SELECT ${had[table]} FROM $table '
          '${table == 'field_clock' ? "WHERE entity != 'projects.annualenvelope' " : ''}'
          'ORDER BY 1, 2',
        ))
          '$table $row',
    ].join('\n');
    final dumped = dump();
    expect(dumped, contains('Second gutters'));
    expect(dumped, contains('0193a1b2c3d40002'));

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    expect(dump(), dumped);
    for (final table in [
      'op_log',
      'extra',
      'pending',
      'purged_homes',
      'other_versions',
    ]) {
      expect(
        raw.select('SELECT COUNT(*) AS n FROM $table').first['n'],
        0,
        reason: table,
      );
    }
    // The envelope takes the id of ADR 0003 and of the web, with its
    // clock; its fields are unchanged.
    final envelope = raw
        .select(
          'SELECT id, home_id, year, amount, updated_at FROM annual_envelopes',
        )
        .single;
    expect(
      Uuid.unparse(envelope['id'] as Uint8List),
      const Uuid().v5(home1, 'envelope:2027'),
    );
    expect(
      [envelope['year'], envelope['amount'], envelope['updated_at']],
      [2027, '1250.50', 4],
    );
    final clock = raw
        .select(
          'SELECT row_id, hlc FROM field_clock '
          "WHERE entity = 'projects.annualenvelope'",
        )
        .single;
    expect(clock['row_id'], envelope['id']);
    expect(clock['hlc'], '0193a1b2c3d40003');
    expect(await db.integrityCheck(), 'ok');
    await db.close();
  });

  test('migrates a schema 7 file with a photo to schema 11: the row and its '
      'mark stay, the list of files is new and empty', () async {
    final schema = await verifier.schemaAt(7);
    final raw = schema.rawDatabase;
    Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
    raw.execute(
      'INSERT INTO homes (id, created_at, updated_at, name, currency, '
      'hemisphere) VALUES (?, 1, 1, ?, ?, ?)',
      [id(1), 'Main home', 'EUR', 'north'],
    );
    raw.execute(
      'INSERT INTO photos (id, created_at, updated_at, home_id, image) '
      'VALUES (?, 2, 2, ?, ?)',
      [id(2), id(1), '{"size":3,"type":"image/jpeg"}'],
    );
    raw.execute(
      "INSERT INTO server_seen (entity, row_id, home_id) VALUES ('rooms.photo', ?, ?)",
      [id(2), id(1)],
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    expect(
      raw.select('SELECT image FROM photos').single['image'],
      '{"size":3,"type":"image/jpeg"}',
    );
    expect(raw.select('SELECT * FROM server_seen'), hasLength(1));
    expect(raw.select('SELECT COUNT(*) AS n FROM file_sync').first['n'], 0);
    expect(await db.integrityCheck(), 'ok');
    await db.close();
  });

  test('migrates a schema 8 file with a task and an attachment kept aside to '
      'schema 10: the table of attachments is new and empty, the operation '
      'stays in pending to be applied', () async {
    final schema = await verifier.schemaAt(8);
    final raw = schema.rawDatabase;
    Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
    raw.execute(
      'INSERT INTO homes (id, created_at, updated_at, name, currency, '
      'hemisphere) VALUES (?, 1, 1, ?, ?, ?)',
      [id(1), 'Main home', 'EUR', 'north'],
    );
    raw.execute(
      'INSERT INTO tasks (id, created_at, updated_at, home_id, title) '
      'VALUES (?, 2, 2, ?, ?)',
      [id(3), id(1), 'Main gutters'],
    );
    raw.execute(
      'INSERT INTO pending (key, entity, home_id, body) VALUES (?, ?, ?, ?)',
      ['k', 'tasks.attachment', id(1), '{"t":"tasks.attachment"}'],
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    expect(
      raw.select('SELECT title FROM tasks').single['title'],
      'Main gutters',
    );
    expect(
      raw.select('SELECT COUNT(*) AS n FROM task_attachments').first['n'],
      0,
    );
    expect(
      raw.select('SELECT entity FROM pending').single['entity'],
      'tasks.attachment',
    );
    expect(await db.integrityCheck(), 'ok');
    await db.close();
  });

  test('migrates a schema 9 file with two homes to schema 11: every home '
      'stays as it was and reads as a real one, the table of ticks is new '
      'and empty', () async {
    final schema = await verifier.schemaAt(9);
    final raw = schema.rawDatabase;
    Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
    raw.execute(
      'INSERT INTO homes (id, created_at, updated_at, name, currency, '
      'hemisphere, archived_at) VALUES (?, 1, 1, ?, ?, ?, NULL), '
      '(?, 1, 1, ?, ?, ?, 9)',
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
      'INSERT INTO field_clock (entity, row_id, field, hlc, device) '
      "VALUES ('homes.home', ?, 'name', '0193a1b2c3d40001', ?)",
      [id(1), id(9)],
    );
    const columns =
        'id, created_at, updated_at, deleted_at, name, currency, '
        'hemisphere, archived_at';
    String dump() => [
      for (final row in raw.select('SELECT $columns FROM homes ORDER BY id'))
        'homes $row',
      for (final row in raw.select('SELECT * FROM field_clock'))
        'field_clock $row',
    ].join('\n');
    final dumped = dump();
    expect(dumped, contains('Second home'));

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    expect(dump(), dumped);
    expect(
      raw
          .select('SELECT is_example FROM homes ORDER BY id')
          .map((r) => r['is_example']),
      [0, 0],
    );
    expect(raw.select('SELECT COUNT(*) AS n FROM step_ticks').first['n'], 0);
    expect(await db.integrityCheck(), 'ok');
    await db.close();
  });
}
