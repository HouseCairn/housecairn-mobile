// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The licence file of the bundled font (assets/fonts/README.md).
const manropeLicenceAsset = 'assets/fonts/Manrope-OFL.txt';

/// Adds the licence of the bundled font Manrope to the licences that About
/// lists (`showLicensePage`), next to those of the packages, as the SIL Open
/// Font License asks of software that bundles the font.
void registerFontLicences() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(manropeLicenceAsset);
    yield LicenseEntryWithLineBreaks(const ['Manrope'], text);
  });
}
