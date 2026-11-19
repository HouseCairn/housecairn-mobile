// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:math';

import 'package:qr/qr.dart';

/// QR labels (web `labels/models.py`, `labels/qr.py`, web ADR 0047; the app's
/// rules are in docs/adr/0014-qr-labels.md).
///
/// The code is the web's: 16 random bytes (128 bits), written in the URL-safe
/// base 64 alphabet without padding, 22 characters (`secrets.token_urlsafe`).
/// It names nothing: not the object, not the home, not a person, not an
/// address. The QR code of a label made by the phone holds that code and
/// nothing else.

/// The kinds of object a label opens (`LabelKind` of the web), by their
/// names on the wire.
enum LabelKind {
  room('room'),
  item('item'),
  article('article');

  const LabelKind(this.wire);

  final String wire;

  static LabelKind? parse(String? value) =>
      values.where((k) => k.wire == value).firstOrNull;
}

/// `CODE_BYTES` and `CODE_LENGTH` of the web.
const labelCodeBytes = 16;
const labelCodeLength = 22;

final _codeShape = RegExp(r'^[A-Za-z0-9_-]{22}$');

/// A new code: 16 bytes of [random] (the secure random of the phone), as
/// `secrets.token_urlsafe(16)` writes them.
String newLabelCode(Random random) {
  final bytes = List<int>.generate(labelCodeBytes, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// `is_code_shaped` of the web: 22 characters of the URL-safe alphabet.
bool isLabelCode(String value) => _codeShape.hasMatch(value);

/// What the QR code of a label made on the phone holds: the code alone, no
/// address of an instance, nothing of the home.
String labelPayload(String code) => code;

/// The code of a label in the text of a scanned QR code, or `null` when the
/// text is not one: the code alone (a label of the phone), or the address a
/// sticker of the web holds, `<address of the instance>/l/<code>/`, of which
/// only the code is kept. The host is never read nor called: a code opens
/// only what this phone knows.
String? labelCodeIn(String scanned) {
  final text = scanned.trim();
  if (isLabelCode(text)) return text;
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;
  if (uri.hasQuery || uri.hasFragment) return null;
  final segments = [
    for (final s in uri.pathSegments)
      if (s.isNotEmpty) s,
  ];
  if (segments.length < 2) return null;
  final code = segments.last;
  if (segments[segments.length - 2] != 'l' || !isLabelCode(code)) return null;
  return code;
}

/// Modules of white around a code: the 4 the standard asks for
/// (`QUIET_ZONE` of the web).
const labelQuietZone = 4;

/// The modules of the QR code of [text], row by row, `true` for a dark
/// module, at the web's level of error correction, Q: a quarter of a scuffed
/// sticker can be lost.
List<List<bool>> labelMatrix(String text) {
  final image = QrImage(
    QrCode.fromData(data: text, errorCorrectLevel: QrErrorCorrectLevel.Q),
  );
  return [
    for (var r = 0; r < image.moduleCount; r++)
      [for (var c = 0; c < image.moduleCount; c++) image.isDark(r, c)],
  ];
}

/// `printable` of the web (`labels/printing.py`): one line, no control
/// character, cut at [limit] characters, and `?` for a character that the
/// font of the sheet, Helvetica in Windows Latin-1, has no glyph for.
String printableLabelText(String text, {int limit = labelNameCharacters}) {
  final flat = text
      .replaceAll(RegExp(r'[\p{Cc}\p{Cf}\p{Zl}\p{Zp}]', unicode: true), ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .join(' ');
  final cut = flat.runes.take(limit).toList();
  return String.fromCharCodes([
    for (final rune in cut) _cp1252(rune) ? rune : 0x3F,
  ]);
}

/// `MAX_NAME_CHARACTERS` and `MAX_LABELS` of the web.
const labelNameCharacters = 120;
const maxLabelsPerSheet = 200;

/// The characters of Windows-1252 outside Latin-1, by their byte.
const _cp1252Extra = {
  0x20AC: 0x80, 0x201A: 0x82, 0x0192: 0x83, 0x201E: 0x84, 0x2026: 0x85, //
  0x2020: 0x86, 0x2021: 0x87, 0x02C6: 0x88, 0x2030: 0x89, 0x0160: 0x8A,
  0x2039: 0x8B, 0x0152: 0x8C, 0x017D: 0x8E, 0x2018: 0x91, 0x2019: 0x92,
  0x201C: 0x93, 0x201D: 0x94, 0x2022: 0x95, 0x2013: 0x96, 0x2014: 0x97,
  0x02DC: 0x98, 0x2122: 0x99, 0x0161: 0x9A, 0x203A: 0x9B, 0x0153: 0x9C,
  0x017E: 0x9E, 0x0178: 0x9F,
};

bool _cp1252(int rune) =>
    (rune >= 0x20 && rune < 0x7F) ||
    (rune >= 0xA0 && rune <= 0xFF) ||
    _cp1252Extra.containsKey(rune);

/// [text], already [printableLabelText], as the bytes of Windows-1252 that
/// the standard fonts of a PDF read (`WinAnsiEncoding`), one character per
/// byte.
String winAnsiText(String text) => String.fromCharCodes([
  for (final rune in text.runes) _cp1252Extra[rune] ?? rune,
]);
