// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/budget.dart' as budget;
import 'package:housecairn_mobile/domain/day.dart';

/// test/fixtures/budget_fixture.json, the rows the web and the app both
/// load (tool/budget_figures.py on the web's side).
Map<String, dynamic> readBudgetFixture() =>
    jsonDecode(File('test/fixtures/budget_fixture.json').readAsStringSync())
        as Map<String, dynamic>;

/// What the web computes from the fixture.
Map<String, dynamic> readWebFigures() =>
    jsonDecode(File('test/fixtures/budget_web_figures.json').readAsStringSync())
        as Map<String, dynamic>;

Day? _day(Object? text) => text == null ? null : Day.parse(text as String);

/// The homes of the fixture, loaded through the repository: every row the
/// screens would write, written by the same calls (projects at the day of
/// their creation, quotes accepted on their line, task budgets, materials,
/// envelopes). Only the occurrences of the tasks are written as rows, with
/// their statuses, dates and costs: what the budget reads of them.
/// Returns the ids of each home's rows by their keys in the fixture.
Future<Map<String, Map<String, String>>> loadBudgetFixture(
  Repository repo,
  FixedClock clock,
  Map<String, dynamic> fixture,
) async {
  final result = <String, Map<String, String>>{};
  for (final spec in (fixture['homes'] as List).cast<Map<String, dynamic>>()) {
    final keys = <String, String>{};
    final home = await repo.createHome(
      name: spec['name'] as String,
      currency: spec['currency'] as String,
    );
    keys['home'] = home;
    final rooms = <String, String>{};
    for (final (i, r)
        in (spec['rooms'] as List).cast<Map<String, dynamic>>().indexed) {
      rooms[r['key'] as String] = await repo.createRoom(
        home,
        name: r['name'] as String,
        position: i,
      );
      keys['room:${r['key']}'] = rooms[r['key']]!;
    }
    final articles = <String, String>{};
    for (final a in (spec['articles'] as List).cast<Map<String, dynamic>>()) {
      articles[a['key'] as String] = await repo.addArticle(
        home,
        ArticleInput(
          name: a['name'] as String,
          unit: 'piece',
          unitPrice: (a['unit_price'] as String?) ?? '',
        ),
      );
    }
    final projects = <String, String>{};
    for (final (i, p)
        in (spec['projects'] as List).cast<Map<String, dynamic>>().indexed) {
      clock.set(
        DateTime.parse('${p['created']}T12:00:00Z').add(Duration(seconds: i)),
      );
      final id = await repo.createProject(
        home,
        ProjectInput(
          title: p['title'] as String,
          status: p['status'] as String,
          roomIds: [for (final k in p['rooms'] as List) rooms[k]!],
        ),
      );
      projects[p['key'] as String] = id;
      keys['project:${p['key']}'] = id;
      final lines = <String, String>{};
      for (final l in (p['lines'] as List).cast<Map<String, dynamic>>()) {
        lines[l['key'] as String] = await repo.createLine(
          id,
          LineInput(
            label: l['label'] as String,
            nature: l['nature'] as String,
            planned: l['planned'] as String,
            paid: l['paid'] as String,
          ),
        );
      }
      for (final q in (p['quotes'] as List).cast<Map<String, dynamic>>()) {
        await repo.createQuote(
          id,
          QuoteInput(
            amount: q['amount'] as String,
            status: q['status'] as String,
            issuedOn: _day(q['issued_on']),
            budgetLineId: q['line'] == null ? null : lines[q['line']],
          ),
        );
      }
    }
    clock.set(DateTime.parse('${fixture['today']}T12:00:00Z'));
    for (final t in (spec['tasks'] as List).cast<Map<String, dynamic>>()) {
      clock.advance(const Duration(seconds: 1));
      final repeat = t['repeat'] as Map<String, dynamic>;
      final series = _day(t['series_start']);
      final id = await repo.createTask(
        home,
        TaskInput(
          title: t['title'] as String,
          roomId: t['room'] == null ? null : rooms[t['room']],
          repeatMode: repeat['mode'] as String,
          repeatUnit: repeat['unit'] as String,
          repeatInterval: repeat['interval'] as int,
          dueOn: series,
        ),
      );
      keys['task:${t['key']}'] = id;
      await repo.setTaskBudgets(
        id,
        material: (t['material_budget'] as String?) ?? '',
        labour: (t['labour_budget'] as String?) ?? '',
      );
      for (final [article, quantity]
          in (t['materials'] as List).cast<List<dynamic>>()) {
        await repo.saveMaterial(id, articles[article]!, quantity as String);
      }
      // The occurrences as rows: the first one the task was given goes.
      await (repo.db.delete(
        repo.db.occurrences,
      )..where((o) => o.taskId.equalsValue(id))).go();
      for (final [status, due, completed, cost]
          in (t['occurrences'] as List).cast<List<dynamic>>()) {
        await repo.db
            .into(repo.db.occurrences)
            .insert(
              OccurrencesCompanion.insert(
                id: repo.newId(),
                homeId: home,
                taskId: id,
                createdAt: 0,
                updatedAt: 0,
                status: Value(status as String),
                dueOn: Value(due as String?),
                completedOn: Value(completed as String?),
                actualCost: Value(cost as String?),
              ),
            );
      }
      if (t['project'] != null) {
        await repo.attachTask(projects[t['project']]!, id);
      }
    }
    for (final MapEntry(:key, :value)
        in (spec['envelopes'] as Map<String, dynamic>).entries) {
      await repo.setEnvelope(home, int.parse(key), value as String);
    }
    result[spec['key'] as String] = keys;
  }
  return result;
}

Map<String, String> _amounts(budget.Amounts a) => a.toJson();

String? _money(Object? value) => (value as Decimal?)?.toStringAsFixed(2);

/// Every figure of a home, in the shape tool/budget_figures.py writes.
Map<String, Object?> figuresOf(budget.Ledger ledger, Map<String, String> keys) {
  final keyOf = {for (final MapEntry(:key, :value) in keys.entries) value: key};
  String? short(String? id) => id == null ? null : keyOf[id]!.split(':').last;
  final years = ledger.years();
  return {
    'currency': ledger.currency,
    'years': years,
    'by_year': [
      for (final line in budget.byYear(ledger))
        {
          'year': line.year,
          'envelope': _money(line.envelope),
          'projects': _amounts(line.projects),
          'upkeep': _amounts(line.upkeep),
          'total': _amounts(line.total),
        },
    ],
    'envelope': {
      for (final year in years)
        '$year': () {
          final e = budget.envelope(ledger, year);
          return {
            'envelope': _money(e.envelope),
            'total': _amounts(e.total),
            'set_aside': _money(e.setAside),
            'spent': _money(e.spent),
            'left': _money(e.left),
            'left_over': _money(e.leftOver),
            'percent': e.percent,
            'left_to_plan': _money(e.leftToPlan),
            'left_to_spend': _money(e.leftToSpend),
          };
        }(),
    },
    'by_room': {
      for (final year in years)
        '$year': [
          for (final line in budget.byRoom(ledger, year).lines)
            {
              'room': short(line.id),
              'amounts': _amounts(line.amounts),
              'projects': _amounts(line.extra['projects']! as budget.Amounts),
              'upkeep': _amounts(line.extra['upkeep']! as budget.Amounts),
            },
        ],
    },
    'by_task': {
      for (final year in years)
        '$year': () {
          final report = budget.byTask(ledger, year);
          return {
            'unlisted': report.note['unlisted'],
            'total': _amounts(report.total),
            'lines': [
              for (final line in report.lines)
                {
                  'task': short(line.id),
                  'amounts': _amounts(line.amounts),
                  'estimate': _money(line.extra['estimate']),
                  'annual_cost': _money(line.extra['annual_cost']),
                  'stock_estimate': _money(line.extra['stock_estimate']),
                  'unpriced_materials': line.extra['unpriced_materials'],
                  'total_paid': _money(line.extra['total_paid']),
                  'missing_costs': line.extra['missing_costs'],
                  'projected': line.extra['projected'],
                },
            ],
          };
        }(),
    },
    'by_nature': {
      for (final year in years)
        '$year': [
          for (final line in budget.byNature(ledger, year))
            {'nature': line.label, 'amounts': _amounts(line.amounts)},
        ],
    },
    'by_project': () {
      final report = budget.byProject(ledger);
      return {
        'total': _amounts(report.total),
        'lines': [
          for (final line in report.lines)
            {
              'project': short(line.id),
              'amounts': _amounts(line.amounts),
              'year': line.extra['year'],
              'status': line.extra['status'],
              'tasks_planned': _money(line.extra['tasks_planned']),
            },
        ],
      };
    }(),
    'rolling': () {
      final r = budget.rolling(ledger);
      return {
        'since': r.since.iso,
        'until': r.until.iso,
        'upkeep': _amounts(r.upkeep),
        'missing': r.missing,
      };
    }(),
  };
}
