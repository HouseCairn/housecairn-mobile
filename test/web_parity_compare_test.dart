// SPDX-License-Identifier: AGPL-3.0-only

// The comparison of projects against the web application on the same phone:
// 390 x 844 logical pixels, in French, with the two projects of the web's
// demonstration (`load_demo_data.py`: Repeindre le salon, Refaire la salle de
// bain, its quote accepted on a line). The web side is measured in a browser
// by tool/web_parity_compare.py into test/parity/web_compare_fr_390.json, at
// the web release that brought the mode of comparison of the list (v0.5.1,
// after the pin of `web_parity`): the list with Compare projects, the list in
// its mode of comparison, the comparison and the comparison of one project.
// The app reads the same things on its render tree.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'projects_compare_test.dart' show reveal, tapKey;
import 'support/app.dart';
import 'support/goldens.dart';
import 'support/screens_2b.dart' show labels;
import 'support/lot3b.dart' show openSection;
import 'web_parity_test.dart' show drawnStyle;

final reference = jsonDecode(
  File('test/parity/web_compare_fr_390.json').readAsStringSync(),
) as Map<String, dynamic>;
Map<String, dynamic> web(String screen) =>
    (reference['screens'] as Map<String, dynamic>)[screen]
        as Map<String, dynamic>;

/// The latest web release a pin of tool/web_alignment.json names: the
/// release the app is aligned on for what came last.
({String release, String commit}) latestPin() {
  final elements =
      (jsonDecode(File('tool/web_alignment.json').readAsStringSync())
              as Map<String, dynamic>)['elements']
          as Map<String, dynamic>;
  List<int> version(String release) => [
    for (final p in release.substring(1).split('.')) int.parse(p),
  ];
  int compare(List<int> a, List<int> b) {
    for (var i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return a.length.compareTo(b.length);
  }

  final pins = [for (final e in elements.values) e as Map<String, dynamic>]
    ..sort(
      (a, b) => compare(
        version(a['release'] as String),
        version(b['release'] as String),
      ),
    );
  return (
    release: pins.last['release'] as String,
    commit: pins.last['commit'] as String,
  );
}

/// The two projects of the web's demonstration, in its order.
class WebDemo {
  late String home;
  late String paint;
  late String bathroom;

  Future<void> seed(Repository r) async {
    home = await r.createHome(name: "Maison d'exemple");
    final living = await r.createRoom(home, name: 'Salon', kind: 'living');
    final bath = await r.createRoom(
      home,
      name: 'Salle de bain',
      kind: 'bathroom',
    );
    final clock = r.clock as FixedClock;
    paint = await r.createProject(
      home,
      ProjectInput(
        title: 'Repeindre le salon',
        goal: "Murs et plafond, avant l'hiver.",
        status: 'planned',
        estimatedMinutes: 960,
        roomIds: [living],
      ),
    );
    for (final (label, nature, planned) in [
      ('Peinture et sous-couche', 'material', '240'),
      ('Peintre (plafond)', 'labour', '650'),
    ]) {
      await r.createLine(
        paint,
        LineInput(label: label, nature: nature, planned: planned, paid: '0'),
      );
    }
    // A second later, as the web creates them one after the other.
    clock.advance(const Duration(seconds: 1));
    bathroom = await r.createProject(
      home,
      ProjectInput(
        title: 'Refaire la salle de bain',
        goal: "Une douche à l'italienne à la place de la baignoire.",
        status: 'planned',
        roomIds: [bath],
      ),
    );
    final lines = <String>[];
    for (final (label, nature, planned, paid) in [
      ('Carrelage et faïence', 'material', '1200', '480'),
      ('Plombier (douche)', 'labour', '3000', '0'),
    ]) {
      lines.add(
        await r.createLine(
          bathroom,
          LineInput(label: label, nature: nature, planned: planned, paid: paid),
        ),
      );
    }
    for (final (name, amount, status) in [
      ('Plomberie des Tilleuls', '2850', 'accepted'),
      ('Bains Services', '3400', 'received'),
    ]) {
      final contractor = await r.createContractor(home, name: name);
      await r.createQuote(
        bathroom,
        QuoteInput(
          contractorId: contractor,
          amount: amount,
          status: status,
          budgetLineId: status == 'accepted' ? lines[1] : null,
          issuedOn: r.today(),
        ),
      );
    }
    await r.setEnvelope(home, r.today().year, '6000');
  }
}

Future<WebDemo> start(WidgetTester tester) async {
  await onPhone(tester, width: 390, height: 1600);
  final demo = WebDemo();
  final state = await pumpApp(tester, locale: 'fr', seed: demo.seed);
  await state.choose(demo.home);
  await tester.pumpAndSettle();
  await openSection(tester, labels['fr']!.projects);
  return demo;
}

/// The texts of [of], in the order they are drawn.
List<String> textsOf(WidgetTester tester, Finder of) => [
  for (final w in tester.widgetList<Text>(
    find.descendant(of: of, matching: find.byType(Text)),
  ))
    w.data!,
];

void main() {
  setUpAll(loadAppFonts);

  test('the measure is of the latest web release the app is aligned on', () {
    final measured = reference['web'] as Map<String, dynamic>;
    final pin = latestPin();
    expect(measured['repository'], 'HouseCairn/housecairn');
    expect(
      (measured['release'], measured['commit']),
      (pin.release, pin.commit),
      reason:
          'the web moved since the comparison was measured: measure again '
          'with tool/web_parity_compare.py',
    );
  });

  testWidgets('the list: Compare projects as the web, a secondary button '
      'the width of the column', (tester) async {
    await start(tester);
    final w = web('projects')['compare_link'] as Map<String, dynamic>;
    final button = find.descendant(
      of: find.byKey(const Key('projects-compare')),
      matching: find.byType(OutlinedButton),
    );
    await reveal(tester, button);
    expect(textsOf(tester, button), [w['text']]);
    expect(w['secondary'], isTrue);
    final rect = tester.getRect(button);
    final box = w['box'] as Map<String, dynamic>;
    expect(rect.left, closeTo((box['x'] as num).toDouble(), 1));
    expect(rect.width, closeTo((box['w'] as num).toDouble(), 1));
    final style = drawnStyle(tester, button);
    expect(style.size, w['font']);
    expect(style.weight, w['weight']);
  });

  testWidgets('the mode of comparison: every row is a box to tick from '
      'anywhere, then Compare the ticked projects (primary) and Cancel '
      '(secondary), 8 apart', (tester) async {
    final demo = await start(tester);
    await tapKey(tester, 'projects-compare');
    final w = web('projects_compare');
    final rows = (w['rows'] as List).cast<Map<String, dynamic>>();
    expect(rows.every((r) => r['tick_is_row'] == true), isTrue);
    expect(find.byType(Checkbox), findsNWidgets(rows.length));
    // Ticked from anywhere in the row: its title.
    await tester.tap(find.text('Repeindre le salon'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Checkbox>(find.byKey(Key('project-tick-${demo.paint}')))
          .value,
      isTrue,
    );
    // The box at the end of the row, as the web's.
    final tick = tester.getRect(find.byKey(Key('project-tick-${demo.paint}')));
    final row = tester.getRect(find.byKey(Key('project-${demo.paint}')));
    expect(tick.center.dx, greaterThan(row.center.dx));
    final submit = w['submit'] as Map<String, dynamic>;
    final cancel = w['cancel'] as Map<String, dynamic>;
    final s = find.byKey(const Key('projects-compare-ticked'));
    final c = find.byKey(const Key('projects-compare-cancel'));
    await reveal(tester, c);
    expect(textsOf(tester, s), [submit['text']]);
    expect(textsOf(tester, c), [cancel['text']]);
    expect(submit['secondary'], isFalse);
    expect(tester.widget(s), isA<FilledButton>());
    expect(cancel['secondary'], isTrue);
    expect(tester.widget(c), isA<OutlinedButton>());
    // Each as wide as its label (not the column), and where the web puts
    // the second: on the same line or under the first, 8 apart.
    final rs = tester.getRect(s), rc = tester.getRect(c);
    final sb = submit['box'] as Map<String, dynamic>;
    final cb = cancel['box'] as Map<String, dynamic>;
    expect(rs.left, closeTo((sb['x'] as num).toDouble(), 1));
    expect(rs.width, closeTo((sb['w'] as num).toDouble(), 24));
    expect(rc.width, closeTo((cb['w'] as num).toDouble(), 24));
    // Whether the second goes under the first depends on the width of the
    // two labels against the column: when the web is within a few pixels
    // of it (French, at 390: 257 + 8 + 95 for 358), a pixel of the drawing
    // of a font decides, so either is taken; otherwise the app does as the
    // web.
    final webSameLine = ((sb['y'] as num) - (cb['y'] as num)).abs() < 1;
    final appSameLine = (rs.top - rc.top).abs() < 1;
    final webTotal =
        (sb['w'] as num) + (w['button_row_gap'] as num) + (cb['w'] as num);
    final link = web('projects')['compare_link'] as Map<String, dynamic>;
    final column = (link['box'] as Map<String, dynamic>)['w'] as num;
    if ((webTotal - column).abs() > 6) expect(appSameLine, webSameLine);
    if (!appSameLine) expect(rc.left, closeTo((cb['x'] as num).toDouble(), 1));
    final gap = appSameLine ? rc.left - rs.right : rc.top - rs.bottom;
    expect(gap, closeTo((w['button_row_gap'] as num).toDouble(), 0.5));
    for (final (finder, m) in [(s, submit), (c, cancel)]) {
      final style = drawnStyle(tester, finder);
      expect(style.size, m['font']);
      expect(style.weight, m['weight']);
    }
  });

  testWidgets('the comparison: the title, the heads and every cell of the '
      'web, its fonts, a table 640 wide that scrolls on its own', (
    tester,
  ) async {
    final demo = await start(tester);
    await tapKey(tester, 'projects-compare');
    await tapKey(tester, 'project-${demo.paint}');
    await tapKey(tester, 'project-${demo.bathroom}');
    await tapKey(tester, 'projects-compare-ticked');
    expect(find.byType(ProjectCompareScreen), findsOneWidget);
    final w = web('project_compare');
    final table = w['table'] as Map<String, dynamic>;
    expect(
      tester.widget<HcLargeTitle>(find.byType(HcLargeTitle)).title,
      (w['h1'] as Map<String, dynamic>)['text'],
    );
    final drawn = tester.widget<HcColumnTable>(find.byType(HcColumnTable));
    expect(drawn.head, table['head']);
    expect(drawn.label, (table['region'] as Map<String, dynamic>)['label']);
    final webRows = (table['rows'] as List).cast<Map<String, dynamic>>();
    // The web's text is read with its spaces made plain.
    String plain(Object? text) =>
        (text as String).replaceAll(RegExp('[\u00a0\u202f]'), ' ');
    expect(
      [
        for (final r in drawn.rows)
          [
            for (final c in [r.head, ...r.cells]) plain(c),
          ],
      ],
      [
        for (final r in webRows) [for (final c in r['cells'] as List) plain(c)],
      ],
    );
    expect(webRows.every((r) => r['link'] == true), isTrue);
    expect(drawn.rows.every((r) => r.onTap != null), isTrue);
    // The area of the table keeps the page's width; the table inside is
    // the web's 640.
    final scroll = find.byKey(const Key('column-table-scroll'));
    final region = (table['region'] as Map<String, dynamic>)['box'] as Map;
    expect(
      tester.getRect(scroll).left,
      closeTo((region['x'] as num).toDouble(), 1),
    );
    expect(
      tester.getRect(scroll).width,
      closeTo((region['w'] as num).toDouble(), 1),
    );
    final inner = find
        .descendant(of: scroll, matching: find.byType(SizedBox))
        .first;
    expect(tester.getSize(inner).width, closeTo(table['width'] as num, 1));
    // The columns share the width as the browser does, within a few pixels
    // of the web's (the widest text of each, then the rest in proportion).
    final heads = [
      for (final h in drawn.head)
        tester.getRect(
          find
              .ancestor(of: find.text(h), matching: find.byType(SizedBox))
              .first,
        ),
    ];
    for (final (i, width) in (table['columns'] as List).indexed) {
      expect(
        heads[i].width,
        closeTo((width as num).toDouble(), 8),
        reason: 'column ${drawn.head[i]}',
      );
    }
    // The fonts of the heads and of the cells.
    final headStyle = drawnStyle(tester, find.text(drawn.head[1]));
    final hs = table['head_style'] as Map<String, dynamic>;
    expect(headStyle.size, hs['font']);
    expect(headStyle.weight, hs['weight']);
    expect(headStyle.line, closeTo((hs['line'] as num).toDouble(), 0.5));
    final cellStyle = drawnStyle(tester, find.text(drawn.rows[0].cells[0]));
    final cs = table['cell_style'] as Map<String, dynamic>;
    expect(cellStyle.size, cs['font']);
    expect(cellStyle.weight, cs['weight']);
    expect(cellStyle.line, closeTo((cs['line'] as num).toDouble(), 0.5));
    final rowHead = drawnStyle(tester, find.text(drawn.rows[0].head));
    final rs = table['row_head_style'] as Map<String, dynamic>;
    expect(rowHead.size, rs['font']);
    expect(rowHead.weight, rs['weight']);
    // The head of the table is the web's height; a row is a target of 48
    // at least, where the web's link is its title alone.
    expect(
      heads.first.height,
      closeTo((table['head_height'] as num).toDouble() - 1, 1.5),
    );
    for (final r in drawn.rows) {
      final height = tester.getSize(find.byKey(r.key!)).height;
      expect(height, greaterThanOrEqualTo(48));
      expect(
        height,
        lessThan((webRows.first['height'] as num).toDouble() + 12),
      );
    }
  });

  testWidgets('one project: the sentence of the web', (tester) async {
    final demo = await start(tester);
    await tapKey(tester, 'projects-compare');
    await tapKey(tester, 'project-${demo.paint}');
    await tapKey(tester, 'projects-compare-ticked');
    expect(
      find.text(web('project_compare_one')['empty'] as String),
      findsOneWidget,
    );
  });
}
