// SPDX-License-Identifier: AGPL-3.0-only

// Migration tests of drift's guided migrations
// (docs/adr/0002-local-storage-and-migrations.md): from every schema version
// in drift_schemas/housecairn/ to the current one (schema 2): 1 to 2 runs the
// migration of lot 2a, and 2 to 2 checks that the schema of AppDatabase is the
// one of drift_schema_v2.json. Regenerate `generated/` with:
//   dart run drift_dev make-migrations
//   dart run drift_dev schema generate drift_schemas/housecairn/ test/drift/housecairn/generated/

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
}
