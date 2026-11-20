// SPDX-License-Identifier: AGPL-3.0-only

// The Stock of an item: the stock items that fit it (their
// `compatible_items`), linked from the item too, after the maintainer's
// report from an iPhone ("I can link a stock item to an item, not the
// reverse"). The link from the item is the same row of
// `stock.article_compatible_items`, with the same id, as the one the stock
// item form writes; a stock item of another home is refused, an archived or
// read-only home writes nothing, the example home writes no operation.
// Widgets in English and French, the words whole at 320 px x2 on Android
// and iOS, goldens at 390 px x1 and x2.

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart' show uuidBytes;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3a.dart';
import 'whole_words_bar_tabs_test.dart' show expectWholeWords;

/// Makes [homeId] a home of a server where the account only reads.
Future<void> _readOnly(Repository r, String homeId) =>
    r.serverState.writeServerState(
      ServerSyncState(
        homes: [
          ServerHome(
            id: homeId,
            name: 'Main home',
            role: 'read_only',
            members: const [],
          ),
        ],
      ).encode(),
    );

/// The live rows of `article_items` between [article] and [item], by id.
Future<List<String>> _links(Repository r, String article, String item) async =>
    [
      for (final row
          in await (r.db.select(r.db.articleItems)..where(
                (l) =>
                    l.articleId.equalsValue(article) &
                    l.itemId.equalsValue(item) &
                    l.deletedAt.isNull(),
              ))
              .get())
        row.id,
    ];

/// The operations written for [homeId].
Future<int> _operations(Repository r, String homeId) async =>
    (await r.db
            .customSelect(
              'SELECT COUNT(*) AS n FROM op_log WHERE home_id = ?',
              variables: [Variable<Uint8List>(uuidBytes(homeId))],
            )
            .getSingle())
        .read<int>('n');

Matcher _refused(Refusal reason) =>
    throwsA(isA<Refused>().having((r) => r.reason, 'reason', reason));

/// Moves the list [list] by [by] pixels, with no fling after it.
void _jump(WidgetTester tester, Finder list, double by) {
  final position = tester.state<ScrollableState>(list).position;
  position.jumpTo(
    (position.pixels + by).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ),
  );
}

/// Scrolls the list of the screen until [finder] shows, clear of the bar at
/// the bottom.
Future<void> _see(WidgetTester tester, Finder finder) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .last;
  // The list is built as it scrolls, its length guessed from what is built:
  // on iOS the bounce back to a guessed end can carry what was found out of
  // the list again, so it is looked for until it stays.
  for (var tries = 0; tries < 4; tries++) {
    for (final delta in [200.0, -200.0]) {
      if (finder.evaluate().isNotEmpty) break;
      try {
        await tester.scrollUntilVisible(
          finder,
          delta,
          scrollable: list,
          maxScrolls: 40,
        );
      } on StateError {
        // Not that way: the other one.
      }
    }
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    if (finder.evaluate().isNotEmpty) break;
  }
  final bottom = tester.getRect(finder.first).bottom;
  final limit = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  if (bottom > limit - 160) {
    _jump(tester, list, bottom - (limit - 160));
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
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  final top = tester.getRect(finder.first).top;
  if (top > 140) {
    _jump(tester, list, top - 140);
    await tester.pumpAndSettle();
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _see(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The item page of the boiler, its Stock in view.
Future<void> _boiler(WidgetTester tester, Lot3a data) async {
  await openScreen(
    tester,
    ItemScreen(homeId: data.main, itemId: data.base.boiler),
  );
  await _see(tester, find.byKey(const Key('item-stock-link')));
}

/// The ids of the stock items that fit [item].
Future<List<String>> _fitting(Repository r, String item) async => [
  for (final e in await r.articlesOfItem(item)) e.article.id,
];

void main() {
  setUpAll(loadAppFonts);

  group('the link from the item (`compatible_items`)', () {
    late Repository r;
    late Lot3a data;
    late String battery;
    setUp(() async {
      r = await openRepository();
      data = await Lot3a.seed(r);
      battery = (await r.articles(data.main))
          .singleWhere((e) => e.article.name == 'Battery 9 V')
          .article
          .id;
    });

    test('linked from the item: the stock items fit it, by name, and the '
        'item is in their Compatible items', () async {
      expect(await _fitting(r, data.base.boiler), [data.filter]);
      await r.linkArticlesToItem(data.base.boiler, [data.paint, battery]);
      expect(
        [
          for (final e in await r.articlesOfItem(data.base.boiler))
            e.article.name,
        ],
        ['Battery 9 V', 'Main filter', 'White paint'],
      );
      for (final a in [data.paint, battery]) {
        expect(
          [for (final i in await r.compatibleItemsOf(a)) i.id],
          [data.base.boiler],
        );
      }
      // Another item's link is its own.
      final kettle = await r.addItem(
        data.base.kitchen,
        const ItemInput(name: 'Kettle'),
      );
      await r.linkArticlesToItem(kettle, [data.paint]);
      expect(await _fitting(r, kettle), [data.paint]);
      await r.unlinkArticleFromItem(data.base.boiler, data.paint);
      expect(
        [
          for (final e in await r.articlesOfItem(data.base.boiler))
            e.article.name,
        ],
        ['Battery 9 V', 'Main filter'],
      );
      expect(await _fitting(r, kettle), [data.paint]);
      // The cellar of the boiler lists them in its Stock.
      expect([
        for (final e in await r.articlesOfRoom(data.base.cellar)) e.article.id,
      ], contains(battery));
    });

    test('the same row, with the same id, as the stock item form writes; '
        'linked twice, still one', () async {
      await r.linkArticlesToItem(data.base.boiler, [battery]);
      final id = StockRepository.articleItemId(
        data.main,
        battery,
        data.base.boiler,
      );
      expect(await _links(r, battery, data.base.boiler), [id]);
      await r.linkArticlesToItem(data.base.boiler, [battery]);
      // The form of the stock item, saved with the item ticked, keeps it.
      await r.updateArticle(
        battery,
        ArticleInput(
          name: 'Battery 9 V',
          unit: 'piece',
          threshold: '2',
          itemIds: [data.base.boiler],
        ),
      );
      expect(await _links(r, battery, data.base.boiler), [id]);
      // Unticked in the form, the item no longer lists it.
      await r.updateArticle(
        battery,
        const ArticleInput(name: 'Battery 9 V', unit: 'piece', threshold: '2'),
      );
      expect(await _fitting(r, data.base.boiler), [data.filter]);
    });

    test('a stock item of another home is refused, and nothing is linked, '
        'not even the ones of the home', () async {
      final elsewhere = await r.addArticle(
        data.base.homes.second,
        const ArticleInput(name: 'Second filter'),
      );
      await expectLater(
        r.linkArticlesToItem(data.base.boiler, [battery, elsewhere]),
        _refused(Refusal.notInHome),
      );
      expect(await _fitting(r, data.base.boiler), [data.filter]);
      expect(await r.compatibleItemsOf(elsewhere), isEmpty);
      // A deleted stock item is not of the home either.
      await r.deleteArticle(battery);
      await expectLater(
        r.linkArticlesToItem(data.base.boiler, [battery]),
        _refused(Refusal.notInHome),
      );
    });

    test('removing a stock item of another home, or a deleted one, is '
        'refused, as linking it is, and nothing changes', () async {
      final elsewhere = await r.addArticle(
        data.base.homes.second,
        const ArticleInput(name: 'Second filter'),
      );
      await expectLater(
        r.unlinkArticleFromItem(data.base.boiler, elsewhere),
        _refused(Refusal.notInHome),
      );
      await r.deleteArticle(battery);
      await expectLater(
        r.unlinkArticleFromItem(data.base.boiler, battery),
        _refused(Refusal.notInHome),
      );
      expect(await _fitting(r, data.base.boiler), [data.filter]);
    });

    test('removed: the link ends, the stock item stays; linked again, the '
        'same row comes back', () async {
      await r.unlinkArticleFromItem(data.base.boiler, data.filter);
      expect(await _fitting(r, data.base.boiler), isEmpty);
      expect(await r.compatibleItemsOf(data.filter), isEmpty);
      expect((await r.article(data.filter))?.name, 'Main filter');
      expect(await r.stockLevel(data.filter), isNotNull);
      await r.linkArticlesToItem(data.base.boiler, [data.filter]);
      expect(await _fitting(r, data.base.boiler), [data.filter]);
      expect(await _links(r, data.filter, data.base.boiler), hasLength(1));
    });

    test('an archived home writes nothing', () async {
      await r.archiveHome(data.main);
      await expectLater(
        r.linkArticlesToItem(data.base.boiler, [battery]),
        _refused(Refusal.homeArchived),
      );
      await expectLater(
        r.unlinkArticleFromItem(data.base.boiler, data.filter),
        _refused(Refusal.homeArchived),
      );
      expect(await _fitting(r, data.base.boiler), [data.filter]);
    });

    test('a read-only member of a server home writes nothing', () async {
      await _readOnly(r, data.main);
      final before = await _operations(r, data.main);
      await expectLater(
        r.linkArticlesToItem(data.base.boiler, [battery]),
        _refused(Refusal.readOnlyHome),
      );
      await expectLater(
        r.unlinkArticleFromItem(data.base.boiler, data.filter),
        _refused(Refusal.readOnlyHome),
      );
      expect(await _fitting(r, data.base.boiler), [data.filter]);
      expect(await _operations(r, data.main), before);
    });

    test('the example home links on the phone and writes no operation, '
        'while a real home does', () async {
      final guide = parseGuide(File('design/guide.json').readAsStringSync());
      final example = await r.createExampleHome(guide);
      final room = await r.createRoom(example, name: 'Cellar');
      final item = await r.addItem(room, const ItemInput(name: 'Boiler'));
      final seal = await r.addArticle(
        example,
        const ArticleInput(name: 'Seal'),
      );
      await r.linkArticlesToItem(item, [seal]);
      expect(await _fitting(r, item), [seal]);
      await r.unlinkArticleFromItem(item, seal);
      expect(await _fitting(r, item), isEmpty);
      expect(await _operations(r, example), 0);
      final before = await _operations(r, data.main);
      await r.linkArticlesToItem(data.base.boiler, [battery]);
      expect(await _operations(r, data.main), greaterThan(before));
    });
  });

  for (final locale in ['en', 'fr']) {
    final m = arbMessages(locale);

    Future<Lot3a> start(
      WidgetTester tester, {
      double width = 360,
      Future<void> Function(Repository, Lot3a)? more,
    }) async {
      await onPhone(tester, width: width);
      late Lot3a data;
      await pumpApp(
        tester,
        locale: locale,
        seed: (r) async {
          data = await Lot3a.seed(r);
          await more?.call(r, data);
        },
      );
      return data;
    }

    group(locale, () {
      testWidgets('the item lists the stock that fits it, with its quantity '
          'and unit price, each opening its page', (tester) async {
        final data = await start(tester);
        await _boiler(tester, data);
        final row = find.byKey(Key('item-article-${data.filter}'));
        expect(row, findsOneWidget);
        final text = tester
            .widgetList<Text>(
              find.descendant(of: row, matching: find.byType(Text)),
            )
            .map((t) => t.data)
            .join(' | ');
        expect(text, contains('Main filter'));
        expect(text, contains(locale == 'en' ? '€12.50 each' : "l'unité"));
        await _tap(tester, row);
        expect(find.byType(ArticleScreen), findsOneWidget);
      });

      testWidgets('Link a stock item…: the others of the home, ticked, fit '
          'the item', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        final elsewhere = await r.addArticle(
          data.base.homes.second,
          const ArticleInput(name: 'Second filter'),
        );
        await _boiler(tester, data);
        await _tap(tester, find.byKey(const Key('item-stock-link')));
        expect(find.byType(ItemStockLinkScreen), findsOneWidget);
        // Not the one that fits already, nor one of another home.
        final choices = find.byKey(const Key('item-stock-choices'));
        expect(
          find.descendant(of: choices, matching: find.text('Main filter')),
          findsNothing,
        );
        expect(find.text('Second filter'), findsNothing);
        expect(find.byKey(Key('item-stock-choice-$elsewhere')), findsNothing);
        await tester.tap(find.byKey(Key('item-stock-choice-${data.paint}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(m['itemStockLinkAction']!).first);
        await tester.pumpAndSettle();
        expect(find.byType(ItemStockLinkScreen), findsNothing);
        expect(await _fitting(r, data.base.boiler), [data.filter, data.paint]);
        await _see(tester, find.byKey(Key('item-article-${data.paint}')));
        expect(find.byKey(Key('item-article-${data.paint}')), findsOneWidget);
      });

      testWidgets('Link with nothing ticked says so and links nothing; with '
          'every stock item fitting, nothing is offered', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        await _boiler(tester, data);
        await _tap(tester, find.byKey(const Key('item-stock-link')));
        await tester.tap(find.text(m['itemStockLinkAction']!).first);
        await tester.pump();
        expect(find.text(m['itemStockNoneTicked']!), findsOneWidget);
        expect(find.byType(ItemStockLinkScreen), findsOneWidget);
        expect(await _fitting(r, data.base.boiler), [data.filter]);
        await r.linkArticlesToItem(data.base.boiler, [
          for (final e in await r.articles(data.main)) e.article.id,
        ]);
        await openScreen(
          tester,
          ItemStockLinkScreen(homeId: data.main, itemId: data.base.boiler),
        );
        expect(find.text(m['itemStockLinkNone']!), findsOneWidget);
        expect(find.text(m['itemStockLinkAction']!), findsNothing);
      });

      testWidgets('New stock item…: the stock item form, the item ticked; '
          'its name required as there', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        final before = (await r.articles(data.main)).length;
        await _boiler(tester, data);
        await _tap(tester, find.byKey(const Key('item-stock-new')));
        expect(find.byType(ArticleFormScreen), findsOneWidget);
        final chip = find.byKey(Key('article-item-${data.base.boiler}'));
        await _see(tester, chip);
        expect(tester.widget<FilterChip>(chip).selected, isTrue);
        // Saved without a name: the form's error, nothing made.
        await tester.tap(find.text(m['save']!).first);
        await tester.pumpAndSettle();
        expect(find.text(m['errTitleRequired']!), findsOneWidget);
        expect((await r.articles(data.main)).length, before);
        await tester.enterText(
          find.byKey(const Key('article-name')),
          'Boiler seal',
        );
        await tester.tap(find.text(m['save']!).first);
        await tester.pumpAndSettle();
        expect(find.byType(ArticleFormScreen), findsNothing);
        final seal = (await r.articles(data.main))
            .singleWhere((e) => e.article.name == 'Boiler seal')
            .article;
        expect(
          [for (final i in await r.compatibleItemsOf(seal.id)) i.id],
          [data.base.boiler],
        );
        expect((await r.articles(data.main)).length, before + 1);
        await _see(tester, find.byKey(Key('item-article-${seal.id}')));
        expect(find.byKey(Key('item-article-${seal.id}')), findsOneWidget);
      });

      testWidgets('New stock item…: it says it will be linked to the item, '
          'and is, even with the item unticked (as the web)', (tester) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        await _boiler(tester, data);
        await _tap(tester, find.byKey(const Key('item-stock-new')));
        expect(
          find.text(m['articleWillLink']!.replaceAll('{name}', 'Main boiler')),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('article-name')),
          'Boiler seal',
        );
        final chip = find.byKey(Key('article-item-${data.base.boiler}'));
        await _tap(tester, chip);
        expect(tester.widget<FilterChip>(chip).selected, isFalse);
        await tester.tap(find.text(m['save']!).first);
        await tester.pumpAndSettle();
        expect(find.byType(ArticleFormScreen), findsNothing);
        final seal = (await r.articles(data.main))
            .singleWhere((e) => e.article.name == 'Boiler seal')
            .article;
        expect(
          [for (final i in await r.compatibleItemsOf(seal.id)) i.id],
          [data.base.boiler],
        );
      });

      testWidgets('New stock item for an item of another home: refused on '
          'save, as the web\'s 404, and nothing is made', (tester) async {
        late String other;
        final data = await start(
          tester,
          more: (r, data) async {
            final room = await r.createRoom(
              data.base.homes.second,
              name: 'Garage',
            );
            other = await r.addItem(room, const ItemInput(name: 'Freezer'));
          },
        );
        final r = stateOf(tester).repository;
        final before = (await r.articles(data.main)).length;
        final beforeSecond = (await r.articles(data.base.homes.second)).length;
        await openScreen(
          tester,
          ArticleFormScreen(homeId: data.main, fitsItemId: other),
        );
        expect(find.byKey(const Key('article-will-link')), findsNothing);
        await tester.enterText(
          find.byKey(const Key('article-name')),
          'Freezer seal',
        );
        await tester.tap(find.text(m['save']!).first);
        await tester.pumpAndSettle();
        expect(find.text(m['errNotInHome']!), findsOneWidget);
        expect(find.byType(ArticleFormScreen), findsOneWidget);
        expect((await r.articles(data.main)).length, before);
        expect((await r.articles(data.base.homes.second)).length, beforeSecond);
      });

      testWidgets('Remove: the link ends, the stock item stays', (
        tester,
      ) async {
        final data = await start(tester);
        final r = stateOf(tester).repository;
        await _boiler(tester, data);
        await _tap(
          tester,
          find.byKey(Key('item-article-remove-${data.filter}')),
        );
        expect(find.byKey(Key('item-article-${data.filter}')), findsNothing);
        expect(find.text(m['itemMaterials']!.toUpperCase()), findsOneWidget);
        expect(find.text(m['itemStockEmpty']!), findsOneWidget);
        expect(await r.compatibleItemsOf(data.filter), isEmpty);
        expect((await r.article(data.filter))?.name, 'Main filter');
      });

      testWidgets('an archived home: the stock is shown, nothing to link, '
          'add or remove', (tester) async {
        final data = await start(
          tester,
          more: (r, data) => r.archiveHome(data.main),
        );
        await openScreen(
          tester,
          ItemScreen(homeId: data.main, itemId: data.base.boiler),
        );
        await _see(tester, find.byKey(Key('item-article-${data.filter}')));
        expect(find.byKey(Key('item-article-${data.filter}')), findsOneWidget);
        expect(find.byKey(const Key('item-stock-link')), findsNothing);
        expect(find.byKey(const Key('item-stock-new')), findsNothing);
        expect(
          find.byKey(Key('item-article-remove-${data.filter}')),
          findsNothing,
        );
      });

      testWidgets('a read-only server home: Link says why and links '
          'nothing', (tester) async {
        final data = await start(
          tester,
          more: (r, data) => _readOnly(r, data.main),
        );
        final r = stateOf(tester).repository;
        await _boiler(tester, data);
        await _tap(tester, find.byKey(const Key('item-stock-link')));
        await tester.tap(find.byKey(Key('item-stock-choice-${data.paint}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(m['itemStockLinkAction']!).first);
        await tester.pumpAndSettle();
        expect(find.text(m['errReadOnlyHome']!), findsOneWidget);
        expect(await _fitting(r, data.base.boiler), [data.filter]);
      });

      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        final name = '${platform.name.toLowerCase()}, $locale';
        testWidgets('320 px x2, $name: no word cut in the Stock of the item, '
            'its buttons and the choices of Link', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          // An item with its name only: its Stock is in the first screens
          // (the long card of the boiler, at twice the size, is measured
          // elsewhere).
          late String tap;
          final data = await start(
            tester,
            width: 320,
            more: (r, data) async {
              tap = await r.addItem(
                data.base.cellar,
                const ItemInput(name: 'Water heater'),
              );
              await r.linkArticlesToItem(tap, [data.filter]);
            },
          );
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await openScreen(tester, ItemScreen(homeId: data.main, itemId: tap));
          expect(tester.takeException(), isNull);
          await _see(tester, find.byKey(const Key('item-stock')));
          expectWholeWords(
            tester,
            find.byKey(const Key('item-stock')),
            'the stock, $name',
          );
          for (final key in ['item-stock-link', 'item-stock-new']) {
            await _see(tester, find.byKey(Key(key)));
            expectWholeWords(tester, find.byKey(Key(key)), '$key, $name');
          }
          await _tap(tester, find.byKey(const Key('item-stock-link')));
          expect(tester.takeException(), isNull);
          expectWholeWords(
            tester,
            find.byKey(const Key('item-stock-choices')),
            'the choices, $name',
          );
          expectWholeWords(
            tester,
            find.text(m['itemStockLinkIntro']!),
            'the intro, $name',
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 10));
        });
      }
    });
  }

  group('goldens', () {
    setUpAll(useTolerantGoldens);
    for (final locale in ['en', 'fr']) {
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

        testWidgets('item_stock, $name', (tester) async {
          final data = await start(tester);
          await openScreen(
            tester,
            ItemScreen(homeId: data.main, itemId: data.base.boiler),
          );
          await _top(tester, find.byKey(Key('item-article-${data.filter}')));
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/item_stock_$name.png'),
          );
        });

        testWidgets('item_stock_link, $name', (tester) async {
          final data = await start(tester);
          await openScreen(
            tester,
            ItemStockLinkScreen(homeId: data.main, itemId: data.base.boiler),
          );
          await tester.tap(find.byKey(Key('item-stock-choice-${data.paint}')));
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/item_stock_link_$name.png'),
          );
        });
      }
    }
  });
}
