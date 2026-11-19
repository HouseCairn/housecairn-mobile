// SPDX-License-Identifier: AGPL-3.0-only

/// The barcode of a product: EAN-8, UPC-A, EAN-13 or GTIN-14, as the web
/// checks it (`barcodes/gtin.py`, web ADR 0083). A code is stored as it is
/// read once spaces and dashes are taken out; it is compared as a GTIN-14,
/// padded with zeros on the left, so that a UPC-A and the EAN-13 it is
/// printed as (`0` in front) are the same product.
library;

/// The lengths of a valid code.
const gtinLengths = {8, 12, 13, 14};

/// The longest code, the length of the column on the web.
const gtinMaxLength = 14;

/// The digits of a code typed or scanned, without spaces or dashes; not
/// checked.
String cleanGtin(String raw) =>
    raw.split(RegExp(r'\s+')).join().replaceAll('-', '');

/// The GS1 check digit of the digits before it (modulo 10, weights 3 and 1
/// from the right).
int gtinCheckDigit(String body) {
  var total = 0;
  var position = 0;
  for (final unit in body.codeUnits.reversed) {
    total += (unit - 0x30) * (position.isEven ? 3 : 1);
    position++;
  }
  return (10 - total % 10) % 10;
}

/// True for 8, 12, 13 or 14 ASCII digits whose last one is the check digit.
bool isValidGtin(String code) {
  if (!gtinLengths.contains(code.length)) return false;
  if (!RegExp(r'^[0-9]+$').hasMatch(code)) return false;
  return gtinCheckDigit(code.substring(0, code.length - 1)) ==
      code.codeUnitAt(code.length - 1) - 0x30;
}

/// The code as a GTIN-14, the form every code is compared in.
String asGtin14(String code) => code.padLeft(gtinMaxLength, '0');

/// The forms a stored code of the same product may have: 8, 12, 13 or 14
/// digits.
Set<String> gtinVariants(String code) {
  final padded = asGtin14(code);
  final found = {code};
  for (final length in const [8, 12, 13, 14]) {
    if (padded.length < length) continue;
    final head = padded.substring(0, padded.length - length);
    final tail = padded.substring(padded.length - length);
    if (head.replaceAll('0', '').isEmpty) found.add(tail);
  }
  return found;
}

/// The code as the open databases publish it: 8 digits for an EAN-8, else
/// 13 or 14.
String asPublishedGtin(String code) {
  final digits = code.replaceFirst(RegExp(r'^0+'), '');
  if (digits.length <= 8) return digits.padLeft(8, '0');
  return digits.padLeft(13, '0');
}

/// Whether [query] finds the stored code [ean] in a search of the stock or
/// of the items (`rooms/services.py`, `stock/services.py`, `_ean_match`): a
/// query of digits, once cleaned, that is the same product or a part of the
/// code.
bool gtinMatches(String query, String ean) {
  if (ean.isEmpty) return false;
  final code = cleanGtin(query);
  if (code.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(code)) return false;
  return gtinVariants(code).contains(ean) || ean.contains(code);
}
