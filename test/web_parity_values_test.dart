// SPDX-License-Identifier: AGPL-3.0-only

// The figures of the app against the web application on the same phone, as
// test/web_parity_test.dart does for the lists: the lines "label at the
// left, value at the right" (HcValueRow, the web's `dl.facts`), the figures
// of a budget table (the web's `.table-stack td` on a phone), the quantity of
// a stock item (HcFigure, `.stock-quantity`) and the gauge of the budget
// (HcProgress, `progress` and its `.small`). The web side is measured by
// tool/web_parity_values.py into test/parity/web_values_fr_390.json.
//
// The second group checks the rule of a line at a large text size: the
// value goes under its label only when the line cannot hold both.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/theme.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:housecairn_mobile/design/values.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart' show openSection;
import 'web_parity_test.dart' show Demo, drawnStyle;

/// The measures the app keeps apart from the web on purpose, with the value
/// the app has instead and the reason (docs/adr/0011).
const adaptations = <String, ({double app, String why})>{
  // The web draws the browser's own `progress` (16 high in Chromium, its
  // width fixed at 10 em); the app draws the gauge of the design, 8 high,
  // across the card, its text at the right as on the web.
  'progress.height': (app: HcProgress.height, why: 'gauge of the design'),
};

String css(Color c) =>
    'rgb(${(c.r * 255).round()}, ${(c.g * 255).round()}, ${(c.b * 255).round()})';

Map<String, Object?> styleOf(WidgetTester tester, Finder text) {
  final s = drawnStyle(tester, text);
  final widget = tester.widget<Text>(text);
  return {
    'font': s.size,
    'weight': s.weight,
    'line': s.line,
    'color': css(widget.style!.color!),
  };
}

/// The first list of [HcValueList] that is [dense] or not.
Finder valueList(bool dense) => find.byWidgetPredicate(
  (w) => w is HcValueList && w.dense == dense && w.children.isNotEmpty,
);

Map<String, Object?> measure(WidgetTester tester) {
  final m = <String, Object?>{};
  final facts = valueList(false);
  if (facts.evaluate().isNotEmpty) {
    final list = facts.first;
    final rows = find.descendant(of: list, matching: find.byType(HcValueRow));
    final first = rows.first;
    final texts = find.descendant(of: first, matching: find.byType(Text));
    final row = tester.getRect(first);
    m['facts'] = {
      'label': styleOf(tester, texts.first),
      'value': styleOf(tester, texts.last),
      'value_right_gap': row.right - tester.getRect(texts.last).right,
      'label_left_gap': tester.getRect(texts.first).left - row.left,
      'heights': [
        for (final r in rows.evaluate())
          tester
              .getRect(
                find
                    .ancestor(
                      of: find.byWidget(r.widget),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .height,
      ],
    };
  }
  final dense = valueList(true);
  if (dense.evaluate().isNotEmpty) {
    final first = find
        .descendant(of: dense.first, matching: find.byType(HcValueRow))
        .first;
    final texts = find.descendant(of: first, matching: find.byType(Text));
    m['dense'] = {
      'label': styleOf(tester, texts.first),
      'value': styleOf(tester, texts.last),
      'height': tester
          .getRect(
            find.ancestor(of: first, matching: find.byType(DecoratedBox)).first,
          )
          .height,
    };
  }
  final figure = find.byType(HcFigure);
  if (figure.evaluate().isNotEmpty) {
    final texts = find.descendant(of: figure, matching: find.byType(Text));
    m['figure'] = {
      'figure': styleOf(tester, texts.at(0)),
      'unit': styleOf(tester, texts.at(1)),
      'gap':
          tester.getRect(texts.at(1)).left - tester.getRect(texts.at(0)).right,
    };
  }
  final progress = find.byKey(const Key('envelope-gauge'));
  if (progress.evaluate().isNotEmpty) {
    final text = find.descendant(of: progress, matching: find.byType(Text));
    m['progress'] = {
      'height': HcProgress.height,
      'text': styleOf(tester, text.first),
    };
  }
  return m;
}

final screens =
    <({String name, Future<void> Function(WidgetTester, Demo) open})>[
      (name: 'budget', open: (tester, demo) => openSection(tester, 'Budget')),
      (
        name: 'project',
        open: (tester, demo) => openScreen(
          tester,
          ProjectScreen(homeId: demo.home, projectId: demo.paintProject),
        ),
      ),
      (
        name: 'article',
        open: (tester, demo) => openScreen(
          tester,
          ArticleScreen(homeId: demo.home, articleId: demo.filter),
        ),
      ),
    ];

const fontTolerance = 0.01;
const boxTolerance = 1.5;

void main() {
  final reference = jsonDecode(
    File('test/parity/web_values_fr_390.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final web = reference['screens'] as Map<String, dynamic>;
  final webToday = DateTime.parse(
    (jsonDecode(File('test/parity/web_fr_390.json').readAsStringSync())
            as Map<String, dynamic>)['today']
        as String,
  );

  final results = <String, Object?>{};

  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  tearDownAll(() {
    final out = Directory('build/parity')..createSync(recursive: true);
    File('${out.path}/app_values_fr_390.json')
        .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(results));
  });

  test('the measure is of the web release the app is aligned on', () {
    final pin =
        (jsonDecode(File('tool/web_alignment.json').readAsStringSync())
                as Map<String, dynamic>)['elements']['web_parity']
            as Map<String, dynamic>;
    final measured = reference['web'] as Map<String, dynamic>;
    expect(
      (measured['release'], measured['commit']),
      (pin['release'], pin['commit']),
      reason:
          'the pin of web_parity moved: measure again with '
          'tool/web_parity_values.py',
    );
  });

  for (final screen in screens) {
    testWidgets('${screen.name}: figures as the web at 390 px', (tester) async {
      // Tall, so that a list builds every card at once; the width is the
      // phone's.
      await onPhone(tester, width: 390, height: 3000);
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
      final app = results[screen.name] = measure(tester);
      final w = web[screen.name] as Map<String, dynamic>;
      final failures = <String>[];

      void compare(String key, Object? a, Object? b, double tol) {
        if (a == null || b == null) {
          failures.add('$key: measured on one side only (app $a, web $b)');
          return;
        }
        if (a is String || b is String) {
          if (a != b) failures.add('$key: app $a, web $b');
          return;
        }
        final expected = adaptations[key]?.app ?? (b as num).toDouble();
        if (((a as num).toDouble() - expected).abs() > tol) {
          failures.add('$key: app $a, expected $expected (web $b)');
        }
      }

      void style(String key, Object? a, Object? b) {
        final x = a as Map<String, Object?>?;
        final y = b as Map<String, dynamic>?;
        if (x == null || y == null) {
          compare(key, x, y, 0);
          return;
        }
        compare('$key.font', x['font'], y['font'], fontTolerance);
        compare('$key.weight', x['weight'], y['weight'], 0);
        compare('$key.line', x['line'], y['line'], fontTolerance);
        compare('$key.color', x['color'], y['color'], 0);
      }

      for (final part in ['facts', 'dense', 'figure', 'progress']) {
        final a = app[part] as Map<String, Object?>?;
        final b = w[part] as Map<String, dynamic>?;
        if (a == null && b == null) continue;
        if (a == null || b == null) {
          failures.add('$part: shown on one side only');
          continue;
        }
        switch (part) {
          case 'facts':
            style('facts.label', a['label'], b['label']);
            style('facts.value', a['value'], b['value']);
            for (final k in ['value_right_gap', 'label_left_gap']) {
              compare('facts.$k', a[k], b[k], boxTolerance);
            }
            // The first row, a row between two others and the last one,
            // where both sides have such rows.
            final ah = (a['heights']! as List).cast<num>();
            final bh = (b['heights'] as List).cast<num>();
            if (ah.length >= 2 && bh.length >= 2) {
              compare('facts.first', ah.first, bh.first, boxTolerance);
            }
            if (ah.length >= 3 && bh.length >= 3) {
              compare('facts.middle', ah[1], bh[1], boxTolerance);
              compare('facts.last', ah.last, bh.last, boxTolerance);
            }
          case 'dense':
            style('dense.label', a['label'], b['label']);
            style('dense.value', a['value'], b['value']);
            compare('dense.height', a['height'], b['height'], boxTolerance);
          case 'figure':
            style('figure.figure', a['figure'], b['figure']);
            style('figure.unit', a['unit'], b['unit']);
            compare('figure.gap', a['gap'], b['gap'], boxTolerance);
          case 'progress':
            compare('progress.height', a['height'], b['height'], 0);
            style('progress.text', a['text'], b['text']);
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }

  group('a line at a large text size', () {
    Future<(Rect, Rect)> lay(
      WidgetTester tester,
      String label,
      String value,
      double scale,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: housecairnTheme(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                // The width of a card's content on a phone of 390.
                child: SizedBox(
                  width: 390 - 2 * HcSpace.s4 - 2 * HcSpace.s4,
                  child: HcValueRow(label, value),
                ),
              ),
            ),
          ),
        ),
      );
      return (
        tester.getRect(find.text(label)),
        tester.getRect(find.text(value)),
      );
    }

    testWidgets('a short line stays on one line at twice the size', (
      tester,
    ) async {
      final (label, value) = await lay(tester, 'Prix unitaire', '12,50 €', 2);
      expect(value.top, lessThan(label.bottom));
      expect(value.left, greaterThan(label.right));
    });

    testWidgets('the value goes under its label when the line cannot hold it', (
      tester,
    ) async {
      final (label, value) = await lay(
        tester,
        'Emplacement de rangement',
        'Garage, étagère 2',
        2,
      );
      expect(value.top, greaterThanOrEqualTo(label.bottom));
      expect(value.left, label.left);
    });

    testWidgets('at the normal size the same line keeps the value at the '
        'right, the label wrapping as on the web', (tester) async {
      final (label, value) = await lay(
        tester,
        'Emplacement de rangement',
        'Garage, étagère 2',
        1,
      );
      expect(value.top, lessThan(label.bottom));
      expect(label.height, greaterThan(HcFont.sizeSm * HcFont.lineHeight));
    });

    test('the rule: the value within 60 %, the longest word of the label '
        'beside it', () {
      expect(
        valuesHoldOnOneLine(
          width: 100,
          labelMinWidth: 20,
          valueWidth: 60,
          gap: 16,
        ),
        isTrue,
      );
      expect(
        valuesHoldOnOneLine(
          width: 100,
          labelMinWidth: 20,
          valueWidth: 61,
          gap: 16,
        ),
        isFalse,
      );
      expect(
        valuesHoldOnOneLine(
          width: 100,
          labelMinWidth: 30,
          valueWidth: 60,
          gap: 16,
        ),
        isFalse,
      );
    });
  });
}
