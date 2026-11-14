// SPDX-License-Identifier: AGPL-3.0-only

// The recurrence port (lib/domain/recurrence.dart) against the vectors
// generated from the Python module of the web application by
// tool/recurrence_vectors.py (docs/plan.md, lot 2: "passes every vector of a
// file generated from the Python module").

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/recurrence.dart';

typedef Json = Map<String, dynamic>;

Rule ruleOf(Object? json) {
  final rule = json! as Json;
  return Rule(
    mode: rule['mode'] as String,
    unit: rule['unit'] as String,
    interval: rule['interval'] as int,
    seasonStart: rule['season_start'] as int?,
    seasonEnd: rule['season_end'] as int?,
  );
}

Day? dayOf(Object? value) => value == null ? null : Day.parse(value as String);

List<String> isoList(List<Day> days) => [for (final d in days) d.iso];

List<int>? windowJson((int, int)? window) =>
    window == null ? null : [window.$1, window.$2];

void main() {
  final document = jsonDecode(
    File('test/fixtures/recurrence_vectors.json').readAsStringSync(),
  ) as Json;
  List<Json> vectors(String name) =>
      (document[name] as List<dynamic>).cast<Json>();

  test('the vectors come from the Python module of the web application', () {
    final source = document['source'] as Json;
    expect(source['repository'], 'HouseCairn/housecairn');
    expect(source['module'], 'housecairn.tasks.recurrence');
    expect(source['commit'], matches(RegExp(r'^[0-9a-f]{40}$')));
  });

  test('the file covers the cases of the plan', () {
    final next = vectors('next_due');
    bool any(bool Function(Json v) p) => next.any(p);
    String? anchor(Json v) => v['anchor'] as String?;
    Json rule(Json v) => v['rule'] as Json;
    // Month ends, 29 February, both hemispheres, after_last, old series.
    expect(any((v) => anchor(v)?.endsWith('-31') ?? false), isTrue);
    expect(any((v) => anchor(v)?.endsWith('-02-29') ?? false), isTrue);
    expect(any((v) => rule(v)['mode'] == afterLast), isTrue);
    expect(
      any((v) => (anchor(v) ?? '9999').compareTo('1960') < 0),
      isTrue,
      reason: 'a fixed series begun decades ago',
    );
    for (final hemisphere in [north, south]) {
      for (final season in predefinedSeasons) {
        final (start, end) = seasonWindow(season, hemisphere)!;
        expect(
          any(
            (v) =>
                rule(v)['season_start'] == start &&
                rule(v)['season_end'] == end,
          ),
          isTrue,
          reason: '$season, $hemisphere',
        );
      }
    }
    expect(
      any((v) => v['expected'] == null && rule(v)['mode'] != once),
      isTrue,
    );
  });

  test('next_due gives the date of the web for every vector', () {
    final failures = <String>[];
    for (final v in vectors('next_due')) {
      final got = nextDue(
        ruleOf(v['rule']),
        anchor: dayOf(v['anchor']),
        dueOn: dayOf(v['due_on']),
        doneOn: dayOf(v['done_on'])!,
      );
      if (got?.iso != v['expected']) failures.add('$v: got $got');
    }
    expect(failures, isEmpty);
    expect(vectors('next_due'), hasLength(greaterThan(1000)));
  });

  test('coming gives the dates of the web for every vector', () {
    final failures = <String>[];
    for (final v in vectors('coming')) {
      final got = coming(
        ruleOf(v['rule']),
        anchor: dayOf(v['anchor']),
        after: dayOf(v['after'])!,
        since: dayOf(v['since'])!,
        end: dayOf(v['end'])!,
      );
      final expected = (v['expected'] as List<dynamic>).cast<String>();
      if (!listEquals(isoList(got), expected)) {
        failures.add('$v: got ${isoList(got)}');
      }
    }
    expect(failures, isEmpty);
  });

  test('preview gives the dates of the web for every vector', () {
    final failures = <String>[];
    for (final v in vectors('preview')) {
      final got = preview(
        ruleOf(v['rule']),
        anchor: dayOf(v['anchor']),
        dueOn: dayOf(v['due_on'])!,
        count: v['count'] as int,
      );
      final expected = (v['expected'] as List<dynamic>).cast<String>();
      if (!listEquals(isoList(got), expected)) {
        failures.add('$v: got ${isoList(got)}');
      }
    }
    expect(failures, isEmpty);
  });

  test('problems, seasons and in_season match the web', () {
    for (final v in vectors('problems')) {
      expect(problems(ruleOf(v['rule'])), v['expected'], reason: '$v');
    }
    for (final v in vectors('season_window')) {
      expect(
        windowJson(
          seasonWindow(v['season'] as String, v['hemisphere'] as String),
        ),
        v['expected'],
        reason: '$v',
      );
    }
    for (final v in vectors('legacy_season')) {
      expect(
        windowJson(
          legacySeason(v['season'] as String, v['hemisphere'] as String),
        ),
        v['expected'],
        reason: '$v',
      );
    }
    for (final v in vectors('season_named')) {
      expect(
        seasonNamed(v['start'] as int?, v['end'] as int?),
        v['expected'],
        reason: '$v',
      );
    }
    for (final v in vectors('in_season')) {
      expect(
        inSeason(ruleOf(v['rule']), dayOf(v['day'])!),
        v['expected'],
        reason: '$v',
      );
    }
  });

  group('Day', () {
    test('counts days as Python dates do, over the whole calendar', () {
      expect(Day(1970, 1, 1).epochDay, 0);
      expect(Day(1, 1, 1).epochDay, -719162);
      expect(Day(9999, 12, 31).epochDay, 2932896);
      for (var n = -719162; n <= 2932896; n += 997) {
        expect(Day.fromEpochDay(n).epochDay, n);
      }
      expect(() => Day(10000, 1, 1), throwsA(isA<DayOutOfRange>()));
      expect(() => Day(2023, 2, 29), throwsA(isA<DayOutOfRange>()));
      expect(() => Day(9999, 12, 31).addDays(1), throwsA(isA<DayOutOfRange>()));
    });

    test('adds months and years as relativedelta does', () {
      expect(Day(2024, 1, 31).addMonths(1), Day(2024, 2, 29));
      expect(Day(2023, 1, 31).addMonths(1), Day(2023, 2, 28));
      expect(Day(2024, 2, 29).addYears(1), Day(2025, 2, 28));
      expect(Day(2024, 3, 31).addMonths(-1), Day(2024, 2, 29));
      expect(Day.parse('2026-11-14').iso, '2026-11-14');
    });

    test('floorDiv rounds as Python //', () {
      expect(floorDiv(-7, 2), -4);
      expect(floorDiv(7, 2), 3);
      expect(floorDiv(-8, 2), -4);
    });
  });
}
