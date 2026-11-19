// SPDX-License-Identifier: AGPL-3.0-only

// No word of the bottom bar or of a row of tabs is cut in two on the narrow
// phone (320 px) with text at twice the size, in French, the language of the
// longest words (Aujourd'hui, Équipements, Terminés): the labels come down in
// size together until the longest word fits, the rule of HcWholeWords. The
// real fonts are loaded, as for the golden files: the test font would not
// measure the words of the app.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/theme.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';
import 'support/screens_2b.dart';

/// Fails when a word of a text under [within] is laid out on more than one
/// line: the word was cut in two. A line may break after a slash or a
/// hyphen, as for HcWholeWords.
void expectWholeWords(WidgetTester tester, Finder within, String where) {
  final paragraphs = tester.renderObjectList<RenderParagraph>(
    find.descendant(of: within, matching: find.byType(RichText)),
  );
  var words = 0;
  for (final paragraph in paragraphs) {
    final text = paragraph.text.toPlainText();
    for (final word in RegExp(r'[^\s/-]+[/-]?').allMatches(text)) {
      final lines = paragraph
          .getBoxesForSelection(
            TextSelection(baseOffset: word.start, extentOffset: word.end),
          )
          .map((box) => box.top.round())
          .toSet();
      expect(
        lines.length,
        1,
        reason: '$where: « ${word.group(0)} » is cut in « $text »',
      );
      words++;
    }
  }
  expect(words, greaterThan(0), reason: '$where: no label found');
}

/// The words of the bottom bar and of every row of tabs on the screen.
void expectBarAndTabsWhole(WidgetTester tester, String where) {
  expectWholeWords(tester, find.byType(NavigationBar), '$where, bar');
  final tabs = find.byType(HcTabs);
  for (var i = 0; i < tabs.evaluate().length; i++) {
    expectWholeWords(tester, tabs.at(i), '$where, tabs');
  }
}

void main() {
  setUpAll(loadAppFonts);

  final l = labels['fr']!;

  testWidgets('the five sections, 320 px x2 (fr)', (tester) async {
    await onPhone(tester, width: 320, textScale: 2);
    late Lot3b data;
    final state = await pumpApp(
      tester,
      locale: 'fr',
      seed: (r) async => data = await Lot3b.seed(r),
    );
    await state.choose(data.main);
    await tester.pumpAndSettle();
    for (final section in [
      "Aujourd'hui",
      l.rooms,
      l.projects,
      l.budget,
      l.more,
    ]) {
      await openSection(tester, section);
      expectBarAndTabsWhole(tester, section);
    }
    // The rows of More (Signalements, Intervenants) and the links of About
    // (Documentation), seen cut in two before.
    final rows = find.byType(HcRow);
    for (var i = 0; i < rows.evaluate().length; i++) {
      expectWholeWords(tester, rows.at(i), 'More, row');
    }
    await scrollMoreTo(tester, find.byKey(const Key('more-about')));
    await tester.tap(find.byKey(const Key('more-about')));
    await tester.pumpAndSettle();
    final links = find.byKey(const Key('about-links'));
    await tester.scrollUntilVisible(links, 100);
    await tester.pumpAndSettle();
    expectWholeWords(tester, links, 'About, links');
  });

  for (final (page, open) in screens3b) {
    testWidgets('$page, 320 px x2 (fr)', (tester) async {
      await onPhone(tester, width: 320, textScale: 2);
      late Lot3b data;
      final state = await pumpApp(
        tester,
        locale: 'fr',
        seed: (r) async => data = await Lot3b.seed(r),
        photoSource: cameraWith(),
        documentSource: FakeDocuments(),
        notifier: FakeNotifier(),
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      await open(tester, data, l);
      expectBarAndTabsWhole(tester, page);
    });
  }

  // Every row of tabs of the app, alone, on the width a screen of 320 px
  // leaves them, at twice the size: those opened from a filter or a list too.
  testWidgets('every row of tabs, 320 px x2 (fr)', (tester) async {
    await onPhone(tester, width: 320, textScale: 2);
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    final rows = [
      [l10n.navToday, l10n.tasksTabAll],
      [l10n.navRooms, l10n.equipmentTab, l10n.stock],
      [l10n.projectsInProgress, l10n.projectsIdeas, l10n.projectsFinished],
      [
        l10n.budgetSummary,
        l10n.budgetRooms,
        l10n.budgetProjects,
        l10n.budgetUpkeep,
      ],
      [l10n.reportsOpen, l10n.reportsClosed, l10n.reportsAll],
      [l10n.stockTabAll, l10n.articleLowStock],
      [l10n.tasksToDo, l10n.tasksDoneFilter],
    ];
    for (final row in rows) {
      for (final current in [0, row.length - 1]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: housecairnTheme(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  // The margins of a page, rounded up.
                  width: 280,
                  child: HcTabs(
                    labels: row,
                    current: current,
                    onSelect: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        expectWholeWords(tester, find.byType(HcTabs), row.join(' / '));
      }
    }
  });

  testWidgets('the size of the labels is kept where they fit', (tester) async {
    for (final (width, scale) in [(390.0, 1.0), (360.0, 1.0), (390.0, 2.0)]) {
      await onPhone(tester, width: width, textScale: scale);
      await pumpApp(tester, locale: 'fr');
      final bar = tester.renderObjectList<RenderParagraph>(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(RichText),
        ),
      );
      for (final paragraph in bar) {
        if (paragraph.text.toPlainText().trim().isEmpty) continue;
        // The bar keeps the size of the design whatever the text size of
        // the phone (docs/adr/0011).
        expect(
          paragraph.textScaler.scale(1),
          1,
          reason: '${paragraph.text.toPlainText()} at $width x$scale',
        );
      }
    }
  });
}
