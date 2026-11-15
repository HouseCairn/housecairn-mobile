// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/core/notifier.dart';
import 'package:housecairn_mobile/core/photo_source.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/icons.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'fixture.dart';

/// A phone of 360 logical pixels by 760, the narrowest width of the spec.
Future<void> onPhone(
  WidgetTester tester, {
  double textScale = 1,
  double height = 760,
}) async {
  tester.view.physicalSize = Size(360 * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Starts the app in [locale] on a repository of its own, after [seed] has
/// written its data (none: the first start, which makes the first home).
Future<AppState> pumpApp(
  WidgetTester tester, {
  String locale = 'en',
  Future<void> Function(Repository repository)? seed,
  PhotoSource? photoSource,
  Notifier? notifier,
  UrlOpener? openUrl,
}) async {
  final repository = await openRepository();
  addTearDown(repository.db.close);
  if (seed != null) await seed(repository);
  final state = AppState(
    repository,
    photoSource: photoSource,
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
