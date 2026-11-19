// SPDX-License-Identifier: AGPL-3.0-only

// Compare projects, as the web release v0.5.1 has it
// (`projects/project_list.html` in its mode of comparison,
// `projects/compare.html`, `projects.services.compare`): the list turns its
// rows into boxes to tick, the ticked projects open side by side, at most six,
// in the order of the list, in the currency of their home.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';
import 'support/screens_2b.dart';

/// Lot 3b with a second project in the tab In progress of the main home
/// (planned, with a duration and a season), and two projects in the CHF home.
class Compared {
  late Lot3b base;
  late String planned;
  late String chfA;
  late String chfB;

  String get main => base.main;
  String get second => base.second;

  static Future<Compared> seed(Repository r) async {
    final data = Compared()..base = await Lot3b.seed(r);
    data.planned = await r.createProject(
      data.main,
      const ProjectInput(
        title: 'New windows',
        status: 'planned',
        estimatedMinutes: 960,
        season: 'spring',
      ),
    );
    await r.createLine(
      data.planned,
      const LineInput(label: 'Windows', nature: 'material', planned: '2400'),
    );
    data.chfA = await r.createProject(
      data.second,
      const ProjectInput(
        title: 'Roof',
        status: 'in_progress',
        budget: '1999.95',
      ),
    );
    data.chfB = await r.createProject(
      data.second,
      const ProjectInput(title: 'Porch', status: 'planned', budget: '300'),
    );
    return data;
  }
}

Future<Compared> start(
  WidgetTester tester, {
  String locale = 'en',
  double width = 390,
  double scale = 1,
}) async {
  await onPhone(tester, width: width, height: 844, textScale: scale);
  late Compared data;
  final state = await pumpApp(
    tester,
    locale: locale,
    seed: (r) async => data = await Compared.seed(r),
  );
  await state.choose(data.main);
  await tester.pumpAndSettle();
  await openSection(tester, labels[locale]!.projects);
  return data;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final found = find.byKey(Key(key));
  await reveal(tester, found);
  await tester.tap(found);
  await tester.pumpAndSettle();
}

/// Scrolls the list until [found] is built and on the screen.
Future<void> reveal(WidgetTester tester, Finder found) async {
  // A row scrolled out of a lazy list is not built: scroll back to it.
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable();
  for (final delta in [-200.0, 200.0]) {
    if (found.evaluate().isNotEmpty) break;
    try {
      await tester.scrollUntilVisible(
        found,
        delta,
        scrollable: list.last,
        maxScrolls: 30,
      );
    } on StateError {
      // Not that way: try the other.
    }
  }
  await tester.ensureVisible(found);
  await tester.pumpAndSettle();
}

const texts = {
  'en': (
    compare: 'Compare projects',
    ticked: 'Compare the ticked projects',
    cancel: 'Cancel',
    two: 'Tick at least two projects in the list to compare them.',
    head: [
      'Project',
      'Status',
      'Planned cost',
      'Committed',
      'Duration',
      'Priority',
      'Season',
    ],
    select: 'Select',
  ),
  'fr': (
    compare: 'Comparer les projets',
    ticked: 'Comparer les projets cochés',
    cancel: 'Annuler',
    two: 'Cochez au moins deux projets dans la liste pour les comparer.',
    head: [
      'Projet',
      'Statut',
      'Coût prévu',
      'Engagé',
      'Durée',
      'Priorité',
      'Saison',
    ],
    select: 'Sélectionner',
  ),
};

void main() {
  setUpAll(loadAppFonts);

  group('the comparison of the repository (`compare`)', () {
    test('the chosen projects of the home, in the order of the list, the '
        'first six ids only, the amounts line by line', () async {
      final r = await openRepository();
      addTearDown(r.db.close);
      final data = await Compared.seed(r);
      final list = [for (final e in await r.projects(data.main)) e.project.id];
      // Asked in another order: they come in the order of the list.
      final asked = [data.planned, data.base.project];
      final rows = await r.compareProjects(data.main, asked);
      expect(
        [for (final e in rows) e.project.id],
        [
          for (final id in list)
            if (asked.contains(id)) id,
        ],
      );
      final repaint = rows.firstWhere((e) => e.project.id == data.base.project);
      // The lines of Repaint the kitchen (300 and 1000), the quote accepted
      // on its labour line (1200.01), what is paid (120); its task plans
      // nothing that the lines would carry (`amounts_by_project`).
      expect(repaint.amounts.planned.toString(), '1300');
      expect(repaint.amounts.committed.toString(), '1200.01');
      expect(repaint.amounts.paid.toString(), '120');
      // A project of the other home, an unknown id and a deleted project
      // give nothing.
      final deleted = await r.createProject(
        data.main,
        const ProjectInput(title: 'Gone', status: 'planned'),
      );
      await r.deleteProject(deleted);
      expect(
        await r.compareProjects(data.main, [
          data.base.project,
          data.chfA,
          'not-an-id',
          deleted,
        ]),
        hasLength(1),
      );
      // Six at most: the seventh id asked is not read, as the web reads the
      // first six of its address.
      final seven = <String>[
        for (var i = 0; i < 7; i++)
          await r.createProject(
            data.main,
            ProjectInput(title: 'P$i', status: 'planned'),
          ),
      ];
      final six = await r.compareProjects(data.main, seven);
      expect(six, hasLength(maxCompared));
      expect(maxCompared, 6);
      expect(six.map((e) => e.project.id), isNot(contains(seven.last)));
    });

    test('a home in CHF compares its own projects only', () async {
      final r = await openRepository();
      addTearDown(r.db.close);
      final data = await Compared.seed(r);
      final rows = await r.compareProjects(data.second, [
        data.chfA,
        data.chfB,
        data.planned,
      ]);
      expect(rows.map((e) => e.project.title), ['Roof', 'Porch']);
      expect(rows.first.amounts.planned.toString(), '1999.95');
    });
  });

  for (final locale in ['en', 'fr']) {
    final t = texts[locale]!;
    group('the list and the comparison, $locale', () {
      testWidgets('Compare projects ticks rows, then opens them side by '
          'side; Cancel goes back to the plain list', (tester) async {
        final data = await start(tester, locale: locale);
        await reveal(tester, find.text(t.compare));
        expect(find.text(t.compare), findsOneWidget);
        expect(find.byType(Checkbox), findsNothing);
        await tapKey(tester, 'projects-compare');
        // The rows carry a box; Compare and Cancel replace the button.
        expect(find.byType(Checkbox), findsNWidgets(2));
        expect(find.text(t.compare), findsNothing);
        await reveal(tester, find.text(t.ticked));
        expect(find.text(t.ticked), findsOneWidget);
        // A row is ticked from anywhere, and untouched it opens nothing.
        await tapKey(tester, 'project-${data.base.project}');
        expect(find.byType(ProjectScreen), findsNothing);
        expect(
          tester
              .widget<Checkbox>(
                find.byKey(Key('project-tick-${data.base.project}')),
              )
              .value,
          isTrue,
        );
        await tapKey(tester, 'projects-compare-cancel');
        expect(find.byType(Checkbox), findsNothing);
        await reveal(tester, find.text(t.compare));
        expect(find.text(t.compare), findsOneWidget);
        // Ticked again: the mode starts with nothing ticked.
        await tapKey(tester, 'projects-compare');
        expect(
          tester
              .widgetList<Checkbox>(find.byType(Checkbox))
              .map((c) => c.value),
          everyElement(isFalse),
        );
        await tapKey(tester, 'project-${data.planned}');
        await tapKey(tester, 'project-${data.base.project}');
        await tapKey(tester, 'projects-compare-ticked');
        expect(find.byType(ProjectCompareScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        final table = find.byKey(const Key('project-compare-table'));
        for (final h in t.head) {
          expect(
            find.descendant(of: table, matching: find.text(h)),
            findsOneWidget,
          );
        }
        String row(String id) => [
          for (final w in tester.widgetList<Text>(
            find.descendant(
              of: find.byKey(Key('compare-$id')),
              matching: find.byType(Text),
            ),
          ))
            w.data!,
        ].join(' | ');
        // In the order of the list: in progress, then planned.
        final repaint = find.byKey(Key('compare-${data.base.project}'));
        final windows = find.byKey(Key('compare-${data.planned}'));
        expect(
          tester.getTopLeft(repaint).dy,
          lessThan(tester.getTopLeft(windows).dy),
        );
        final nb = '\u202f', sp = '\u00a0';
        expect(
          row(data.base.project),
          locale == 'en'
              ? 'Repaint the kitchen | In progress | €1,300.00 | €1,200.01 '
                    '| \u2014 | High | \u2014'
              : 'Repaint the kitchen | En cours | 1${nb}300,00$sp€ '
                    '| 1${nb}200,01$sp€ | \u2014 | Haute | \u2014',
        );
        expect(
          row(data.planned),
          locale == 'en'
              ? 'New windows | Planned | €2,400.00 | €0.00 | 16 h | Normal '
                    '| Spring'
              : 'New windows | Prévu | 2${nb}400,00$sp€ | 0,00$sp€ | 16 h '
                    '| Normale | Printemps',
        );
        // A row opens its project.
        await tester.tap(windows);
        await tester.pumpAndSettle();
        expect(find.byType(ProjectScreen), findsOneWidget);
        expect(find.text('New windows'), findsWidgets);
      });

      testWidgets('fewer than two ticked: the page asks to tick more', (
        tester,
      ) async {
        final data = await start(tester, locale: locale);
        await tapKey(tester, 'projects-compare');
        await tapKey(tester, 'project-${data.planned}');
        await tapKey(tester, 'projects-compare-ticked');
        expect(find.text(t.two), findsOneWidget);
        expect(find.byKey(const Key('project-compare-table')), findsNothing);
      });

      testWidgets('one project in the tab: no comparison offered', (
        tester,
      ) async {
        await start(tester, locale: locale);
        // Ideas holds Garden shed alone.
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('projects-tabs')),
            matching: find.text(locale == 'en' ? 'Ideas' : 'Idées'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('projects-compare')), findsNothing);
        expect(find.byKey(const Key('projects-select')), findsNothing);
      });

      testWidgets('a home in CHF: its amounts in francs', (tester) async {
        await onPhone(tester, width: 390, height: 844);
        late Compared data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Compared.seed(r),
        );
        await state.choose(data.second);
        await tester.pumpAndSettle();
        await openScreen(
          tester,
          ProjectCompareScreen(
            homeId: data.second,
            projectIds: [data.chfA, data.chfB],
          ),
        );
        final roof = [
          for (final w in tester.widgetList<Text>(
            find.descendant(
              of: find.byKey(Key('compare-${data.chfA}')),
              matching: find.byType(Text),
            ),
          ))
            w.data!,
        ];
        expect(roof[2], contains('CHF'));
        expect(
          roof[2],
          contains(locale == 'en' ? '1,999.95' : '1\u202f999,95'),
        );
      });
    });
  }

  group('the selection of each platform (web design/patterns.md, row 12)', () {
    testWidgets('Android: a long press starts it with the row ticked; no '
        'Select in the bar', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final data = await start(tester);
      expect(find.byKey(const Key('projects-select')), findsNothing);
      await tester.longPress(find.byKey(Key('project-${data.planned}')));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectScreen), findsNothing);
      expect(
        tester
            .widget<Checkbox>(find.byKey(Key('project-tick-${data.planned}')))
            .value,
        isTrue,
      );
    });

    testWidgets('iPhone: Select in the bar starts it; the rows have no '
        'long press', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final data = await start(tester);
      expect(
        tester
            .widget<HcRow>(find.byKey(Key('project-${data.planned}')))
            .onLongPress,
        isNull,
      );
      expect(find.byType(Checkbox), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('projects-select')),
          matching: find.text('Select'),
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'projects-select');
      expect(find.byType(Checkbox), findsNWidgets(2));
      // In the mode, the bar no longer offers Select.
      expect(find.byKey(const Key('projects-select')), findsNothing);
    });
  });

  group('accessibility', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('the mode of comparison and the comparison meet the '
          'guidelines, ${platform.name}', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final handle = tester.ensureSemantics();
        final data = await start(tester);
        await tapKey(tester, 'projects-compare');
        await tapKey(tester, 'project-${data.planned}');
        // The row is one check box, said with its title and its state.
        expect(
          tester.getSemantics(find.byKey(Key('project-${data.planned}'))),
          isSemantics(
            isChecked: true,
            hasCheckedState: true,
            hasTapAction: true,
            label: 'New windows\nPlanned €2,400.00\n€2,400.00 left',
          ),
        );
        for (final g in [
          androidTapTargetGuideline,
          iOSTapTargetGuideline,
          labeledTapTargetGuideline,
          textContrastGuideline,
        ]) {
          await expectLater(tester, meetsGuideline(g));
        }
        await tapKey(tester, 'project-${data.base.project}');
        await tapKey(tester, 'projects-compare-ticked');
        // The table is a region named by its caption, which scrolls on its
        // own: the page keeps its width.
        expect(
          find.bySemanticsLabel('The projects side by side'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('column-table-scroll')), findsOneWidget);
        for (final g in [
          androidTapTargetGuideline,
          iOSTapTargetGuideline,
          labeledTapTargetGuideline,
          textContrastGuideline,
        ]) {
          await expectLater(tester, meetsGuideline(g));
        }
        handle.dispose();
      });
    }

    testWidgets('at 320 px and twice the text, nothing overflows and the '
        'table scrolls', (tester) async {
      final data = await start(tester, width: 320, scale: 2);
      await tapKey(tester, 'projects-compare');
      await tapKey(tester, 'project-${data.planned}');
      await tapKey(tester, 'project-${data.base.project}');
      await tapKey(tester, 'projects-compare-ticked');
      expect(tester.takeException(), isNull);
      final scroll = tester.widget<SingleChildScrollView>(
        find.byKey(const Key('column-table-scroll')),
      );
      expect(scroll.scrollDirection, Axis.horizontal);
      final table = find.descendant(
        of: find.byKey(const Key('column-table-scroll')),
        matching: find.byType(SizedBox),
      );
      expect(tester.getSize(table.first).width, greaterThan(640));
      expect(find.byType(HcColumnTable), findsOneWidget);
    });
  });
}
