// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../domain/stock.dart' as stock;
import '../l10n/app_localizations.dart';

/// Quantities and amounts as the web writes them, in the language of the
/// phone, without ever going through floating point: the whole part is
/// formatted by `intl` as an integer, the decimals are written from the
/// decimal value itself (`test/no_double_test.dart`).

/// A quantity as the web's `floatformat:"-2"`: no decimals when it is whole,
/// else two (`2`, `2,50`).
String formatQuantity(String locale, Decimal value) {
  final negative = value < stock.zero;
  final cents = ((negative ? -value : value) * Decimal.fromInt(100))
      .round()
      .toBigInt();
  final whole = cents ~/ BigInt.from(100);
  final fraction = (cents % BigInt.from(100)).toInt();
  final format = NumberFormat.decimalPattern(locale);
  final text = StringBuffer(negative ? '-' : '')
    ..write(format.format(whole.toInt()));
  if (fraction != 0) {
    text
      ..write(format.symbols.DECIMAL_SEP)
      ..write(fraction.toString().padLeft(2, '0'));
  }
  return text.toString();
}

/// An amount in [currency], the currency of its home (docs/spec.md,
/// "Budget": homes are never added together), with the digits the currency
/// has.
String formatMoney(String locale, String currency, Decimal value) {
  final format = NumberFormat.currency(locale: locale, name: currency);
  final digits = format.decimalDigits ?? 2;
  final scale = BigInt.from(10).pow(digits);
  final negative = value < stock.zero;
  final units = ((negative ? -value : value) * Decimal.fromBigInt(scale))
      .round()
      .toBigInt();
  final whole = (units ~/ scale).toInt();
  final text = format.format(negative ? -whole : whole);
  if (digits == 0) return text;
  final sep = format.symbols.DECIMAL_SEP;
  final zeros = '$sep${'0' * digits}';
  final at = text.lastIndexOf(zeros);
  if (at < 0) return text;
  final fraction = (units % scale).toString().padLeft(digits, '0');
  return '${text.substring(0, at)}$sep$fraction'
      '${text.substring(at + zeros.length)}';
}

/// The unit of [article] as it reads after [quantity] ("1 litre",
/// "2 litres"), or what Other stands for; empty without a unit
/// (`stock/models.py` `unit_text`).
String unitAfter(AppLocalizations l10n, ArticleRow article, Decimal quantity) {
  final count = stock.pluralCount(quantity.abs());
  return switch (article.unit) {
    'piece' => l10n.unitPiece(count),
    'litre' => l10n.unitLitre(count),
    'metre' => l10n.unitMetre(count),
    'kilogram' => l10n.unitKilogram(count),
    'roll' => l10n.unitRoll(count),
    'box' => l10n.unitBox(count),
    'other' => article.unitOther,
    _ => '',
  };
}

/// A quantity of the article with its unit: "2,50 litres", "1 box", "3"
/// (`stock_extras.amount`).
String amountOf(
  AppLocalizations l10n,
  String locale,
  ArticleRow article,
  Decimal quantity,
) {
  final number = formatQuantity(locale, quantity);
  final unit = unitAfter(l10n, article, quantity);
  return unit.isEmpty ? number : '$number $unit';
}

/// The choices of the unit list, with their words.
List<(String, String)> unitChoices(AppLocalizations l10n) => [
  ('', l10n.unitNone),
  ('piece', l10n.unitPieceChoice),
  ('litre', l10n.unitLitreChoice),
  ('metre', l10n.unitMetreChoice),
  ('kilogram', l10n.unitKilogramChoice),
  ('roll', l10n.unitRollChoice),
  ('box', l10n.unitBoxChoice),
  ('other', l10n.unitOtherChoice),
];

String movementKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  stock.entryKind => l10n.movementEntry,
  stock.exitKind => l10n.movementExit,
  _ => l10n.movementInventory,
};
