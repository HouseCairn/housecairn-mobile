// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/budget.dart' as budget;
import 'package:housecairn_mobile/domain/day.dart';

import 'support/fixture.dart';

Decimal d(String s) => Decimal.parse(s);

/// The rules of projects, quotes, envelopes and reports of lot 3b
/// (`projects/services.py`, `reports/services.py`), on two homes in EUR and
/// CHF, and the sums of lib/domain/budget.dart that the comparison with the
/// web (test/budget_web_test.dart) does not isolate.
void main() {
  group('amounts', () {
    test('a line is spent for the more of committed and paid', () {
      final a = budget.Amounts.line(d('100'), d('120'), d('30'));
      expect(a.engaged, d('120'));
      expect(a.gap, d('-20'));
      expect(a.state, 'over');
      expect(a.toPay, d('90'));
      final b = budget.Amounts.line(d('100'), d('0'), d('110'));
      expect((b.engaged, b.toPay, b.state), (d('110'), d('0'), 'over'));
    });

    test('an overrun on one line is not hidden by the room of another', () {
      final sum =
          budget.Amounts.line(d('100'), d('150')) +
          budget.Amounts.line(d('100'), d('0'));
      // engaged 150 + 0, gap 200 - 150: still 50 left, but the first line is over.
      expect(sum.engaged, d('150'));
      expect(sum.toPay, d('150'));
      final paidAbove =
          budget.Amounts.line(d('0'), d('10'), d('30')) +
          budget.Amounts.line(d('0'), d('20'), d('0'));
      // The line paid above its quote owes nothing and lowers nothing.
      expect(paidAbove.toPay, d('20'));
    });

    test(
      'shared between rooms, the odd cents go first and the sum is exact',
      () {
        final parts = budget.share(budget.Amounts.line(d('99.99')), 3);
        expect(
          [for (final p in parts) p.planned],
          [d('33.33'), d('33.33'), d('33.33')],
        );
        final more = budget.share(budget.Amounts.line(d('100.01')), 3);
        expect(
          [for (final p in more) p.planned],
          [d('33.34'), d('33.34'), d('33.33')],
        );
        expect(more.fold(budget.zero, (s, p) => s + p.planned), d('100.01'));
      },
    );

    test('rounding: half up to the cent, the percent half to even', () {
      expect(budget.cents(d('0.005')), d('0.01'));
      expect(budget.cents(d('0.24'), 48), d('0.01'));
      expect(budget.cents(d('-0.005')), d('-0.01'));
      final half = budget.EnvelopeReport(
        2026,
        d('200'),
        budget.Amounts.line(d('0'), d('1')),
        budget.Amounts.none,
      );
      expect(half.percent, 0); // 0.5 % rounds to the even 0
      final more = budget.EnvelopeReport(
        2026,
        d('200'),
        budget.Amounts.line(d('0'), d('3')),
        budget.Amounts.none,
      );
      expect(more.percent, 2); // 1.5 % rounds to the even 2
    });

    test('money is a decimal of at most two places, below 10^10', () {
      expect(budget.parseMoney('1250,50'), d('1250.5'));
      expect(budget.parseMoney('9999999999.99'), d('9999999999.99'));
      for (final bad in ['', '-1', '1.234', '1e3', '10000000000', 'NaN']) {
        expect(budget.parseMoney(bad), isNull, reason: bad);
      }
      expect(budget.storedMoney(d('2.5')), '2.50');
    });
  });

  group('projects and quotes, two homes', () {
    late Repository repo;
    late TwoHomes homes;
    late String project;
    late String other;

    setUp(() async {
      repo = await openRepository();
      homes = await TwoHomes.create(repo);
      project = await repo.createProject(
        homes.main,
        const ProjectInput(title: 'Repaint', budget: '500'),
      );
      other = await repo.createProject(
        homes.second,
        const ProjectInput(title: 'Floor', budget: '80'),
      );
    });

    test(
      'a budget given on creation is the first line, of nature Other',
      () async {
        final lines = await repo.linesOf(project);
        expect(lines.single.line.nature, budget.other);
        expect(lines.single.amounts.planned, d('500'));
      },
    );

    test('an accepted quote cannot be saved without a budget line', () async {
      await expectLater(
        repo.createQuote(
          project,
          const QuoteInput(amount: '120', status: 'accepted'),
        ),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.quoteNeedsLine,
          ),
        ),
      );
      final id = await repo.createQuote(
        project,
        const QuoteInput(amount: '120', status: 'received'),
      );
      await expectLater(
        repo.updateQuote(
          id,
          const QuoteInput(amount: '120', status: 'accepted'),
        ),
        throwsA(isA<Refused>()),
      );
      expect((await repo.quote(id))!.status, 'received');
      expect(await repo.db.select(repo.db.quotes).get(), hasLength(1));
    });

    test('a quote is committed only on a line of its own project', () async {
      final line = (await repo.linesOf(other)).single.line.id;
      await expectLater(
        repo.createQuote(
          project,
          QuoteInput(amount: '10', status: 'accepted', budgetLineId: line),
        ),
        throwsA(
          isA<Refused>().having((r) => r.reason, 'r', Refusal.notInProject),
        ),
      );
    });

    test(
      'accepted, a quote commits its amount; another status releases it',
      () async {
        final line = (await repo.linesOf(project)).single.line.id;
        final quote = await repo.createQuote(
          project,
          QuoteInput(amount: '650', status: 'accepted', budgetLineId: line),
        );
        var entry = (await repo.linesOf(project)).single;
        expect(entry.amounts.committed, d('650'));
        expect(entry.amounts.state, 'over');
        await repo.updateQuote(
          quote,
          QuoteInput(amount: '650', status: 'rejected', budgetLineId: line),
        );
        expect((await repo.quote(quote))!.budgetLineId, isNull);
        entry = (await repo.linesOf(project)).single;
        expect(entry.amounts.committed, budget.zero);
      },
    );

    test(
      'deleting a line sends its accepted quotes back to Received',
      () async {
        final line = (await repo.linesOf(project)).single.line.id;
        final quote = await repo.createQuote(
          project,
          QuoteInput(amount: '50', status: 'accepted', budgetLineId: line),
        );
        await repo.deleteLine(line);
        final q = (await repo.quote(quote))!;
        expect((q.status, q.budgetLineId), ('received', null));
      },
    );

    test('the validity of a quote cannot end before its date', () async {
      await expectLater(
        repo.createQuote(
          project,
          QuoteInput(issuedOn: Day(2026, 11, 10), validUntil: Day(2026, 11, 9)),
        ),
        throwsA(isA<Refused>()),
      );
    });

    test('a task is in one project at most', () async {
      final task = await repo.addProjectTask(
        project,
        const TaskInput(title: 'Sand the walls'),
      );
      final second = await repo.createProject(
        homes.main,
        const ProjectInput(title: 'Other'),
      );
      await expectLater(
        repo.attachTask(second, task),
        throwsA(
          isA<Refused>().having((r) => r.reason, 'r', Refusal.taskInProject),
        ),
      );
      await repo.detachTask(project, task);
      await repo.attachTask(second, task);
      expect((await repo.projectOfTask(task))!.id, second);
    });

    test('a link is http(s), never read; files are a PDF or a photo, five a '
        'quote', () async {
      await expectLater(
        repo.addLink(project, url: 'ftp://example.com/a'),
        throwsA(isA<Refused>()),
      );
      await repo.addLink(project, url: 'https://example.com/idea');
      expect((await repo.linksOf(project)).single.title, '');
      final quote = await repo.createQuote(project, const QuoteInput());
      final pdf = Uint8List.fromList('%PDF-1.4'.codeUnits);
      for (var i = 0; i < maxFilesPerQuote; i++) {
        await repo.addProjectFile(
          project,
          name: '../../quote $i.pdf',
          bytes: pdf,
          contentType: 'application/pdf',
          quoteId: quote,
        );
      }
      await expectLater(
        repo.addProjectFile(
          project,
          name: 'one more.pdf',
          bytes: pdf,
          contentType: 'application/pdf',
          quoteId: quote,
        ),
        throwsA(isA<Refused>()),
      );
      final files = await repo.filesOf(project);
      expect(files.first.name, 'quote 0.pdf');
      expect(repo.projectFile(files.first).readAsBytesSync(), pdf);
      await expectLater(
        repo.addProjectFile(
          project,
          name: 'a.exe',
          bytes: pdf,
          contentType: 'application/x-msdownload',
        ),
        throwsA(isA<Refused>()),
      );
    });

    test('envelopes are per home and year, in the currency of each', () async {
      await repo.setEnvelope(homes.main, 2026, '5000');
      await repo.setEnvelope(homes.second, 2026, '300,50');
      expect(await repo.envelopesOf(homes.main), {2026: d('5000')});
      expect(await repo.envelopesOf(homes.second), {2026: d('300.5')});
      await repo.setEnvelope(homes.main, 2026, '');
      expect(await repo.envelopesOf(homes.main), isEmpty);
      await repo.setEnvelope(homes.main, 2026, '10');
      expect(await repo.envelopesOf(homes.main), {2026: d('10')});
      final a = await repo.ledger(homes.main);
      final b = await repo.ledger(homes.second);
      expect((a.currency, b.currency), ('EUR', 'CHF'));
      final year = repo.today().year;
      expect(budget.envelope(a, year).envelope, d('10'));
      expect(budget.envelope(b, year).envelope, d('300.5'));
      // Each ledger holds its home's project only.
      expect([for (final p in a.projects) p.project.id], [project]);
      expect([for (final p in b.projects) p.project.id], [other]);
    });

    test('deleting a project keeps its tasks, out of the project', () async {
      final task = await repo.addProjectTask(
        project,
        const TaskInput(title: 'Prime'),
      );
      await repo.deleteProject(project);
      expect(await repo.project(project), isNull);
      expect(await repo.task(task), isNotNull);
      expect(await repo.projectOfTask(task), isNull);
      expect(await repo.linesOf(project), isEmpty);
    });
  });

  group('task budgets, real cost, paint left', () {
    test('the real cost goes on a done occurrence only', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      final task = await repo.createTask(
        homes.main,
        TaskInput(title: 'Clean', dueOn: testToday),
      );
      await repo.setTaskBudgets(task, material: '5', labour: '');
      expect((await repo.task(task))!.materialBudget, '5.00');
      final open = (await repo.openOccurrencesOf(task)).single;
      await expectLater(
        repo.setActualCost(open.id, '10'),
        throwsA(isA<Refused>()),
      );
      await repo.complete(open.id);
      await repo.setActualCost(open.id, '12,40');
      expect((await repo.occurrence(open.id))!.actualCost, '12.40');
      final ledger = await repo.ledger(homes.main);
      final row = ledger.tasks.firstWhere((t) => t.task.id == task);
      expect(row.figures(budget.anytime).paid, d('12.4'));
    });

    test('the paint left of a room is an article of its home', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      final room = (await repo.rooms(homes.main)).first.id;
      final mine = (await repo.articles(homes.main)).first.article.id;
      final theirs = (await repo.articles(homes.second)).first.article.id;
      await expectLater(
        repo.setPaintArticle(room, theirs),
        throwsA(isA<Refused>()),
      );
      await repo.setPaintArticle(room, mine);
      expect((await repo.room(room))!.paintArticleId, mine);
      await repo.setPaintArticle(room, null);
      expect((await repo.room(room))!.paintArticleId, isNull);
    });
  });

  group('reports', () {
    test('make a task, close, reopen, and the count of Today', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      final room = (await repo.rooms(homes.main)).first;
      final report = await repo.createReport(
        homes.main,
        title: 'The tap drips',
        roomId: room.id,
        place: room.name,
      );
      await repo.createReport(homes.second, title: 'A tile is loose');
      expect(await repo.openReportCount([homes.main]), 1);
      expect(await repo.openReportCount([homes.main, homes.second]), 2);
      final task = await repo.makeTask(report);
      expect((await repo.task(task))!.roomId, room.id);
      expect((await repo.report(report))!.status, reportTask);
      expect(await repo.openReportCount([homes.main]), 0);
      await expectLater(repo.makeTask(report), throwsA(isA<Refused>()));
      await repo.closeReport(report, reportResolved);
      await expectLater(
        repo.closeReport(report, reportNoAction),
        throwsA(isA<Refused>()),
      );
      await repo.reopenReport(report);
      // Back to its task, which still exists.
      expect((await repo.report(report))!.status, reportTask);
      await repo.closeReport(report, reportNoAction);
      await repo.deleteTask(task);
      await repo.reopenReport(report);
      expect((await repo.report(report))!.status, reportOpen);
    });

    test('a report has one place at most, of its home', () async {
      final repo = await openRepository();
      final homes = await TwoHomes.create(repo);
      final room = (await repo.rooms(homes.main)).first.id;
      final other = (await repo.rooms(homes.second)).first.id;
      final item = (await repo.itemsOfHome(homes.main)).first.id;
      await expectLater(
        repo.createReport(homes.main, title: 'x', roomId: room, itemId: item),
        throwsA(isA<Refused>()),
      );
      await expectLater(
        repo.createReport(homes.main, title: 'x', roomId: other),
        throwsA(isA<Refused>()),
      );
      await expectLater(
        repo.createReport(homes.main, title: '  '),
        throwsA(isA<Refused>()),
      );
    });
  });
}
