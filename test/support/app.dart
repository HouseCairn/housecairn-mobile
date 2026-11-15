// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/core/document_source.dart';
import 'package:housecairn_mobile/core/notifier.dart';
import 'package:housecairn_mobile/core/photo_source.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/icons.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'fixture.dart';

/// A phone of 360 logical pixels by 760, the narrowest width of the spec,
/// or of [width].
Future<void> onPhone(
  WidgetTester tester, {
  double textScale = 1,
  double width = 360,
  double height = 760,
}) async {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Starts the app in [locale] on a repository of its own, after [seed] has
/// written its data (none: the first home is made at start). The way to use
/// the app is "alone" unless [firstStart] is set: then none is stored, as on
/// a new install, and the app asks (lot 2c); with homes in [seed] it is the
/// install of a build of lot 2.
Future<AppState> pumpApp(
  WidgetTester tester, {
  String locale = 'en',
  Future<void> Function(Repository repository)? seed,
  PhotoSource? photoSource,
  DocumentSource? documentSource,
  Notifier? notifier,
  UrlOpener? openUrl,
  bool firstStart = false,
}) async {
  final repository = await openRepository();
  addTearDown(repository.db.close);
  if (seed != null) await seed(repository);
  if (!firstStart) await repository.setSyncMode(SyncMode.alone);
  final state = AppState(
    repository,
    photoSource: photoSource,
    documentSource: documentSource,
    notifier: notifier,
    // Synchronous, so that the widget tests do not wait for an isolate.
    photoProcessor: (bytes) async => processPhoto(bytes),
    // Read at once: the asset bundle needs a real event loop.
    loadTemplates: () async =>
        parseTemplates(File('assets/task_templates.yaml').readAsStringSync()),
    openUrl: openUrl ?? (_) async => true,
  );
  await tester.pumpWidget(HousecairnApp(state: state, locale: Locale(locale)));
  await tester.pumpAndSettle();
  return state;
}

Finder destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Taps the back button of the app bar (the one of material_ui, which
/// `WidgetTester.pageBack` does not know).
Future<void> back(WidgetTester tester) async {
  await tester.tap(
    find.byWidgetPredicate((w) => w.runtimeType.toString() == 'BackButton'),
  );
  await tester.pumpAndSettle();
}

/// An icon of the app's own set ([HcIcons]).
Finder hcIcon(HcIcons icon) =>
    find.byWidgetPredicate((w) => w is HcIcon && w.icon == icon);

/// A heading of a group of rows, by its text (it shows in capitals).
Finder heading(String text) =>
    find.byWidgetPredicate((w) => w is HcSectionHeading && w.text == text);

/// Taps the add button of key [key], after its list: scrolls the list of the
/// screen until it shows.
Future<void> tapAdd(WidgetTester tester, String key) async {
  final button = find.byKey(Key(key));
  await tester.scrollUntilVisible(
    button,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  // To the end of the list: the button is its last child, and only that
  // shows all of it above the bottom bar at large text sizes.
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// The scrollable of the list of the task form (not the one of a field).
Finder _taskFormList() => find
    .descendant(
      of: find.byType(TaskFormScreen),
      matching: find.byType(Scrollable),
    )
    .first;

/// Shows [finder] in the task form, by scrolling its list.
Future<void> seeInTaskForm(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _taskFormList());
  await tester.pumpAndSettle();
}

/// Opens the folded section of key [key] of the task form (Repeat, Who,
/// Time and budget, How to do it), when it is not open yet.
Future<void> unfoldTaskSection(WidgetTester tester, String key) async {
  final section = find.byKey(Key(key));
  await seeInTaskForm(tester, section);
  if (tester.state<State<HcFoldSection>>(section).mounted &&
      find
          .descendant(of: section, matching: find.byIcon(Icons.arrow_right))
          .evaluate()
          .isNotEmpty) {
    await tester.tap(
      find.descendant(of: section, matching: find.byIcon(Icons.arrow_right)),
    );
    await tester.pumpAndSettle();
  }
}

/// Saves the task form: its button is at the end of the form.
Future<void> saveTask(WidgetTester tester) async {
  final button = find.byKey(const Key('task-save'));
  await seeInTaskForm(tester, button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}
