// SPDX-License-Identifier: AGPL-3.0-only

// Amounts and quantities never pass through floating point (docs/plan.md,
// lot 3; docs/adr/0002, "Amounts are TEXT"; web ADR 0051): the code of the
// stock and of its amounts may not name `double`, convert to one, or parse
// a number other than as a `Decimal`. Lot 3b adds the budget's files here.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The files of the stock and of the amounts.
const checked = [
  'lib/domain/stock.dart',
  'lib/data/stock_repository.dart',
  'lib/ui/stock_format.dart',
  'lib/ui/stock_screens.dart',
];

final floating = RegExp(
  r'\bdouble\b|\btoDouble\s*\(|\bnum\.(try)?parse\b|\bdouble\.(try)?parse\b|'
  r'\bnum\b|\btoStringAsPrecision\b|\d\.\d+\s*[*/+-]|[*/+-]\s*\d\.\d+',
);

List<String> offences(String source) => [
  for (final (i, line) in source.split('\n').indexed)
    if (floating.hasMatch(line.split('//').first)) '${i + 1}: ${line.trim()}',
];

void main() {
  for (final path in checked) {
    test('$path has no floating point', () {
      expect(offences(File(path).readAsStringSync()), isEmpty);
    });
  }

  test('the check finds floating point', () {
    expect(offences('final double price = 1;'), hasLength(1));
    expect(offences('x.toDouble()'), hasLength(1));
    expect(offences("double.parse('1.5')"), hasLength(1));
    expect(offences('num.tryParse(text)'), hasLength(1));
    expect(offences('final num n = 2;'), hasLength(1));
    expect(offences('total * 0.2'), hasLength(1));
    expect(offences("Decimal.parse('1.5')"), isEmpty);
    expect(offences('// a double in a comment'), isEmpty);
  });
}
