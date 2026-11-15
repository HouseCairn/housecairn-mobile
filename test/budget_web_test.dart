// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';

import 'support/budget_fixture.dart';
import 'support/fixture.dart';

/// The criterion of lot 3 (docs/plan.md): the budget figures of a fixed home
/// equal those of the web application for the same data. The fixture is
/// loaded here through the repository of the app, and by
/// tool/budget_figures.py into the web application at the release pinned in
/// tool/web_alignment.json (CI regenerates that file with
/// `tool/web_alignment.py check`, element `budget`). Every figure is compared:
/// planned, committed, paid, engaged, gap and still to pay, of every year, by
/// year, envelope, room, project, task and nature, the projected times of
/// each task and the last 12 months.
void main() {
  test('the web figures were computed at the pinned web release', () {
    final pin =
        (jsonDecode(File('tool/web_alignment.json').readAsStringSync())
                as Map<String, dynamic>)['elements']['budget']
            as Map<String, dynamic>;
    final source = readWebFigures()['source'] as Map<String, dynamic>;
    expect(source['commit'], pin['commit']);
    expect(source['fixture'], 'test/fixtures/budget_fixture.json');
  });

  test('every budget figure of the two homes equals the web\'s', () async {
    final fixture = readBudgetFixture();
    final clock = FixedClock(testNow);
    final repo = await openRepository(clock: clock);
    final keys = await loadBudgetFixture(repo, clock, fixture);
    final web = readWebFigures()['homes'] as Map<String, dynamic>;
    expect(keys.keys, unorderedEquals(web.keys));
    final today = Day.parse(fixture['today'] as String);
    for (final MapEntry(key: home, value: ids) in keys.entries) {
      final ledger = await repo.ledger(ids['home']!, today: today);
      final mine = jsonDecode(jsonEncode(figuresOf(ledger, ids)));
      final differences = <String>[];
      _compare(home, mine, web[home], differences);
      expect(differences, isEmpty, reason: differences.take(20).join('\n'));
    }
  });

  test('the two homes keep their currencies and are never added', () async {
    final fixture = readBudgetFixture();
    final clock = FixedClock(testNow);
    final repo = await openRepository(clock: clock);
    final keys = await loadBudgetFixture(repo, clock, fixture);
    final today = Day.parse(fixture['today'] as String);
    final a = await repo.ledger(keys['a']!['home']!, today: today);
    final b = await repo.ledger(keys['b']!['home']!, today: today);
    expect((a.currency, b.currency), ('EUR', 'CHF'));
    expect(a.envelopes[2026].toString(), '5000');
    expect(b.envelopes[2026].toString(), '120');
    // Not a row of one home is in the ledger of the other.
    final idsA = {for (final p in a.projects) p.project.id};
    expect(b.projects.where((p) => idsA.contains(p.project.id)), isEmpty);
    expect(
      b.tasks
          .map((t) => t.task.id)
          .toSet()
          .intersection(a.tasks.map((t) => t.task.id).toSet()),
      isEmpty,
    );
  });
}

void _compare(String path, Object? mine, Object? web, List<String> out) {
  if (web is Map) {
    if (mine is! Map) {
      out.add('$path: app $mine, web $web');
      return;
    }
    for (final key in {...web.keys, ...mine.keys}) {
      _compare('$path.$key', mine[key], web[key], out);
    }
  } else if (web is List) {
    if (mine is! List || mine.length != web.length) {
      out.add('$path: app ${jsonEncode(mine)}, web ${jsonEncode(web)}');
      return;
    }
    for (var i = 0; i < web.length; i++) {
      _compare('$path[$i]', mine[i], web[i], out);
    }
  } else if (mine != web) {
    out.add('$path: app $mine, web $web');
  }
}
