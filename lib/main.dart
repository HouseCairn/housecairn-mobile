// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens (or creates) the database of the phone before the first screen,
  // so that a failure shows at start. Nothing reads it yet in lot 1.
  final db = AppDatabase.onPhone();
  await db.open();
  runApp(const HousecairnApp());
}
