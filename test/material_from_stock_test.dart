// SPDX-License-Identifier: AGPL-3.0-only

// The materials of a task worked out from its priced stock items (web ADR
// 0081): one rule (`materialOf`, the web's `material_of`), read by the
// budget, the page of the task and its form. The figures of the budget are
// compared with the web's in budget_web_test.dart; this file covers the rule
// itself and the screens.

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/budget.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart' show stateOf;
import 'support/material_stock.dart';

Decimal d(String s) => Decimal.parse(s);

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  group('the rule', () {
    test('a priced stock item replaces the material budget typed', () {
      // The example of the ADR: one filter at 7.90, its price typed as well.
      final plan = stockPlan([(d('1'), d('7.90'))]);
      expect(materialOf(d('7.90'), plan), d('7.90'));
      expect(materialOf(null, plan), d('7.90'));
    });

    test('a price of zero is a price', () {
      final plan = stockPlan([(d('1'), d('0'))]);
      expect(plan.priced, 1);
      expect(materialOf(d('9.00'), plan), d('0'));
    });

    test('with only unpriced items, or none, the budget typed counts', () {
      expect(materialOf(d('15.00'), stockPlan([(d('1'), null)])), d('15.00'));
      expect(materialOf(d('15.00'), stockPlan(const [])), d('15.00'));
      expect(materialOf(null, stockPlan(const [])), d('0'));
    });

    test('the stock plan is quantity times unit price, rounded once', () {
      final plan = stockPlan([
        (d('2'), d('12.50')),
        (d('0.333'), d('1.00')),
        (d('3'), null),
      ]);
      expect((plan.amount, plan.priced, plan.unpriced), (d('25.33'), 2, 1));
      expect(materialOf(d('80.00'), plan), d('25.33'));
    });
  });

  for (final locale in ['en', 'fr']) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<MaterialStock> start(WidgetTester tester) async {
      await onPhone(tester);
      late MaterialStock data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await MaterialStock.seed(r),
        notifier: FakeNotifier(),
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      return data;
    }

    testWidgets('the cost of a task says planned and real apart, $locale', (
      tester,
    ) async {
      final data = await start(tester);
      await openTaskCost(tester, data);
      final card = find.byKey(const Key('task-cost'));
      final planned = tester.getRect(
        find.byKey(const Key('task-cost-planned')),
      );
      final real = tester.getRect(find.byKey(const Key('task-cost-real')));
      expect(planned.top, lessThan(real.top), reason: 'planned, then real');
      expect(
        find.descendant(of: card, matching: find.text(t('Planned', 'Prévu'))),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text(t('Real', 'Réel'))),
        findsOneWidget,
      );
      // 12.50 typed and one filter at 12.50: the estimate is 12.50, not 25.
      final money = t('12.50', '12,50');
      final fromStock = find.byKey(const Key('task-materials-from-stock'));
      expect(
        find.descendant(of: fromStock, matching: find.textContaining(money)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.textContaining(money)),
        findsNWidgets(2),
        reason: 'the estimate each time and the materials from the stock',
      );
      expect(
        find.text(
          t(
            'The materials are calculated from the stock items of the task: '
                'quantity times unit price.',
            'Le matériel est calculé à partir des articles de la tâche : '
                'quantité fois prix unitaire.',
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the form shows the materials calculated in place of the '
        'field, and keeps the amount typed, $locale', (tester) async {
      final data = await start(tester);
      await openTaskBudget(tester, data);
      expect(find.byKey(const Key('task-material-budget')), findsNothing);
      expect(
        find.textContaining(
          t(
            'each time, calculated from the stock items of the task.',
            'à chaque fois, calculé à partir des articles de la tâche.',
          ),
        ),
        findsOneWidget,
      );
      await saveTask(tester);
      final repository = stateOf(tester).repository;
      expect(
        (await repository.task(data.service))!.materialBudget,
        isNotNull,
        reason: 'the amount typed stays, not counted',
      );
      // The priced item goes: the field comes back with what was typed.
      await repository.removeMaterial(data.service, data.filter);
      await openTaskBudget(tester, data);
      expect(find.byKey(const Key('task-material-from-stock')), findsNothing);
      final field = find.descendant(
        of: find.byKey(const Key('task-material-budget')),
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(field).controller.text,
        t('12.50', '12,50'),
      );
    });
  }

  group('goldens', () {
    for (final locale in ['en', 'fr']) {
      for (final scale in [1.0, 2.0]) {
        final name = '${locale}_x${scale.toInt()}';
        for (final (page, open) in [
          ('task_cost_from_stock', openTaskCost),
          ('task_form_material_from_stock', openTaskBudget),
        ]) {
          testWidgets('$page, $name', (tester) async {
            await onPhone(tester, textScale: scale);
            late MaterialStock data;
            final state = await pumpApp(
              tester,
              locale: locale,
              seed: (r) async => data = await MaterialStock.seed(r),
              notifier: FakeNotifier(),
            );
            await state.choose(data.main);
            await tester.pumpAndSettle();
            await open(tester, data);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/${page}_$name.png'),
            );
          });
        }
      }
    }
  });
}
