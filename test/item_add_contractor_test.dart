// SPDX-License-Identifier: AGPL-3.0-only

// Add a contractor… in the maintenance contract of an item, as on the web
// (`contract_contractor` of `rooms/forms.py`, `clean_new_contractor`): the
// last choice of the list, also in a home with no contractor; the fields of
// the new one open in place, the task form's; it is made in the home of the
// item with the item, in one write, or not at all (cancelled, refused, or a
// save that fails after it); a name is required, and one of the home is
// refused whatever its case; a read-only or archived home writes nothing; on
// the example home of the guide it stays on the phone, as any of its rows.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/adaptive.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/new_contractor.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'd12_test.dart' show readOnly;
import 'screens_2b_test.dart' show reveal, tapKey, type;
import 'support/app.dart';
import 'support/arb.dart';
import 'support/lot2b.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

/// The rows of `op_log`, the operations that wait to be sent.
Future<int> operations(Repository r) async =>
    (await r.db.customSelect('SELECT COUNT(*) AS n FROM op_log').getSingle())
        .read<int>('n');

void main() {
  setUpAll(initializeDateFormatting);

  for (final locale in ['en', 'fr']) {
    final m = arbMessages(locale);

    Future<(AppState, Lot2b)> start(
      WidgetTester tester, {
      Future<void> Function(Repository r, Lot2b data)? more,
    }) async {
      await onPhone(tester);
      late Lot2b data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async {
          data = await Lot2b.seed(r);
          await more?.call(r, data);
        },
      );
      return (state, data);
    }

    /// Chooses Add a contractor… in the list of the contract.
    Future<void> chooseAdd(WidgetTester tester) async {
      await tapKey(tester, 'item-contractor');
      await tester.tap(find.text(m['taskAddContractor']!).last);
      await tester.pumpAndSettle();
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.text(m['save']!).first);
      await tester.pumpAndSettle();
    }

    Future<List<String>> names(AppState state, String home) async => [
      for (final c in await state.repository.contractors(home)) c.name,
    ];

    testWidgets('Add a contractor… is the last choice of the contract, '
        'in a home with no contractor too, $locale', (tester) async {
      late String empty;
      late String hall;
      final (state, data) = await start(
        tester,
        more: (r, data) async {
          empty = await r.createHome(name: 'Empty home');
          hall = await r.createRoom(empty, name: 'Hall');
        },
      );
      for (final (home, room) in [
        (data.homes.main, data.kitchen),
        (empty, hall),
      ]) {
        await openScreen(tester, ItemFormScreen(homeId: home, roomId: room));
        await reveal(tester, find.byKey(const Key('item-contractor')));
        final list = tester.widget<HcSelect<String?>>(
          find.byKey(const Key('item-contractor')),
        );
        final contractors = await state.repository.contractors(home);
        expect(list.choices.last, (
          newContractorChoice,
          m['taskAddContractor']!,
        ));
        expect(list.choices.first.$1, isNull);
        expect(list.choices, hasLength(contractors.length + 2));
        // And it opens the fields of the new one.
        await chooseAdd(tester);
        expect(
          find.byKey(const Key('item-new-contractor-name')),
          findsOneWidget,
        );
        expect(
          find.text(m['taskNewContractor']!.toUpperCase()),
          findsOneWidget,
        );
        Navigator.of(
          tester.element(find.byKey(const Key('item-new-contractor-name'))),
        ).pop();
        await tester.pumpAndSettle();
      }
      expect(await names(state, empty), isEmpty);
    });

    testWidgets('a new item is made with its new contractor, in its home, '
        '$locale', (tester) async {
      final (state, data) = await start(tester);
      final before = await names(state, data.homes.second);
      await openScreen(
        tester,
        ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await type(tester, 'item-name', 'Heat pump');
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', '  Acme   Heating ');
      await tapKey(tester, 'item-new-contractor-trade');
      await tester.tap(find.text(m['tradeHeatingEngineer']!).last);
      await tester.pumpAndSettle();
      await save(tester);
      final repository = state.repository;
      final made = (await repository.contractors(data.homes.main))
          .singleWhere((c) => c.name == 'Acme Heating');
      expect(made.trade, 'heating_engineer');
      expect(made.homeId, data.homes.main);
      final item = (await repository.itemList(
        data.homes.main,
        query: 'heat pump',
      )).single.item;
      expect(item.contractContractorId, made.id);
      expect(item.roomId, data.kitchen);
      // Nothing in the other home.
      expect(await names(state, data.homes.second), before);
      // Both wait to be sent, as a task and its new contractor do.
      final out = [
        for (final o in await repository.outgoing()) '${o.operation}',
      ];
      expect(out.where((o) => o.contains(made.id)), isNotEmpty);
      expect(out.where((o) => o.contains(item.id)), isNotEmpty);
    });

    testWidgets('an existing item takes a new contractor, and waits for '
        'its button, $locale', (tester) async {
      final (state, data) = await start(tester);
      final repository = state.repository;
      await openScreen(
        tester,
        ItemFormScreen(
          homeId: data.homes.main,
          roomId: data.cellar,
          itemId: data.boiler,
        ),
      );
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', 'Boiler Care');
      // No save of the sheet while a contractor is to be added with it.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(
        (await repository.item(data.boiler))!.contractContractorId,
        data.plumber,
      );
      expect(
        await names(state, data.homes.main),
        isNot(contains('Boiler Care')),
      );
      await save(tester);
      final made = (await repository.contractors(data.homes.main))
          .singleWhere((c) => c.name == 'Boiler Care');
      final item = (await repository.item(data.boiler))!;
      expect(item.contractContractorId, made.id);
      // The rest of the item is as it was.
      expect(item.contractNumber, 'C-2024-0187');
      expect(item.name, 'Main boiler');
    });

    testWidgets('closing the form makes no contractor, $locale', (
      tester,
    ) async {
      final (state, data) = await start(tester);
      final before = await names(state, data.homes.main);
      final operationsBefore = await operations(state.repository);
      await openScreen(
        tester,
        ItemFormScreen(
          homeId: data.homes.main,
          roomId: data.cellar,
          itemId: data.boiler,
        ),
      );
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', 'Never made');
      Navigator.of(
        tester.element(find.byKey(const Key('item-new-contractor-name'))),
      ).pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(await names(state, data.homes.main), before);
      expect(await operations(state.repository), operationsBefore);
      expect(
        (await state.repository.item(data.boiler))!.contractContractorId,
        data.plumber,
      );
    });

    testWidgets('a name is required, and one of the home is refused, '
        '$locale', (tester) async {
      final (state, data) = await start(tester);
      final before = await names(state, data.homes.main);
      await openScreen(
        tester,
        ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await type(tester, 'item-name', 'Heat pump');
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', '   ');
      await save(tester);
      await reveal(tester, find.text(m['errNewContractorName']!));
      expect(find.text(m['errNewContractorName']!), findsOneWidget);
      // The name of a contractor of the home, in another case.
      await type(tester, 'item-new-contractor-name', 'main PLUMBER');
      await save(tester);
      final taken = m['errNewContractorTaken']!.replaceAll(
        '{name}',
        'main PLUMBER',
      );
      await reveal(tester, find.text(taken));
      expect(find.text(taken), findsOneWidget);
      // The trade Other wants its words.
      await type(tester, 'item-new-contractor-name', 'Odd jobs');
      await tapKey(tester, 'item-new-contractor-trade');
      await tester.tap(find.text(m['tradeOther']!).last);
      await tester.pumpAndSettle();
      await save(tester);
      await reveal(tester, find.text(m['errTradeOther']!));
      // Under the field of the words, as the web says it.
      expect(
        find.descendant(
          of: find.byKey(const Key('item-new-contractor-other')),
          matching: find.text(m['errTradeOther']!),
        ),
        findsOneWidget,
      );
      expect(await names(state, data.homes.main), before);
      expect(
        await state.repository.itemList(data.homes.main, query: 'heat pump'),
        isEmpty,
      );
    });

    testWidgets('a save that fails after the contractor leaves none, '
        '$locale', (tester) async {
      final (state, data) = await start(tester);
      final before = await names(state, data.homes.main);
      await openScreen(
        tester,
        ItemFormScreen(
          homeId: data.homes.main,
          roomId: data.cellar,
          itemId: data.boiler,
        ),
      );
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', 'Too late');
      // The item goes while the form is open: its write is refused once the
      // contractor is written, and the contractor goes with it.
      await state.repository.deleteItem(data.boiler);
      await save(tester);
      expect(find.text(m['errNotFound']!), findsOneWidget);
      expect(await names(state, data.homes.main), before);
    });

    testWidgets('an archived home writes nothing, $locale', (tester) async {
      final (state, data) = await start(tester);
      final before = await names(state, data.homes.main);
      await openScreen(
        tester,
        ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await type(tester, 'item-name', 'Heat pump');
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', 'Acme Heating');
      await state.repository.archiveHome(data.homes.main);
      await save(tester);
      expect(find.text(m['errHomeArchived']!), findsOneWidget);
      expect(await names(state, data.homes.main), before);
    });

    testWidgets('a read-only home of a server writes nothing, $locale', (
      tester,
    ) async {
      final (state, data) = await start(
        tester,
        more: (r, data) => readOnly(r, data.homes.main),
      );
      final before = await names(state, data.homes.main);
      await openScreen(
        tester,
        ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await type(tester, 'item-name', 'Heat pump');
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', 'Acme Heating');
      await save(tester);
      expect(find.text(m['errReadOnlyHome']!), findsOneWidget);
      expect(await names(state, data.homes.main), before);
      expect(
        await state.repository.itemList(data.homes.main, query: 'heat pump'),
        isEmpty,
      );
    });

    testWidgets('on the example home, the contractor stays on the phone, '
        '$locale', (tester) async {
      late String example;
      late String room;
      final (state, _) = await start(
        tester,
        more: (r, data) async {
          example = await r.createExampleHome(guide);
          room = await r.createRoom(example, name: 'Hall');
        },
      );
      final repository = state.repository;
      final operationsBefore = await operations(repository);
      await openScreen(tester, ItemFormScreen(homeId: example, roomId: room));
      await type(tester, 'item-name', 'Heat pump');
      await chooseAdd(tester);
      await type(tester, 'item-new-contractor-name', 'Acme Heating');
      await save(tester);
      final made = (await repository.contractors(example))
          .singleWhere((c) => c.name == 'Acme Heating');
      final item = (await repository.itemList(
        example,
        query: 'heat pump',
      )).single.item;
      expect(item.contractContractorId, made.id);
      expect(made.homeId, example);
      expect(await operations(repository), operationsBefore);
      expect(
        (await repository.outgoing()).where(
          (o) => '${o.operation}'.contains(made.id),
        ),
        isEmpty,
      );
    });
  }
}
