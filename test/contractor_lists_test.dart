// SPDX-License-Identifier: AGPL-3.0-only

// The two lists of contractors (the provider of an item's contract, the
// contractor of a task), on Android and on iOS, in English and French: the
// choice Add a contractor… is read whole in its field on the narrow phone
// (320 px) with text at twice the size, its words on two lines rather than
// cut by the field or ended in an ellipsis (`wrap` of HcSelect); and a
// contractor that is no longer in the home shows None.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart' show uuidBytes;
import 'package:housecairn_mobile/design/adaptive.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/new_contractor.dart';
import 'package:housecairn_mobile/ui/task_form_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens_2b_test.dart' show reveal;
import 'support/app.dart';
import 'support/arb.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/whole_choice.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    // The real fonts, as for the golden files: the test font would not
    // measure the words of the app.
    await loadAppFonts();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in ['en', 'fr']) {
      final m = arbMessages(locale);
      final name = '${platform.name.toLowerCase()}, $locale';

      Future<Lot2b> start(
        WidgetTester tester, {
        double width = 360,
        double scale = 1,
      }) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await onPhone(tester, textScale: scale, width: width);
        late Lot2b data;
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
        );
        return data;
      }

      /// Chooses [choice] in the list of key [key], as the menu of Android
      /// or the wheel of iOS gives it.
      Future<void> choose(
        WidgetTester tester,
        String key,
        String? choice,
      ) async {
        tester
            .widget<HcSelect<String?>>(find.byKey(Key(key)))
            .onChanged(choice);
        await tester.pumpAndSettle();
      }

      Future<void> end(WidgetTester tester) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 10));
      }

      testWidgets('the task form reads Add a contractor… whole at 320 px '
          'x2, $name', (tester) async {
        final data = await start(tester, width: 320, scale: 2);
        await openScreen(tester, TaskFormScreen(homeId: data.homes.main));
        await unfoldTaskSection(tester, 'task-section-who');
        await seeInTaskForm(tester, find.byKey(const Key('task-contractor')));
        await choose(tester, 'task-contractor', newContractorChoice);
        await seeInTaskForm(tester, find.byKey(const Key('task-contractor')));
        expect(tester.takeException(), isNull);
        expectChoiceWhole(
          tester,
          find.byKey(const Key('task-contractor')),
          m['taskAddContractor']!,
          'the task form, $name',
        );
        await end(tester);
      });

      testWidgets('the item form reads Add a contractor… whole at 320 px '
          'x2, $name', (tester) async {
        final data = await start(tester, width: 320, scale: 2);
        await openScreen(
          tester,
          ItemFormScreen(
            homeId: data.homes.main,
            roomId: data.cellar,
            itemId: data.boiler,
          ),
        );
        await reveal(tester, find.byKey(const Key('item-contractor')));
        await choose(tester, 'item-contractor', newContractorChoice);
        await reveal(tester, find.byKey(const Key('item-contractor')));
        expect(tester.takeException(), isNull);
        expectChoiceWhole(
          tester,
          find.byKey(const Key('item-contractor')),
          m['taskAddContractor']!,
          'the item form, $name',
        );
        await end(tester);
      });

      testWidgets('a provider no longer in the home shows None, $name', (
        tester,
      ) async {
        late Lot2b data;
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await onPhone(tester);
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async {
            data = await Lot2b.seed(r);
            // Deleted from elsewhere (a synchronisation), the item still
            // naming it.
            await r.db.customStatement(
              'UPDATE contractors SET deleted_at = 1 WHERE id = ?',
              [uuidBytes(data.plumber)],
            );
          },
        );
        await openScreen(
          tester,
          ItemFormScreen(
            homeId: data.homes.main,
            roomId: data.cellar,
            itemId: data.boiler,
          ),
        );
        await reveal(tester, find.byKey(const Key('item-contractor')));
        expect(tester.takeException(), isNull);
        final list = find.byKey(const Key('item-contractor'));
        expect(tester.widget<HcSelect<String?>>(list).value, isNull);
        expectChoiceWhole(tester, list, m['contractNone']!, 'None, $name');
        await end(tester);
      });
    }
  }
}
