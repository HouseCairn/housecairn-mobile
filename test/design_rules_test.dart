// SPDX-License-Identifier: AGPL-3.0-only

// Rules of the visual system (docs/adr/0010-design-from-the-web-app.md), as on
// the web (design guide, "Visual system"): a screen takes its colours and
// sizes from the tokens (lib/design/tokens.dart) and its look from the
// components (lib/design/widgets.dart, the theme), never from a value of its
// own; and every pair of text and background colour of the components meets
// WCAG 2.2 AA.

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// What a screen may not write: a colour, a text style or a size of its own.
final forbidden = <RegExp, String>{
  RegExp(r'\bColor\s*\(|\bColor\.from|\bColors\.'): 'a colour outside HcColors',
  RegExp(r'\bTextStyle\s*\(|\bfontSize\s*:|\bfontWeight\s*:\s*FontWeight\.'):
      'a text style outside HcText and HcFont',
  RegExp(
    r'\b(EdgeInsets\.\w+|EdgeInsetsDirectional\.\w+|SizedBox|SizedBox\.\w+|'
    r'Radius\.circular|BorderRadius\.circular|BoxConstraints|Size|Offset)'
    r'\s*\([^;{}]*?(?<![\w.])\d+(\.\d+)?\b',
  ): 'a size outside the tokens',
  RegExp(
    r'\b(width|height|size|dimension|maxWidth|minWidth|maxHeight|minHeight|'
    r'elevation|spacing|runSpacing|thickness|indent)\s*:\s*\d',
  ): 'a size outside the tokens',
};

/// The places of [source] that break a rule, as `line: rule`.
List<String> offences(String source) {
  final found = <String>{};
  final lines = source.split('\n');
  for (final (i, line) in lines.indexed) {
    final code = line.split('//').first;
    for (final MapEntry(key: pattern, value: rule) in forbidden.entries) {
      if (pattern.hasMatch(code)) found.add('${i + 1}: $rule: ${line.trim()}');
    }
  }
  return found.toList();
}

/// Relative luminance (WCAG 2.2).
double luminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Contrast ratio of two opaque colours (WCAG 2.2).
double contrast(Color a, Color b) {
  final la = luminance(a), lb = luminance(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  group('screens use the tokens and the components', () {
    final screens = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('there are screens to check', () {
      expect(screens.length, greaterThanOrEqualTo(5));
    });

    for (final file in screens) {
      test('${file.path} has no colour, text style or size of its own', () {
        expect(offences(file.readAsStringSync()), isEmpty);
      });
    }

    test('the components take their colours from the tokens only', () {
      for (final path in [
        'lib/design/widgets.dart',
        'lib/design/theme.dart',
        'lib/design/icons.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(
          RegExp(r'\bColor\s*\(|\bColor\.from').hasMatch(source),
          isFalse,
          reason: path,
        );
        expect(
          RegExp(r'\bColors\.(?!transparent\b)').hasMatch(source),
          isFalse,
          reason: path,
        );
      }
    });

    test(
      'the check finds a colour, a text style and a size written in a screen',
      () {
        expect(offences('color: Color(0xFF000000),'), hasLength(1));
        expect(offences('color: Colors.red,'), hasLength(1));
        expect(offences('style: TextStyle(color: x),'), hasLength(1));
        expect(
          offences('Text(a, style: s.copyWith(fontSize: 18)),'),
          hasLength(1),
        );
        expect(offences('padding: EdgeInsets.all(12),'), hasLength(1));
        expect(offences('const SizedBox(height: 8),'), hasLength(1));
        expect(offences('BorderRadius.circular(6)'), hasLength(1));
        expect(offences('maxWidth: 160,'), hasLength(1));
        expect(offences('padding: EdgeInsets.all(HcSpace.s4),'), isEmpty);
        expect(offences('const SizedBox(height: HcSpace.s2),'), isEmpty);
        expect(offences('MediaQuery.sizeOf(context).width / 2'), isEmpty);
        expect(offences("Key('today-\${id}')"), isEmpty);
      },
    );
  });

  group('contrast of the text on its background meets WCAG 2.2 AA', () {
    // Every pair the components and the theme draw: text, then background.
    final pairs = <String, (Color, Color)>{
      'body text on the page': (HcColors.text, HcColors.background),
      'body text in a card': (HcColors.text, HcColors.surface),
      'muted text on the page': (HcColors.textMuted, HcColors.background),
      'muted text in a card': (HcColors.textMuted, HcColors.surface),
      'title of an overdue row': (HcColors.text, HcColors.dangerSoft),
      'muted text of an overdue row': (HcColors.textMuted, HcColors.dangerSoft),
      'overdue heading': (HcColors.danger, HcColors.background),
      'primary button': (HcColors.textInverse, HcColors.primary),
      'secondary and text buttons in a card': (
        HcColors.primary,
        HcColors.surface,
      ),
      'text buttons on the page': (HcColors.primary, HcColors.background),
      'danger button': (HcColors.textInverse, HcColors.danger),
      'danger outlined button': (HcColors.danger, HcColors.surface),
      'field label in a card': (HcColors.textMuted, HcColors.surface),
      'field error in a card': (HcColors.danger, HcColors.surface),
      'current section in the bar': (HcColors.primary, HcColors.surface),
      'other sections in the bar': (HcColors.textMuted, HcColors.surface),
      'undo bar': (HcColors.text, HcColors.sageSoft),
      'undo bar action': (HcColors.primary, HcColors.sageSoft),
      for (final tone in HcPillTone.values)
        'pill ${tone.name}': (
          tone.foreground,
          tone.background ?? HcColors.surface,
        ),
      'danger pill on an overdue row': (
        HcPillTone.danger.foreground,
        HcPillTone.danger.background!,
      ),
    };

    for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
      test('$name: 4.5:1 at least', () {
        expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
      });
    }

    test('the formula is the one of WCAG', () {
      expect(
        contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
      expect(
        contrast(const Color(0xFF777777), const Color(0xFFFFFFFF)),
        closeTo(4.48, 0.01),
      );
    });
  });
}
