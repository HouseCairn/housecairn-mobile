// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/document_source.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';
import 'support/screens_2b.dart';

/// The screens of lot 3b used as a person would, on the two homes of the
/// fixture (EUR and CHF).
void main() {
  for (final MapEntry(key: locale, value: l) in labels.entries) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<(Lot3b, FakeDocuments, List<Uri>)> start(WidgetTester tester) async {
      await onPhone(tester);
      late Lot3b data;
      final documents = FakeDocuments(
        PickedDocument(
          'Quote 42.pdf',
          Uint8List.fromList('%PDF-1.4'.codeUnits),
          'application/pdf',
        ),
      );
      final opened = <Uri>[];
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot3b.seed(r),
        photoSource: cameraWith(),
        documentSource: documents,
        notifier: FakeNotifier(),
        openUrl: (uri) async {
          opened.add(uri);
          return true;
        },
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      return (data, documents, opened);
    }

    testWidgets('an accepted quote is not saved without a budget line, '
        '$locale', (tester) async {
      final (data, _, _) = await start(tester);
      await openScreen(
        tester,
        QuoteFormScreen(homeId: data.main, projectId: data.project),
      );
      await tester.enterText(find.byKey(const Key('quote-amount')), '99');
      await tester.tap(find.byKey(const Key('quote-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('Accepted', 'Accepté')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          t(
            'Choose the budget line the quote is committed on.',
            'Choisissez la ligne de budget sur laquelle le devis est engagé.',
          ),
        ),
        findsOneWidget,
      );
      final repo = stateOf(tester).repository;
      expect(await repo.quotesOf(data.project), hasLength(1));
    });

    testWidgets('the PDF of a quote comes from the document picker, $locale', (
      tester,
    ) async {
      final (data, documents, _) = await start(tester);
      await openScreen(
        tester,
        QuoteFormScreen(
          homeId: data.main,
          projectId: data.project,
          quoteId: data.quote,
        ),
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('quote-file-add')),
        200,
        scrollable: _vertical(),
      );
      await tester.ensureVisible(find.byKey(const Key('quote-file-add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quote-file-add')));
      await tester.pumpAndSettle();
      expect(documents.asked, 1);
      expect(find.text('Quote 42.pdf'), findsOneWidget);
    });

    testWidgets('a link opens in the browser of the phone, $locale', (
      tester,
    ) async {
      final (data, _, opened) = await start(tester);
      await openScreen(
        tester,
        ProjectScreen(homeId: data.main, projectId: data.project),
      );
      await tester.scrollUntilVisible(
        find.text('Colour ideas'),
        250,
        scrollable: _vertical(),
      );
      // Inspiration comes after the tasks, the budget and the quotes, as on
      // the web: bring the row above the bar of the sections.
      await tester.drag(_vertical(), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Colour ideas'));
      await tester.pumpAndSettle();
      expect(opened, [Uri.parse('https://example.com/colours')]);
    });

    testWidgets('Today counts the open reports; one is made a task, $locale', (
      tester,
    ) async {
      final (data, _, _) = await start(tester);
      expect(
        find.text(t('1 problem reported', '1 problème signalé')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('today-reports-see')));
      await tester.pumpAndSettle();
      expect(find.byType(ReportsScreen), findsOneWidget);
      await tester.tap(find.text('The tap of the kitchen drips'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('report-make-task')));
      await tester.pumpAndSettle();
      expect(
        find.text(t('Made into a task', 'Transformé en tâche')),
        findsWidgets,
      );
      await tester.tap(find.byKey(const Key('report-resolve')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('report-reopen')));
      await tester.pumpAndSettle();
      final repo = stateOf(tester).repository;
      expect((await repo.report(data.report))!.status, 'task');
      expect(await repo.openReportCount([data.main]), 0);
    });

    testWidgets('the budget of each home is in its own currency, $locale', (
      tester,
    ) async {
      final (data, _, _) = await start(tester);
      await budgetTab(tester, l, 2);
      expect(find.text('Repaint the kitchen'), findsOneWidget);
      expect(find.text('Second floor oil'), findsNothing);
      final state = stateOf(tester);
      await state.choose(data.second);
      await tester.pumpAndSettle();
      expect(find.text('Second floor oil'), findsOneWidget);
      expect(find.text('Repaint the kitchen'), findsNothing);
      expect(find.textContaining('CHF'), findsWidgets);
      expect(find.textContaining('€'), findsNothing);
    });
  }
}

Finder _vertical() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .last;
