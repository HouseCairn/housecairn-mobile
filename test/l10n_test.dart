// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';

const locales = ['en', 'fr'];

Set<String> placeholders(String message) => {
  for (final match in RegExp(
    r'\{([A-Za-z_][A-Za-z0-9_]*)\}',
  ).allMatches(message))
    match.group(1)!,
};

/// Opens every screen of the app, one after the other, and checks each.
Future<void> visitEveryScreen(
  WidgetTester tester,
  Future<void> Function(String screen) check,
) async {
  final bar = find.byType(NavigationBar);
  final destinations = find.descendant(
    of: bar,
    matching: find.byType(NavigationDestination),
  );
  expect(destinations, findsNWidgets(5));
  for (var i = 0; i < 5; i++) {
    await tester.tap(destinations.at(i));
    await tester.pumpAndSettle();
    await check('section ${i + 1}');
  }
  // More (the last section) is open: its entry About.
  await tester.tap(find.byIcon(Icons.info_outline));
  await tester.pumpAndSettle();
  await check('About');
}

void main() {
  group('ARB files', () {
    final en = arbMessages('en');

    for (final locale in locales) {
      test('$locale has every message of the English source, and no other', () {
        final messages = arbMessages(locale);
        expect(messages.keys.toSet(), en.keys.toSet());
        for (final key in en.keys) {
          expect(messages[key]!.trim(), isNotEmpty, reason: key);
          expect(
            placeholders(messages[key]!),
            placeholders(en[key]!),
            reason: key,
          );
        }
      });
    }

    test('every English message has a description for translators', () {
      final json = jsonDecode(
        File('lib/l10n/app_en.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final key in en.keys) {
        final meta = json['@$key'] as Map<String, dynamic>?;
        expect(meta?['description'], isA<String>(), reason: key);
      }
    });

    test('the attribution is the one of NOTICE, untranslated', () {
      final notice = File('NOTICE').readAsStringSync();
      expect(notice, contains('"Housecairn, by\n   Robvred"'));
      for (final locale in locales) {
        expect(
          arbMessages(locale)['aboutAttribution'],
          'Housecairn, by Robvred',
        );
      }
    });
  });

  group('Strings shown to people', () {
    for (final locale in locales) {
      testWidgets('every one is in the ARB file ($locale)', (tester) async {
        await pumpApp(tester, locale: locale);
        final offending = <String>[];
        await visitEveryScreen(tester, (screen) async {
          offending.addAll(
            textsNotInArb(tester, locale).map((t) => '$screen: $t'),
          );
        });
        expect(offending, isEmpty);
      });
    }

    testWidgets('a string written in the code is caught', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [Text('Housecairn'), Text('Hard-coded text')],
          ),
        ),
      );
      expect(textsNotInArb(tester, 'en'), ['Hard-coded text']);
    });

    test('a placeholder matches any value, the rest must be exact', () {
      final pattern = messagePattern('version {version}');
      expect(pattern.hasMatch('version 0.0.1'), isTrue);
      expect(pattern.hasMatch('Version 0.0.1'), isFalse);
      expect(pattern.hasMatch('version '), isFalse);
    });
  });
}
