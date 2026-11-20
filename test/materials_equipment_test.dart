// SPDX-License-Identifier: AGPL-3.0-only

// A stock item linked to an item of equipment, the three ways the web v0.5.1
// has: the Compatible items of the stock item's form, grouped by room
// (`stock/forms.py` `ItemChoiceField`); a stock item added from the
// Materials of a task, which fits the equipment of the task
// (`tasks/views.py` `save_materials`); and the Stock section of a room,
// which lists what fits its equipment (`stock/services.py`
// `articles_of_room`). Goldens at 390 px x1 and x2, and the words whole at
// 320 px x2, in English and in French.

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:housecairn_mobile/ui/task_form_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3a.dart';
import 'whole_words_bar_tabs_test.dart' show expectWholeWords;

/// Scrolls the list of the screen until [finder] shows, then a little more,
/// so that the bar at the bottom does not cover it.
Future<void> _see(WidgetTester tester, Finder finder) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .last;
  await tester.scrollUntilVisible(finder, 200, scrollable: list);
  await tester.pumpAndSettle();
  final bottom = tester.getRect(finder.first).bottom;
  final limit = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  if (bottom > limit - 160) {
    await tester.drag(list, Offset(0, limit - 160 - bottom));
    await tester.pumpAndSettle();
  }
}

/// Scrolls the list of the screen until [finder] is near its top.
Future<void> _top(WidgetTester tester, Finder finder) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .last;
  await tester.scrollUntilVisible(finder, 200, scrollable: list);
  await tester.pumpAndSettle();
  final top = tester.getRect(finder.first).top;
  if (top > 140) {
    await tester.drag(list, Offset(0, 140 - top));
    await tester.pumpAndSettle();
  }
}

/// Picks [text] in the list of the field of key [key].
Future<void> _choose(WidgetTester tester, String key, String text) async {
  await _see(tester, find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// The form of the boiler service, a second line of materials on *Add a
/// stock item…*, its name typed.
Future<void> _addStockItemLine(
  WidgetTester tester,
  Lot3a data,
  Map<String, String> m, {
  String name = 'Boiler seal',
}) async {
  await openScreen(
    tester,
    TaskFormScreen(homeId: data.main, taskId: data.service),
  );
  await _see(tester, find.byKey(const Key('task-material-add')));
  await tester.tap(find.byKey(const Key('task-material-add')));
  await tester.pumpAndSettle();
  await _choose(tester, 'task-material-article-1', m['materialAddArticle']!);
  await _see(tester, find.byKey(const Key('task-material-new-name-1')));
  await tester.enterText(
    find.byKey(const Key('task-material-new-name-1')),
    name,
  );
  await tester.pumpAndSettle();
}

void main() {
  // The real fonts, for the words measured at 320 px and the goldens.
  setUpAll(loadAppFonts);

  group('the rule of the room (`articles_of_room`)', () {
    late Repository r;
    late Lot3a data;
    setUp(() async {
      r = await openRepository();
      data = await Lot3a.seed(r);
    });

    Future<List<String>> namesIn(String room) async => [
      for (final e in await r.articlesOfRoom(room)) e.article.name,
    ];

    test('kept there, fitting one of its items, or its paint left over; '
        'by name', () async {
      final seal = await r.addArticle(
        data.main,
        ArticleInput(name: 'Boiler seal', itemIds: [data.base.boiler]),
      );
      expect(await namesIn(data.base.cellar), ['Boiler seal', 'Main filter']);
      expect(await namesIn(data.base.kitchen), ['White paint']);
      final tin = await r.addArticle(
        data.main,
        const ArticleInput(name: 'Blue paint'),
      );
      await r.setPaintArticle(data.base.kitchen, tin);
      expect(await namesIn(data.base.kitchen), ['Blue paint', 'White paint']);
      await r.deleteArticle(seal);
      expect(await namesIn(data.base.cellar), ['Main filter']);
    });

    test(
      'an item deleted no longer brings its stock items to the room',
      () async {
        await r.updateArticle(
          data.filter,
          ArticleInput(name: 'Main filter', itemIds: [data.base.boiler]),
        );
        expect(await namesIn(data.base.cellar), ['Main filter']);
        await r.deleteItem(data.base.boiler);
        expect(await namesIn(data.base.cellar), isEmpty);
      },
    );

    test(
      'the compatible items of a stock item, by room then by name',
      () async {
        final kettle = await r.addItem(
          data.base.kitchen,
          const ItemInput(name: 'Kettle'),
        );
        final aerator = await r.addItem(
          data.base.kitchen,
          const ItemInput(name: 'Aerator'),
        );
        await r.updateArticle(
          data.filter,
          ArticleInput(
            name: 'Main filter',
            itemIds: [kettle, data.base.boiler, aerator],
          ),
        );
        final rooms = {
          for (final room in await r.rooms(data.main)) room.id: room.name,
        };
        expect(
          [
            for (final i in await r.compatibleItemsOf(data.filter))
              '${rooms[i.roomId]}: ${i.name}',
          ],
          [
            'Main cellar: Main boiler',
            'Main kitchen: Aerator',
            'Main kitchen: Kettle',
          ],
        );
      },
    );
  });

  for (final locale in ['en', 'fr']) {
    final m = arbMessages(locale);

    Future<Lot3a> start(WidgetTester tester, {double width = 360}) async {
      await onPhone(tester, width: width);
      late Lot3a data;
      await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot3a.seed(r),
      );
      return data;
    }

    group(locale, () {
      testWidgets('a stock item added from the materials of a task joins the '
          'stock, fitting the equipment of the task', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        final before = (await r.articles(data.main)).length;
        await _addStockItemLine(tester, data, m);
        // The sheet of the task no longer saves itself: nothing is written
        // and no field is flagged until Save.
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(find.text(m['errNewArticleName']!), findsNothing);
        expect((await r.articles(data.main)).length, before);
        expect(
          find.text(m['materialNewArticle']!.toUpperCase()),
          findsOneWidget,
        );
        expect(find.text(m['materialNewArticleHelp']!), findsOneWidget);
        await _choose(
          tester,
          'task-material-new-unit-1',
          m['unitPieceChoice']!,
        );
        await saveTask(tester);
        final seal = (await r.articles(data.main))
            .singleWhere((e) => e.article.name == 'Boiler seal')
            .article;
        expect(seal.unit, 'piece');
        expect(
          [for (final i in await r.compatibleItemsOf(seal.id)) i.id],
          [data.base.boiler],
        );
        final lines = await r.materialsOf(data.service);
        expect(
          {for (final l in lines) l.article.name: l.quantity.toString()},
          {'Main filter': '1', 'Boiler seal': '1'},
        );
      });

      testWidgets('a new task with a new item: the stock item added fits '
          'that item', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        await openScreen(
          tester,
          TaskFormScreen(homeId: data.main, roomId: data.base.cellar),
        );
        await tester.enterText(find.byKey(const Key('task-title')), 'Bleed');
        await _choose(tester, 'task-item', m['taskAddItem']!);
        await tester.enterText(
          find.byKey(const Key('task-new-item-name')),
          'Radiator',
        );
        await unfoldTaskSection(tester, 'task-section-materials');
        await _choose(
          tester,
          'task-material-article-0',
          m['materialAddArticle']!,
        );
        await _see(tester, find.byKey(const Key('task-material-new-name-0')));
        await tester.enterText(
          find.byKey(const Key('task-material-new-name-0')),
          'Bleed key',
        );
        await saveTask(tester);
        final radiator = (await r.itemsOf(data.base.cellar))
            .singleWhere((i) => i.name == 'Radiator');
        final key = (await r.articles(data.main))
            .singleWhere((e) => e.article.name == 'Bleed key')
            .article;
        expect(
          [for (final i in await r.compatibleItemsOf(key.id)) i.id],
          [radiator.id],
        );
      });

      testWidgets('the name of the new stock item: required, not one of the '
          'stock whatever its case, not added twice', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        final before = (await r.articles(data.main)).length;
        await _addStockItemLine(tester, data, m, name: '  ');
        await saveTask(tester);
        expect(find.text(m['errNewArticleName']!), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('task-material-new-name-1')),
          'main  FILTER',
        );
        await saveTask(tester);
        expect(
          find.text(
            m['errNewArticleInStock']!.replaceAll('{name}', 'main FILTER'),
          ),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('task-material-new-name-1')),
          'Seal',
        );
        await _see(tester, find.byKey(const Key('task-material-add')));
        await tester.tap(find.byKey(const Key('task-material-add')));
        await tester.pumpAndSettle();
        await _choose(
          tester,
          'task-material-article-2',
          m['materialAddArticle']!,
        );
        await _see(tester, find.byKey(const Key('task-material-new-name-2')));
        await tester.enterText(
          find.byKey(const Key('task-material-new-name-2')),
          'seal',
        );
        await saveTask(tester);
        expect(
          find.text(m['errNewArticleTwice']!.replaceAll('{name}', 'seal')),
          findsOneWidget,
        );
        expect((await r.articles(data.main)).length, before, reason: 'none');
      });

      testWidgets('the unit Other of the new stock item says which', (
        tester,
      ) async {
        final data = await start(tester);
        await _addStockItemLine(tester, data, m);
        await _choose(
          tester,
          'task-material-new-unit-1',
          m['unitOtherChoice']!,
        );
        await saveTask(tester);
        expect(find.text(m['errUnitOther']!), findsOneWidget);
      });

      testWidgets('the room lists its stock: what fits its equipment, '
          'or nothing yet', (tester) async {
        final data = await start(tester);
        await openScreen(
          tester,
          RoomScreen(homeId: data.main, roomId: data.base.cellar),
        );
        final stockList = find.byKey(const Key('room-stock'));
        expect(
          find.descendant(of: stockList, matching: find.text('Main filter')),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(of: stockList, matching: find.text('Main filter')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ArticleScreen), findsOneWidget);
        // The room of the compatible item under its name, as on the web.
        await _see(tester, find.text('Main boiler'));
        expect(find.text('Main cellar'), findsWidgets);
        final repository = stateOf(tester).repository;
        final empty = await repository.createRoom(data.main, name: 'Attic');
        await openScreen(tester, RoomScreen(homeId: data.main, roomId: empty));
        expect(find.text(m['roomStockEmpty']!), findsOneWidget);
      });

      testWidgets('the compatible items of the stock item form, under the '
          'name of their room', (tester) async {
        final data = await start(tester);
        await openScreen(
          tester,
          ArticleFormScreen(homeId: data.main, articleId: data.filter),
        );
        final boiler = find.byKey(Key('article-item-${data.base.boiler}'));
        await _see(tester, boiler);
        final chip = tester.getRect(boiler);
        final room = tester.getRect(find.text('Main cellar').first);
        expect(room.bottom, lessThanOrEqualTo(chip.top), reason: 'room above');
        expect(tester.widget<FilterChip>(boiler).selected, isTrue);
      });

      testWidgets('320 px x2: no word cut in the stock of a room nor in the '
          'fields of a new stock item', (tester) async {
        final data = await start(tester, width: 320);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        await openScreen(
          tester,
          RoomScreen(homeId: data.main, roomId: data.base.cellar),
        );
        await _see(tester, find.byKey(const Key('room-stock')));
        expectWholeWords(tester, find.byKey(const Key('room-stock')), 'stock');
        await _addStockItemLine(tester, data, m);
        for (final (key, upper) in [
          ('materialNewArticle', true),
          ('materialNewArticleName', false),
          ('materialAddArticle', false),
        ]) {
          final text = find.text(upper ? m[key]!.toUpperCase() : m[key]!);
          await _see(tester, text.last);
          expectWholeWords(tester, text.last, key);
        }
      });
    });
  }

  group('goldens', () {
    setUpAll(useTolerantGoldens);
    for (final locale in ['en', 'fr']) {
      final m = arbMessages(locale);
      for (final scale in [1.0, 2.0]) {
        final name = '${locale}_x${scale.toInt()}';
        Future<Lot3a> start(WidgetTester tester) async {
          await onPhone(tester, width: 390, height: 844, textScale: scale);
          late Lot3a data;
          await pumpApp(
            tester,
            locale: locale,
            seed: (r) async => data = await Lot3a.seed(r),
          );
          return data;
        }

        testWidgets('room_stock, $name', (tester) async {
          final data = await start(tester);
          await openScreen(
            tester,
            RoomScreen(homeId: data.main, roomId: data.base.cellar),
          );
          await _top(tester, find.text(m['stock']!.toUpperCase()));
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/room_stock_$name.png'),
          );
        });

        testWidgets('task_form_new_stock_item, $name', (tester) async {
          final data = await start(tester);
          await _addStockItemLine(tester, data, m);
          await _top(tester, find.text(m['materialNewArticle']!.toUpperCase()));
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/task_form_new_stock_item_$name.png'),
          );
        });
      }
    }
  });
}
