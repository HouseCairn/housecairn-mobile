// SPDX-License-Identifier: AGPL-3.0-only

import 'day.dart';

/// The manufacturer's warranty of an item, as the web works it out
/// (`rooms/models.py` `warranty_end`, web ADR 0080).

/// The units of a warranty's duration (`WarrantyUnit`).
const warrantyMonth = 'month';
const warrantyYear = 'year';
const warrantyUnits = [warrantyMonth, warrantyYear];

/// Who gives the warranty (`WarrantyProvider`); `''` when not said.
const warrantyProviders = ['manufacturer', 'shop'];

/// A warranty of more than 99 months or years is a typing error
/// (`MAX_WARRANTY_DURATION`).
const maxWarrantyDuration = 99;

/// The day a warranty of [duration] months or years from [start] ends, or
/// `null` without a start, a duration or a known unit: the same date that
/// many months or years later, the last day of the month when that month is
/// shorter (31 January plus one month ends on 28 or 29 February).
Day? warrantyEnd(Day? start, int? duration, String unit) {
  if (start == null || duration == null || duration == 0) return null;
  return switch (unit) {
    warrantyYear => start.addYears(duration),
    warrantyMonth => start.addMonths(duration),
    _ => null,
  };
}

/// The start of a warranty: the date given, else the purchase date
/// (`Item.warranty_start`).
Day? warrantyStart(Day? startsOn, Day? purchasedOn) => startsOn ?? purchasedOn;
