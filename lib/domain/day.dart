// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart' show immutable;

/// A date out of the calendar of the web application: before 1 January 1 or
/// after 31 December 9999, the range of Python's `datetime.date`. The port of
/// the recurrence catches it where the Python code catches `OverflowError`
/// and `ValueError`.
class DayOutOfRange implements Exception {
  const DayOutOfRange(this.message);

  final String message;

  @override
  String toString() => 'DayOutOfRange: $message';
}

/// A calendar day, never an instant (web ADR 0032): a due date cannot move
/// with a change of clock or time zone.
///
/// Held as whole numbers (year, month, day); arithmetic is done on the count
/// of days since 1970-01-01 of the proleptic Gregorian calendar, the one of
/// Python's `datetime.date`. Its range is the same: years 1 to 9999.
@immutable
class Day implements Comparable<Day> {
  /// The day [year]-[month]-[day]; throws [DayOutOfRange] for a day that does
  /// not exist (30 February) or a year outside 1 to 9999.
  factory Day(int year, int month, int day) {
    if (year < 1 || year > 9999) {
      throw DayOutOfRange('year $year is out of range');
    }
    if (month < 1 || month > 12) {
      throw DayOutOfRange('month $month is out of range');
    }
    if (day < 1 || day > daysInMonth(year, month)) {
      throw DayOutOfRange('day $day is out of range for $year-$month');
    }
    return Day._(year, month, day);
  }

  const Day._(this.year, this.month, this.day);

  /// The day [count] days after 1970-01-01 (before it when negative).
  factory Day.fromEpochDay(int count) {
    // Civil from days, H. Hinnant, http://howardhinnant.github.io/date_algorithms.html
    final z = count + 719468;
    final era = _floorDiv(z, 146097);
    final doe = z - era * 146097;
    final yoe = (doe - doe ~/ 1460 + doe ~/ 36524 - doe ~/ 146096) ~/ 365;
    final doy = doe - (365 * yoe + yoe ~/ 4 - yoe ~/ 100);
    final mp = (5 * doy + 2) ~/ 153;
    final d = doy - (153 * mp + 2) ~/ 5 + 1;
    final m = mp < 10 ? mp + 3 : mp - 9;
    final y = yoe + era * 400 + (m <= 2 ? 1 : 0);
    return Day(y, m, d);
  }

  /// A day written `YYYY-MM-DD`, as the database and the web store it.
  factory Day.parse(String text) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (match == null) throw FormatException('Not a day: $text');
    return Day(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// The calendar day of a local [DateTime] (its date part).
  factory Day.of(DateTime local) => Day(local.year, local.month, local.day);

  final int year;
  final int month;
  final int day;

  static bool isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  static int daysInMonth(int year, int month) => switch (month) {
    2 => isLeapYear(year) ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  /// Days since 1970-01-01.
  int get epochDay {
    // Days from civil, H. Hinnant.
    final y = month <= 2 ? year - 1 : year;
    final era = _floorDiv(y, 400);
    final yoe = y - era * 400;
    final mp = month > 2 ? month - 3 : month + 9;
    final doy = (153 * mp + 2) ~/ 5 + day - 1;
    final doe = yoe * 365 + yoe ~/ 4 - yoe ~/ 100 + doy;
    return era * 146097 + doe - 719468;
  }

  /// Python `date + timedelta(days=count)`.
  Day addDays(int count) => Day.fromEpochDay(epochDay + count);

  /// Python `date + relativedelta(months=count)`: the day is clamped to the
  /// last day of a shorter month (31 January + 1 month = 28 February).
  Day addMonths(int count) {
    final index = year * 12 + (month - 1) + count;
    final y = _floorDiv(index, 12);
    final m = index - y * 12 + 1;
    if (y < 1 || y > 9999) throw DayOutOfRange('year $y is out of range');
    final last = daysInMonth(y, m);
    return Day(y, m, day > last ? last : day);
  }

  /// Python `date + relativedelta(years=count)`: 29 February gives 28
  /// February in other years.
  Day addYears(int count) => addMonths(12 * count);

  /// Whole days from [other] to this day (Python `(self - other).days`).
  int daysSince(Day other) => epochDay - other.epochDay;

  bool operator <(Day other) => compareTo(other) < 0;
  bool operator <=(Day other) => compareTo(other) <= 0;
  bool operator >(Day other) => compareTo(other) > 0;
  bool operator >=(Day other) => compareTo(other) >= 0;

  static Day max(Day a, Day b) => a >= b ? a : b;
  static Day min(Day a, Day b) => a <= b ? a : b;

  @override
  int compareTo(Day other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is Day &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `YYYY-MM-DD`.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  String toString() => iso;
}

/// Python's `//` on integers: rounds towards negative infinity (Dart's `~/`
/// rounds towards zero).
int floorDiv(int a, int b) => _floorDiv(a, b);

int _floorDiv(int a, int b) {
  final q = a ~/ b;
  return (a % b != 0 && (a < 0) != (b < 0)) ? q - 1 : q;
}
