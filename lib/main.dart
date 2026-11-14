// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/clock.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'ui/state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens (or creates and migrates) the database of the phone before the
  // first screen, so that a failure shows at start.
  final db = AppDatabase.onPhone();
  await db.open();
  // The files of the homes live next to the database, in the app's private
  // directory, which SQLite names (no other package needed for it).
  final list = await db.customSelect('PRAGMA database_list').get();
  final path = list.first.data['file'] as String;
  final repository = Repository(
    db,
    clock: const SystemClock(),
    files: File(path).parent,
  );
  await repository.open();
  runApp(HousecairnApp(state: AppState(repository)));
}
