// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/theme.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

final tokens = jsonDecode(
  File('design/tokens.json').readAsStringSync(),
) as Map<String, dynamic>;

Color parseColor(String value) {
  final hex = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(value);
  if (hex != null) {
    return Color(0xFF000000 | int.parse(hex.group(1)!, radix: 16));
  }
  final rgba = RegExp(r'^rgba\((\d+),\s*(\d+),\s*(\d+),\s*([0-9.]+)\)$')
      .firstMatch(value);
  if (rgba != null) {
    return Color.fromRGBO(
      int.parse(rgba.group(1)!),
      int.parse(rgba.group(2)!),
      int.parse(rgba.group(3)!),
      double.parse(rgba.group(4)!),
    );
  }
  throw FormatException('Unknown colour', value);
}

/// `1rem` is 16 logical pixels; `px` are logical pixels.
double parseLength(String value) {
  if (value.endsWith('rem')) {
    return double.parse(value.replaceAll('rem', '')) * 16;
  }
  if (value.endsWith('px')) return double.parse(value.replaceAll('px', ''));
  throw FormatException('Unknown length', value);
}

void main() {
  test('every colour token is in HcColors, with its value', () {
    final colours = (tokens['color'] as Map<String, dynamic>)
        .cast<String, String>();
    expect(HcColors.byName.keys.toSet(), colours.keys.toSet());
    for (final entry in colours.entries) {
      expect(
        HcColors.byName[entry.key],
        parseColor(entry.value),
        reason: entry.key,
      );
    }
  });

  test('spacing and radii are those of the tokens', () {
    final space = (tokens['space'] as Map<String, dynamic>)
        .cast<String, String>();
    expect(HcSpace.byName.keys.toSet(), space.keys.toSet());
    for (final entry in space.entries) {
      expect(
        HcSpace.byName[entry.key],
        parseLength(entry.value),
        reason: entry.key,
      );
    }
    final radius = (tokens['radius'] as Map<String, dynamic>)
        .cast<String, String>();
    expect(HcRadius.byName.keys.toSet(), radius.keys.toSet());
    for (final entry in radius.entries) {
      expect(
        HcRadius.byName[entry.key],
        parseLength(entry.value),
        reason: entry.key,
      );
    }
  });

  test('layout sizes used by the app are those of the tokens', () {
    final layout = (tokens['layout'] as Map<String, dynamic>)
        .cast<String, String>();
    for (final entry in HcLayout.byName.entries) {
      expect(entry.value, parseLength(layout[entry.key]!), reason: entry.key);
    }
  });

  test('the theme takes its main colours from the tokens', () {
    final scheme = housecairnTheme().colorScheme;
    expect(scheme.primary, HcColors.primary);
    expect(scheme.onPrimary, HcColors.textInverse);
    expect(scheme.secondary, HcColors.accent);
    expect(scheme.error, HcColors.danger);
    expect(scheme.surface, HcColors.surface);
    expect(scheme.onSurface, HcColors.text);
    expect(housecairnTheme().scaffoldBackgroundColor, HcColors.background);
  });
}
