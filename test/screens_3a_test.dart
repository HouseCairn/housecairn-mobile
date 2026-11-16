// SPDX-License-Identifier: AGPL-3.0-only

// Screens of lot 3a (docs/plan.md, lot 3): Stock, an article with its
// movements and suppliers, their forms, and the materials of a task taken by
// Done and given back by Undo, at 360 px, in English and French, with the two
// homes of the fixture (EUR and CHF).

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/values.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens_2b_test.dart' show reveal, tapKey, type;
import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3a.dart';
import 'support/screens_2b.dart';

void main() {
  setUpAll(initializeDateFormatting);

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<(AppState, Lot3a)> start(WidgetTester tester) async {
      await onPhone(tester);
      late Lot3a data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot3a.seed(r),
        notifier: FakeNotifier(),
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      return (state, data);
    }

    Future<void> openStock(WidgetTester tester, Lot3a data) =>
        screens3a.firstWhere((s) => s.$1 == 'stock').$2(tester, data, l);

    testWidgets('Stock lists the articles of the current home only, each in '
        'its currency, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openStock(tester, data);
      expect(find.text('Main filter'), findsOneWidget);
      expect(find.text('White paint'), findsOneWidget);
      expect(find.text('Second filter'), findsNothing);
      expect(
        find.text(t('2.50 litres · Garage', '2,50 litres · Garage')),
        findsOneWidget,
      );
      // The filter: 2 in stock, threshold 2, flagged as the tab and the page
      // of the article say it: Low stock.
      final low = t('Low stock', 'Stock bas');
      expect(
        find.descendant(
          of: find.byKey(Key('article-${data.filter}')),
          matching: find.text(low),
        ),
        findsOneWidget,
      );
      // Low stock, then All again, then a search by the supplier's name.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('stock-tabs')),
          matching: find.text(low),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('White paint'), findsNothing);
      expect(find.text('Main filter'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('stock-tabs')),
          matching: find.text(t('All', 'Tous')),
        ),
      );
      await tester.pumpAndSettle();
      await type(tester, 'stock-search', 'main shop');
      await tester.pumpAndSettle();
      expect(find.text('White paint'), findsNothing);
      expect(find.text('Main filter'), findsOneWidget);
      // The other home: its own article, in CHF.
      await state.choose(data.base.homes.second);
      await tester.pumpAndSettle();
      await type(tester, 'stock-search', '');
      await tester.pumpAndSettle();
      expect(find.text('Second filter'), findsOneWidget);
      expect(find.text('Main filter'), findsNothing);
      await tester.tap(find.text('Second filter'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text(t('CHF\u00a012.50', '12,50\u00a0CHF')));
      expect(find.text(t('CHF\u00a012.50', '12,50\u00a0CHF')), findsWidgets);
    });

    testWidgets('an article shows its stock, records an entry, refuses an '
        'exit beyond it, and sets a count, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openScreen(
        tester,
        ArticleScreen(homeId: data.main, articleId: data.filter),
      );
      // The level as the web's `.stock-quantity`: the figure, then its unit.
      final level = tester.widget<HcFigure>(
        find.byKey(const Key('article-level')),
      );
      expect((level.figure, level.unit), ('2', t('pieces', 'pièces')));
      expect(find.text(t('€12.50', '12,50\u00a0€')), findsOneWidget);
      await type(tester, 'movement-quantity', '3');
      await tapKey(tester, 'movement-entry');
      expect(
        await state.repository.stockLevel(data.filter),
        Decimal.fromInt(5),
      );
      await type(tester, 'movement-quantity', '9');
      await tapKey(tester, 'movement-exit');
      expect(
        find.text(t('Only 5 in stock.', "Il n'y en a que 5 en stock.")),
        findsOneWidget,
      );
      expect(
        await state.repository.stockLevel(data.filter),
        Decimal.fromInt(5),
      );
      await type(tester, 'movement-quantity', '1');
      await tapKey(tester, 'movement-inventory');
      expect(await state.repository.stockLevel(data.filter), Decimal.one);
      await reveal(
        tester,
        find.text(t('Inventory · -4 pieces', 'Inventaire · -4 pièces')),
      );
      expect(
        find.text(t('Inventory · -4 pieces', 'Inventaire · -4 pièces')),
        findsOneWidget,
      );
    });

    testWidgets('an article and a supplier are added from their forms, '
        '$locale', (tester) async {
      final (state, data) = await start(tester);
      await openStock(tester, data);
      await tapKey(tester, 'article-add');
      await type(tester, 'article-name', 'Example glue');
      await type(tester, 'article-threshold', '1,5');
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      final added = (await state.repository.articles(
        data.main,
        query: 'example glue',
      )).single;
      expect(added.article.threshold, '1.50');
      await tester.tap(find.text('Example glue'));
      await tester.pumpAndSettle();
      await tapKey(tester, 'supplier-add');
      await type(tester, 'supplier-name', 'Example store');
      await type(tester, 'supplier-last-price', '3.40');
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      // The last price paid fills the empty unit price (web ADR 0062).
      expect(
        (await state.repository.article(added.article.id))!.unitPrice,
        '3.40',
      );
      expect(find.text('Example store'), findsOneWidget);
    });

    testWidgets('Done on Today takes the materials and Undo gives them back, '
        '$locale', (tester) async {
      final (state, data) = await start(tester);
      final repo = state.repository;
      // The boiler's service needs 3 filters; there are 2.
      await repo.saveMaterial(data.service, data.filter, '3');
      final occurrence = (await repo.openOccurrencesOf(data.service)).single;
      await repo.postpone(occurrence.id, repo.today());
      await state.refresh();
      await tester.pumpAndSettle();
      final done = find.descendant(
        of: find.ancestor(
          of: find.text('Service the boiler'),
          matching: find.byType(HcTaskRow),
        ),
        matching: find.widgetWithText(FilledButton, t('Done', 'Fait')),
      );
      // Under the title and the selector of the home, the row may be below
      // the first screen.
      await tester.ensureVisible(done);
      await tester.pumpAndSettle();
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(await repo.stockLevel(data.filter), Decimal.zero);
      expect(
        find.textContaining(
          t(
            'Not enough in stock, the stock is at zero: Main filter (1 piece).',
            'Stock insuffisant, le stock est à zéro : Main filter (1 pièce).',
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(t('Undo', 'Annuler')));
      await tester.pumpAndSettle();
      expect(await repo.stockLevel(data.filter), Decimal.fromInt(2));
      expect(await repo.drawsOf(occurrence.id), isEmpty);
    });

    testWidgets('the materials of a task: add, the stock shown, remove, '
        '$locale', (tester) async {
      final (state, data) = await start(tester);
      await screens3a
          .firstWhere((s) => s.$1 == 'task_materials')
          .$2(tester, data, l);
      expect(find.byKey(Key('material-${data.filter}')), findsOneWidget);
      await reveal(tester, find.byKey(const Key('material-add')));
      await type(tester, 'material-quantity', '0,5');
      await tapKey(tester, 'material-add');
      final lines = await state.repository.materialsOf(data.service);
      expect(lines, hasLength(2));
      await tapKey(tester, 'material-remove-${data.filter}');
      expect([
        for (final m in await state.repository.materialsOf(data.service))
          m.article.name,
      ], isNot(contains('Main filter')));
    });
  }
}
