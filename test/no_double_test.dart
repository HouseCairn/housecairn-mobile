// SPDX-License-Identifier: AGPL-3.0-only

// Amounts and quantities never pass through floating point (docs/plan.md,
// lot 3; docs/adr/0002, "Amounts are TEXT"; web ADR 0051): the code of the
// stock and of its amounts may not name `double`, convert to one, or parse
// a number other than as a `Decimal`. Lot 3b added the budget's files.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The files of the stock, of the budget and of the amounts.
const checked = [
  'lib/domain/stock.dart',
  'lib/data/stock_repository.dart',
  'lib/ui/stock_format.dart',
  'lib/ui/stock_screens.dart',
  'lib/domain/budget.dart',
  'lib/data/budget_repository.dart',
  'lib/ui/budget_parts.dart',
  'lib/ui/budget_screens.dart',
  'lib/ui/project_screens.dart',
  'lib/ui/report_screens.dart',
  'lib/ui/task_screen.dart',
  // Sync carries amounts as decimal strings and never converts them (lot 4).
  'lib/sync/operation.dart',
  'lib/sync/engine.dart',
  'lib/data/sync_repository.dart',
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
