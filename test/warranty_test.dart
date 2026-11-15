// SPDX-License-Identifier: AGPL-3.0-only

// The maintainer's feedback of 2026-11-15 on the phone: the manufacturer's
// warranty of an item (web ADR 0080, `rooms/models.py` `warranty_end`), the
// list of every item (`rooms/services.py` `item_rows`) and the millilitre.
// Two homes: nothing of one is ever in the other.

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/stock.dart' as stock;
import 'package:housecairn_mobile/domain/warranty.dart';

import 'support/fixture.dart';

Matcher refusedWith(Refusal reason) =>
    throwsA(isA<Refused>().having((e) => e.reason, 'reason', reason));

void main() {
  group('warrantyEnd, as relativedelta', () {
    test('the same date that many months or years later', () {
      expect(warrantyEnd(Day(2026, 3, 15), 2, warrantyYear), Day(2028, 3, 15));
      expect(
        warrantyEnd(Day(2026, 3, 15), 18, warrantyMonth),
        Day(2027, 9, 15),
      );
    });

    test('the last day of a shorter month', () {
      expect(warrantyEnd(Day(2026, 1, 31), 1, warrantyMonth), Day(2026, 2, 28));
      expect(
        warrantyEnd(Day(2027, 1, 31), 13, warrantyMonth),
        Day(2028, 2, 29),
      );
      expect(warrantyEnd(Day(2028, 2, 29), 1, warrantyYear), Day(2029, 2, 28));
    });

    test('none without a start, a duration or a known unit', () {
      expect(warrantyEnd(null, 2, warrantyYear), isNull);
      expect(warrantyEnd(Day(2026, 1, 1), null, warrantyYear), isNull);
      expect(warrantyEnd(Day(2026, 1, 1), 2, 'week'), isNull);
    });

    test('the start is the date given, else the purchase date', () {
      expect(warrantyStart(Day(2026, 2, 1), Day(2026, 1, 1)), Day(2026, 2, 1));
      expect(warrantyStart(null, Day(2026, 1, 1)), Day(2026, 1, 1));
      expect(warrantyStart(null, null), isNull);
    });
  });

  group('the warranty of an item', () {
    late Repository repo;
    late TwoHomes homes;
    late String kitchen;

    setUp(() async {
      repo = await openRepository();
      homes = await TwoHomes.create(repo);
      kitchen = (await repo.rooms(homes.main))
          .firstWhere((r) => r.name == 'Main kitchen')
          .id;
    });

    test('with a duration, its end is worked out from the purchase date, '
        'and the fields keep the web names', () async {
      final id = await repo.addItem(
        kitchen,
        ItemInput(
          name: 'Coffee machine',
          purchasedOn: Day(2026, 1, 31),
          warrantyDuration: 1,
          warrantyDurationUnit: warrantyMonth,
          warrantyProvider: 'shop',
          warrantyProviderName: ' Example shop ',
          // Typed, but a duration and a start win.
          warrantyEndsOn: Day(2030, 1, 1),
        ),
      );
      final item = (await repo.item(id))!;
      expect(item.warrantyEndsOn, '2026-02-28');
      expect(item.warrantyProviderName, 'Example shop');
      expect(item.warrantyProvider, 'shop');
      expect(item.warrantyDurationUnit, warrantyMonth);
      final clocks = await repo.db
          .customSelect(
            "SELECT field FROM field_clock WHERE entity = 'rooms.item'",
          )
          .get();
      expect(
        clocks.map((r) => r.data['field']),
        containsAll([
          'purchased_on',
          'warranty_duration',
          'warranty_duration_unit',
          'warranty_provider',
          'warranty_provider_name',
          'warranty_starts_on',
          'warranty_ends_on',
        ]),
      );
    });

    test('a start given wins over the purchase date', () async {
      final id = await repo.addItem(
        kitchen,
        ItemInput(
          name: 'Fridge',
          purchasedOn: Day(2026, 1, 1),
          warrantyStartsOn: Day(2026, 2, 1),
          warrantyDuration: 2,
        ),
      );
      expect((await repo.item(id))!.warrantyEndsOn, '2028-02-01');
    });

    test(
      'without a duration, the end typed stays, as before schema 5',
      () async {
        final id = await repo.addItem(
          kitchen,
          ItemInput(name: 'Oven', warrantyEndsOn: Day(2027, 5, 1)),
        );
        final item = (await repo.item(id))!;
        expect(item.warrantyEndsOn, '2027-05-01');
        expect(item.warrantyDuration, isNull);
        expect(Repository.warrantyState(item, Day(2027, 5, 1)), 'active');
        expect(Repository.warrantyState(item, Day(2027, 5, 2)), 'expired');
      },
    );

    test('a duration of 0 or 100 and an unknown unit or provider are '
        'refused', () {
      for (final d in [0, 100]) {
        expect(
          repo.addItem(kitchen, ItemInput(name: 'X', warrantyDuration: d)),
          refusedWith(Refusal.warrantyDurationOutOfRange),
        );
      }
      expect(
        repo.addItem(
          kitchen,
          const ItemInput(name: 'X', warrantyDurationUnit: 'week'),
        ),
        refusedWith(Refusal.choiceInvalid),
      );
      expect(
        repo.addItem(
          kitchen,
          const ItemInput(name: 'X', warrantyProvider: 'friend'),
        ),
        refusedWith(Refusal.choiceInvalid),
      );
    });

    test('an edit writes only the fields it changes', () async {
      final id = await repo.addItem(
        kitchen,
        ItemInput(name: 'Kettle', purchasedOn: Day(2026, 1, 1)),
      );
      final before = (await repo.item(id))!.updatedAt;
      await repo.updateItem(
        id,
        ItemInput(name: 'Kettle', purchasedOn: Day(2026, 1, 1)),
      );
      expect((await repo.item(id))!.updatedAt, before);
      await repo.updateItem(
        id,
        ItemInput(
          name: 'Kettle',
          purchasedOn: Day(2026, 1, 1),
          warrantyDuration: 2,
        ),
      );
      expect((await repo.item(id))!.warrantyEndsOn, '2028-01-01');
    });
  });

  group('the list of every item', () {
    late Repository repo;
    late TwoHomes homes;

    setUp(() async {
      repo = await openRepository();
      homes = await TwoHomes.create(repo);
    });

    test('every room of the home, its next task, and nothing of the other '
        'home', () async {
      final rows = await repo.itemList(homes.main);
      expect(rows.map((r) => r.item.name), ['Main boiler']);
      expect(rows.single.room.name, 'Main cellar');
      final second = await repo.itemList(homes.second);
      expect(second.map((r) => r.item.name), ['Second boiler']);
    });

    test('filtered by room and by words of the name, brand, model or serial '
        'number, whatever their case', () async {
      final kitchen = (await repo.rooms(homes.main))
          .firstWhere((r) => r.name == 'Main kitchen')
          .id;
      await repo.addItem(
        kitchen,
        const ItemInput(
          name: 'Coffee machine',
          brand: 'Acme',
          model: 'X-1',
          serialNumber: 'SN-42',
        ),
      );
      expect((await repo.itemList(homes.main)).map((r) => r.item.name), [
        'Coffee machine',
        'Main boiler',
      ]);
      expect(
        (await repo.itemList(
          homes.main,
          roomId: kitchen,
        )).map((r) => r.item.name),
        ['Coffee machine'],
      );
      for (final words in ['acme', 'x-1', 'sn-42', 'COFFEE']) {
        expect(
          (await repo.itemList(
            homes.main,
            query: words,
          )).map((r) => r.item.name),
          ['Coffee machine'],
          reason: words,
        );
      }
      expect(await repo.itemList(homes.main, query: 'nothing'), isEmpty);
      expect(await repo.itemList(homes.second, query: 'acme'), isEmpty);
    });

    test('the next task is the open occurrence due the soonest', () async {
      final rows = await repo.itemList(homes.main);
      final boiler = rows.single.item;
      await repo.createTask(
        homes.main,
        TaskInput(
          title: 'Later',
          dueOn: testToday.addDays(30),
          itemId: boiler.id,
        ),
      );
      await repo.createTask(
        homes.main,
        TaskInput(
          title: 'Late',
          dueOn: testToday.addDays(-9),
          itemId: boiler.id,
        ),
      );
      final next = (await repo.itemList(homes.main)).single.next!;
      expect(next.task.title, 'Late');
    });
  });

  test('the millilitre is a unit, between the litre and the metre', () {
    expect(stock.units.indexOf('millilitre'), stock.units.indexOf('litre') + 1);
  });
}
