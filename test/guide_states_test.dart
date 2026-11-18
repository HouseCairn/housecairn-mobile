// SPDX-License-Identifier: AGPL-3.0-only

// The evaluator of the steps of the guide (lib/domain/guide.dart) against
// the vectors written by the web (`guide.states`, web ADR 0084), carried
// byte for byte as test/fixtures/guide_states.json: every snapshot of every
// case gives the steps the web gives, a tick staying once it is made.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/domain/guide.dart';

typedef Json = Map<String, dynamic>;

final guide = parseGuide(File('design/guide.json').readAsStringSync());

List<GuideRow> rowsOf(Object? snapshot) => [
  for (final r in (snapshot! as Json)['rows'] as List)
    GuideRow(
      (r as Json)['entity'] as String,
      (r['fields'] as Map).cast<String, Object?>(),
    ),
];

void main() {
  final document = jsonDecode(
    File('test/fixtures/guide_states.json').readAsStringSync(),
  ) as Json;
  final cases = (document['cases'] as List).cast<Json>();

  test('the vectors are of version 1 and cover the cases of ADR 0084', () {
    expect(document['version'], 1);
    final names = [for (final c in cases) c['name']];
    expect(names, contains('marked done, then planned again: the tick stays'));
    expect(names, contains('a payment of 0.00 is not a payment'));
    expect(names, contains('everything of the example'));
  });

  for (final c in cases) {
    test('vector: ${c['name']}', () {
      final snapshots = (c['snapshots'] as List).cast<Json>();
      final expected = [
        for (final s in snapshots) (s['ticked'] as List).cast<String>(),
      ];
      expect(
        tickedAfter(guide, [for (final s in snapshots) rowsOf(s)]),
        expected,
      );
    });
  }

  test('every snapshot of every vector, one by one, ticks what the web '
      'ticks', () {
    var snapshots = 0;
    for (final c in cases) {
      final all = (c['snapshots'] as List).cast<Json>();
      final after = tickedAfter(guide, [for (final s in all) rowsOf(s)]);
      for (final (i, s) in all.indexed) {
        expect(
          after[i],
          (s['ticked'] as List).cast<String>(),
          reason: '${c['name']} #$i',
        );
        snapshots++;
      }
    }
    expect(cases, hasLength(10));
    expect(snapshots, 35);
  });

  test('the whole example ticks every step that has a state, and only '
      'those', () {
    final stated = [
      for (final s in guide.steps)
        if (s.doneWhen != null) s.id,
    ];
    final whole = cases.singleWhere(
      (c) => c['name'] == 'everything of the example',
    );
    final rows = rowsOf((whole['snapshots'] as List).single);
    expect(trueSteps(guide, rows), stated);
    expect(stated, hasLength(16));
    expect(
      [
        for (final s in guide.steps)
          if (s.manual) s.id,
      ],
      [
        'create-home.2',
        'create-home.3',
        'recurring-task.4',
        'report-problem.2',
      ],
    );
  });

  group('the conditions of `where`', () {
    GuideRow row(Map<String, Object?> fields) => GuideRow('x', fields);
    test('equality, not, gt, set', () {
      expect(rowMatches(row({'a': 'b'}), {'a': 'b'}), isTrue);
      expect(rowMatches(row({'a': 'c'}), {'a': 'b'}), isFalse);
      expect(
        rowMatches(row({'a': 'c'}), {
          'a': {'not': 'b'},
        }),
        isTrue,
      );
      expect(
        rowMatches(row({'a': null}), {
          'a': {'not': 'b'},
        }),
        isTrue,
      );
      expect(
        rowMatches(row({'p': '0.01'}), {
          'p': {'gt': 0},
        }),
        isTrue,
      );
      expect(
        rowMatches(row({'p': '0.00'}), {
          'p': {'gt': 0},
        }),
        isFalse,
      );
      expect(
        rowMatches(row({'p': null}), {
          'p': {'gt': 0},
        }),
        isFalse,
      );
      expect(
        rowMatches(row({'p': 'abc'}), {
          'p': {'gt': 0},
        }),
        isFalse,
      );
      expect(
        rowMatches(row({'b': 'x'}), {
          'b': {'set': true},
        }),
        isTrue,
      );
      expect(
        rowMatches(row({'b': ''}), {
          'b': {'set': true},
        }),
        isFalse,
      );
      expect(
        rowMatches(row({'b': null}), {
          'b': {'set': false},
        }),
        isTrue,
      );
      expect(
        rowMatches(row({'b': <Object>[]}), {
          'b': {'set': false},
        }),
        isTrue,
      );
      expect(rowMatches(row({'n': 1}), {'n': 1.0}), isTrue);
    });

    test('an unknown operator is an error, as on the web', () {
      expect(
        () => rowMatches(row({'a': 1}), {
          'a': {'lt': 2},
        }),
        throwsFormatException,
      );
    });
  });

  test('the language of the file: fr-FR reads fr, an unknown one English', () {
    expect(guide.languageFor('fr-FR'), 'fr');
    expect(guide.languageFor('fr_CA'), 'fr');
    expect(guide.languageFor('de'), 'en');
    expect(guide.languageFor(null), 'en');
    expect(guide.text(guide.home['name'], 'fr'), "Maison d'exemple");
    expect(guide.text('EUR', 'fr'), 'EUR');
  });
}
