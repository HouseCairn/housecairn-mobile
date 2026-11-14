// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'fixture.dart';

/// A phone of 360 logical pixels by 760, the narrowest width of the spec.
Future<void> onPhone(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(360 * 3, 760 * 3);
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
}) async {
  final repository = await openRepository();
  addTearDown(repository.db.close);
  if (seed != null) await seed(repository);
  final state = AppState(repository);
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
