// SPDX-License-Identifier: AGPL-3.0-only

// The real cost of a done task, as the web counts it (web ADR 0090, 0091,
// 0092): the rule of lib/domain/costs.dart with the cases of the web's
// `tests/test_real_cost_of_stock.py` and `tests/test_real_cost_planned.py`,
// the Budget by nature, and the repository: the fields the server keeps are
// read from it, estimated on the phone until it answers, and never sent.

import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/budget.dart' as budget;
import 'package:housecairn_mobile/domain/costs.dart';
import 'package:housecairn_mobile/domain/stock.dart' show entryKind;
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/sync/transport.dart' show SyncOperation;

import 'drift/housecairn/generated/schema.dart';
import 'support/fixture.dart';

Decimal d(String text) => Decimal.parse(text);

void main() {
  group('the rule (tasks/costs.py of the web)', () {
    test('done without typing anything costs the stock', () {
      final used = stockUsed([(d('2'), d('45.50')), (d('1'), d('60.00'))]);
      expect(used.amount, d('151.00'));
      expect(realCost(null, used.amount), d('151.00'));
    });

    test('the amount typed is added to the stock', () {
      expect(realCost(d('40'), d('151.00')), d('191.00'));
    });

    test('an item without a price counts for nothing and is said', () {
      final used = stockUsed([(d('3'), null)]);
      expect([used.amount, used.unpriced, used.any], [d('0'), 1, true]);
      // Done without a cost, as before: no amount, which is not zero.
      expect(realCost(null, used.amount), isNull);
    });

    test('rounded once to the cent, half up', () {
      final used = stockUsed([
        for (var i = 0; i < 3; i++) (d('0.50'), d('0.01')),
      ]);
      // 3 x 0.005 = 0.015, rounded once: 0.02 (each rounded first: 0.03).
      expect(used.amount, d('0.02'));
      expect(stockUsed(const []).any, isFalse);
    });

    test('done with nothing typed pays the labour planned', () {
      expect(realCost(null, budget.zero, Planned(d('120'))), d('120'));
    });

    test('an amount typed replaces the plan', () {
      expect(realCost(d('90'), budget.zero, Planned(d('120'))), d('90'));
    });

    test('zero typed is zero, not the plan', () {
      expect(realCost(d('0'), budget.zero, Planned(d('120'))), d('0'));
      expect(rest(d('0'), Planned(d('120'))), d('0'));
    });

    test('stock and labour planned add up', () {
      expect(realCost(null, d('151.00'), Planned(d('120'))), d('271.00'));
    });

    test('with stock an amount typed replaces the plan, not the stock', () {
      expect(realCost(d('10'), d('151.00'), Planned(d('120'))), d('161.00'));
    });

    test('the material budget is not counted again over the stock', () {
      final plan = planWhenDone(
        inProject: false,
        labourBudget: d('120'),
        materialBudget: d('40'),
        materialFromStock: true,
      );
      expect([plan.labour, plan.material], [d('120'), null]);
    });

    test('a material budget without a priced stock is materials', () {
      final plan = planWhenDone(
        inProject: false,
        labourBudget: null,
        materialBudget: d('40'),
        materialFromStock: false,
      );
      expect([plan.labour, plan.material, plan.known], [null, d('40'), true]);
    });

    test('a task without a plan is still done without a cost', () {
      expect(realCost(null, budget.zero), isNull);
      expect(noPlan.known, isFalse);
    });

    test('a task of a project keeps no plan', () {
      final plan = planWhenDone(
        inProject: true,
        labourBudget: d('120'),
        materialBudget: d('40'),
        materialFromStock: false,
      );
      expect(plan.known, isFalse);
    });

    test('the plan counts as paid only when nothing is typed', () {
      final planned = Planned(d('120'), d('40'));
      expect(OccurrenceCost(null, nothingUsed, planned).fromPlan, planned);
      expect(OccurrenceCost(d('0'), nothingUsed, planned).fromPlan, noPlan);
    });
  });

  group('the Budget by nature (by_nature of the web)', () {
    budget.Ledger ledgerOf(
      List<budget.OccurrenceFacts> done, {
      String? labour,
    }) {
      final day = testToday;
      return budget.Ledger.of(
        currency: 'EUR',
        today: day,
        projects: const [],
        lines: const [],
        acceptedQuotes: const [],
        projectOfTask: const {},
        tasks: [
          budget.TaskFacts(
            id: 't',
            title: 'Service',
            labourBudget: labour == null ? null : d(labour),
            occurrences: done,
            stock: [(d('2'), d('45.50')), (d('1'), d('60.00'))],
          ),
        ],
        envelopes: const {},
        rooms: const [],
      );
    }

    Map<String, Decimal> paid(budget.Ledger ledger) => {
      for (final line in budget.byNature(ledger, testToday.year))
        line.label: line.amounts.paid,
    };

    budget.OccurrenceFacts done(OccurrenceCost cost) =>
        budget.OccurrenceFacts('done', testToday, testToday, cost.typed, cost);

    final stock = stockUsed([(d('2'), d('45.50')), (d('1'), d('60.00'))]);

    test('the stock is materials', () {
      final ledger = ledgerOf([done(OccurrenceCost(null, stock))]);
      final found = paid(ledger);
      expect(found[budget.material], d('151.00'));
      expect(found[budget.labour], d('0'));
      expect(found[budget.other], d('0'));
    });

    test('the amount typed follows the share of the estimate', () {
      final ledger = ledgerOf([
        done(OccurrenceCost(d('40'), stock)),
      ], labour: '151.00');
      final found = paid(ledger);
      // Estimate: 151.00 of materials from the stock, 151.00 of labour.
      expect(found[budget.material], d('171.00'));
      expect(found[budget.labour], d('20.00'));
      expect(found[budget.other], d('0'));
    });

    test('the labour planned is labour, the material planned materials', () {
      final ledger = ledgerOf([
        done(OccurrenceCost(null, nothingUsed, Planned(d('120'), d('40')))),
      ], labour: '120');
      final found = paid(ledger);
      expect(found[budget.labour], d('120'));
      expect(found[budget.material], d('40'));
      expect(found[budget.other], d('0'));
      final row = ledger.tasks.single.figures(budget.anytime);
      expect([row.paid, row.missing, row.typed], [d('160'), 0, d('0')]);
    });

    test('without an estimate only the amount typed is other', () {
      final figures = budget.TaskFigures(
        1,
        d('0'),
        d('0'),
        d('191.00'),
        0,
        0,
        d('151.00'),
      );
      expect(budget.realCostSplit(figures, d('0'), d('0')), (
        budget.zero,
        budget.zero,
      ));
      expect(figures.typed, d('40.00'));
    });
  });

  group('the repository', () {
    late Repository repo;
    late String home;
    late String task;
    late String filter;
    late String brush;

    setUp(() async {
      repo = await openRepository();
      home = await repo.createHome(name: 'Main home');
      filter = await repo.addArticle(
        home,
        const ArticleInput(name: 'Filter', unitPrice: '45.50'),
      );
      brush = await repo.addArticle(
        home,
        const ArticleInput(name: 'Brush', unitPrice: '60'),
      );
      for (final a in [filter, brush]) {
        await repo.recordMovement(a, kind: entryKind, quantity: '10');
      }
      task = await repo.createTask(
        home,
        TaskInput(title: 'Service', dueOn: testToday),
      );
      await repo.addMaterial(task, filter, '2');
      await repo.addMaterial(task, brush, '1');
    });

    Future<void> asServerHome() => repo.serverState.writeServerState(
      ServerSyncState(
        homes: [
          ServerHome(id: home, name: 'Main home', role: 'owner', members: []),
        ],
      ).encode(),
    );

    Future<OccurrenceCost> costOf(String id) async =>
        (await repo.costsOf(home, [(await repo.occurrence(id))!]))[id]!;

    Future<List<MaterialDrawRow>> drawsOf(String occurrence) => (repo.db.select(
      repo.db.materialDraws,
    )..where((r) => r.occurrenceId.equalsValue(occurrence))).get();

    var clock = 0;
    SyncOperation fromServer(
      String type,
      String id,
      Map<String, Object?> f,
    ) => {
      Op.type: type,
      Op.home: home,
      Op.id: id,
      Op.kind: Op.put,
      Op.clock: '7fffffffffff${(++clock).toRadixString(16).padLeft(4, '0')}',
      Op.device: b64(Uint8List(16)),
      Op.schema: 13,
      Op.fields: f,
    };

    Future<String> doneOne() async {
      final open = (await repo.openOccurrencesOf(task)).single;
      await repo.complete(open.id);
      return open.id;
    }

    test('alone, the phone counts the stock it used at the prices of now: '
        '151', () async {
      final id = await doneOne();
      final cost = await costOf(id);
      expect(
        [cost.total, cost.stock.amount, cost.estimated],
        [d('151.00'), d('151.00'), false],
      );
      final ledger = await repo.ledger(home);
      expect(ledger.tasks.single.figures(budget.anytime).paid, d('151.00'));
    });

    test('with a server, a closing not yet taken is an estimate, then the '
        'values the server kept replace it', () async {
      await asServerHome();
      await repo.setTaskBudgets(task, material: '', labour: '120');
      final id = await doneOne();
      final estimate = await costOf(id);
      expect(estimate.estimated, isTrue);
      expect(estimate.total, d('271.00'));
      // The server took the push and gives the prices of the day and the
      // plan it kept; the phone's operations are gone from op_log.
      await repo.db.customStatement('DELETE FROM op_log');
      final draws = await drawsOf(id);
      await repo.applyOperations([
        for (final draw in draws)
          fromServer('tasks.materialdraw', draw.id, {
            'unit_price': draw.articleId == filter ? '45.50' : '60.00',
          }),
        fromServer('tasks.occurrence', id, {
          'planned_labour': '120.00',
          'planned_material': null,
        }),
      ]);
      // A price changed afterwards changes nothing: the kept one is read.
      await repo.updateArticle(
        filter,
        const ArticleInput(name: 'Filter', unitPrice: '99'),
      );
      await repo.setTaskBudgets(task, material: '', labour: '500');
      await repo.db.customStatement('DELETE FROM op_log');
      final kept = await costOf(id);
      expect([kept.total, kept.estimated], [d('271.00'), false]);
      expect(kept.planned.labour, d('120.00'));
    });

    test('with a server, 90 typed is 90, 0 typed is 0, nothing typed is the '
        'plan kept, and an undo leaves nothing', () async {
      await asServerHome();
      await repo.db.customStatement('DELETE FROM task_materials');
      final id = await doneOne();
      await repo.db.customStatement('DELETE FROM op_log');
      await repo.applyOperations([
        fromServer('tasks.occurrence', id, {'planned_labour': '120.00'}),
      ]);
      expect((await costOf(id)).total, d('120.00'));
      await repo.setActualCost(id, '90');
      expect((await costOf(id)).total, d('90.00'));
      await repo.setActualCost(id, '0');
      expect((await costOf(id)).total, d('0.00'));
      await repo.setActualCost(id, '');
      expect((await costOf(id)).total, d('120.00'));
      await repo.undo(id);
      expect((await costOf(id)).total, isNull);
    });

    test('the fields the server sets are never sent', () async {
      await asServerHome();
      final id = await doneOne();
      final draws = await drawsOf(id);
      await repo.db.customStatement('DELETE FROM op_log');
      await repo.applyOperations([
        for (final draw in draws)
          fromServer('tasks.materialdraw', draw.id, {'unit_price': '45.50'}),
        fromServer('tasks.occurrence', id, {'planned_labour': '120.00'}),
      ]);
      expect((await repo.occurrence(id))!.plannedLabour, '120.00');
      // A change of the phone, and every row sent again after a 410 (rule
      // 3: none was seen by the server).
      await repo.setActualCost(id, '12');
      await repo.reconcileAfterRestart(home, {});
      final sent = [
        for (final op in await repo.outgoing())
          if (serverOnlyFields.containsKey(op.operation[Op.type]))
            ...(op.operation[Op.fields]! as Map).keys,
      ];
      expect(sent, contains('actual_cost'));
      expect(sent, contains('drawn'));
      for (final field in [
        'unit_price',
        'planned_labour',
        'planned_material',
      ]) {
        expect(sent, isNot(contains(field)));
      }
    });
  });

  test('a schema 12 file keeps its rows, and the cost fields kept in extra '
      'move to their columns', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(12);
    final raw = schema.rawDatabase;
    Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
    raw.execute(
      'INSERT INTO homes (id, created_at, updated_at, name, currency, '
      'hemisphere, is_example) VALUES (?, 1, 1, ?, ?, ?, 0)',
      [id(1), 'Main home', 'EUR', 'north'],
    );
    raw.execute(
      'INSERT INTO tasks (id, created_at, updated_at, home_id, title) '
      'VALUES (?, 1, 1, ?, ?)',
      [id(2), id(1), 'Service'],
    );
    raw.execute(
      'INSERT INTO occurrences (id, created_at, updated_at, home_id, task_id, '
      "status) VALUES (?, 1, 1, ?, ?, 'done')",
      [id(3), id(1), id(2)],
    );
    raw.execute(
      'INSERT INTO articles (id, created_at, updated_at, home_id, name) '
      'VALUES (?, 1, 1, ?, ?)',
      [id(4), id(1), 'Filter'],
    );
    raw.execute(
      'INSERT INTO material_draws (id, created_at, updated_at, home_id, '
      'occurrence_id, article_id, wanted, drawn) VALUES (?, 1, 1, ?, ?, ?, '
      "'2.00', '2.00')",
      [id(5), id(1), id(3), id(4)],
    );
    for (final (entity, row, json) in [
      (
        'tasks.occurrence',
        id(3),
        {'planned_labour': '120.00', 'planned_material': null, 'other': 1},
      ),
      ('tasks.materialdraw', id(5), {'unit_price': '45.50'}),
    ]) {
      raw.execute(
        'INSERT INTO extra (entity, row_id, home_id, json) VALUES (?, ?, ?, ?)',
        [entity, row, id(1), jsonEncode(json)],
      );
    }
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 13);
    Future<List<Map<String, Object?>>> rows(String sql) async => [
      for (final r in await db.customSelect(sql).get()) r.data,
    ];
    expect(
      await rows('SELECT planned_labour, planned_material FROM occurrences'),
      [
        {'planned_labour': '120.00', 'planned_material': null},
      ],
    );
    expect(await rows('SELECT unit_price, drawn FROM material_draws'), [
      {'unit_price': '45.50', 'drawn': '2.00'},
    ]);
    expect(await rows('SELECT entity, json FROM extra'), [
      {'entity': 'tasks.occurrence', 'json': '{"other":1}'},
    ]);
    expect(await db.integrityCheck(), 'ok');
    await db.close();
  });
}
