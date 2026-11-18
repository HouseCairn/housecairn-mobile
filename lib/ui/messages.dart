// SPDX-License-Identifier: AGPL-3.0-only

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'stock_format.dart';

/// The message of a refusal of the repository, from the ARB files.
String refusalMessage(
  AppLocalizations l10n,
  Refusal reason, {
  String available = '0',
}) => switch (reason) {
  Refusal.titleRequired => l10n.errTitleRequired,
  Refusal.tooLong => l10n.errTooLong,
  Refusal.intervalOutOfRange => l10n.errIntervalOutOfRange,
  Refusal.seasonMonthsRequired => l10n.errSeasonMonths,
  Refusal.fixedNeedsDate => l10n.errFixedNeedsDate,
  Refusal.dateOutOfRange => l10n.errDateOutOfRange,
  Refusal.futureDate => l10n.errFutureDate,
  Refusal.pastDate => l10n.errPastDate,
  Refusal.alreadyClosed => l10n.errAlreadyClosed,
  Refusal.notClosed => l10n.errNotClosed,
  Refusal.nextChanged => l10n.errNextChanged,
  Refusal.homeArchived => l10n.errHomeArchived,
  Refusal.lastActiveHome => l10n.errLastActiveHome,
  Refusal.nameMismatch => l10n.errNameMismatch,
  Refusal.currencyInvalid => l10n.errCurrencyInvalid,
  Refusal.notFound => l10n.errNotFound,
  Refusal.warrantyDurationOutOfRange => l10n.errWarrantyDuration,
  Refusal.phoneInvalid => l10n.errPhoneInvalid,
  Refusal.emailInvalid => l10n.errEmailInvalid,
  Refusal.urlInvalid => l10n.errUrlInvalid,
  Refusal.tooManyLinks => l10n.errTooManyLinks,
  Refusal.tradeOtherRequired => l10n.errTradeOther,
  Refusal.choiceInvalid => l10n.errChoiceInvalid,
  Refusal.notInHome => l10n.errNotInHome,
  Refusal.tooManyPhotos => l10n.errTooManyPhotos,
  Refusal.photoUnreadable => l10n.errPhotoUnreadable,
  Refusal.photoTooLarge => l10n.errPhotoTooLarge,
  Refusal.quantityInvalid => l10n.errQuantityInvalid,
  Refusal.quantityNotPositive => l10n.errQuantityNotPositive,
  Refusal.stockShort => l10n.errStockShort(available),
  Refusal.unitOtherRequired => l10n.errUnitOther,
  Refusal.materialListed => l10n.errMaterialListed,
  Refusal.tooManyMaterials => l10n.errTooManyMaterials,
  Refusal.moneyInvalid => l10n.errMoneyInvalid,
  Refusal.quoteNeedsLine => l10n.errQuoteNeedsLine,
  Refusal.notInProject => l10n.errNotInProject,
  Refusal.validityBeforeDate => l10n.errValidityBeforeDate,
  Refusal.tooManyFiles => l10n.errTooManyFiles,
  Refusal.fileTypeRefused => l10n.errFileType,
  Refusal.tooManyAttachments => l10n.errTooManyAttachments,
  Refusal.taskInProject => l10n.errTaskInProject,
  Refusal.onePlace => l10n.errOnePlace,
  Refusal.reportNotOpen => l10n.errReportNotOpen,
  Refusal.reportNotClosed => l10n.errReportNotClosed,
  Refusal.readOnlyHome => l10n.errReadOnlyHome,
  Refusal.ownersOnly => l10n.errOwnersOnly,
  Refusal.deleteOnServer => l10n.errDeleteOnServer,
  Refusal.exampleExists => l10n.errExampleExists,
  Refusal.tooManyLabels => l10n.errTooManyLabels,
};

/// Shows a refusal in a bar at the bottom of the screen.
void showRefusal(BuildContext context, Refused refused) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          refusalMessage(
            l10n,
            refused.reason,
            available: refused.available == null
                ? '0'
                : formatQuantity(
                    Localizations.localeOf(context).toLanguageTag(),
                    refused.available!,
                  ),
          ),
        ),
      ),
    );
}

/// A day in the language of the phone (docs/spec.md, "Languages").
String formatDay(BuildContext context, Day day) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale)
      .format(DateTime(day.year, day.month, day.day));
}

/// [Day] as the date pickers of Material take it.
DateTime asDateTime(Day day) => DateTime(day.year, day.month, day.day);

/// The state of an open occurrence in a pill, as the web shows it
/// (`tasks/_due.html`): late, today, postponed, the date, or no date.
Widget duePill(
  BuildContext context,
  Day? due,
  Day today, {
  bool postponed = false,
}) {
  final l10n = AppLocalizations.of(context);
  if (due == null) return HcPill(l10n.todayNoDate, tone: HcPillTone.ghost);
  final late = today.daysSince(due);
  if (late == 1) return HcPill(l10n.dayLate, tone: HcPillTone.danger);
  if (late > 1) return HcPill(l10n.daysLate(late), tone: HcPillTone.danger);
  if (late == 0) return HcPill(l10n.dueToday, tone: HcPillTone.warning);
  if (postponed) {
    return HcPill(
      l10n.postponedTo(formatDay(context, due)),
      tone: HcPillTone.info,
    );
  }
  // The date alone, as the web writes it (`|day`, "21 nov. 2026").
  return HcPill(formatDay(context, due), tone: HcPillTone.sand);
}
