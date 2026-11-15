// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/arb.dart';

/// The terms of the glossary of the web (design/glossary.json, a copy of the web file,
/// design/patterns.md of HouseCairn/housecairn), by id.
final Map<String, Map<String, dynamic>> glossary = {
  for (final term
      in (jsonDecode(File('design/glossary.json').readAsStringSync())
              as Map<String, dynamic>)['terms']
          as List<dynamic>)
    (term as Map<String, dynamic>)['id'] as String: term,
};

/// The ARB keys that show a term of the glossary, and the term.
const keys = <String, String>{
  'navToday': 'today',
  'todayToday': 'today',
  'navRooms': 'rooms',
  'budgetRooms': 'rooms',
  'navProjects': 'projects',
  'budgetProjects': 'projects',
  'navBudget': 'budget',
  'budgetHeading': 'budget',
  'navMore': 'more',
  'moreHouseholdGroup': 'home',
  'moreHelpGroup': 'help',
  'about': 'about',
  'homes': 'my-homes',
  'contractors': 'contractors',
  'room': 'room',
  'item': 'item',
  'itemKindEquipment': 'equipment',
  'stock': 'stock',
  'materialArticle': 'stock-item',
  'materials': 'materials',
  'natureMaterial': 'materials',
  'suppliers': 'suppliers',
  'paintArticle': 'paint-left',
  'budgetUpkeep': 'upkeep',
  'actionDone': 'done',
  'actionPostpone': 'postpone',
  'actionSkip': 'skip',
  'undo': 'undo',
  'edit': 'edit',
  'save': 'save',
  'cancel': 'cancel',
  'delete': 'delete',
  'todayOverdue': 'overdue',
  'todayComingUp': 'coming-up',
  'todayNoDate': 'no-date',
  'repeat': 'repeat',
  'season': 'season',
  'priority': 'priority',
  'addTask': 'add-task',
  'addRoom': 'add-room',
  'addItem': 'add-item',
  'addPhoto': 'add-photo',
  'reports': 'reports',
  'reportProblem': 'report-a-problem',
  'reportsClosed': 'reports-closed',
  'reportsAll': 'reports-all',
  'whatIsWrong': 'what-is-wrong',
  'reportWhere': 'where',
  'sendReport': 'send-report',
  'envelope': 'envelope',
  'spent': 'spent',
  'amountPlanned': 'amount-planned',
  'amountCommitted': 'committed',
  'amountPaid': 'paid',
  'projectsInProgress': 'in-progress',
  'projectsIdeas': 'ideas',
  'projectsFinished': 'finished-tab',
  'quotes': 'quotes',
};

/// Keys known to differ from the glossary, with the lot that aligns them
/// (design/patterns.md of the web, Gaps at the time of writing). The test fails
/// once a key agrees, so that this list only shrinks.
const pending = <String, String>{
  'homes': 'lot D6: "My homes" / "Mes logements" (app: Homes / Logements)',
  'moreHouseholdGroup': 'lot D6: the group of More is "Home" / "Logement"; "Foyer" names the members',
  'whatIsWrong': 'lot D6: the labels of the report form are the web\'s',
  'reportWhere': 'lot D6: the labels of the report form are the web\'s',
  'sendReport': 'lot D6: the labels of the report form are the web\'s',
};

void main() {
  final en = arbMessages('en');
  final fr = arbMessages('fr');

  test('every key and term of the table exists', () {
    for (final entry in keys.entries) {
      expect(en, contains(entry.key), reason: 'no ARB key ${entry.key}');
      expect(glossary, contains(entry.value), reason: 'no term ${entry.value}');
    }
    for (final key in pending.keys) {
      expect(keys, contains(key), reason: 'pending key $key is not in keys');
    }
  });

  for (final entry in keys.entries) {
    test('${entry.key} says the term ${entry.value} of the glossary', () {
      final term = glossary[entry.value]!;
      final agrees = en[entry.key] == term['en'] && fr[entry.key] == term['fr'];
      if (pending.containsKey(entry.key)) {
        expect(
          agrees,
          isFalse,
          reason:
              '${entry.key} now agrees with the glossary: remove it from pending',
        );
      } else {
        expect(en[entry.key], term['en'], reason: '${entry.key} (en)');
        expect(fr[entry.key], term['fr'], reason: '${entry.key} (fr)');
      }
    });
  }
}
