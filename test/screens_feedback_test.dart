// SPDX-License-Identifier: AGPL-3.0-only

// The screens of the maintainer's feedback of 2026-11-15 (web pull request
// #160), in English and French, on two homes: Equipment under Rooms, the
// manufacturer's warranty of the item form and sheet, the millilitre, and the
// sheets of existing rows saved as they are changed, with a "Saved" said by
// the screen reader.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart' show HomeRow;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/autosave.dart';
import 'package:housecairn_mobile/ui/equipment_screen.dart';
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

    testWidgets('Equipment adds an item: the button is there, the room being '
        'filtered is chosen, the list gets it back, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openEquipment(tester);
      expect(find.byKey(const Key('equipment-add')), findsOneWidget);
      expect(find.text(t('Add an item', 'Ajouter un élément')), findsOneWidget);
      // Filtered on the cellar: the form starts with that room.
      await tapKey(tester, 'equipment-room');
      await tester.tap(find.text('Main cellar').last);
      await tester.pumpAndSettle();
      await tapKey(tester, 'equipment-add');
      expect(find.byKey(const Key('item-room')), findsOneWidget);
      await type(tester, 'item-name', 'Dehumidifier');
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      final added = (await state.repository.itemList(
        data.homes.main,
        query: 'dehumidifier',
      )).single;
      expect(added.room.name, 'Main cellar');
      // Back on the list, which is still filtered on the cellar.
      expect(find.byKey(const Key('equipment-add')), findsOneWidget);
      expect(find.text('Dehumidifier'), findsOneWidget);
      expect(find.text('Main boiler'), findsOneWidget);
    });

    testWidgets('Equipment: with no room filter the form asks for the room, '
        'and an archived home has no button, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openEquipment(tester);
      await tapKey(tester, 'equipment-add');
      await tapKey(tester, 'item-room');
      await tester.tap(find.text('Main cellar').last);
      await tester.pumpAndSettle();
      await type(tester, 'item-name', 'Shelf');
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      expect(
        (await state.repository.itemList(
          data.homes.main,
          query: 'shelf',
        )).single.room.name,
        'Main cellar',
      );
      await state.repository.archiveHome(data.homes.main);
      final archived = (await state.repository.homes()).firstWhere(
        (h) => h.id == data.homes.main,
      );
      expect(archived.archivedAt, isNotNull);
      await openScreen(
        tester,
        HcScaffold(
          title: 'Equipment',
          body: EquipmentList(home: archived, tabs: const SizedBox.shrink()),
        ),
      );
      expect(find.text('Coffee machine'), findsOneWidget);
      expect(find.byKey(const Key('equipment-add')), findsNothing);
    });

    testWidgets('Equipment empty: with rooms the short text sits above the '
        'button, with no room the long text and no button, $locale', (
      tester,
    ) async {
      final (state, _) = await start(tester);
      final id = await state.repository.createHome(name: 'Bare home');
      Future<HomeRow> reread() async =>
          (await state.repository.homes()).firstWhere((h) => h.id == id);
      final short = t('No item yet.', 'Aucun élément pour l\'instant.');
      final long = t(
        'No item yet. Add one from the page of a room.',
        'Aucun élément pour l\'instant. Ajoutez-en un depuis la page d\'une '
            'pièce.',
      );
      // No room yet: the long text points to the page of a room.
      await openScreen(
        tester,
        HcScaffold(
          title: 'Equipment',
          body: EquipmentList(home: await reread(), tabs: const SizedBox()),
        ),
      );
      expect(find.text(long), findsOneWidget);
      expect(find.byKey(const Key('equipment-add')), findsNothing);
      // A room and no item: the short text, and the button under it.
      await state.repository.createRoom(id, name: 'Bare room');
      await openScreen(
        tester,
        HcScaffold(
          title: 'Equipment',
          body: EquipmentList(home: await reread(), tabs: const SizedBox()),
        ),
      );
      expect(find.text(short), findsOneWidget);
      expect(find.text(long), findsNothing);
      expect(find.byKey(const Key('equipment-add')), findsOneWidget);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('Equipment: Add an item opens the form and the room list '
          'on ${platform.name}, $locale', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await start(tester);
          await openEquipment(tester);
          await tapKey(tester, 'equipment-add');
          expect(find.byKey(const Key('item-name')), findsOneWidget);
          expect(find.byKey(const Key('item-room')), findsOneWidget);
          await tapKey(tester, 'item-room');
          expect(find.text('Main cellar'), findsWidgets);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('the search of Equipment keeps its focus while the words '
        'go on, and the list follows, $locale', (tester) async {
      await start(tester);
      await openEquipment(tester);
      final field = find.byKey(const Key('equipment-search'));
      final before = tester.state<EditableTextState>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      );
      bool focused() => tester
          .widget<EditableText>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .focusNode
          .hasPrimaryFocus;

      await tester.tap(field);
      await tester.pumpAndSettle();
      expect(focused(), isTrue);
      // Two entries in a row, without the field being tapped again.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'ac',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(focused(), isTrue);
      expect(find.text('Coffee machine'), findsOneWidget);
      expect(find.text('Main boiler'), findsNothing);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'acme',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      await tester.pumpAndSettle();
      expect(focused(), isTrue);
      expect(find.text('Coffee machine'), findsOneWidget);
      expect(find.text('Main boiler'), findsNothing);
      expect(
        tester.state<EditableTextState>(
          find.descendant(of: field, matching: find.byType(EditableText)),
        ),
        same(before),
      );
      expect(tester.testTextInput.hasAnyClients, isTrue);
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
