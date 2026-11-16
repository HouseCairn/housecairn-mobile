// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/clock.dart';
import 'core/document_source.dart';
import 'core/local_notifier.dart';
import 'core/photo_source.dart';
import 'core/secure_store.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'design/fonts.dart';
import 'sync/server_connection.dart';
import 'ui/state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicences();
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
  // The secure store holds a copy of the device id that no backup carries:
  // a database restored from a backup gets a new one (lot 4b).
  final secrets = SecureStore();
  await repository.open(secrets: secrets);
  // The camera, the gallery and the local notifications: each asks for its
  // permission at the moment of use, never here.
  late final AppState state;
  final notifier = LocalNotifier(
    onOpen: (payload) => state.openReminder(payload),
  );
  state = AppState(
    repository,
    photoSource: ImagePickerSource(),
    documentSource: const FilePickerSource(),
    notifier: notifier,
    store: secrets,
  );
  // Before the app's navigator: the end of a sign-in in the browser comes
  // back as a link to the app, which is not a route (lot 4b).
  SignInCallbacks.instance.listen();
  runApp(HousecairnApp(state: state));
}
