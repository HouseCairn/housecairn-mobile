// SPDX-License-Identifier: AGPL-3.0-only

// The screens of the maintainer's feedback of 2026-11-15 (web pull request
// #160), in English and French, on two homes: Equipment under Rooms, the
// manufacturer's warranty of the item form and sheet, the millilitre, and the
// sheets of existing rows saved as they are changed, with a "Saved" said by
// the screen reader.

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/ui/autosave.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/stock_format.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens_2b_test.dart' show reveal, tapKey, type;
import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';

void main() {
  setUpAll(initializeDateFormatting);

  for (final locale in ['en', 'fr']) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<(AppState, Lot2b)> start(WidgetTester tester) async {
      await onPhone(tester);
      late Lot2b data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async {
          data = await Lot2b.seed(r);
          final kitchen = data.kitchen;
          await r.addItem(
            kitchen,
            ItemInput(
              name: 'Coffee machine',
              brand: 'Acme',
              purchasedOn: Day(2026, 1, 31),
              warrantyDuration: 2,
              warrantyProvider: 'shop',
              warrantyProviderName: 'Example shop',
            ),
          );
        },
        notifier: FakeNotifier(),
      );
      await state.choose(data.homes.main);
      await tester.pumpAndSettle();
      return (state, data);
    }

    Future<void> openEquipment(WidgetTester tester) async {
      await openRooms(tester, t('Rooms', 'Pièces'));
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('rooms-tabs')),
          matching: find.text(t('Equipment', 'Équipements')),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Equipment lists every item of the current home, filtered by '
        'room and words, $locale', (tester) async {
      final (_, data) = await start(tester);
      await openEquipment(tester);
      expect(find.text('Coffee machine'), findsOneWidget);
      expect(find.text('Main boiler'), findsOneWidget);
      expect(find.text('Second boiler'), findsNothing);
      expect(find.text('Main kitchen · Acme'), findsOneWidget);
      expect(
        find.textContaining(t('warranty until', 'garantie jusqu')),
        findsWidgets,
      );
      expect(
        find.textContaining(t('Next: Main boiler service', 'Prochaine : ')),
        findsWidgets,
      );
      await type(tester, 'equipment-search', 'ACME');
      await tester.pumpAndSettle();
      expect(find.text('Coffee machine'), findsOneWidget);
      expect(find.text('Main boiler'), findsNothing);
      await type(tester, 'equipment-search', 'nothing');
      await tester.pumpAndSettle();
      expect(
        find.text(t('No item matches.', 'Aucun élément ne correspond.')),
        findsOneWidget,
      );
      await type(tester, 'equipment-search', '');
      await tester.pumpAndSettle();
      await tapKey(tester, 'equipment-room');
      await tester.tap(find.text('Main cellar').last);
      await tester.pumpAndSettle();
      expect(find.text('Main boiler'), findsOneWidget);
      expect(find.text('Coffee machine'), findsNothing);
      expect(data.kitchen, isNotEmpty);
    });

    testWidgets('the sheet of an item shows its warranty worked out, and '
        'saves itself as it is changed, $locale', (tester) async {
      final (state, data) = await start(tester);
      final item = (await state.repository.itemList(
        data.homes.main,
        query: 'coffee',
      )).single.item;
      // Two years from 31 January 2026, the purchase date.
      expect(item.warrantyEndsOn, '2028-01-31');
      await openScreen(
        tester,
        ItemFormScreen(
          homeId: data.homes.main,
          roomId: data.kitchen,
          itemId: item.id,
        ),
      );
      await reveal(tester, find.byKey(const Key('item-warranty-end')));
      expect(find.byKey(const Key('item-warranty-end')), findsOneWidget);
      expect(find.byKey(const Key('autosave-status')), findsNothing);
      final semantics = tester.ensureSemantics();
      await type(tester, 'item-warranty-duration', '3');
      // Nothing is written while the typing goes on.
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        (await state.repository.item(item.id))!.warrantyEndsOn,
        '2028-01-31',
      );
      await tester.pump(autosavePause);
      await tester.pumpAndSettle();
      expect(
        (await state.repository.item(item.id))!.warrantyEndsOn,
        '2029-01-31',
      );
      expect(find.text(t('Saved', 'Enregistré')), findsOneWidget);
      expect(
        tester.takeAnnouncements().map((a) => a.message),
        contains(t('Saved', 'Enregistré')),
      );
      // A value the form refuses is kept, with its error, and not written.
      await type(tester, 'item-warranty-duration', '100');
      await tester.pump(autosavePause);
      await tester.pumpAndSettle();
      expect(
        find.text(
          t(
            'A warranty lasts from 1 to 99 months or years.',
            'Une garantie dure de 1 à 99 mois ou ans.',
          ),
        ),
        findsOneWidget,
      );
      expect((await state.repository.item(item.id))!.warrantyDuration, 3);
      semantics.dispose();
    });

    testWidgets('a new item waits for its button, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openScreen(
        tester,
        ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await type(tester, 'item-name', 'Kettle');
      await tester.pump(autosavePause);
      await tester.pumpAndSettle();
      expect(
        (await state.repository.itemList(data.homes.main, query: 'kettle')),
        isEmpty,
      );
    });

    testWidgets('the unit list has the millilitre, $locale', (tester) async {
      await onPhone(tester);
      await pumpApp(tester, locale: locale);
      final context = tester.element(find.byType(Scaffold).first);
      final l10n = AppLocalizations.of(context);
      expect(unitChoices(l10n).map((c) => c.$1), contains('millilitre'));
      expect(l10n.unitMillilitre, 'mL');
      expect(l10n.unitMillilitreChoice, 'Millilitre (mL)');
    });
  }
}
