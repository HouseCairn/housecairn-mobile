// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';

/// The rules of the stock of the web application (`stock/models.py`,
/// `stock/services.py`, `tasks/materials.py`), in decimal: a quantity or an
/// amount never passes through floating point (docs/adr/0002, web ADR 0051;
/// `test/no_double_test.dart` checks it).

/// The units of an article: a short list plus Other (`stock/models.py:24-33`),
/// the millilitre included (web ADR 0080 lot, no conversion between units).
const units = [
  'piece',
  'litre',
  'millilitre',
  'metre',
  'kilogram',
  'roll',
  'box',
  'other',
];

/// The kinds of a movement (`stock/models.py` `MovementKind`).
const entryKind = 'entry';
const exitKind = 'exit';
const inventoryKind = 'inventory';
const movementKinds = [entryKind, exitKind, inventoryKind];

/// At most this many articles on one task (`tasks/materials.py:28`).
const maxMaterialsPerTask = 50;

final zero = Decimal.zero;

/// A quantity or an amount of the model: `max_digits=10, decimal_places=2`
/// (`stock/models.py:20-21`), so at most two decimals and below 10^8.
/// `null` when [text] is not one; a comma is read as the decimal point, as
/// the French keyboard types it.
Decimal? parseQuantity(String text) {
  final clean = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,8}(\.\d{1,2})?$').hasMatch(clean)) return null;
  return Decimal.parse(clean);
}

/// The text a quantity is stored as: two decimals, `"2.50"` (docs/protocol.md,
/// section 2.2: amounts and quantities as decimal strings).
String storedQuantity(Decimal value) => value.toStringAsFixed(2);

/// The stored text read back.
Decimal readQuantity(String text) => Decimal.parse(text);

/// The quantity without trailing zeros: `3`, `0.5` (`stock/services.py`
/// `plain`).
String plain(Decimal value) {
  final text = value.toStringAsFixed(2);
  final trimmed = text.contains('.')
      ? text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
      : text;
  return trimmed == '-0' ? '0' : trimmed;
}

/// The count that chooses the plural of a unit after [quantity]
/// (`stock/models.py` `unit_text`): a whole quantity is its own count; a
/// fraction counts as plural above one, and as zero below it, so that a
/// language that says "0,5 litre" keeps the singular.
int pluralCount(Decimal quantity) {
  if (quantity == quantity.truncate()) {
    return quantity.toBigInt().toInt();
  }
  return quantity > Decimal.one ? 2 : 0;
}

/// A line of the ledger as the rules read it.
class LedgerLine {
  const LedgerLine(this.kind, this.quantity);

  final String kind;

  /// What the person typed: the amount added or taken, or the count of an
  /// inventory.
  final Decimal quantity;
}

/// The effect of each line of [lines] on the stock, in the order given (the
/// order of their clocks, docs/adr/0003-sync-protocol.md, "Derived"): an
/// entry adds its quantity, an exit takes it, an inventory sets the stock to
/// its count, so its effect is the count minus the sum of the lines before
/// it. The stock is the sum of these effects ([levelOf]).
List<Decimal> effectsOf(List<LedgerLine> lines) {
  var level = zero;
  final effects = <Decimal>[];
  for (final line in lines) {
    final effect = switch (line.kind) {
      entryKind => line.quantity,
      exitKind => -line.quantity,
      inventoryKind => line.quantity - level,
      _ => throw ArgumentError.value(line.kind, 'kind'),
    };
    effects.add(effect);
    level += effect;
  }
  return effects;
}

/// The stock of an article: the sum of the effects of its movements
/// (`stock/models.py:177-180`), never stored.
Decimal levelOf(List<LedgerLine> lines) =>
    effectsOf(lines).fold(zero, (sum, effect) => sum + effect);

/// Whether the stock is at or below the threshold (`stock/services.py`
/// `is_low`).
bool isLow(Decimal level, Decimal? threshold) =>
    threshold != null && level <= threshold;

/// What a closing takes of an article: [wanted], as far as the stock
/// [available] allows, never below zero and never above [wanted]
/// (`stock/services.py` `draw_for_task`, `tasks/models.py:400-401`).
Decimal drawable(Decimal wanted, Decimal available) {
  if (wanted <= zero) return zero;
  final stock = available > zero ? available : zero;
  return wanted < stock ? wanted : stock;
}
