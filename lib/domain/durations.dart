// SPDX-License-Identifier: AGPL-3.0-only

/// Estimated durations: a number and a unit on screen, minutes in the data
/// (`tasks/durations.py`, web ADR 0045).
library;

const minute = 'minute';
const hour = 'hour';
const day = 'day';
const week = 'week';
const month = 'month';
const year = 'year';

/// The units, the smallest first.
const durationUnits = [minute, hour, day, week, month, year];

/// Minutes in one unit: an estimate is of elapsed time, a day is 24 hours, a
/// month 30 days and a year 365 days, whatever the calendar.
const minutesIn = {
  minute: 1,
  hour: 60,
  day: 24 * 60,
  week: 7 * 24 * 60,
  month: 30 * 24 * 60,
  year: 365 * 24 * 60,
};

const minMinutes = 1;
final maxMinutes = minutesIn[year]!;

/// [value] units as minutes.
int toMinutes(int value, String unit) => value * minutesIn[unit]!;

/// Whether [minutes] is between a minute and a year.
bool withinBounds(int minutes) =>
    minutes >= minMinutes && minutes <= maxMinutes;

/// The biggest unit that holds [minutes] exactly, to show them back in a form.
(int, String) split(int minutes) {
  for (final unit in [year, month, week, day, hour]) {
    if (minutes % minutesIn[unit]! == 0) {
      return (minutes ~/ minutesIn[unit]!, unit);
    }
  }
  return (minutes, minute);
}
