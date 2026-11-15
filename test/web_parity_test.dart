// SPDX-License-Identifier: AGPL-3.0-only

// The rendering of the app against the web application on the same phone:
// 390 x 844 logical pixels (an iPhone), in French, with the data of the web's
// demonstration (`manage.py load_demo_data --language fr`). The web side is
// measured in a headless browser at 390 x 844 CSS pixels by
// tool/web_parity.py, which writes test/parity/web_fr_390.json; this test
// measures the same things on the app's render tree and fails when one
// drifts beyond a small tolerance (docs/adr/0011, "Same rendering as the
// web"). A CSS pixel of the web and a logical pixel of Flutter are the same
// unit on a phone (a point on iOS, a dp on Android).
//
// To look at the screens, write them as images in build/parity/:
//   flutter test --update-goldens --dart-define=PARITY_CAPTURE=true \
//     test/web_parity_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/theme.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/contractor_screens.dart';
import 'package:housecairn_mobile/ui/homes_screen.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/messages.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';

const capture = bool.fromEnvironment('PARITY_CAPTURE');

/// The French demonstration home of the web application
/// (`src/housecairn/homes/management/commands/load_demo_data.py`).
class Demo {
  late String home;
  late String utility;
  late String boiler;
  late String plumber;

  /// The day the web was measured on: the rows' dates are relative to it
  /// (`today` of test/parity/web_fr_390.json).
  Demo(this.webToday);

  final DateTime webToday;

  Future<void> seed(Repository r) async {
    // The clock of the tests stands on the day of the web's measure, and
    // moves a second between two tasks, as the web's demonstration creates
    // them one after the other (rows of one day come in the order created).
    final clock = r.clock as FixedClock;
    clock.advance(
      Duration(days: webToday.difference(asDateTime(r.today())).inDays),
    );
    home = await r.createHome(name: "Maison d'exemple");
    final rooms = <String, String>{};
    for (final (i, (kind, name)) in [
      ('living', 'Salon'),
      ('kitchen', 'Cuisine'),
      ('bathroom', 'Salle de bain'),
      ('hallway', 'Entrée'),
      ('utility', 'Buanderie'),
      ('outdoor', 'Jardin'),
    ].indexed) {
      rooms[name] = await r.createRoom(
        home,
        name: name,
        kind: kind,
        position: i,
      );
    }
    utility = rooms['Buanderie']!;
    boiler = await r.createItem(home, roomId: utility, name: 'Chaudière');
    plumber = await r.createContractor(
      home,
      name: "Plombier d'exemple",
      trade: 'plumber',
      phone: '+33 1 99 00 12 34',
    );
    final today = r.today();
    for (final (title, room, days) in [
      ('Tester le détecteur de fumée', 'Entrée', -3),
      ('Nettoyer le filtre de la VMC', 'Salle de bain', 0),
      ('Détartrer la bouilloire', 'Cuisine', 0),
      ('Entretien annuel de la chaudière', 'Buanderie', 6),
    ]) {
      await r.createTask(
        home,
        TaskInput(
          title: title,
          dueOn: today.addDays(days),
          roomId: rooms[room],
        ),
      );
      clock.advance(const Duration(seconds: 1));
    }
  }
}

/// What is measured on a screen, by the names of the web measures.
typedef Measures = Map<String, Object?>;

Rect rectOf(WidgetTester tester, Finder finder) => tester.getRect(finder);

/// The size a text is drawn at: its style's size through the text scaler.
double drawnSize(WidgetTester tester, Finder text) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: text, matching: find.byType(RichText)).first,
  );
  final size =
      paragraph.text.style?.fontSize ??
      (paragraph.text as TextSpan).children!.first.style!.fontSize!;
  return paragraph.textScaler.scale(size);
}

/// The text style a drawn text has: weight and size through the text scaler.
({double size, int weight, double line}) drawnStyle(
  WidgetTester tester,
  Finder text,
) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: text, matching: find.byType(RichText)).first,
  );
  final style =
      paragraph.text.style ??
      (paragraph.text as TextSpan).children!.first.style!;
  final size = paragraph.textScaler.scale(style.fontSize!);
  return (
    size: size,
    weight: (style.fontWeight ?? FontWeight.w400).value,
    line: size * (style.height ?? 1),
  );
}

/// A text drawn with one of the app's row styles.
Finder withStyle(TextStyle style) =>
    find.byWidgetPredicate((w) => w is Text && w.style == style);

/// What a list shows, section by section, as `tool/web_parity.py` reads the
/// web's `section` elements: the heading (in capitals, with its count), then
/// for each row its title, its place, its pills and its height.
List<Map<String, Object?>> sectionsOf(WidgetTester tester) {
  String text(Finder f) => tester.widget<Text>(f.first).data ?? '';
  final headings = find.byType(HcSectionHeading).evaluate().toList();
  final lists = find
      .byType(HcCardList)
      .evaluate()
      .where(
        (l) => find
            .descendant(
              of: find.byWidget(l.widget),
              matching: find.byType(HcTaskRow),
            )
            .evaluate()
            .isNotEmpty,
      )
      .toList();
  if (lists.isEmpty) return [];
  return [
    for (var i = 0; i < headings.length && i < lists.length; i++)
      {
        'heading': text(
          find.descendant(
            of: find.byWidget(headings[i].widget),
            matching: find.byType(Text),
          ),
        ),
        'rows': [
          for (final row
              in find
                  .descendant(
                    of: find.byWidget(lists[i].widget),
                    matching: find.byType(HcTaskRow),
                  )
                  .evaluate())
            {
              'title': text(
                find.descendant(
                  of: find.byWidget(row.widget),
                  matching: withStyle(HcText.rowTitle),
                ),
              ),
              'text':
                  find
                      .descendant(
                        of: find.byWidget(row.widget),
                        matching: withStyle(HcText.rowText),
                      )
                      .evaluate()
                      .isEmpty
                  ? ''
                  : text(
                      find.descendant(
                        of: find.byWidget(row.widget),
                        matching: withStyle(HcText.rowText),
                      ),
                    ),
              'pills': [
                for (final pill
                    in find
                        .descendant(
                          of: find.byWidget(row.widget),
                          matching: find.byType(HcPill),
                        )
                        .evaluate())
                  tester.widget<HcPill>(find.byWidget(pill.widget)).label,
              ],
              'height': tester.getRect(find.byWidget(row.widget)).height,
              'title_lines':
                  (tester
                              .getSize(
                                find.descendant(
                                  of: find.byWidget(row.widget),
                                  matching: withStyle(HcText.rowTitle),
                                ),
                              )
                              .height /
                          (HcFont.sizeBase * HcComponent.rowLineHeight))
                      .round(),
            },
        ],
      },
  ];
}

Measures measure(
  WidgetTester tester, {
  String? rowTitle,
  String? add,
  bool done = false,
  bool field = false,
}) {
  final m = <String, Object?>{};
  final title = find.descendant(
    of: find.byType(AppBar).last,
    matching: find.byType(Text),
  );
  m['h1_font'] = drawnSize(tester, title.first);
  m['nav_height'] = rectOf(tester, find.byType(NavigationBar)).height;
  if (rowTitle != null) {
    m['row_title_font'] = drawnSize(tester, find.text(rowTitle).first);
  }
  // The styles of the rows, of the headings and of the pills, wherever the
  // screen has them: the size, the weight and the line height are the web's.
  for (final (name, finder) in [
    ('row_title', withStyle(HcText.rowTitle)),
    ('row_text', withStyle(HcText.rowText)),
    (
      'pill',
      find.descendant(of: find.byType(HcPill), matching: find.byType(Text)),
    ),
    (
      'h2',
      find.descendant(
        of: find.byType(HcSectionHeading),
        matching: find.byType(Text),
      ),
    ),
  ]) {
    if (finder.evaluate().isEmpty) continue;
    final style = drawnStyle(tester, finder.first);
    m['${name}_font'] = style.size;
    m['${name}_weight'] = style.weight;
    if (name.startsWith('row_')) m['${name}_line'] = style.line;
  }
  final taskRows = find.byType(HcTaskRow);
  if (taskRows.evaluate().isNotEmpty) {
    m['row_height'] = rectOf(tester, taskRows.first).height;
  }
  m['sections'] = sectionsOf(tester);
  final cards = find.byType(HcCardList);
  if (cards.evaluate().isNotEmpty) {
    m['content_left'] = rectOf(tester, cards.first).left;
  } else if (find.byType(HcCard).evaluate().isNotEmpty) {
    m['content_left'] = rectOf(tester, find.byType(HcCard).first).left;
  } else if (find.byType(HcField).evaluate().isNotEmpty) {
    // A form: the web's `.card` holds the fields, the app has them on the page.
    m['content_left'] = rectOf(tester, find.byType(HcField).first).left;
  }
  if (done) {
    final button = find.widgetWithText(FilledButton, 'Fait').first;
    final r = rectOf(tester, button);
    m['done_button'] = {'w': r.width, 'h': r.height};
    m['done_font'] = drawnSize(tester, find.text('Fait').first);
  }
  if (add != null) {
    final label = find.text(add);
    final button = find
        .ancestor(
          of: label,
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        )
        .first;
    final floating = find
        .ancestor(of: label, matching: find.byType(FloatingActionButton))
        .evaluate()
        .isNotEmpty;
    final r = floating
        ? rectOf(
            tester,
            find
                .ancestor(
                  of: label,
                  matching: find.byType(FloatingActionButton),
                )
                .first,
          )
        : rectOf(tester, button);
    m['add_button'] = {'x': r.left, 'w': r.width, 'h': r.height};
    m['add_font'] = drawnSize(tester, label);
    m['add_in_flow'] =
        !floating &&
        find
            .ancestor(of: label, matching: find.byType(Scrollable))
            .evaluate()
            .isNotEmpty;
    // The gap to the list above it, as the web's margin between the two.
    final above = [
      for (final e in [...cards.evaluate(), ...find.byType(HcEmpty).evaluate()])
        if (tester.getRect(find.byElementPredicate((x) => x == e)).bottom <=
            r.top + 0.5)
          tester.getRect(find.byElementPredicate((x) => x == e)).bottom,
    ];
    m['add_gap'] = above.isEmpty || floating
        ? null
        : r.top - above.reduce((a, b) => a > b ? a : b);
  }
  if (field) {
    final decorator = find.byType(InputDecorator).first;
    m['field_height'] = rectOf(tester, decorator).height;
    final label = find.descendant(
      of: find.byType(HcField).first,
      matching: find.byType(Text),
    );
    m['label_font'] = drawnSize(tester, label.first);
  }
  return m;
}

/// A screen of the app, how it opens, and what to measure on it.
typedef Screen = ({
  String name,
  Future<void> Function(WidgetTester, Demo) open,
  Measures Function(WidgetTester) measure,
});

final screens = <Screen>[
  (
    name: 'today',
    open: (tester, demo) async {},
    measure: (t) => measure(
      t,
      rowTitle: 'Tester le détecteur de fumée',
      add: 'Ajouter une tâche',
      done: true,
    ),
  ),
  (
    name: 'task_form',
    open: (tester, demo) => openScreen(tester, TaskScreen(homeId: demo.home)),
    measure: (t) => measure(t, field: true),
  ),
  (
    name: 'homes',
    open: (tester, demo) => openScreen(tester, const HomesScreen()),
    measure: (t) =>
        measure(t, rowTitle: "Maison d'exemple", add: 'Ajouter un logement'),
  ),
  (
    name: 'rooms',
    open: (tester, demo) => openRooms(tester, 'Pièces'),
    measure: (t) => measure(t, rowTitle: 'Salon', add: 'Ajouter une pièce'),
  ),
  (
    name: 'room',
    open: (tester, demo) =>
        openScreen(tester, RoomScreen(homeId: demo.home, roomId: demo.utility)),
    measure: (t) => measure(t, add: 'Ajouter une tâche'),
  ),
  (
    name: 'room_form',
    open: (tester, demo) =>
        openScreen(tester, RoomFormScreen(homeId: demo.home)),
    measure: (t) => measure(t, field: true),
  ),
  (
    name: 'item',
    open: (tester, demo) =>
        openScreen(tester, ItemScreen(homeId: demo.home, itemId: demo.boiler)),
    measure: (t) => measure(t, add: 'Ajouter une tâche'),
  ),
  (
    name: 'item_form',
    open: (tester, demo) => openScreen(
      tester,
      ItemFormScreen(homeId: demo.home, roomId: demo.utility),
    ),
    measure: (t) => measure(t, field: true),
  ),
  (
    name: 'contractors',
    open: (tester, demo) => openScreen(tester, const ContractorsScreen()),
    measure: (t) => measure(
      t,
      rowTitle: "Plombier d'exemple",
      add: 'Ajouter un intervenant',
    ),
  ),
  (
    name: 'contractor_form',
    open: (tester, demo) =>
        openScreen(tester, ContractorFormScreen(homeId: demo.home)),
    measure: (t) => measure(t, field: true),
  ),
];

/// Tolerances, in logical pixels: a font size is exact; a box may differ by
/// the rounding of the web's line boxes.
const fontTolerance = 0.01;
const boxTolerance = 1.5;

/// The measures the app keeps apart from the web on purpose, with the
/// reason, and the value the app must have instead (docs/adr/0011).
const adaptations = <String, ({double app, String why})>{
  // 48, the touch target of Android and of the app (accessibility), where
  // the web's buttons are 44 high plus their border (45.19).
  'add_button.h': (app: 48, why: 'touch target of 48 dp'),
  // The page title sits in the app bar of the platform (back button, title,
  // actions), not under the brand bar of the web.
  'h1_font': (app: 24, why: 'title in the app bar'),
  // NavigationBar of 64 dp, plus the line above it; the web's bar is 64 px
  // with its line and the safe area, which the app's Scaffold adds itself.
  'nav_height': (app: 64, why: 'bar of the platform'),
  // Fields are 48 high, the touch target, where the web's are 50 (padding
  // and a line height of 1.5); the text inside has the same size.
  'field_height': (app: 48, why: 'touch target of 48 dp'),
};

/// Measures one side lacks on purpose, `<screen>.<measure>`, with the reason.
const absences = <String, String>{
  'rooms.label_font':
      'the web has a search field above the rooms; the app has no search yet',
  'room_form.h2_font':
      'the memory of the room is in this form, a screen of its own on the web',
  'room_form.h2_weight':
      'the memory of the room is in this form, a screen of its own on the web',
  'item_form.h2_font': 'the links and the contract are in this form, screens of their own on the web',
  'item_form.h2_weight': 'the links and the contract are in this form, screens of their own on the web',
  'item.row_text_font': 'the card of the item writes its room and kind in the style of a row text, the web as `.small` (same size and weight)',
  'item.row_text_weight': 'the card of the item writes its room and kind in the style of a row text, the web as `.small` (same size and weight)',
  'item.row_text_line': 'the card of the item writes its room and kind in the style of a row text, the web as `.small` (same size and weight)',
};

/// Rows whose title takes a second line in the app, with the reason: the
/// row has the menu of skip and postpone (48 dp, the touch target) that the
/// web's row does not have, so the title has 36 dp less. The height must be
/// the web's plus one line of the title.
const menuWraps = <String>{'Entretien annuel de la chaudière'};

void main() {
  final reference = jsonDecode(
    File('test/parity/web_fr_390.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final web = reference['screens'] as Map<String, dynamic>;
  final webToday = DateTime.parse(reference['today'] as String);
  final results = <String, Measures>{};

  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  tearDownAll(() {
    final out = Directory('build/parity')..createSync(recursive: true);
    File('${out.path}/app_fr_390.json')
        .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(results));
  });

  for (final screen in screens) {
    testWidgets('${screen.name} renders as the web at 390 px', (tester) async {
      await onPhone(tester, width: 390, height: 844);
      final demo = Demo(webToday);
      final state = await pumpApp(
        tester,
        locale: 'fr',
        seed: demo.seed,
        notifier: FakeNotifier(),
      );
      await state.choose(demo.home);
      await tester.pumpAndSettle();
      await screen.open(tester, demo);
      final app = results[screen.name] = screen.measure(tester);
      if (capture) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../build/parity/app_${screen.name}.png'),
        );
      }
      final w = web[screen.name] as Map<String, dynamic>;
      final failures = <String>[];
      // A measure taken on one side only is a failure, unless `absences`
      // names it with its reason: a screen that lacks what the web has, or
      // has what the web lacks, is not the same screen.
      void compare(String key, Object? appValue, Object? webValue, double tol) {
        if (appValue == null && webValue == null) return;
        final absent = absences['${screen.name}.$key'];
        if (appValue == null || webValue == null) {
          if (absent == null) {
            failures.add(
              '$key: measured on one side only (app $appValue, web $webValue)',
            );
          }
          return;
        }
        if (absent != null) {
          failures.add(
            '$key: listed in `absences` ($absent) but measured on both sides',
          );
          return;
        }
        final expected = adaptations[key]?.app ?? (webValue as num).toDouble();
        final actual = (appValue as num).toDouble();
        if ((actual - expected).abs() > tol) {
          failures.add('$key: app $actual, expected $expected (web $webValue)');
        }
      }

      for (final key in [
        'h1_font',
        'h2_font',
        'row_title_font',
        'row_text_font',
        'pill_font',
        'done_font',
        'add_font',
        'label_font',
      ]) {
        compare(key, app[key], w[key], fontTolerance);
      }
      for (final key in [
        'h2_weight',
        'row_title_weight',
        'row_text_weight',
        'pill_weight',
      ]) {
        compare(key, app[key], w[key], 0);
      }
      for (final key in ['row_title_line', 'row_text_line']) {
        compare(key, app[key], w[key], fontTolerance);
      }
      for (final key in [
        'nav_height',
        'content_left',
        'field_height',
        'row_height',
      ]) {
        compare(key, app[key], w[key], boxTolerance);
      }
      if (w['done_button'] != null) {
        final a = app['done_button']! as Map<String, Object?>;
        final b = w['done_button'] as Map<String, dynamic>;
        compare('done_button.h', a['h'], b['h'], boxTolerance);
        compare('done_button.w', a['w'], b['w'], 4);
      }
      if (w['add_button'] != null) {
        expect(app['add_button'], isNotNull, reason: 'no add button');
        final a = app['add_button']! as Map<String, Object?>;
        final b = w['add_button'] as Map<String, dynamic>;
        compare('add_button.x', a['x'], b['x'], boxTolerance);
        // A label's width depends on the shaping of the font (a variable font on
        // the web, static weights in the app): 4 px.
        compare('add_button.w', a['w'], b['w'], 4);
        compare('add_button.h', a['h'], b['h'], boxTolerance);
        compare('add_gap', app['add_gap'], w['add_gap'], boxTolerance);
        if (app['add_in_flow'] != true) {
          failures.add('add_button: floating, the web has it after the list');
        }
      }
      // What the list shows, section by section: the words and the heights.
      final webSections = w['sections'] as List<dynamic>;
      final appSections = app['sections']! as List<Map<String, Object?>>;
      if (webSections.length != appSections.length) {
        failures.add(
          'sections: ${appSections.length} in the app, ${webSections.length} on the web',
        );
      } else {
        for (final (i, ws) in webSections.indexed) {
          final as = appSections[i];
          if (as['heading'] != ws['heading']) {
            failures.add(
              'section $i heading: app "${as['heading']}", web "${ws['heading']}"',
            );
          }
          final webRows = ws['rows'] as List<dynamic>;
          final appRows = as['rows']! as List<Map<String, Object?>>;
          if (webRows.length != appRows.length) {
            failures.add(
              'section $i: ${appRows.length} rows in the app, ${webRows.length} on the web',
            );
            continue;
          }
          for (final (k, wr) in webRows.indexed) {
            final ar = appRows[k];
            for (final field in ['title', 'text']) {
              if (ar[field] != wr[field]) {
                failures.add(
                  'section $i row $k $field: app "${ar[field]}", web "${wr[field]}"',
                );
              }
            }
            if (ar['pills'].toString() != (wr['pills'] as List).toString()) {
              failures.add(
                'section $i row $k pills: app ${ar['pills']}, web ${wr['pills']}',
              );
            }
            final wraps = menuWraps.contains(wr['title']);
            if (wraps && ar['title_lines'] != 2) {
              failures.add(
                'section $i row $k: listed in `menuWraps`, but its title has ${ar['title_lines']} line(s)',
              );
            }
            // Rows after the first have the border of the list above them.
            compare(
              'section $i row $k height',
              ar['height'],
              (wr['height'] as num) +
                  (wraps ? HcFont.sizeBase * HcComponent.rowLineHeight : 0),
              boxTolerance,
            );
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }
}
