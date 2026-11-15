// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/sections.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';
import 'fixture.dart';

/// The data of the screens of lot 2b: the two homes of the plan's fixture,
/// and in the main home a room with its memory, an item with a warranty, a
/// contract and links, a contractor with every field, tasks and photos.
class Lot2b {
  late TwoHomes homes;
  late String kitchen;
  late String cellar;
  late String boiler;
  late String plumber;
  late String photo;

  static Future<Lot2b> seed(Repository repository) async {
    final data = Lot2b();
    data.homes = await TwoHomes.create(repository);
    final main = data.homes.main;
    final rooms = await repository.rooms(main);
    data.kitchen = rooms.firstWhere((r) => r.name == 'Main kitchen').id;
    await repository.updateRoom(
      data.kitchen,
      const RoomInput(
        name: 'Main kitchen',
        kind: 'kitchen',
        notes: 'South facing, two windows',
        paintColour: 'Sage green',
        paintBrand: 'Example Paints',
        paintReference: 'EP-1204',
        paintBatch: 'L-88',
        floorCovering: 'Terracotta tiles',
        wallCovering: 'Lime wash',
        memoryNotes: 'Water pipe behind the sink, 20 cm from the floor',
      ),
    );
    data.plumber = (await repository.contractors(main)).first.id;
    await repository.updateContractor(
      data.plumber,
      const ContractorInput(
        name: 'Main plumber',
        trade: 'plumber',
        phone: '+33 1 99 00 12 34',
        email: 'plumber@example.com',
        address: '1 Example street\n00000 Example City',
        note: 'Ask for the morning',
      ),
    );
    data.cellar = rooms.firstWhere((r) => r.name == 'Main cellar').id;
    data.boiler = (await repository.itemsOf(data.cellar)).first.id;
    await repository.updateItem(
      data.boiler,
      ItemInput(
        name: 'Main boiler',
        brand: 'Example Heat',
        model: 'EH-3000',
        serialNumber: 'SN-0042',
        installedOn: Day(2022, 10, 3),
        warrantyEndsOn: Day(2032, 10, 3),
        contractContractorId: data.plumber,
        contractNumber: 'C-2024-0187',
        contractUrl: 'https://example.com/contract',
        links: const [
          ItemLink(url: 'https://example.com/manual', label: 'Manual'),
          ItemLink(url: 'https://example.com/support'),
        ],
        notes: 'Bleed the radiators in October',
      ),
    );
    data.photo = (await repository.photosOf(roomId: data.kitchen)).first.id;
    await repository.updatePhoto(data.photo, category: 'behind_walls');
    // A task of the room and a task of the item.
    await repository.createTask(
      main,
      TaskInput(
        title: 'Descale the kettle',
        roomId: data.kitchen,
        dueOn: repository.today().addDays(5),
        repeatMode: 'after_last',
        repeatUnit: 'month',
      ),
    );
    await repository.createTask(
      main,
      TaskInput(title: 'Service the boiler', itemId: data.boiler),
    );
    return data;
  }
}

/// Opens [screen] on the navigator of Today, as the lists of the app do.
Future<void> openScreen(WidgetTester tester, Widget screen) async {
  // Pushed on the navigator of the section More, as its rows do: each section
  // has a navigator of its own (the floating buttons of two sections under
  // one navigator would share a hero tag).
  final more = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byType(NavigationDestination),
  );
  await tester.tap(more.last);
  await tester.pumpAndSettle();
  Navigator.of(tester.element(find.byType(MoreScreen)))
      .push(MaterialPageRoute<void>(builder: (_) => screen));
  await tester.pumpAndSettle();
}

/// A photo as the camera gives it, for the fake source.
FakePhotoSource cameraWith({bool denied = false}) =>
    FakePhotoSource(photo: jpegWithGps(orientation: 1), denied: denied);

/// The state of the app, to check what a screen changed.
AppState stateOf(WidgetTester tester) =>
    AppScope.of(tester.element(find.byType(Scaffold).first));

/// The rooms section opened.
Future<void> openRooms(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
  expect(find.byType(RoomsScreen), findsOneWidget);
}
