// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the photos and files to send, in Settings on a server (lot
// 4c): two files wait and the server refused one for its quota, at 320 px, in
// English and French, at text scale 1 and 2, on Android and on iOS. Regenerate
// after a deliberate change:
//   flutter test --update-goldens test/goldens_files_test.dart
// and review every changed image in the pull request.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/goldens.dart';
import 'support/server_fake.dart';

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  final more = {
    'en': AppLocalizationsEn().navMore,
    'fr': AppLocalizationsFr().navMore,
  };

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in more.keys) {
      for (final scale in [1.0, 2.0]) {
        final name =
            '${platform.name.toLowerCase()}_${locale}_x${scale.toInt()}';

        testWidgets('files to send, one refused, $name', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await onPhone(tester, width: 320, textScale: scale);
            final on = await startOnServer(tester, locale: locale);
            final repo = on.state.repository;
            final home = on.state.homes.first.id;
            final room = await repo.createRoom(home, name: 'Kitchen');
            for (var i = 0; i < 2; i++) {
              await repo.addPhoto(
                home,
                processPhoto(jpegWithGps(orientation: 1)),
                roomId: room,
              );
            }
            await repo.scanFiles();
            final photos = await repo.photosOf(roomId: room);
            final reference = FileReference.parse(
              photos.first.image,
              rowId: photos.first.id,
            )!;
            await repo.fileFailed(reference.file, 'quota_exceeded');
            await on.state.refresh();
            await tester.pumpAndSettle();
            await tester.tap(destination(more[locale]!));
            await tester.pumpAndSettle();
            const files = Key('settings-files');
            await tester.scrollUntilVisible(
              find.byKey(files),
              100,
              scrollable: find.byType(Scrollable).last,
            );
            await tester.pumpAndSettle();
            await Scrollable.ensureVisible(
              tester.element(find.byKey(files)),
              alignment: 0.1,
            );
            await precacheImages(tester);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/settings_files_$name.png'),
            );
            // The sync a change asks for, a day later: not wanted here.
            await tester.pumpWidget(const SizedBox.shrink());
            on.state.dispose();
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });
      }
    }
  }
}
