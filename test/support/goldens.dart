// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Loads every font the app bundles (FontManifest.json: Manrope, and the
/// Material icons), so that golden files show the real text and icons
/// instead of the boxes of the test font.
Future<void> loadAppFonts() async {
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font
        in (family['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

/// Compares golden files with a tolerance of [tolerance] of the pixels, so
/// that a difference of anti-aliasing between two Linux machines does not
/// fail the test; a change of layout, colour or text changes far more.
class TolerantComparator extends LocalFileComparator {
  TolerantComparator(super.testFile, {this.tolerance = 0.002});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

/// Uses [TolerantComparator] for the golden files of the running test file,
/// in the directory of the comparator `flutter test` set for it.
void useTolerantGoldens() {
  final local = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = TolerantComparator(local.basedir.resolve('test.dart'));
}

/// Decodes the images of the screen (the cairn of the header) before a
/// capture: the first test of a file would take it before its image is
/// ready, as `goldens_settings_test.dart` found.
Future<void> precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pumpAndSettle();
}
