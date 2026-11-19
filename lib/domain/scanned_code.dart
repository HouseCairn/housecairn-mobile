// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/zxing.dart';

/// The kinds of code the scanner of the app reads (docs/adr/0014-qr-labels.md):
/// the QR code of a label, and the bar codes of products (EAN-8, EAN-13,
/// UPC-A), which a later lot reads with the same scanner. A screen asks for
/// the kinds it wants; any other code in front of the camera is ignored.
enum CodeFormat { qr, ean8, ean13, upcA }

/// What the scanner read: the kind of code and its text, as printed.
class ScannedCode {
  const ScannedCode(this.format, this.text);

  final CodeFormat format;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is ScannedCode && other.format == format && other.text == text;

  @override
  int get hashCode => Object.hash(format, text);

  @override
  String toString() => 'ScannedCode(${format.name}, $text)';
}

/// One frame of the camera as its luminance: one byte per pixel, [rowStride]
/// bytes per row (the Y plane of a frame of Android as it comes, or the
/// luminance worked out from the colours of a frame of iOS).
class LumaFrame {
  const LumaFrame(this.bytes, this.width, this.height, {int? rowStride})
    : rowStride = rowStride ?? width;

  final Uint8List bytes;
  final int width;
  final int height;
  final int rowStride;
}

const _zxingFormats = {
  CodeFormat.qr: BarcodeFormat.qrCode,
  CodeFormat.ean8: BarcodeFormat.ean8,
  CodeFormat.ean13: BarcodeFormat.ean13,
  CodeFormat.upcA: BarcodeFormat.upcA,
};

/// Reads the first code of [formats] in [frame], or `null` when there is
/// none. Pure Dart (ZXing, `zxing_lib`): nothing leaves the phone, and the
/// same function runs in the tests on images the tests make.
ScannedCode? readCode(LumaFrame frame, Set<CodeFormat> formats) {
  if (formats.isEmpty || frame.width <= 0 || frame.height <= 0) return null;
  final wanted = [for (final f in formats) _zxingFormats[f]!];
  final source = PlanarYUVLuminanceSource(
    frame.bytes,
    frame.rowStride,
    frame.height,
    width: frame.width,
    height: frame.height,
  );
  final reader = MultiFormatReader();
  for (final binarizer in <Binarizer Function(LuminanceSource)>[
    HybridBinarizer.new,
    GlobalHistogramBinarizer.new,
  ]) {
    try {
      final result = reader.decode(
        BinaryBitmap(binarizer(source)),
        DecodeHint(possibleFormats: wanted, tryHarder: true),
      );
      final format = _zxingFormats.entries
          .where((e) => e.value == result.barcodeFormat)
          .firstOrNull
          ?.key;
      if (format == null || !formats.contains(format)) continue;
      return ScannedCode(format, result.text);
    } on ReaderException {
      continue;
    } on ArgumentError {
      continue;
    }
  }
  return null;
}
