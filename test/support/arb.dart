// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The messages of an ARB file of lib/l10n, by key (metadata left out).
Map<String, String> arbMessages(String locale) {
  final json = jsonDecode(
    File('lib/l10n/app_$locale.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value as String,
  };
}

/// A pattern that matches a message once its placeholders are filled. A
/// plural (`{count, plural, one{{count} thing} other{{count} things}}`, ICU) matches any
/// of its forms.
RegExp messagePattern(String message) =>
    RegExp('^${_icuPattern(message)}\$', dotAll: true);

/// The regular expression of [message]: literal text escaped, `{name}` as any
/// text, and a plural as the alternation of its forms.
String _icuPattern(String message) {
  final out = StringBuffer();
  var i = 0;
  while (i < message.length) {
    final open = message.indexOf('{', i);
    if (open < 0) {
      out.write(RegExp.escape(message.substring(i)));
      break;
    }
    out.write(RegExp.escape(message.substring(i, open)));
    final close = _closing(message, open);
    final inner = message.substring(open + 1, close);
    final plural = RegExp(
      r'^\s*\w+\s*,\s*plural\s*,(.*)$',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(inner);
    if (plural == null) {
      out.write('.+');
    } else {
      final forms = <String>[];
      final body = plural.group(1)!;
      var j = 0;
      while (j < body.length) {
        final brace = body.indexOf('{', j);
        if (brace < 0) break;
        final end = _closing(body, brace);
        forms.add(_icuPattern(body.substring(brace + 1, end)));
        j = end + 1;
      }
      out.write('(?:${forms.join('|')})');
    }
    i = close + 1;
  }
  return out.toString();
}

/// The index of the brace that closes the one at [open].
int _closing(String text, int open) {
  var depth = 0;
  for (var i = open; i < text.length; i++) {
    if (text[i] == '{') depth++;
    if (text[i] == '}' && --depth == 0) return i;
  }
  throw FormatException('Unbalanced braces in "$text"');
}

/// Every text shown on the screen: text of `RichText` (which `Text` builds)
/// and of editable fields (which `SelectableText` builds). The glyph of an
/// `Icon` is a `RichText` too, of one character of the icon font: left out.
List<String> shownTexts(WidgetTester tester) {
  final texts = <String>[];
  for (final element in tester.allElements) {
    final widget = element.widget;
    if (widget is RichText) {
      if (element.findAncestorWidgetOfExactType<Icon>() != null) continue;
      texts.add(widget.text.toPlainText(includeSemanticsLabels: false));
    } else if (widget is EditableText) {
      texts.add(widget.controller.text);
    }
  }
  return texts.where((text) => text.trim().isNotEmpty).toList();
}

/// The shown texts that are no message of the ARB file of [locale]: a string
/// written in the code instead of the ARB files. [data] are the texts typed
/// by the person in the test (names of homes, titles of tasks), shown as
/// they are.
List<String> textsNotInArb(
  WidgetTester tester,
  String locale, {
  Iterable<String> data = const [],
}) {
  final patterns = [
    for (final message in arbMessages(locale).values) ...[
      messagePattern(message),
      // Headings of groups show in capitals, as on the web (HcSectionHeading).
      messagePattern(message.toUpperCase()),
    ],
  ];
  final typed = data.toSet();
  return shownTexts(tester)
      .where((text) => !typed.contains(text))
      .where((text) => !patterns.any((pattern) => pattern.hasMatch(text)))
      .toList();
}
