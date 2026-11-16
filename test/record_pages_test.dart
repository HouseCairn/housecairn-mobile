// SPDX-License-Identifier: AGPL-3.0-only

// The pages of a room, an item, a stock item, a report and a project on the
// pattern of a record page (design/patterns.md of the web, Record page):
// Report a problem in the action row, the sections in the order of the web,
// the memory of a room behind Edit the memory, and the record opened after
// it is created from the list of its own section (design guide of the web,
// After a form). In English and French.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/values.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens_2b_test.dart' show reveal, tapKey, type;
import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';

void main() {
  setUpAll(initializeDateFormatting);

  for (final locale in ['en', 'fr']) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<(AppState, Lot3b)> start(
      WidgetTester tester, {
      double height = 760,
    }) async {
      await onPhone(tester, height: height);
      late Lot3b data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot3b.seed(r),
        documentSource: FakeDocuments(),
        notifier: FakeNotifier(),
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      return (state, data);
    }

    /// The headings of the screen from the top, by their text.
    List<String> headings(WidgetTester tester) {
      final found = find.byType(HcSectionHeading).evaluate().toList()
        ..sort(
          (a, b) => tester
              .getTopLeft(find.byWidget(a.widget))
              .dy
              .compareTo(tester.getTopLeft(find.byWidget(b.widget)).dy),
        );
      return [for (final e in found) (e.widget as HcSectionHeading).text];
    }

    /// Opens Report a problem with [key] and sends it; the report made.
    Future<ReportEntry> report(
      WidgetTester tester,
      AppState state,
      Lot3b data,
      String key,
      String title,
    ) async {
      await reveal(tester, find.byKey(Key(key)));
      await tapKey(tester, key);
      expect(find.byType(ReportFormScreen), findsOneWidget);
      await type(tester, 'report-title', title);
      await tester.tap(
        find.text(t('Send the report', 'Envoyer le signalement')).last,
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReportFormScreen), findsNothing);
      return (await state.repository.reportsOf(data.main))
          .firstWhere((e) => e.report.title == title);
    }

    testWidgets('a room: Type on a line, Report a problem in the action row '
        'with the room as Where, the sections in the order of the web, '
        '$locale', (tester) async {
      // Tall, so that the list builds every section at once.
      final (state, data) = await start(tester, height: 2400);
      await openScreen(
        tester,
        RoomScreen(homeId: data.main, roomId: data.base.base.kitchen),
      );
      // Type is a line of label and value, not stacked.
      final type = find.ancestor(
        of: find.text(t('Type', 'Type')),
        matching: find.byType(HcValueRow),
      );
      expect(type, findsOneWidget);
      // The sections of the web, in its order (the stock of a room is a web
      // feature, ADR 0011).
      expect(headings(tester), [
        t('Room memory', 'Mémoire de la pièce'),
        t('Photos', 'Photos'),
        t('Items', 'Éléments'),
        t('Tasks', 'Tâches'),
      ]);
      // Report a problem: a secondary button as wide as its label.
      final button = find.byKey(const Key('room-report'));
      expect(button, findsOneWidget);
      expect(
        find.descendant(
          of: button,
          matching: find.text(t('Report a problem', 'Signaler un problème')),
        ),
        findsOneWidget,
      );
      expectOneRow(tester, [button]);
      final made = await report(tester, state, data, 'room-report', 'Damp');
      expect(made.report.roomId, data.base.base.kitchen);
      expect(made.report.place, 'Main kitchen');
      expect(find.byType(RoomScreen), findsOneWidget);
    });

    testWidgets('a room: the memory has its own form, behind Edit the '
        'memory, and Edit has no memory, $locale', (tester) async {
      final (state, data) = await start(tester);
      // The cellar has no memory yet.
      final cellar = data.base.base.cellar;
      await openScreen(tester, RoomScreen(homeId: data.main, roomId: cellar));
      expect(
        find.text(
          t(
            'Nothing noted yet: paint, floor and wall coverings, and what '
                'runs behind the walls.',
            'Rien de noté pour l\'instant : peinture, revêtements de sol et '
                'de murs, et ce qui passe derrière les murs.',
          ),
        ),
        findsOneWidget,
      );
      await reveal(tester, find.byKey(const Key('room-memory-edit')));
      expect(
        find.descendant(
          of: find.byKey(const Key('room-memory-edit')),
          matching: find.text(t('Edit the memory', 'Modifier la mémoire')),
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'room-memory-edit');
      final form = find.byType(RoomFormScreen);
      expect(tester.widget<RoomFormScreen>(form).memory, isTrue);
      expect(find.byKey(const Key('room-name')), findsNothing);
      expect(find.text(t('Paint colour', 'Couleur de la peinture')), findsOne);
      await tester.enterText(
        find.descendant(
          of: find.ancestor(
            of: find.text(t('Paint colour', 'Couleur de la peinture')),
            matching: find.byType(HcField),
          ),
          matching: find.byType(TextField),
        ),
        'Warm white',
      );
      await tester.tap(find.text(t('Save', 'Enregistrer')).last);
      await tester.pumpAndSettle();
      expect((await state.repository.room(cellar))!.paintColour, 'Warm white');
      // Back on the room: the colour is a line of label and value.
      expect(find.byType(RoomFormScreen), findsNothing);
      expect(
        find.ancestor(
          of: find.text('Warm white'),
          matching: find.byType(HcValueRow),
        ),
        findsOneWidget,
      );
      // Edit opens the room's name, type and notes, without the memory.
      await tester.tap(find.text(t('Edit', 'Modifier')).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('room-name')), findsOneWidget);
      expect(
        find.text(t('Paint colour', 'Couleur de la peinture')),
        findsNothing,
      );
    });

    testWidgets('an item: Report a problem in the action row, with the item '
        'as Where, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openScreen(
        tester,
        ItemScreen(homeId: data.main, itemId: data.base.base.boiler),
      );
      expect(find.byKey(const Key('item-report')), findsOneWidget);
      final made = await report(tester, state, data, 'item-report', 'Noise');
      expect(made.report.itemId, data.base.base.boiler);
      expect(made.report.roomId, isNull);
      expect(made.report.place, 'Main cellar · Main boiler');
    });

    testWidgets('a stock item: Edit and Report a problem on one action row, '
        'with the stock item as Where, $locale', (tester) async {
      final (state, data) = await start(tester);
      await openScreen(
        tester,
        ArticleScreen(homeId: data.main, articleId: data.base.filter),
      );
      final edit = find.byKey(const Key('article-edit'));
      final report0 = find.byKey(const Key('article-report'));
      expectOneRow(tester, [edit, report0]);
      final made = await report(tester, state, data, 'article-report', 'Torn');
      expect(made.report.articleId, data.base.filter);
      expect(made.report.place, 'Main filter');
    });

    testWidgets('a report: its pill, its title, its facts on lines of label '
        'and value, Where a link, the actions on one wrapping row, $locale', (
      tester,
    ) async {
      final (_, data) = await start(tester);
      await openScreen(
        tester,
        ReportScreen(homeId: data.main, reportId: data.report),
      );
      final pill = find.byKey(const Key('report-status'));
      final title = find.text('The tap of the kitchen drips').first;
      expect(tester.getTopLeft(pill).dy, lessThan(tester.getTopLeft(title).dy));
      // Where (the web's label, without a question mark) and Reported on.
      for (final label in [t('Where', 'Où'), t('Reported on', 'Signalé le')]) {
        expect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(HcValueRow),
          ),
          findsOneWidget,
        );
      }
      // The actions side by side, as wide as their label.
      final make = find.byKey(const Key('report-make-task'));
      final resolve = find.byKey(const Key('report-resolve'));
      expectOneRow(tester, [
        make,
        resolve,
        find.byKey(const Key('report-no-action')),
      ]);
      expect(find.byType(FilledButton), findsOneWidget);
      // Where opens the room.
      await tapKey(tester, 'report-where');
      expect(find.byType(RoomScreen), findsOneWidget);
    });

    testWidgets('a report made a task shows its task as a link; a closed one '
        'shows when it was closed and only Reopen, $locale', (tester) async {
      final (state, data) = await start(tester);
      final repository = state.repository;
      // Made a task: Task is a line of label and value, a link to the task,
      // and the report can still be closed.
      final taskId = await repository.makeTask(data.report);
      await openScreen(
        tester,
        ReportScreen(homeId: data.main, reportId: data.report),
      );
      final task = (await repository.task(taskId))!;
      expect(
        find.ancestor(
          of: find.text(t('Task', 'Tâche')),
          matching: find.byType(HcValueRow),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-make-task')), findsNothing);
      expect(find.byKey(const Key('report-resolve')), findsOneWidget);
      await tapKey(tester, 'report-task');
      expect(
        tester.widget<TaskScreen>(find.byType(TaskScreen)).taskId,
        task.id,
      );
      await back(tester);
      // Closed: Closed on is a line, Reopen is the only action.
      await tapKey(tester, 'report-resolve');
      expect(
        find.ancestor(
          of: find.text(t('Closed on', 'Classé le')),
          matching: find.byType(HcValueRow),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('report-resolve')), findsNothing);
      expect(find.byKey(const Key('report-no-action')), findsNothing);
      expect(find.byKey(const Key('report-reopen')), findsOneWidget);
      await tapKey(tester, 'report-reopen');
      expect(find.byKey(const Key('report-reopen')), findsNothing);
      expect(find.byKey(const Key('report-resolve')), findsOneWidget);
    });

    testWidgets(
      'a project: pills with what is left, title, goal as a '
      'paragraph, rooms as links, then Tasks, Budget, Quotes, Inspiration and Files, $locale',
      (tester) async {
        final (_, data) = await start(tester, height: 3000);
        await openScreen(
          tester,
          ProjectScreen(homeId: data.main, projectId: data.project),
        );
        final pills = find.byKey(const Key('project-pills'));
        // The state of the budget, as on the web: the lines plan 1 300, the
        // accepted quote commits 1 200.01 on a line of 1 000, so the project
        // is over its budget by 20.01.
        expect(
          find.descendant(
            of: pills,
            // The French amount has a no-break space before the euro sign.
            matching: find.textContaining(
              t('Over budget by', 'Budget dépassé de'),
            ),
          ),
          findsOneWidget,
        );
        expect(find.text(t('Goal', 'Objectif')), findsNothing);
        expect(find.byKey(const Key('project-goal')), findsOneWidget);
        expect(headings(tester), [
          t('Tasks', 'Tâches'),
          t('Budget', 'Budget'),
          t('Quotes', 'Devis'),
          t('Inspiration', 'Inspiration'),
          t('Files', 'Fichiers'),
        ]);
        // A budget line: Planned, Committed, Paid and Gap, without Used.
        final line = find.byKey(Key('line-${data.line}'));
        await reveal(tester, line);
        for (final label in [
          t('Planned', 'Prévu'),
          t('Committed', 'Engagé'),
          t('Paid', 'Payé'),
          t('Gap', 'Écart'),
        ]) {
          expect(
            find.descendant(of: line, matching: find.text(label)),
            findsOneWidget,
          );
        }
        expect(find.byKey(const Key('amount-gauge')), findsNothing);
        expect(
          find.text(t('Where it stands', 'Où en est le budget')),
          findsNothing,
        );
        // The line opens its form.
        await tester.tap(line);
        await tester.pumpAndSettle();
        expect(find.byType(LineFormScreen), findsOneWidget);
        await back(tester);
        // The room concerned is a link to its page.
        await tester.drag(find.byType(Scrollable).last, const Offset(0, 3000));
        await tester.pumpAndSettle();
        await tapKey(tester, 'project-room-${data.base.base.kitchen}');
        expect(find.byType(RoomScreen), findsOneWidget);
      },
    );

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('Projects: saving a new project opens its page, Back '
          'returns to the list, on ${platform.name}, $locale', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          final (state, data) = await start(tester);
          await openSection(tester, t('Projects', 'Projets'));
          await tapAdd(tester, 'project-add');
          await type(tester, 'project-title', 'New fence');
          await tester.tap(find.text(t('Save', 'Enregistrer')).last);
          await tester.pumpAndSettle();
          final added = (await state.repository.projects(data.main))
              .firstWhere((e) => e.project.title == 'New fence');
          final page = tester.widget<ProjectScreen>(find.byType(ProjectScreen));
          expect(page.projectId, added.project.id);
          await back(tester);
          expect(find.byType(ProjectScreen), findsNothing);
          expect(find.byKey(const Key('project-add')), findsOneWidget);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });

      testWidgets('Stock: saving a new stock item opens its page, Back '
          'returns to the list, on ${platform.name}, $locale', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          final (state, data) = await start(tester);
          await openRooms(tester, t('Rooms', 'Pièces'));
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('rooms-tabs')),
              matching: find.text(t('Stock', 'Matériel')),
            ),
          );
          await tester.pumpAndSettle();
          await tapAdd(tester, 'article-add');
          await type(tester, 'article-name', 'Fuse 10 A');
          await tester.tap(find.text(t('Save', 'Enregistrer')).last);
          await tester.pumpAndSettle();
          final added = (await state.repository.articles(data.main))
              .firstWhere((e) => e.article.name == 'Fuse 10 A');
          final page = tester.widget<ArticleScreen>(find.byType(ArticleScreen));
          expect(page.articleId, added.article.id);
          await back(tester);
          expect(find.byType(ArticleScreen), findsNothing);
          expect(find.byKey(const Key('article-add')), findsOneWidget);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('a stock item edited from its page goes back to it, and opens '
        'nothing else, $locale', (tester) async {
      final (_, data) = await start(tester);
      await openScreen(
        tester,
        ArticleScreen(homeId: data.main, articleId: data.base.filter),
      );
      await tapKey(tester, 'article-edit');
      await tester.tap(find.text(t('Save', 'Enregistrer')).last);
      await tester.pumpAndSettle();
      expect(find.byType(ArticleScreen), findsOneWidget);
      expect(find.byType(ArticleFormScreen), findsNothing);
    });
  }
}

/// [buttons] are in one action row: one `RecordActions`, which is a `Wrap`
/// (buttons as wide as their label, on lines that wrap), not a column of
/// buttons stretched to the width of the card. The test font is as wide as
/// it is high, so the width of a label is not measured here.
void expectOneRow(WidgetTester tester, List<Finder> buttons) {
  final rows = {
    for (final b in buttons)
      find
          .ancestor(of: b, matching: find.byType(RecordActions))
          .evaluate()
          .single,
  };
  expect(rows, hasLength(1));
  final row = find.byWidget(rows.single.widget);
  expect(find.descendant(of: row, matching: find.byType(Wrap)), findsOneWidget);
  for (final b in buttons) {
    expect(
      find.ancestor(of: b, matching: find.byType(Wrap)),
      findsOneWidget,
      reason: 'a button of the row is directly in its Wrap',
    );
  }
}
