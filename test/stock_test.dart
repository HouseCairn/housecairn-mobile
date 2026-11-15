// SPDX-License-Identifier: AGPL-3.0-only

// The stock of lot 3a (docs/plan.md, lot 3): the rules of the web
// (`stock/services.py`, `tasks/materials.py`) on two homes in two currencies,
// EUR and CHF (test/support/fixture.dart, TwoHomes).

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/stock.dart';
import 'package:housecairn_mobile/ui/stock_format.dart';

import 'support/fixture.dart';

Decimal d(String text) => Decimal.parse(text);

Matcher refused(Refusal reason) =>
    throwsA(isA<Refused>().having((r) => r.reason, 'reason', reason));

void main() {
  group('rules of the ledger', () {
    test('the stock is the sum of the effects of the movements', () {
      final lines = [
        LedgerLine(entryKind, d('3')),
        LedgerLine(exitKind, d('1')),
        LedgerLine(entryKind, d('0.5')),
      ];
      expect(effectsOf(lines), [d('3'), d('-1'), d('0.5')]);
      expect(levelOf(lines), d('2.5'));
    });

    test('an inventory sets the stock: its effect is the count minus the '
        'stock before it', () {
      final lines = [
        LedgerLine(entryKind, d('3')),
        LedgerLine(inventoryKind, d('5')),
        LedgerLine(exitKind, d('2')),
        LedgerLine(inventoryKind, d('1')),
      ];
      expect(effectsOf(lines), [d('3'), d('2'), d('-2'), d('-2')]);
      expect(levelOf(lines), d('1'));
      // The same count after other lines has another effect: it is
      // recomputed from the lines before it, never stored.
      final moved = [lines[0], lines[2], lines[1], lines[3]];
      expect(effectsOf(moved), [d('3'), d('-2'), d('4'), d('-4')]);
      expect(levelOf(moved), d('1'));
    });

    test('a draw never takes more than wanted, nor below zero', () {
      expect(drawable(d('2'), d('5')), d('2'));
      expect(drawable(d('2'), d('1')), d('1'));
      expect(drawable(d('2'), d('-3')), d('0'));
      expect(drawable(d('0'), d('3')), d('0'));
      final random = Random(7);
      for (var i = 0; i < 500; i++) {
        final wanted = Decimal.fromInt(random.nextInt(2000)) / Decimal.ten;
        final stock =
            Decimal.fromInt(random.nextInt(4000) - 2000) / Decimal.ten;
        final taken = drawable(wanted.toDecimal(), stock.toDecimal());
        expect(taken <= wanted.toDecimal(), isTrue);
        expect(taken >= Decimal.zero, isTrue);
      }
    });

    test('quantities are those of the model: two decimals, below 10^8', () {
      expect(parseQuantity('2'), d('2'));
      expect(parseQuantity('2,5'), d('2.5'));
      expect(parseQuantity(' 12.50 '), d('12.5'));
      for (final bad in ['', 'x', '1.234', '-1', '123456789', '1e3']) {
        expect(parseQuantity(bad), isNull, reason: bad);
      }
      expect(storedQuantity(d('2.5')), '2.50');
      expect(plain(d('3.00')), '3');
      expect(plain(d('0.50')), '0.5');
    });

    test('the plural of a unit follows the web (`unit_text`)', () {
      expect(pluralCount(d('1')), 1);
      expect(pluralCount(d('2')), 2);
      expect(pluralCount(d('0.5')), 0);
      expect(pluralCount(d('2.5')), 2);
    });
  });

  group('amounts in the currency of their home, never through double', () {
    test('EUR and CHF, in English and French', () {
      expect(formatMoney('en', 'EUR', d('12.5')), '€12.50');
      expect(formatMoney('en', 'CHF', d('9.9')), 'CHF\u00a09.90');
      expect(formatMoney('fr', 'EUR', d('1234.05')), '1\u202f234,05\u00a0€');
      expect(formatMoney('fr', 'CHF', d('0.1')), '0,10\u00a0CHF');
    });

    test('a quantity with two decimals keeps them, a whole one has none', () {
      expect(formatQuantity('fr', d('2.5')), '2,50');
      expect(formatQuantity('en', d('3')), '3');
      expect(formatQuantity('en', d('-2')), '-2');
    });

    test('an amount far beyond a double keeps its last cent', () {
      // 2^53 + 1 cents: a double cannot hold it.
      expect(
        formatMoney('en', 'EUR', d('90071992547409.93')),
        '€90,071,992,547,409.93',
      );
    });
  });

  group('the stock of two homes, EUR and CHF', () {
    late Repository repo;
    late TwoHomes homes;

    setUp(() async {
      repo = await openRepository();
      homes = await TwoHomes.create(repo);
    });

    Future<String> articleOf(String home) async =>
        (await repo.articles(home)).single.article.id;

    test('each home has its own articles, stock and prices', () async {
      final main = (await repo.articles(homes.main)).single;
      final second = (await repo.articles(homes.second)).single;
      expect(main.article.name, 'Main filter');
      expect(second.article.name, 'Second filter');
      expect(main.level, d('2'));
      expect(second.level, d('2'));
      // A movement in one home changes nothing in the other.
      await repo.recordMovement(
        second.article.id,
        kind: entryKind,
        quantity: '5',
      );
      expect(await repo.stockLevel(main.article.id), d('2'));
      expect(await repo.stockLevel(second.article.id), d('7'));
      final currencies = {for (final h in await repo.homes()) h.id: h.currency};
      expect(currencies[homes.main], 'EUR');
      expect(currencies[homes.second], 'CHF');
    });

    test(
      'the stock is the sum of the movements, read back from the rows',
      () async {
        for (final home in [homes.main, homes.second]) {
          final article = await articleOf(home);
          await repo.recordMovement(article, kind: entryKind, quantity: '0.5');
          await repo.recordMovement(
            article,
            kind: inventoryKind,
            quantity: '4',
          );
          await repo.recordMovement(article, kind: exitKind, quantity: '1.25');
          final movements = await repo.movementsOf(article);
          final sum = movements.fold(Decimal.zero, (s, m) => s + m.effect);
          expect(await repo.stockLevel(article), sum);
          expect(sum, d('2.75'));
          final inventory = movements.firstWhere(
            (m) => m.movement.kind == inventoryKind,
          );
          // 3 in, 1 out, 0.5 in: 2.5 before the count of 4.
          expect(inventory.effect, d('1.5'));
          expect(inventory.quantity, d('4'));
        }
      },
    );

    test('no effect of a movement is stored: the table has no delta', () async {
      final columns = repo.db.movements.$columns.map((c) => c.$name).toSet();
      expect(columns.contains('delta'), isFalse);
      expect(columns, containsAll(['kind', 'quantity', 'occurred_on']));
    });

    test(
      'an exit of more than the stock is refused and says how much there '
      'is; an inventory may count zero; an entry needs more than zero',
      () async {
        final article = await articleOf(homes.second);
        await expectLater(
          repo.recordMovement(article, kind: exitKind, quantity: '3'),
          throwsA(
            isA<Refused>()
                .having((r) => r.reason, 'reason', Refusal.stockShort)
                .having((r) => r.available, 'available', d('2')),
          ),
        );
        await expectLater(
          repo.recordMovement(article, kind: entryKind, quantity: '0'),
          refused(Refusal.quantityNotPositive),
        );
        await expectLater(
          repo.recordMovement(article, kind: entryKind, quantity: '1.234'),
          refused(Refusal.quantityInvalid),
        );
        await repo.recordMovement(article, kind: inventoryKind, quantity: '0');
        expect(await repo.stockLevel(article), Decimal.zero);
      },
    );

    test('done takes the materials, never more than wanted, and undo puts '
        'them back by entries', () async {
      for (final home in [homes.main, homes.second]) {
        final article = await articleOf(home);
        final prefix = home == homes.main ? 'Main' : 'Second';
        final task = (await repo.db.select(repo.db.tasks).get()).firstWhere(
          (t) => t.title == '$prefix gutters',
        );
        await repo.saveMaterial(task.id, article, '3');
        final occurrence = (await repo.openOccurrencesOf(task.id)).single;
        final closing = await repo.complete(occurrence.id);
        // 2 in stock, 3 wanted: 2 taken, 1 short; the closing is not refused.
        expect(await repo.stockLevel(article), Decimal.zero);
        expect(closing.short.single.missing, d('1'));
        final draw = (await repo.drawsOf(occurrence.id)).single.$1;
        expect(readQuantity(draw.wanted), d('3'));
        expect(readQuantity(draw.drawn), d('2'));
        await repo.undo(occurrence.id);
        expect(await repo.stockLevel(article), d('2'));
        expect(await repo.drawsOf(occurrence.id), isEmpty);
        final kinds = [
          for (final m in await repo.movementsOf(article)) m.movement.kind,
        ];
        // Nothing erased: the exit of the closing and the entry of the undo.
        expect(kinds.where((k) => k == exitKind), hasLength(2));
        expect(kinds.where((k) => k == entryKind), hasLength(2));
        // Done again: the draw of the same id comes back.
        await repo.complete(occurrence.id);
        expect(await repo.drawsOf(occurrence.id), hasLength(1));
        expect(await repo.stockLevel(article), Decimal.zero);
      }
    });

    test('a skip takes nothing from the stock', () async {
      final article = await articleOf(homes.main);
      final task = (await repo.db.select(repo.db.tasks).get()).firstWhere(
        (t) => t.title == 'Main gutters',
      );
      await repo.skip((await repo.openOccurrencesOf(task.id)).single.id);
      expect(await repo.stockLevel(article), d('2'));
    });

    test('a material is of an article of the same home, listed once, more '
        'than zero', () async {
      final mainArticle = await articleOf(homes.main);
      final secondArticle = await articleOf(homes.second);
      final task = (await repo.db.select(repo.db.tasks).get()).firstWhere(
        (t) => t.title == 'Main smoke alarm',
      );
      await expectLater(
        repo.saveMaterial(task.id, secondArticle, '1'),
        refused(Refusal.notInHome),
      );
      await expectLater(
        repo.saveMaterial(task.id, mainArticle, '0'),
        refused(Refusal.quantityNotPositive),
      );
      await repo.addMaterial(task.id, mainArticle, '1');
      await expectLater(
        repo.addMaterial(task.id, mainArticle, '2'),
        refused(Refusal.materialListed),
      );
      await repo.saveMaterial(task.id, mainArticle, '2');
      final lines = await repo.materialsOf(task.id);
      expect(lines.single.quantity, d('2'));
      expect(
        lines.single.line.id,
        StockRepository.materialId(homes.main, task.id, mainArticle),
      );
      await repo.removeMaterial(task.id, mainArticle);
      expect(await repo.materialsOf(task.id), isEmpty);
    });

    test(
      'a supplier\'s last price fills an empty unit price, never a typed one',
      () async {
        final id = await repo.addArticle(
          homes.second,
          const ArticleInput(name: 'Second tape', unit: 'roll'),
        );
        await repo.addSupplier(
          id,
          const SupplierInput(name: 'Example shop', lastPrice: '4.20'),
        );
        expect((await repo.article(id))!.unitPrice, '4.20');
        final supplier = (await repo.suppliersOf(id)).single;
        await repo.updateSupplier(
          supplier.id,
          const SupplierInput(name: 'Example shop', lastPrice: '5'),
        );
        expect((await repo.article(id))!.unitPrice, '4.20');
      },
    );

    test(
      'search by name, reference or supplier, and the low ones only',
      () async {
        await repo.addArticle(
          homes.main,
          const ArticleInput(name: 'Main tape', manufacturerReference: 'T-9'),
        );
        expect(
          [
            for (final e in await repo.articles(homes.main, query: 't-9'))
              e.article.name,
          ],
          ['Main tape'],
        );
        expect(
          [
            for (final e in await repo.articles(homes.main, query: 'main shop'))
              e.article.name,
          ],
          ['Main filter'],
        );
        expect(await repo.articles(homes.main, low: true), isEmpty);
        final filter = await articleOf(homes.second);
        await repo.recordMovement(filter, kind: exitKind, quantity: '1');
        expect(
          [
            for (final e in await repo.articles(homes.second, low: true))
              e.article.name,
          ],
          ['Second filter'],
        );
      },
    );

    test(
      'an article\'s rooms and items are of its home; Other needs its word',
      () async {
        final filter = await articleOf(homes.main);
        final otherRoom = (await repo.rooms(homes.second)).first.id;
        await expectLater(
          repo.addArticle(
            homes.main,
            ArticleInput(name: 'Main glue', roomIds: [otherRoom]),
          ),
          refused(Refusal.notInHome),
        );
        await expectLater(
          repo.addArticle(
            homes.main,
            const ArticleInput(name: 'Main glue', unit: 'other'),
          ),
          refused(Refusal.unitOtherRequired),
        );
        final id = await repo.addArticle(
          homes.main,
          const ArticleInput(
            name: 'Main glue',
            unit: 'other',
            unitOther: ' tube  of 20 g ',
          ),
        );
        expect((await repo.article(id))!.unitOther, 'tube of 20 g');
        expect(
          [for (final r in await repo.roomsOfArticle(filter)) r.name],
          ['Main cellar'],
        );
        expect(
          [for (final i in await repo.compatibleItemsOf(filter)) i.name],
          ['Main boiler'],
        );
        expect(
          [for (final t in await repo.tasksUsing(filter)) t.title],
          ['Main gutters'],
        );
      },
    );

    test(
      'deleting an article removes it with its suppliers and movements',
      () async {
        final filter = await articleOf(homes.main);
        await repo.deleteArticle(filter);
        expect(await repo.articles(homes.main), isEmpty);
        expect(await repo.movementsOf(filter), isEmpty);
        expect(await repo.suppliersOf(filter), isEmpty);
        expect((await repo.articles(homes.second)), hasLength(1));
      },
    );

    test('property: any sequence of movements, closings and undos over two '
        'homes keeps every draw within wanted and the stock the sum of the '
        'movements', () async {
      final random = Random(42);
      final articles = {
        for (final h in [homes.main, homes.second]) h: await articleOf(h),
      };
      final tasks = <String, String>{};
      for (final t in await repo.db.select(repo.db.tasks).get()) {
        if (t.title.endsWith('gutters')) tasks[t.homeId] = t.id;
      }
      for (var step = 0; step < 120; step++) {
        final home = random.nextBool() ? homes.main : homes.second;
        final article = articles[home]!;
        final task = tasks[home]!;
        final quantity = '${random.nextInt(4)}.${random.nextInt(10)}';
        try {
          switch (random.nextInt(6)) {
            case 0:
              await repo.recordMovement(
                article,
                kind: entryKind,
                quantity: quantity,
              );
            case 1:
              await repo.recordMovement(
                article,
                kind: exitKind,
                quantity: quantity,
              );
            case 2:
              await repo.recordMovement(
                article,
                kind: inventoryKind,
                quantity: quantity,
              );
            case 3:
              await repo.saveMaterial(task, article, quantity);
            case 4:
              final open = await repo.openOccurrencesOf(task);
              if (open.isNotEmpty) await repo.complete(open.single.id);
            default:
              final done = (await repo.occurrencesOf(task))
                  .where((o) => o.status == 'done')
                  .toList();
              if (done.isNotEmpty) await repo.undo(done.first.id);
          }
        } on Refused {
          // A refusal is a rule of the web; the invariants hold all the same.
        }
        for (final h in [homes.main, homes.second]) {
          final a = articles[h]!;
          final movements = await repo.movementsOf(a);
          final sum = movements.fold(Decimal.zero, (s, m) => s + m.effect);
          expect(await repo.stockLevel(a), sum);
          expect(
            sum >= Decimal.zero,
            isTrue,
            reason: 'one phone never goes below zero',
          );
        }
        for (final draw in await repo.db.select(repo.db.materialDraws).get()) {
          expect(readQuantity(draw.drawn) <= readQuantity(draw.wanted), isTrue);
          expect(readQuantity(draw.drawn) >= Decimal.zero, isTrue);
        }
      }
    });
  });
}
