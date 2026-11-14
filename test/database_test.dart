// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/db.dart';
import 'package:housecairn_mobile/data/database.dart';

Future<Object?> pragma(AppDatabase db, String name) async {
  final row = await db.customSelect('PRAGMA $name').getSingle();
  return row.data.values.first;
}

void main() {
  test(
    'the empty database opens at schema 1 and passes integrity_check',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final Db asDb = db;
      await asDb.open();
      expect(asDb.schemaVersion, 1);
      expect(await pragma(db, 'user_version'), 1);
      expect(await pragma(db, 'foreign_keys'), 1);
      expect(await asDb.integrityCheck(), 'ok');
      await asDb.close();
    },
  );

  test(
    'a database file reopens at schema 1, in WAL mode, and stays sound',
    () async {
      final dir = await Directory.systemTemp.createTemp('housecairn-db-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/housecairn.sqlite');

      final first = AppDatabase(NativeDatabase(file));
      await first.open();
      expect(await pragma(first, 'journal_mode'), 'wal');
      await first.close();
      expect(file.existsSync(), isTrue);

      // The file is at schema 1 and the app writes schema 1: opening it again
      // neither creates nor upgrades anything.
      final second = AppDatabase(NativeDatabase(file));
      await second.open();
      expect(await pragma(second, 'user_version'), 1);
      expect(await pragma(second, 'journal_mode'), 'wal');
      expect(await pragma(second, 'foreign_keys'), 1);
      expect(await second.integrityCheck(), 'ok');
      await second.close();
    },
  );

  test('a migration from a schema the app does not know is refused', () async {
    final dir = await Directory.systemTemp.createTemp('housecairn-db-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/housecairn.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    await first.open();
    await first.customStatement('PRAGMA user_version = 2');
    await first.close();

    // A file written by a newer version of the app (schema 2) is not
    // downgraded silently: drift calls onUpgrade(2, 1), which throws.
    final second = AppDatabase(NativeDatabase(file));
    await expectLater(second.open(), throwsStateError);
    await second.close();
  });
}
