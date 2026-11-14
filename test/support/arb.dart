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

/// A pattern that matches a message once its placeholders are filled.
RegExp messagePattern(String message) {
  final buffer = StringBuffer('^');
  var last = 0;
  for (final match in RegExp(
    r'\{[A-Za-z_][A-Za-z0-9_]*\}',
  ).allMatches(message)) {
    buffer
      ..write(RegExp.escape(message.substring(last, match.start)))
      ..write('.+');
    last = match.end;
  }
  buffer
    ..write(RegExp.escape(message.substring(last)))
    ..write(r'$');
  return RegExp(buffer.toString(), dotAll: true);
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
