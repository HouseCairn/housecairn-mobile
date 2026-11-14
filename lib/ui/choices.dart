// SPDX-License-Identifier: AGPL-3.0-only

import '../l10n/app_localizations.dart';

/// The words of the lists of choices (lib/domain/choices.dart), from the ARB
/// files: the catalogue of the web, so that both say the same things.

String roomKindLabel(AppLocalizations l10n, String code) => switch (code) {
  'living' => l10n.roomKindLiving,
  'kitchen' => l10n.roomKindKitchen,
  'bathroom' => l10n.roomKindBathroom,
  'bedroom' => l10n.roomKindBedroom,
  'hallway' => l10n.roomKindHallway,
  'office' => l10n.roomKindOffice,
  'utility' => l10n.roomKindUtility,
  'garage' => l10n.roomKindGarage,
  'cellar' => l10n.roomKindCellar,
  'attic' => l10n.roomKindAttic,
  'outdoor' => l10n.roomKindOutdoor,
  _ => l10n.roomKindOther,
};

String itemKindLabel(AppLocalizations l10n, String code) =>
    code == 'surface' ? l10n.itemKindSurface : l10n.itemKindEquipment;

String tradeLabel(AppLocalizations l10n, String code) => switch (code) {
  'plumber' => l10n.tradePlumber,
  'electrician' => l10n.tradeElectrician,
  'heating_engineer' => l10n.tradeHeatingEngineer,
  'roofer' => l10n.tradeRoofer,
  'carpenter' => l10n.tradeCarpenter,
  'painter' => l10n.tradePainter,
  'mason' => l10n.tradeMason,
  'gardener' => l10n.tradeGardener,
  'locksmith' => l10n.tradeLocksmith,
  'chimney_sweep' => l10n.tradeChimneySweep,
  'other' => l10n.tradeOther,
  _ => '',
};

String photoCategoryLabel(AppLocalizations l10n, String code) => switch (code) {
  'behind_walls' => l10n.photoCategoryBehindWalls,
  'before' => l10n.photoCategoryBefore,
  'after' => l10n.photoCategoryAfter,
  'other' => l10n.photoCategoryOther,
  _ => l10n.photoCategoryGeneral,
};

/// "every 3 months" for an interval of a template.
String everyLabel(AppLocalizations l10n, int interval, String unit) =>
    switch (unit) {
      'day' => l10n.templateEveryDays(interval),
      'week' => l10n.templateEveryWeeks(interval),
      'year' => l10n.templateEveryYears(interval),
      _ => l10n.templateEveryMonths(interval),
    };
