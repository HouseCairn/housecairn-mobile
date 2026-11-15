// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/ui/contractor_screens.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/photos.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/reminders_row.dart';
import 'package:housecairn_mobile/ui/templates_screen.dart';

import 'lot2b.dart';

/// The screens of lot 2b, each opened as the app opens it. `page` is the
/// name of the golden file.
final screens2b =
    <(String page, Future<void> Function(WidgetTester, Lot2b, Labels))>[
      ('rooms', (tester, data, l) => openRooms(tester, l.rooms)),
      (
        'room',
        (tester, data, l) => openScreen(
          tester,
          RoomScreen(homeId: data.homes.main, roomId: data.kitchen),
        ),
      ),
      (
        'item',
        (tester, data, l) => openScreen(
          tester,
          ItemScreen(homeId: data.homes.main, itemId: data.boiler),
        ),
      ),
      (
        'contractors',
        (tester, data, l) => openScreen(tester, const ContractorsScreen()),
      ),
      (
        'contractor',
        (tester, data, l) => openScreen(
          tester,
          ContractorScreen(homeId: data.homes.main, contractorId: data.plumber),
        ),
      ),
      (
        'room_form',
        (tester, data, l) => openScreen(
          tester,
          RoomFormScreen(homeId: data.homes.main, roomId: data.kitchen),
        ),
      ),
      (
        'item_form',
        (tester, data, l) => openScreen(
          tester,
          ItemFormScreen(
            homeId: data.homes.main,
            roomId: data.cellar,
            itemId: data.boiler,
          ),
        ),
      ),
      (
        'contractor_form',
        (tester, data, l) => openScreen(
          tester,
          ContractorFormScreen(
            homeId: data.homes.main,
            contractorId: data.plumber,
          ),
        ),
      ),
      (
        'photo',
        (tester, data, l) => openScreen(
          tester,
          PhotoScreen(photoId: data.photo, writable: true),
        ),
      ),
      (
        'templates',
        (tester, data, l) => openScreen(tester, const TemplatesScreen()),
      ),
      (
        'reminders',
        // The switch of the reminders is on Notifications (More, Me).
        (tester, data, l) => openScreen(tester, const NotificationsScreen()),
      ),
    ];

/// The few words of the navigation, by language.
typedef Labels = ({
  String rooms,
  String more,
  String stock,
  String materials,
  String projects,
  String budget,
  String budgetRooms,
  String budgetProjects,
  String budgetUpkeep,
  String doneFilter,
});

const labels = {
  'en': (
    rooms: 'Rooms',
    more: 'More',
    stock: 'Stock',
    materials: 'MATERIALS',
    projects: 'Projects',
    budget: 'Budget',
    budgetRooms: 'Rooms',
    budgetProjects: 'Projects',
    budgetUpkeep: 'Upkeep',
    doneFilter: 'Done',
  ),
  'fr': (
    rooms: 'Pièces',
    more: 'Plus',
    stock: 'Matériel',
    materials: 'FOURNITURES',
    projects: 'Projets',
    budget: 'Budget',
    budgetRooms: 'Pièces',
    budgetProjects: 'Projets',
    budgetUpkeep: 'Entretien',
    doneFilter: 'Faites',
  ),
};
