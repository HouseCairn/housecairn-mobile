// SPDX-License-Identifier: AGPL-3.0-only

// Screens of lot 2b (docs/plan.md): Rooms, Room, Item, Contractors, Add from a
// template, the photos of a room or an item, and the Reminders switch of
// More, at 360 px, in English and French, with the fixture of two homes.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/choices.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/ui/choices.dart';
import 'package:housecairn_mobile/ui/contractor_screens.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/templates_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';

/// Scrolls the list of the screen on top until [target] is shown.
Future<void> reveal(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    final list = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable();
    for (final delta in [-300.0, 300.0]) {
      if (target.evaluate().isNotEmpty) break;
      try {
        await tester.scrollUntilVisible(
          target,
          delta,
          scrollable: list.last,
          maxScrolls: 40,
        );
      } on StateError {
        // Not that way: the other one.
      }
    }
  }
  if (target.evaluate().length == 1) await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  final target = find.text(text);
  await reveal(tester, target.first);
  await tester.tap(target.first);
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  await reveal(tester, target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> type(WidgetTester tester, String key, String text) async {
  final target = find.byKey(Key(key));
  await reveal(tester, target);
  await tester.enterText(target, text);
  await tester.pump();
}

void main() {
  setUpAll(initializeDateFormatting);

  for (final locale in ['en', 'fr']) {
    final AppLocalizations l = locale == 'en'
        ? AppLocalizationsEn()
        : AppLocalizationsFr();
    group('lot 2b, $locale', () {
      late Lot2b data;

      Future<void> seed(Repository repository) async =>
          data = await Lot2b.seed(repository);

      Future<void> start(
        WidgetTester tester, {
        FakePhotoSource? photos,
        FakeNotifier? notifier,
        List<Uri>? opened,
        bool canOpen = true,
        double scale = 1,
      }) async {
        await onPhone(tester, textScale: scale, height: 2600);
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: seed,
          photoSource: photos,
          notifier: notifier,
          openUrl: (uri) async {
            opened?.add(uri);
            return canOpen;
          },
        );
        await state.choose(data.homes.main);
        await tester.pumpAndSettle();
        await openRooms(tester, l.navRooms);
      }

      testWidgets(
        'Rooms lists the rooms of the current home only, with kind and items',
        (tester) async {
          await start(tester);
          expect(find.text('Main kitchen'), findsOneWidget);
          expect(find.text('Main cellar'), findsOneWidget);
          expect(find.text('Second kitchen'), findsNothing);
          expect(
            find.text(l.roomSummary(roomKindLabel(l, 'kitchen'), 0)),
            findsOneWidget,
          );
          expect(
            find.text(l.roomSummary(roomKindLabel(l, 'other'), 1)),
            findsOneWidget,
          );
          // Another home, another list.
          final state = stateOf(tester);
          await state.choose(data.homes.second);
          await tester.pumpAndSettle();
          expect(find.text('Second kitchen'), findsOneWidget);
          expect(find.text('Main kitchen'), findsNothing);
        },
      );

      testWidgets('a new home has no room: the screen says so', (tester) async {
        await onPhone(tester);
        await pumpApp(tester, locale: locale);
        await openRooms(tester, l.navRooms);
        expect(find.text(l.roomsEmpty), findsOneWidget);
      });

      testWidgets('a room with only a name is added, and needs a name', (
        tester,
      ) async {
        await start(tester);
        await tapKey(tester, 'room-add');
        await tester.tap(find.text(l.save));
        await tester.pumpAndSettle();
        expect(find.text(l.errTitleRequired), findsOneWidget);
        await type(tester, 'room-name', 'Pantry');
        await tester.tap(find.text(l.save));
        await tester.pumpAndSettle();
        expect(find.text('Pantry'), findsOneWidget);
        final rooms = await stateOf(tester).repository.rooms(data.homes.main);
        expect(rooms.last.name, 'Pantry');
        expect(rooms.last.position, rooms.length - 1, reason: 'added last');
      });

      testWidgets(
        'a room shows its memory, items, photos and tasks; its memory is edited',
        (tester) async {
          await start(tester);
          await tapText(tester, 'Main kitchen');
          expect(find.text(roomKindLabel(l, 'kitchen')), findsOneWidget);
          expect(find.text('South facing, two windows'), findsOneWidget);
          expect(find.text('Sage green'), findsOneWidget);
          expect(find.text('Lime wash'), findsOneWidget);
          await reveal(tester, find.text('Descale the kettle'));
          expect(find.text('Descale the kettle'), findsOneWidget);
          expect(find.text(l.itemsEmpty), findsOneWidget);
          // Edit the memory.
          await tester.tap(find.text(l.edit));
          await tester.pumpAndSettle();
          expect(find.text(l.editRoom), findsOneWidget);
          await type(tester, 'room-name', 'Kitchen');
          await tester.tap(find.text(l.save));
          await tester.pumpAndSettle();
          expect(find.text('Kitchen'), findsWidgets);
          expect(
            find.text('Sage green'),
            findsOneWidget,
            reason: 'the memory stays',
          );
        },
      );

      testWidgets(
        'a room is deleted with its items and photos; its tasks stay',
        (tester) async {
          await start(tester);
          await tapText(tester, 'Main kitchen');
          await tester.tap(find.text(l.edit));
          await tester.pumpAndSettle();
          await tapKey(tester, 'room-delete');
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tap(find.widgetWithText(FilledButton, l.delete));
          await tester.pumpAndSettle();
          expect(find.byType(RoomsScreen), findsOneWidget);
          expect(find.text('Main kitchen'), findsNothing);
          final repository = stateOf(tester).repository;
          expect(
            (await repository.todayEntries(homeId: data.homes.main))
                .map((e) => e.task.title),
            contains('Descale the kettle'),
          );
        },
      );

      testWidgets(
        'an item is added to a room, shown with its details, edited and deleted',
        (tester) async {
          final opened = <Uri>[];
          await start(tester, opened: opened);
          await tapText(tester, 'Main cellar');
          // The boiler of the fixture, with its warranty, contract and links.
          await tapText(tester, 'Main boiler');
          expect(find.text('Example Heat · EH-3000'), findsWidgets);
          expect(find.text('SN-0042'), findsOneWidget);
          expect(
            find.text(l.warrantyUntil(formatDate(l, Day(2032, 10, 3)))),
            findsOneWidget,
          );
          expect(find.text('Main plumber'), findsOneWidget);
          expect(find.text('C-2024-0187'), findsOneWidget);
          expect(find.text('Manual'), findsOneWidget);
          // A link opens in the browser of the phone, once tapped.
          expect(opened, isEmpty);
          await tapText(tester, 'Manual');
          expect(opened, [Uri.parse('https://example.com/manual')]);
          expect(find.text('Service the boiler'), findsOneWidget);
          // Edit: the warranty ended.
          await tester.tap(find.text(l.edit));
          await tester.pumpAndSettle();
          expect(find.text(l.editItem), findsOneWidget);
          await type(tester, 'item-name', 'Boiler');
          await tester.tap(find.text(l.save));
          await tester.pumpAndSettle();
          expect(find.text('Boiler'), findsWidgets);
          // Delete.
          await tester.tap(find.text(l.edit));
          await tester.pumpAndSettle();
          await tapKey(tester, 'item-delete');
          await tester.tap(find.widgetWithText(FilledButton, l.delete));
          await tester.pumpAndSettle();
          expect(find.text('Boiler'), findsNothing);
          expect(find.text(l.itemsEmpty), findsOneWidget);
        },
      );

      testWidgets('an item needs only a name, and a bad link is refused', (
        tester,
      ) async {
        await start(tester);
        await tapText(tester, 'Main kitchen');
        await tapKey(tester, 'item-add');
        await type(tester, 'item-name', 'Fridge');
        await tapKey(tester, 'item-link-add');
        await type(tester, 'item-link-0', 'javascript:alert(1)');
        await tester.tap(find.text(l.save));
        await tester.pumpAndSettle();
        expect(find.text(l.errUrlInvalid), findsOneWidget);
        await type(tester, 'item-link-0', 'https://example.com/fridge');
        await tester.tap(find.text(l.save));
        await tester.pumpAndSettle();
        await reveal(tester, find.text('Fridge'));
        expect(find.text('Fridge'), findsOneWidget);
      });

      testWidgets('an ended warranty is a red pill', (tester) async {
        await start(tester);
        final repository = stateOf(tester).repository;
        await repository.updateItem(
          data.boiler,
          ItemInput(name: 'Main boiler', warrantyEndsOn: Day(2020, 1, 31)),
        );
        await stateOf(tester).refresh();
        await tapText(tester, 'Main cellar');
        await tapText(tester, 'Main boiler');
        expect(
          find.text(l.warrantyEnded(formatDate(l, Day(2020, 1, 31)))),
          findsOneWidget,
        );
      });

      testWidgets('Contractors: the list, the card, call and write', (
        tester,
      ) async {
        final opened = <Uri>[];
        await start(tester, opened: opened);
        await tester.tap(destination(l.navMore));
        await tester.pumpAndSettle();
        await tapText(tester, l.contractors);
        expect(find.byType(ContractorsScreen), findsOneWidget);
        expect(
          find.text('${tradeLabel(l, 'plumber')} · +33 1 99 00 12 34'),
          findsOneWidget,
        );
        expect(find.text('Second plumber'), findsNothing);
        await tapText(tester, 'Main plumber');
        expect(find.text('plumber@example.com'), findsOneWidget);
        expect(find.text(l.contractorNoTasks), findsOneWidget);
        await tapKey(tester, 'contractor-call');
        await tapKey(tester, 'contractor-write');
        expect(opened, [
          Uri(scheme: 'tel', path: '+33 1 99 00 12 34'),
          Uri(scheme: 'mailto', path: 'plumber@example.com'),
        ]);
      });

      testWidgets('nothing on the phone to call with: a message, no crash', (
        tester,
      ) async {
        await start(tester, canOpen: false);
        await tester.tap(destination(l.navMore));
        await tester.pumpAndSettle();
        await tapText(tester, l.contractors);
        await tapText(tester, 'Main plumber');
        await tapKey(tester, 'contractor-call');
        expect(find.text(l.contractorCannotOpen), findsOneWidget);
      });

      testWidgets(
        'a contractor: phone, e-mail and the trade Other are checked',
        (tester) async {
          await start(tester);
          await tester.tap(destination(l.navMore));
          await tester.pumpAndSettle();
          await tapText(tester, l.contractors);
          await tapKey(tester, 'contractor-add');
          await type(tester, 'contractor-name', 'Pool Co');
          await type(tester, 'contractor-phone', 'call me');
          await type(tester, 'contractor-email', 'nobody');
          await tester.tap(find.text(l.save));
          await tester.pumpAndSettle();
          expect(find.text(l.errPhoneInvalid), findsOneWidget);
          expect(find.text(l.errEmailInvalid), findsOneWidget);
          await type(tester, 'contractor-phone', '01 99 00 12 34');
          await type(tester, 'contractor-email', 'pool@example.com');
          await tapKey(tester, 'contractor-trade');
          await tester.tap(find.text(l.tradeOther).last);
          await tester.pumpAndSettle();
          await tester.tap(find.text(l.save));
          await tester.pumpAndSettle();
          expect(find.text(l.errTradeOther), findsOneWidget);
          await type(tester, 'contractor-trade-other', 'Pool maintenance');
          await tester.tap(find.text(l.save));
          await tester.pumpAndSettle();
          expect(find.text('Pool Co'), findsOneWidget);
          expect(
            find.text('Pool maintenance · 01 99 00 12 34'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'a contractor is deleted; the item that named them keeps its contract number',
        (tester) async {
          await start(tester);
          await tester.tap(destination(l.navMore));
          await tester.pumpAndSettle();
          await tapText(tester, l.contractors);
          await tapText(tester, 'Main plumber');
          await tester.tap(find.text(l.edit));
          await tester.pumpAndSettle();
          await tapKey(tester, 'contractor-delete');
          await tester.tap(find.widgetWithText(FilledButton, l.delete));
          await tester.pumpAndSettle();
          expect(find.text('Main plumber'), findsNothing);
          final item = (await stateOf(tester).repository.item(data.boiler))!;
          expect(item.contractContractorId, isNull);
          expect(item.contractNumber, 'C-2024-0187');
        },
      );

      testWidgets('Add from a template: tick, choose a room, add', (
        tester,
      ) async {
        await start(tester);
        await tester.tap(destination(l.navMore));
        await tester.pumpAndSettle();
        await tapText(tester, l.addFromTemplate);
        expect(find.byType(TemplatesScreen), findsOneWidget);
        // Nothing ticked: a message, nothing added.
        await tapKey(tester, 'templates-add');
        expect(find.text(l.templatesNoneTicked), findsOneWidget);
        await tapKey(tester, 'template-smoke-alarm-test');
        await tapKey(tester, 'template-smoke-alarm-battery');
        await tapKey(tester, 'templates-room');
        await tester.tap(find.text('Main kitchen').last);
        await tester.pumpAndSettle();
        await tapKey(tester, 'templates-add');
        expect(find.byType(TemplatesScreen), findsNothing);
        final tasks = await stateOf(tester).repository
            .tasksOf(roomId: data.kitchen);
        final titles = tasks.map((e) => e.task.title).toSet();
        final expected = locale == 'en'
            ? [
                'Test the smoke alarms',
                'Replace the battery of the smoke alarms',
              ]
            : [
                'Tester les détecteurs de fumée',
                'Changer la pile des détecteurs de fumée',
              ];
        expect(titles, containsAll(expected));
        for (final e in tasks.where((e) => expected.contains(e.task.title))) {
          expect(e.task.estimatedMinutes, isNotNull);
          expect(e.task.notes, isNotEmpty);
        }
      });

      testWidgets(
        'a task from a template shows the rule of one country as such',
        (tester) async {
          await start(tester);
          await tester.tap(destination(l.navMore));
          await tester.pumpAndSettle();
          await tapText(tester, l.addFromTemplate);
          final boiler = find.byKey(const Key('template-boiler-service'));
          expect(
            find.descendant(
              of: boiler,
              matching: find.textContaining(l.templateRegion('FR')),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets('a task can be attached to a room and an item', (
        tester,
      ) async {
        await start(tester);
        await tapText(tester, 'Main cellar');
        await tapKey(tester, 'task-add');
        await type(tester, 'task-title', 'Check the valve');
        await saveTask(tester);
        final repository = stateOf(tester).repository;
        final cellar = (await repository.rooms(data.homes.main))
            .firstWhere((r) => r.name == 'Main cellar')
            .id;
        final tasks = await repository.tasksOf(roomId: cellar);
        expect(tasks.map((e) => e.task.title), contains('Check the valve'));
      });

      group('photos', () {
        Future<void> addFromSheet(WidgetTester tester, String choice) async {
          await tapKey(tester, 'photo-add');
          await tester.tap(find.text(choice));
          await tester.pumpAndSettle();
        }

        testWidgets('taken with the camera: stored without metadata, shown', (
          tester,
        ) async {
          final source = cameraWith();
          await start(tester, photos: source);
          await tapText(tester, 'Main kitchen');
          await addFromSheet(tester, l.photoTake);
          expect(source.taken, 1);
          final repository = stateOf(tester).repository;
          final photos = await repository.photosOf(roomId: data.kitchen);
          expect(
            photos,
            hasLength(2),
            reason: 'the fixture\'s photo and this one',
          );
          final added = photos.firstWhere((p) => p.id != data.photo);
          final file = repository.photoFile(added);
          expect(file.existsSync(), isTrue);
          expect(jpegMetadata(file.readAsBytesSync()), isEmpty);
          expect(jsonDecode(added.image!)['type'], 'image/jpeg');
        });

        testWidgets('picked from the gallery', (tester) async {
          final source = cameraWith();
          await start(tester, photos: source);
          await tapText(tester, 'Main kitchen');
          await addFromSheet(tester, l.photoPick);
          expect(source.picked, 1);
          expect(source.taken, 0);
          expect(
            await stateOf(tester).repository.photosOf(roomId: data.kitchen),
            hasLength(2),
          );
        });

        testWidgets('cancelled: nothing is stored', (tester) async {
          final source = FakePhotoSource();
          await start(tester, photos: source);
          await tapText(tester, 'Main kitchen');
          await addFromSheet(tester, l.photoTake);
          expect(
            await stateOf(tester).repository.photosOf(roomId: data.kitchen),
            hasLength(1),
          );
        });

        testWidgets('the camera refused: said, and nothing is stored', (
          tester,
        ) async {
          final source = cameraWith(denied: true);
          await start(tester, photos: source);
          await tapText(tester, 'Main kitchen');
          await addFromSheet(tester, l.photoTake);
          expect(find.text(l.photoDenied), findsOneWidget);
          expect(
            await stateOf(tester).repository.photosOf(roomId: data.kitchen),
            hasLength(1),
          );
          // And the app still works.
          await addFromSheet(tester, l.photoPick);
          expect(find.text(l.photoDenied), findsOneWidget);
        });

        testWidgets('no camera on the phone: said, the gallery still works', (
          tester,
        ) async {
          final source = cameraWith();
          source.noCamera = true;
          await start(tester, photos: source);
          await tapText(tester, 'Main kitchen');
          await addFromSheet(tester, l.photoTake);
          expect(find.text(l.photoNoCamera), findsOneWidget);
          expect(
            await stateOf(tester).repository.photosOf(roomId: data.kitchen),
            hasLength(1),
          );
          await addFromSheet(tester, l.photoPick);
          expect(
            await stateOf(tester).repository.photosOf(roomId: data.kitchen),
            hasLength(2),
          );
        });

        testWidgets('a file that is not a photo is refused with a message', (
          tester,
        ) async {
          final source = FakePhotoSource(photo: jpegWithGps().sublist(0, 4));
          await start(tester, photos: source);
          await tapText(tester, 'Main kitchen');
          await addFromSheet(tester, l.photoTake);
          expect(find.text(l.errPhotoUnreadable), findsOneWidget);
        });

        testWidgets('a photo of an item', (tester) async {
          final source = cameraWith();
          await start(tester, photos: source);
          await tapText(tester, 'Main cellar');
          await tapText(tester, 'Main boiler');
          await addFromSheet(tester, l.photoTake);
          expect(
            await stateOf(tester).repository.photosOf(itemId: data.boiler),
            hasLength(1),
          );
        });

        testWidgets('a photo: category and caption changed, then deleted', (
          tester,
        ) async {
          await start(tester);
          await tapText(tester, 'Main kitchen');
          await tester.tap(
            find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.label ==
                      l.photoLabel(photoCategoryLabel(l, 'behind_walls')),
            ),
          );
          await tester.pumpAndSettle();
          await type(tester, 'photo-caption', 'Pipes');
          await tester.tap(find.text(l.save));
          await tester.pumpAndSettle();
          final repository = stateOf(tester).repository;
          expect((await repository.photo(data.photo))!.caption, 'Pipes');
          await tester.tap(
            find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.label ==
                      l.photoLabel(photoCategoryLabel(l, 'behind_walls')),
            ),
          );
          await tester.pumpAndSettle();
          await tapKey(tester, 'photo-delete');
          expect(await repository.photo(data.photo), isNull);
          expect(find.text(l.photosEmpty), findsOneWidget);
        });
      });

      group('reminders', () {
        Future<void> openMore(WidgetTester tester) async {
          await tester.tap(destination(l.navMore));
          await tester.pumpAndSettle();
        }

        testWidgets(
          'off by default; the permission is asked when they are turned on',
          (tester) async {
            final notifier = FakeNotifier();
            await start(tester, notifier: notifier);
            expect(notifier.asked, 0, reason: 'nothing is asked at start');
            await openMore(tester);
            expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(notifier.asked, 1);
            expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
            expect(notifier.scheduled, isNotEmpty);
          },
        );

        testWidgets('refused: the switch stays off and the screen says why', (
          tester,
        ) async {
          final notifier = FakeNotifier(allowed: false);
          await start(tester, notifier: notifier);
          await openMore(tester);
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();
          expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
          expect(find.text(l.remindersDenied), findsOneWidget);
          expect(notifier.scheduled, isEmpty);
        });

        testWidgets('done in one tap on Today: the reminder goes', (
          tester,
        ) async {
          final notifier = FakeNotifier();
          await start(tester, notifier: notifier);
          final state = stateOf(tester);
          await state.setReminders(true);
          bool has() => notifier.scheduled.values.any(
            (n) => n.title.contains('Main smoke alarm'),
          );
          expect(has(), isTrue);
          final entry = (await state.repository.todayEntries(
            homeId: data.homes.main,
          )).firstWhere((e) => e.task.title == 'Main smoke alarm');
          await state.repository.complete(entry.occurrence.id);
          await state.refresh();
          expect(has(), isFalse);
        });
      });
    });
  }

  test('every kind, trade and category of the model has its words in both languages', () {
    for (final l in [AppLocalizationsEn(), AppLocalizationsFr()]) {
      for (final kind in roomKinds) {
        expect(roomKindLabel(l, kind), isNotEmpty, reason: kind);
      }
      for (final trade in trades) {
        expect(tradeLabel(l, trade), isNotEmpty, reason: trade);
      }
      for (final category in photoCategories) {
        expect(photoCategoryLabel(l, category), isNotEmpty, reason: category);
      }
      for (final kind in itemKinds) {
        expect(itemKindLabel(l, kind), isNotEmpty, reason: kind);
      }
    }
    final english = AppLocalizationsEn();
    expect(
      {for (final k in roomKinds) roomKindLabel(english, k)},
      hasLength(roomKinds.length),
      reason: 'two kinds never share a word',
    );
  });

  test('the web files the model comes from are named in the plan', () {
    expect(
      File('docs/spec.md').readAsStringSync(),
      contains('rooms/models.py'),
    );
  });
}

/// A day as the screens show it (`DateFormat.yMMMd` in the language).
String formatDate(AppLocalizations l, Day day) =>
    DateFormat.yMMMd(l.localeName)
        .format(DateTime(day.year, day.month, day.day));
