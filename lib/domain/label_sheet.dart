// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:pdf/pdf.dart';

import 'labels.dart';

/// The sheet of labels as a PDF, made on the phone in the layouts of the web
/// (`labels/printing.py`, web ADR 0047): an A4 sheet of 3 by 8 labels of 63.5
/// by 33.9 mm, the format of the common adhesive sheets, and a 62 mm roll
/// for a label printer, one label per page. Each label carries the QR code,
/// the name of the object in bold and where it is. The text is set in
/// Helvetica, which every PDF reader has: nothing is embedded, nothing is
/// fetched. Nothing is stored either: the bytes go to the share sheet of the
/// phone, and the file it was written to is removed.

const double _mm = 72 / 25.4;

/// One layout of the web, its numbers in points (1/72 inch).
class LabelLayout {
  const LabelLayout._({
    required this.code,
    required this.columns,
    required this.rows,
    required this.page,
    required this.label,
    required this.left,
    required this.top,
    required this.gap,
    required this.qrSide,
    required this.nameSize,
    required this.placeSize,
  });

  /// The name of the layout on the web (`a4-3x8`, `roll-62`).
  final String code;
  final int columns;
  final int rows;
  final (double, double) page;
  final (double, double) label;
  final double left;
  final double top;

  /// Between two columns.
  final double gap;
  final double qrSide;
  final double nameSize;
  final double placeSize;

  int get perPage => columns * rows;
}

const a4Sheet = LabelLayout._(
  code: 'a4-3x8',
  columns: 3,
  rows: 8,
  page: (210 * _mm, 297 * _mm),
  label: (63.5 * _mm, 33.9 * _mm),
  left: 7.2 * _mm,
  top: 15.1 * _mm,
  gap: 2.5 * _mm,
  qrSide: 27 * _mm,
  nameSize: 8.5,
  placeSize: 7,
);

const roll62 = LabelLayout._(
  code: 'roll-62',
  columns: 1,
  rows: 1,
  page: (62 * _mm, 40 * _mm),
  label: (62 * _mm, 40 * _mm),
  left: 0,
  top: 0,
  gap: 0,
  qrSide: 32 * _mm,
  nameSize: 10,
  placeSize: 8,
);

/// In the order of the web's choice; the first is the default.
const labelLayouts = [a4Sheet, roll62];

/// What one label shows: the name of its object, where it is, and the text
/// of its QR code ([labelPayload]).
class Sticker {
  const Sticker({required this.name, required this.place, required this.code});

  final String name;
  final String place;
  final String code;
}

/// The lines of [text] in [font] at [size] that fit [width], word by word as
/// ReportLab's `simpleSplit`, at most [maximum], the last one cut with `…`
/// when there are more.
List<String> _lines(
  String text,
  PdfFont font,
  double size,
  double width,
  int maximum,
) {
  double widthOf(String s) => font.stringMetrics(s).width * size;
  final lines = <String>[];
  var line = '';
  for (final word in text.split(' ').where((w) => w.isNotEmpty)) {
    final candidate = line.isEmpty ? word : '$line $word';
    if (line.isNotEmpty && widthOf(candidate) > width) {
      lines.add(line);
      line = word;
    } else {
      line = candidate;
    }
  }
  if (line.isNotEmpty) lines.add(line);
  if (lines.length > maximum) {
    lines.removeRange(maximum, lines.length);
    final last = lines.last.trimRight();
    lines[maximum - 1] = last.isEmpty
        ? '\u0085'
        : '${last.substring(0, last.length - 1)}\u0085';
  }
  return lines;
}

void _drawCode(PdfGraphics g, String text, double x, double y, double side) {
  final rows = labelMatrix(text);
  final total = rows.length + 2 * labelQuietZone;
  final module = side / total;
  g
    ..setFillColor(PdfColors.white)
    ..drawRect(x, y, side, side)
    ..fillPath()
    ..setFillColor(PdfColors.black);
  for (var r = 0; r < rows.length; r++) {
    final row = rows[r];
    var c = 0;
    while (c < row.length) {
      if (!row[c]) {
        c++;
        continue;
      }
      final start = c;
      while (c < row.length && row[c]) {
        c++;
      }
      g.drawRect(
        x + (start + labelQuietZone) * module,
        y + side - (r + labelQuietZone + 1) * module,
        (c - start) * module,
        module,
      );
    }
  }
  g.fillPath();
}

void _drawLabel(
  PdfGraphics g,
  LabelLayout layout,
  Sticker sticker,
  double x,
  double y, {
  required PdfFont font,
  required PdfFont bold,
}) {
  final (width, height) = layout.label;
  const padding = 1.5 * _mm;
  final side = layout.qrSide < height - 2 * padding
      ? layout.qrSide
      : height - 2 * padding;
  _drawCode(
    g,
    labelPayload(sticker.code),
    x + padding,
    y + (height - side) / 2,
    side,
  );
  final textX = x + padding + side + 1.5 * _mm;
  final textWidth = x + width - padding - textX;
  final top = y + height - padding;
  g.setFillColor(PdfColors.black);
  var cursor = top - layout.nameSize;
  final name = winAnsiText(printableLabelText(sticker.name));
  for (final line in _lines(name, bold, layout.nameSize, textWidth, 3)) {
    g.drawString(bold, layout.nameSize, line, textX, cursor);
    cursor -= layout.nameSize * 1.2;
  }
  final place = winAnsiText(printableLabelText(sticker.place));
  if (place.isNotEmpty) {
    cursor -= layout.placeSize * 0.3;
    g.setFillColor(const PdfColor(0.25, 0.25, 0.25));
    for (final line in _lines(place, font, layout.placeSize, textWidth, 2)) {
      g.drawString(font, layout.placeSize, line, textX, cursor);
      cursor -= layout.placeSize * 1.2;
    }
  }
}

/// The PDF of [stickers] in [layout]: between 1 and [maxLabelsPerSheet].
/// [compress] is for the tests, which read the objects of the file.
Future<Uint8List> labelSheet(
  List<Sticker> stickers,
  LabelLayout layout, {
  bool compress = true,
}) {
  if (stickers.isEmpty || stickers.length > maxLabelsPerSheet) {
    throw ArgumentError.value(
      stickers.length,
      'stickers',
      'between 1 and $maxLabelsPerSheet',
    );
  }
  final document = PdfDocument(compress: compress);
  PdfInfo(
    document,
    title: 'HouseCairn labels',
    author: 'HouseCairn',
    creator: 'HouseCairn',
    producer: 'HouseCairn',
  );
  final font = PdfFont.helvetica(document);
  final bold = PdfFont.helveticaBold(document);
  final (pageWidth, pageHeight) = layout.page;
  PdfGraphics? g;
  for (var index = 0; index < stickers.length; index++) {
    final slot = index % layout.perPage;
    if (slot == 0) {
      g = PdfPage(
        document,
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
      ).getGraphics();
    }
    final column = slot % layout.columns;
    final row = slot ~/ layout.columns;
    final x = layout.left + column * (layout.label.$1 + layout.gap);
    final y = pageHeight - layout.top - (row + 1) * layout.label.$2;
    _drawLabel(g!, layout, stickers[index], x, y, font: font, bold: bold);
  }
  return document.save();
}
