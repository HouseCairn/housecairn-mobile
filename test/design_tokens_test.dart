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

/// `0.08em` is 0.08 (a multiple of the size).
double parseEm(String value) => double.parse(value.replaceAll('em', ''));

/// A length, a multiple of the size (`em`) or a plain number.
double parseNumber(String value) {
  if (value.endsWith('rem') || value.endsWith('px')) return parseLength(value);
  if (value.endsWith('em')) return parseEm(value);
  return double.parse(value);
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

  test('type sizes and weights are those of the tokens', () {
    final font = (tokens['font'] as Map<String, dynamic>)
        .cast<String, String>();
    for (final entry in HcFont.sizeByName.entries) {
      expect(entry.value, parseLength(font[entry.key]!), reason: entry.key);
    }
    expect(
      HcFont.sizeByName.keys.toSet(),
      font.keys.where((k) => k.startsWith('size-')).toSet(),
    );
    for (final entry in HcFont.weightByName.entries) {
      expect(entry.value.value, int.parse(font[entry.key]!), reason: entry.key);
    }
    expect(HcFont.lineHeight, double.parse(font['line-height']!));
    expect(HcFont.lineHeightTight, double.parse(font['line-height-tight']!));
    expect(HcFont.trackingCaps, parseEm(font['tracking-caps']!));
    expect(font['family-base'], startsWith('"${HcFont.family}"'));
  });

  test('every weight the app draws is declared in pubspec.yaml', () {
    // The weights of the Manrope family, read from the text of pubspec.yaml
    // (no YAML package: the `weight:` lines are the only ones of the file).
    final declared = RegExp(r'^\s*weight:\s*(\d+)\s*$', multiLine: true)
        .allMatches(File('pubspec.yaml').readAsStringSync())
        .map((m) => int.parse(m.group(1)!))
        .toSet();
    for (final weight in HcFont.weights) {
      expect(declared, contains(weight.value), reason: 'w${weight.value}');
    }
    // And no weight is bundled that the app does not draw.
    expect(declared, HcFont.weights.map((w) => w.value).toSet());
  });

  test('shadows are those of the tokens', () {
    final shadow = (tokens['shadow'] as Map<String, dynamic>)
        .cast<String, String>();
    expect(HcShadow.byName.keys.toSet(), shadow.keys.toSet());
    for (final entry in shadow.entries) {
      final parts = RegExp(r'^(-?\d+)(?:px)? (-?\d+)px (\d+)px (rgba\(.*\))$')
          .firstMatch(entry.value)!;
      final box = HcShadow.byName[entry.key]!.single;
      expect(box.offset.dx, double.parse(parts.group(1)!), reason: entry.key);
      expect(box.offset.dy, double.parse(parts.group(2)!), reason: entry.key);
      expect(box.blurRadius, double.parse(parts.group(3)!), reason: entry.key);
      expect(box.color, parseColor(parts.group(4)!), reason: entry.key);
    }
  });

  test('component sizes are those of the tokens', () {
    final component = (tokens['component'] as Map<String, dynamic>)
        .cast<String, String>();
    expect(HcComponent.byName.keys.toSet(), component.keys.toSet());
    for (final entry in component.entries) {
      expect(
        HcComponent.byName[entry.key],
        parseNumber(entry.value),
        reason: entry.key,
      );
    }
  });

  test('every value of the tokens names its web source', () {
    final sources = (tokens[r'$sources'] as Map<String, dynamic>)
        .cast<String, String>();
    final keys = <String>{
      for (final MapEntry(key: group, value: values) in tokens.entries)
        if (!group.startsWith(r'$'))
          for (final key in (values as Map<String, dynamic>).keys)
            '$group.$key',
    };
    expect(sources.keys.toSet(), keys);
    for (final source in sources.values) {
      expect(source, matches(RegExp(r'^(design|src/housecairn/static)/')));
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
