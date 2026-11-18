// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';

import 'package:decimal/decimal.dart';

/// The interactive guide of web ADR 0084: its content, read from
/// `design/guide.json` (a byte-for-byte copy of the web file), and the
/// evaluator of the states that tick its steps, the port of
/// `housecairn.guide.states` of the web.
///
/// A step ticks when the state of the data of the example home that the
/// file names is true: an entity, a minimum number of rows and filters on
/// fields. A tick is stored as soon as its state is true, and it stays: the
/// guide never goes backwards. [rowMatches], [satisfied], [trueSteps] and
/// [tickedAfter] are pure, over rows as `{entity, fields}`; the vectors of
/// the web (`test/fixtures/guide_states.json`) run them.

/// The language of the file used when a text has none in the language asked.
const guideFallbackLanguage = 'en';

/// A row as the states read it: an entity of the web (`rooms.room`) and its
/// fields, named as in the `where` of the file (a foreign key without
/// `_id`), a decimal as a string.
class GuideRow {
  const GuideRow(this.entity, this.fields);

  final String entity;
  final Map<String, Object?> fields;

  @override
  String toString() => 'GuideRow($entity, $fields)';
}

/// A step of a scenario.
class GuideStep {
  const GuideStep({
    required this.id,
    required this.raw,
    this.doneWhen,
    this.manual = false,
  });

  /// `<scenario>.<number>` (`create-home.1`).
  final String id;

  /// Its state, `{entity, min, where}`, when the data can say that it is done.
  final Map<String, Object?>? doneWhen;

  /// A step that has no state: ticked by hand.
  final bool manual;

  /// Every key of the step as the file has it (title, explain, screen,
  /// suggest...), for the screens.
  final Map<String, Object?> raw;
}

/// A scenario: a short list of steps.
class GuideScenario {
  const GuideScenario({
    required this.id,
    required this.steps,
    required this.raw,
  });

  final String id;
  final List<GuideStep> steps;
  final Map<String, Object?> raw;
}

/// A row of the example home in the file: `{key, entity, stage, fields}`.
class ExampleRow {
  const ExampleRow({
    required this.key,
    required this.entity,
    required this.stage,
    required this.fields,
  });

  final String key;
  final String entity;

  /// The number of the scenario that makes it.
  final int stage;
  final Map<String, Object?> fields;
}

/// The content of `design/guide.json`.
class Guide {
  const Guide({
    required this.version,
    required this.home,
    required this.rows,
    required this.scenarios,
  });

  final int version;

  /// The example home itself: `name` (a text), `currency`, `hemisphere`.
  final Map<String, Object?> home;

  /// The rows of the example home but the home itself, in the order of the
  /// file (a row refers only to rows before it).
  final List<ExampleRow> rows;
  final List<GuideScenario> scenarios;

  /// Every step of every scenario, in order.
  List<GuideStep> get steps => [for (final s in scenarios) ...s.steps];

  /// The languages the file is written in, those of the name of the home.
  Set<String> get languages =>
      (home['name']! as Map).keys.cast<String>().toSet();

  /// The language of the file that serves [code] (`fr-CA` reads `fr`),
  /// English when the file does not have it (`content.language_in_file`).
  String languageFor(String? code) {
    final base = (code ?? '')
        .toLowerCase()
        .replaceAll('_', '-')
        .split('-')
        .first;
    return languages.contains(base) ? base : guideFallbackLanguage;
  }

  /// A value of the file in [language]: a text in every language of the
  /// file reads as one, any other value as it is (`content.text`).
  Object? text(Object? value, String language) {
    if (value is Map &&
        value.keys.toSet().containsAll(languages) &&
        languages.containsAll(value.keys.cast<String>())) {
      final chosen = value[language];
      return (chosen == null || chosen == '')
          ? value[guideFallbackLanguage]
          : chosen;
    }
    return value;
  }
}

Map<String, Object?> _map(Object? value, String what) {
  if (value is! Map) throw FormatException('$what is not an object');
  return value.cast<String, Object?>();
}

/// The guide from the JSON of `design/guide.json`; a [FormatException] when
/// it is not of the version this code reads (1).
Guide parseGuide(String source) {
  final document = _map(jsonDecode(source), 'The guide');
  if (document['version'] != 1) {
    throw const FormatException('The guide is not of version 1.');
  }
  final example = _map(document['example'], 'example');
  final home = _map(example['home'], 'example.home');
  final rows = [
    for (final raw in example['rows']! as List)
      () {
        final row = _map(raw, 'a row of the example');
        return ExampleRow(
          key: row['key']! as String,
          entity: row['entity']! as String,
          stage: row['stage']! as int,
          fields: _map(row['fields'], 'fields'),
        );
      }(),
  ];
  final scenarios = [
    for (final raw in document['scenarios']! as List)
      () {
        final scenario = _map(raw, 'a scenario');
        return GuideScenario(
          id: scenario['id']! as String,
          raw: scenario,
          steps: [
            for (final s in scenario['steps']! as List)
              () {
                final step = _map(s, 'a step');
                final state = step['done_when'];
                return GuideStep(
                  id: step['id']! as String,
                  raw: step,
                  doneWhen: state == null ? null : _map(state, 'done_when'),
                  manual: step['manual'] == true,
                );
              }(),
          ],
        );
      }(),
  ];
  return Guide(version: 1, home: home, rows: rows, scenarios: scenarios);
}

/// `Decimal(str(value))` of the web: a number written as text, or `null`.
Decimal? _decimal(Object? value) {
  if (value == null || value is bool) return null;
  return Decimal.tryParse('$value'.trim());
}

/// The equality of Python's `==` on JSON values: a number equals the same
/// number whatever its type, and a boolean is never equal to a number here
/// (the file compares no boolean to a number).
bool _equal(Object? a, Object? b) {
  if (a is num && b is num && a is! bool && b is! bool) return a == b;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_equal(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

/// Whether the fields of [row] satisfy every condition of [where].
///
/// A condition is a value (equality), `{"not": v}`, `{"gt": n}` (a number
/// above `n`) or `{"set": true|false}` (a field with a value, or without
/// one). An unknown operator is an error, as on the web.
bool rowMatches(GuideRow row, Map<String, Object?> where) {
  for (final MapEntry(key: name, value: wanted) in where.entries) {
    final value = row.fields[name];
    final bool ok;
    if (wanted is Map) {
      if (wanted.length != 1) {
        throw FormatException('A condition has one operator: $wanted');
      }
      final MapEntry(key: operator, value: operand) = wanted.entries.single;
      switch (operator) {
        case 'not':
          ok = !_equal(value, operand);
        case 'gt':
          final number = _decimal(value), limit = _decimal(operand);
          ok = number != null && limit != null && number > limit;
        case 'set':
          final present =
              value != null && value != '' && !(value is List && value.isEmpty);
          ok = present == (operand == true);
        default:
          throw FormatException('Unknown condition: $operator');
      }
    } else {
      ok = _equal(value, wanted);
    }
    if (!ok) return false;
  }
  return true;
}

/// The state that ticks a step: enough rows of the entity, each matching
/// `where`.
bool satisfied(Map<String, Object?> predicate, Iterable<GuideRow> rows) {
  final where =
      (predicate['where'] as Map?)?.cast<String, Object?>() ?? const {};
  final entity = predicate['entity'];
  final found = rows
      .where((r) => r.entity == entity && rowMatches(r, where))
      .length;
  return found >= (predicate['min']! as num).toInt();
}

/// The ids of the steps that have a state and whose state is true over
/// [rows].
List<String> trueSteps(Guide guide, List<GuideRow> rows) => [
  for (final step in guide.steps)
    if (step.doneWhen != null && satisfied(step.doneWhen!, rows)) step.id,
];

/// The steps ticked after each snapshot of the rows, a tick staying once it
/// is made.
List<List<String>> tickedAfter(
  Guide guide,
  Iterable<List<GuideRow>> snapshots,
) {
  final stored = <String>{};
  return [
    for (final rows in snapshots)
      () {
        stored.addAll(trueSteps(guide, rows));
        return [
          for (final step in guide.steps)
            if (stored.contains(step.id)) step.id,
        ];
      }(),
  ];
}

/// For each entity a state names, the fields its conditions read.
Map<String, Set<String>> wantedFields(Guide guide) {
  final wanted = <String, Set<String>>{};
  for (final step in guide.steps) {
    final predicate = step.doneWhen;
    if (predicate == null) continue;
    final where =
        (predicate['where'] as Map?)?.cast<String, Object?>() ?? const {};
    (wanted[predicate['entity']! as String] ??= {}).addAll(where.keys);
  }
  return wanted;
}
