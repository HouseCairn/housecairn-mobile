// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'lot2b.dart';
import 'screens_2b.dart';

/// The data of the screens of lot 3a: the homes of lot 2b, whose fixture
/// gives each home a filter with a supplier and two movements
/// (test/support/fixture.dart), and in the main home two articles more and
/// the filter needed by the boiler's service. Neutral names only.
class Lot3a {
  late Lot2b base;
  late String filter;
  late String shop;
  late String paint;
  late String service;

  String get main => base.homes.main;

  static Future<Lot3a> seed(Repository r) async {
    final data = Lot3a()..base = await Lot2b.seed(r);
    final main = data.main;
    data.filter = (await r.articles(main)).single.article.id;
    await r.updateArticle(
      data.filter,
      ArticleInput(
        name: 'Main filter',
        manufacturerReference: 'F-100',
        dimensions: '20 x 25 cm',
        storageLocation: 'Cellar, second shelf',
        unit: 'piece',
        threshold: '2',
        unitPrice: '12.50',
        roomIds: [data.base.cellar],
        itemIds: [data.base.boiler],
      ),
    );
    data.shop = (await r.suppliersOf(data.filter)).single.id;
    await r.updateSupplier(
      data.shop,
      const SupplierInput(
        name: 'Main shop',
        reference: 'EX-42',
        url: 'https://example.com/filter',
        lastPrice: '11.90',
      ),
    );
    data.paint = await r.addArticle(
      main,
      ArticleInput(
        name: 'White paint',
        unit: 'litre',
        storageLocation: 'Garage',
        roomIds: [data.base.kitchen],
      ),
    );
    await r.recordMovement(data.paint, kind: 'entry', quantity: '2.5');
    final battery = await r.addArticle(
      main,
      const ArticleInput(name: 'Battery 9 V', unit: 'piece', threshold: '2'),
    );
    await r.recordMovement(battery, kind: 'entry', quantity: '4');
    await r.recordMovement(
      battery,
      kind: 'inventory',
      quantity: '3',
      note: 'Counted in the drawer',
    );
    data.service = (await r.db.select(r.db.tasks).get())
        .firstWhere((t) => t.title == 'Service the boiler')
        .id;
    await r.saveMaterial(data.service, data.filter, '1');
    return data;
  }
}

/// The screens of lot 3a, each opened as the app opens it. `page` is the
/// name of the golden file.
final screens3a =
    <(String page, Future<void> Function(WidgetTester, Lot3a, Labels))>[
      (
        'stock',
        (tester, data, l) async {
          await openRooms(tester, l.rooms);
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('rooms-tabs')),
              matching: find.text(l.stock),
            ),
          );
          await tester.pumpAndSettle();
        },
      ),
      (
        'article',
        (tester, data, l) => openScreen(
          tester,
          ArticleScreen(homeId: data.main, articleId: data.filter),
        ),
      ),
      (
        'article_form',
        (tester, data, l) => openScreen(
          tester,
          ArticleFormScreen(homeId: data.main, articleId: data.filter),
        ),
      ),
      (
        'supplier_form',
        (tester, data, l) => openScreen(
          tester,
          SupplierFormScreen(
            homeId: data.main,
            articleId: data.filter,
            supplierId: data.shop,
          ),
        ),
      ),
      (
        'task_materials',
        (tester, data, l) async {
          await openScreen(
            tester,
            TaskScreen(homeId: data.main, taskId: data.service),
          );
          final heading = find.text(l.materials);
          await tester.scrollUntilVisible(
            heading,
            300,
            scrollable: find
                .byWidgetPredicate(
                  (w) =>
                      w is Scrollable && w.axisDirection == AxisDirection.down,
                )
                .hitTestable()
                .last,
          );
          await tester.pumpAndSettle();
        },
      ),
    ];
