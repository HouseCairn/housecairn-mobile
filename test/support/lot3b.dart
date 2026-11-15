// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/document_source.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'lot2b.dart';
import 'lot3a.dart';
import 'screens_2b.dart';

/// The data of the screens of lot 3b: the homes of lot 3a, and in each home
/// a project with lines, quotes, a task, a link and an envelope, a report;
/// a task of the upkeep with an estimate and a real cost. Neutral names only.
class Lot3b {
  late Lot3a base;
  late String project;
  late String line;
  late String quote;
  late String report;
  late String secondProject;

  String get main => base.main;
  String get second => base.base.homes.second;

  static Future<Lot3b> seed(Repository r) async {
    final data = Lot3b()..base = await Lot3a.seed(r);
    final main = data.main;
    final kitchen = data.base.base.kitchen;
    data.project = await r.createProject(
      main,
      ProjectInput(
        title: 'Repaint the kitchen',
        goal: 'Walls and ceiling in white',
        status: 'in_progress',
        priority: 'high',
        roomIds: [kitchen],
      ),
    );
    data.line = await r.createLine(
      data.project,
      const LineInput(
        label: 'Paint',
        nature: 'material',
        planned: '300',
        paid: '120',
      ),
    );
    final labour = await r.createLine(
      data.project,
      const LineInput(label: 'Painter', nature: 'labour', planned: '1000'),
    );
    final contractor = (await r.contractors(main)).first.id;
    data.quote = await r.createQuote(
      data.project,
      QuoteInput(
        contractorId: contractor,
        amount: '1200.01',
        status: 'accepted',
        budgetLineId: labour,
        issuedOn: r.today(),
      ),
    );
    await r.addProjectFile(
      data.project,
      name: 'quote.pdf',
      bytes: Uint8List.fromList('%PDF-1.4'.codeUnits),
      contentType: 'application/pdf',
      quoteId: data.quote,
    );
    await r.addLink(
      data.project,
      url: 'https://example.com/colours',
      title: 'Colour ideas',
    );
    await r.addProjectTask(
      data.project,
      TaskInput(title: 'Sand the walls', dueOn: r.today()),
    );
    await r.createProject(
      main,
      const ProjectInput(title: 'Garden shed', budget: '2500'),
    );
    await r.setEnvelope(main, r.today().year, '5000');
    await r.setTaskBudgets(data.base.service, material: '', labour: '120');
    data.report = await r.createReport(
      main,
      title: 'The tap of the kitchen drips',
      roomId: kitchen,
      place: 'Main kitchen',
    );
    data.secondProject = await r.createProject(
      data.second,
      const ProjectInput(title: 'Second floor oil', budget: '85.50'),
    );
    await r.setEnvelope(data.second, r.today().year, '120');
    return data;
  }
}

/// A document picker that gives one PDF.
class FakeDocuments implements DocumentSource {
  FakeDocuments([this.picked]);

  final PickedDocument? picked;
  int asked = 0;

  @override
  Future<PickedDocument?> pickDocument() async {
    asked++;
    return picked;
  }
}

Future<void> openSection(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<void> budgetTab(WidgetTester tester, Labels l, int tab) async {
  await openSection(tester, l.budget);
  if (tab == 0) return;
  final tabs = find.byKey(const Key('budget-tabs'));
  final label = [l.budgetRooms, l.budgetProjects, l.budgetUpkeep][tab - 1];
  await tester.tap(find.descendant(of: tabs, matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// The screens of lot 3b, each opened as the app opens it. `page` is the
/// name of the golden file.
final screens3b =
    <(String page, Future<void> Function(WidgetTester, Lot3b, Labels))>[
      ('projects', (tester, data, l) => openSection(tester, l.projects)),
      (
        'project',
        (tester, data, l) => openScreen(
          tester,
          ProjectScreen(homeId: data.main, projectId: data.project),
        ),
      ),
      (
        'project_form',
        (tester, data, l) => openScreen(
          tester,
          ProjectFormScreen(homeId: data.main, projectId: data.project),
        ),
      ),
      (
        'line_form',
        (tester, data, l) => openScreen(
          tester,
          LineFormScreen(
            homeId: data.main,
            projectId: data.project,
            lineId: data.line,
          ),
        ),
      ),
      (
        'quote_form',
        (tester, data, l) => openScreen(
          tester,
          QuoteFormScreen(
            homeId: data.main,
            projectId: data.project,
            quoteId: data.quote,
          ),
        ),
      ),
      (
        'envelope_form',
        (tester, data, l) =>
            openScreen(tester, EnvelopeFormScreen(homeId: data.main)),
      ),
      ('budget', (tester, data, l) => budgetTab(tester, l, 0)),
      ('budget_rooms', (tester, data, l) => budgetTab(tester, l, 1)),
      ('budget_projects', (tester, data, l) => budgetTab(tester, l, 2)),
      ('budget_upkeep', (tester, data, l) => budgetTab(tester, l, 3)),
      (
        'reports',
        (tester, data, l) =>
            openScreen(tester, ReportsScreen(homeId: data.main)),
      ),
      (
        'report',
        (tester, data, l) => openScreen(
          tester,
          ReportScreen(homeId: data.main, reportId: data.report),
        ),
      ),
      (
        'report_form',
        (tester, data, l) =>
            openScreen(tester, ReportFormScreen(homeId: data.main)),
      ),
    ];
