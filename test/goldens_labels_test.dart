// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the QR labels (docs/adr/0014-qr-labels.md), at 360 px, in
// English and French, at text scale 1 and 2, on Android and on iOS: the page
// of a label, the list of what to label, and the scanner when the camera was
// refused. The fixture is the neutral home of lot 2b. Regenerate after a
// deliberate change:
//   flutter test --update-goldens test/goldens_labels_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/code_camera.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/labels.dart';
import 'package:housecairn_mobile/domain/scanned_code.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:housecairn_mobile/ui/label_screens.dart';
import 'package:housecairn_mobile/ui/scanner.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';

class _RefusedCamera implements CodeCamera {
  @override
  Future<void> start(
    Set<CodeFormat> formats,
    void Function(ScannedCode code) onCode,
  ) async => throw const CodeCameraDenied();

  @override
  Widget preview() => const SizedBox.shrink();

  @override
  Future<void> stop() async {}
}

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final screens = <(String, Widget Function(Lot2b, String))>[
    ('label', (d, label) => LabelScreen(homeId: d.homes.main, labelId: label)),
    ('labels', (d, label) => LabelsScreen(homeId: d.homes.main)),
    (
      'scanner_refused',
      (d, label) => Builder(
        builder: (context) => CodeScannerScreen(
          camera: _RefusedCamera(),
          formats: const {CodeFormat.qr},
          title: AppLocalizations.of(context).scanLabel,
          hint: AppLocalizations.of(context).scanHint,
        ),
      ),
    ),
  ];

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in ['en', 'fr']) {
      for (final scale in [1.0, 2.0]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_x${scale.toInt()}';
        for (final (page, screen) in screens) {
          testWidgets('$page, $name', (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            try {
              await onPhone(tester, textScale: scale);
              late Lot2b data;
              late String label;
              await pumpApp(
                tester,
                locale: locale,
                seed: (r) async {
                  data = await Lot2b.seed(r);
                  label = (await r.createLabel(
                    data.homes.main,
                    LabelKind.room,
                    data.kitchen,
                  )).$1.id;
                  await r.createLabel(
                    data.homes.main,
                    LabelKind.item,
                    data.boiler,
                  );
                },
              );
              await openScreen(tester, screen(data, label));
              await tester.pumpAndSettle();
              await precacheImages(tester);
              expect(tester.takeException(), isNull);
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile('goldens/labels_${page}_$name.png'),
              );
            } finally {
              debugDefaultTargetPlatformOverride = null;
            }
          });
        }
      }
    }
  }
}
