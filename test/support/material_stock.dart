// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'lot2b.dart';
import 'lot3a.dart';

/// The data of the materials worked out from the stock (web ADR 0081): the
/// homes of lot 3a, whose boiler service needs one filter at 12.50, with the
/// price of that filter typed in its material budget as well (the second
/// figure the rule leaves uncounted). Neutral names only.
class MaterialStock {
  late Lot3a lot;

  String get main => lot.main;
  String get service => lot.service;
  String get filter => lot.filter;

  static Future<MaterialStock> seed(Repository r) async {
    final data = MaterialStock()..lot = await Lot3a.seed(r);
    await r.setTaskBudgets(data.service, material: '12.50', labour: '');
    return data;
  }
}

/// The page of the task, scrolled to its Cost card.
Future<void> openTaskCost(WidgetTester tester, MaterialStock data) async {
  await openScreen(tester, TaskScreen(homeId: data.main, taskId: data.service));
  await tester.scrollUntilVisible(
    find.byKey(const Key('task-cost-planned')),
    300,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .last,
  );
  // The whole card in sight, its top at the top of the screen.
  await tester.ensureVisible(find.byKey(const Key('task-cost')));
  await tester.pumpAndSettle();
}

/// The form of the task, its section Time and budget open and in sight.
Future<void> openTaskBudget(WidgetTester tester, MaterialStock data) async {
  await openScreen(
    tester,
    TaskFormScreen(homeId: data.main, taskId: data.service),
  );
  await unfoldTaskSection(tester, 'task-section-budget');
  await seeInTaskForm(tester, find.byKey(const Key('task-labour-budget')));
  await tester.ensureVisible(find.byKey(const Key('task-section-budget')));
  await tester.pumpAndSettle();
}
