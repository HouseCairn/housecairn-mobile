// SPDX-License-Identifier: AGPL-3.0-only

/// Recurrence of tasks: the Dart port of `tasks/recurrence.py` of the web
/// application (docs/spec.md, "Rules taken as they are";
/// docs/adr/0001-flutter-stack-and-packages.md, "Recurrence is ported").
///
/// Pure functions on calendar days ([Day]): no model, no clock, no time zone.
/// Each function keeps the name, the arguments and the result of its Python
/// original, and `test/recurrence_test.dart` checks them against the vectors
/// of `test/fixtures/recurrence_vectors.json`, generated from the Python
/// module by `tool/recurrence_vectors.py`. Where the web code relies on the
/// RFC 5545 engine of python-dateutil (`_series`), the port computes the same
/// dates directly: the rules use only the frequency, the interval and, from
/// the 29th of a month, "that day or the last day of the month".
library;

import 'day.dart';

const once = 'once';
const fixed = 'fixed';
const afterLast = 'after_last';
const modes = [once, fixed, afterLast];

const dayUnit = 'day';
const weekUnit = 'week';
const monthUnit = 'month';
const yearUnit = 'year';
const units = [dayUnit, weekUnit, monthUnit, yearUnit];

/// Largest interval of each unit: about fifty years, so that a date stays far
/// from 9999 (`recurrence.py:25-26`).
const maxInterval = {
  dayUnit: 18250,
  weekUnit: 2600,
  monthUnit: 600,
  yearUnit: 50,
};

const spring = 'spring';
const summer = 'summer';
const autumn = 'autumn';
const winter = 'winter';
const custom = 'custom';

/// The former predefined season, now custom months (`recurrence.py:32-35`).
const heating = 'heating';
const north = 'north';
const south = 'south';

/// Predefined seasons, as the months they cover in the northern hemisphere.
const Map<String, (int, int)> _northWindows = {
  spring: (3, 5),
  summer: (6, 8),
  autumn: (9, 11),
  winter: (12, 2),
};
const Map<String, (int, int)> _legacyWindows = {heating: (10, 4)};
final predefinedSeasons = _northWindows.keys.toList(growable: false);
final legacySeasons = _legacyWindows.keys.toList(growable: false);

(int, int)? _shift((int, int) window, String hemisphere) {
  if (hemisphere == north) return window;
  if (hemisphere == south) {
    return ((window.$1 + 5) % 12 + 1, (window.$2 + 5) % 12 + 1);
  }
  return null;
}

/// The months of a season no longer offered (`heating`) in a hemisphere.
(int, int)? legacySeason(String season, [String hemisphere = north]) {
  final window = _legacyWindows[season];
  return window == null ? null : _shift(window, hemisphere);
}

/// First and last month of a predefined season in a hemisphere; `null` for
/// any other value. The southern one is the northern one shifted by six months.
(int, int)? seasonWindow(String season, [String hemisphere = north]) {
  final window = _northWindows[season];
  return window == null ? null : _shift(window, hemisphere);
}

/// The predefined season (northern hemisphere) that exactly covers these
/// months, or [custom]; the empty string without months.
String seasonNamed(int? start, int? end) {
  if (start == null || end == null) return '';
  for (final MapEntry(key: season, value: window) in _northWindows.entries) {
    if (window == (start, end)) return season;
  }
  return custom;
}

/// How a task comes back. [seasonStart] and [seasonEnd] are months (1-12) of
/// a window outside of which nothing falls; it may run over the new year.
class Rule {
  const Rule({
    this.mode = once,
    this.unit = monthUnit,
    this.interval = 1,
    this.seasonStart,
    this.seasonEnd,
  });

  final String mode;
  final String unit;
  final int interval;
  final int? seasonStart;
  final int? seasonEnd;

  bool get repeats => mode != once;
}

/// Why the rule is unusable, as codes; empty when it is fine.
List<String> problems(Rule rule) {
  final found = <String>[];
  if (!modes.contains(rule.mode)) {
    found.add('mode');
  } else if (rule.mode != once) {
    if (!units.contains(rule.unit)) {
      found.add('unit');
    } else if (!(1 <= rule.interval &&
        rule.interval <= maxInterval[rule.unit]!)) {
      found.add('interval');
    }
  }
  final start = rule.seasonStart;
  final end = rule.seasonEnd;
  if ((start == null) != (end == null) ||
      (start != null &&
          !(1 <= start &&
              start <= 12 &&
              1 <= (end ?? 0) &&
              (end ?? 0) <= 12))) {
    found.add('season');
  }
  return found;
}

bool inSeason(Rule rule, Day day) {
  final start = rule.seasonStart;
  final end = rule.seasonEnd;
  if (start == null || end == null) return true;
  if (start <= end) return start <= day.month && day.month <= end;
  return day.month >= start || day.month <= end;
}

/// [day], or the first day of the next season when [day] is out of season.
Day _enterSeason(Rule rule, Day day) {
  if (inSeason(rule, day)) return day;
  final start = rule.seasonStart!;
  final year = day.month < start ? day.year : day.year + 1;
  return Day(year, start, 1);
}

/// `date + _delta(rule)`.
Day _addInterval(Rule rule, Day day, [int times = 1]) {
  final n = rule.interval * times;
  return switch (rule.unit) {
    dayUnit => day.addDays(n),
    weekUnit => day.addDays(7 * n),
    monthUnit => day.addMonths(n),
    _ => day.addYears(n),
  };
}

/// A date of the series of [anchor] shortly before [after], to count from.
Day _near(Rule rule, Day anchor, Day after) {
  final n = rule.interval;
  final int periods;
  if (rule.unit == dayUnit) {
    periods = floorDiv(after.daysSince(anchor), n);
  } else if (rule.unit == weekUnit) {
    periods = floorDiv(after.daysSince(anchor), 7 * n);
  } else if (rule.unit == monthUnit) {
    periods = floorDiv(
      (after.year - anchor.year) * 12 + after.month - anchor.month,
      n,
    );
  } else {
    periods = floorDiv(after.year - anchor.year, n);
  }
  final steps = (periods - 1 > 0 ? periods - 1 : 0) * n;
  return switch (rule.unit) {
    dayUnit => anchor.addDays(steps),
    weekUnit => anchor.addDays(7 * steps),
    monthUnit => anchor.addMonths(steps),
    _ => anchor.addYears(steps),
  };
}

/// The dates of a fixed rule, from its first date (the anchor), counted from
/// [start], a date of the series: `_series` of the web, which hands this to
/// `rrule(FREQ, interval, dtstart=start)` with, from the 29th, the day of the
/// month taken as "the anchor's day or the last day, the first that exists"
/// (BYMONTHDAY=(d, -1), BYSETPOS=1). Ends where the calendar ends (9999), as
/// the iteration of dateutil does.
Iterable<Day> _series(Rule rule, Day anchor, Day start) sync* {
  if (rule.unit == dayUnit || rule.unit == weekUnit) {
    final step = rule.interval * (rule.unit == weekUnit ? 7 : 1);
    for (var k = 0; ; k++) {
      final Day day;
      try {
        day = start.addDays(k * step);
      } on DayOutOfRange {
        return;
      }
      yield day;
    }
  }
  final clamp = anchor.day > 28;
  final monthStep = rule.interval * (rule.unit == yearUnit ? 12 : 1);
  for (var k = 0; ; k++) {
    final index = start.year * 12 + start.month - 1 + k * monthStep;
    final year = floorDiv(index, 12);
    final month = index - year * 12 + 1;
    if (year > 9999) return;
    final int dayOfMonth;
    if (clamp) {
      final last = Day.daysInMonth(year, month);
      dayOfMonth = anchor.day < last ? anchor.day : last;
    } else {
      dayOfMonth = start.day;
    }
    // A month, or a year, is given its month by `start` (the anchor's month
    // for a year, BYMONTH): both are dates of the series.
    yield Day(year, month, dayOfMonth);
  }
}

/// The due date that follows an occurrence closed on [doneOn]; `null` for a
/// task done once (`recurrence.py:202-235`).
///
/// - [afterLast]: [doneOn] plus the interval.
/// - [fixed]: the first date of the series after both the due date and
///   [doneOn]: dates missed meanwhile are not brought back one by one.
///
/// A date out of season moves to the first day of the next season.
Day? nextDue(
  Rule rule, {
  required Day? anchor,
  required Day? dueOn,
  required Day doneOn,
}) {
  if (!rule.repeats) return null;
  try {
    final Day candidate;
    if (rule.mode == afterLast) {
      candidate = _addInterval(rule, doneOn);
    } else {
      final after = dueOn != null ? Day.max(dueOn, doneOn) : doneOn;
      final origin = anchor != null && anchor < after ? anchor : after;
      final start = _near(rule, origin, after);
      Day? found;
      for (final day in _series(rule, origin, start)) {
        if (day > after) {
          found = day;
          break;
        }
      }
      if (found == null) return null;
      candidate = found;
    }
    return _enterSeason(rule, candidate);
  } on DayOutOfRange {
    return null;
  }
}

/// The last date of the unbroken chain [current], +1 interval, +2... that is
/// not after [target] (`recurrence.py:238-261`).
Day _jump(Rule rule, Day current, Day target) {
  final n = rule.interval;
  if (rule.unit == dayUnit || rule.unit == weekUnit) {
    final step = n * (rule.unit == weekUnit ? 7 : 1);
    return current.addDays(floorDiv(target.daysSince(current), step) * step);
  }
  while (current.day > 28 && _addInterval(rule, current) <= target) {
    current = _addInterval(rule, current);
  }
  if (current > target || current.day > 28) return current;
  final gap = (target.year - current.year) * 12 + target.month - current.month;
  final unit = rule.unit == yearUnit ? 12 : 1;
  final quotient = floorDiv(gap, unit * n) - 1;
  final steps = (quotient > 0 ? quotient : 0) * n;
  final jumped = rule.unit == yearUnit
      ? current.addYears(steps)
      : current.addMonths(steps);
  return jumped <= target ? jumped : current;
}

/// The dates of the fixed series of [anchor], from the first one after [last].
Iterable<Day> _datesAfter(Rule rule, Day anchor, Day last) sync* {
  if (rule.unit == dayUnit || rule.unit == weekUnit) {
    final days = rule.interval * (rule.unit == weekUnit ? 7 : 1);
    var day = anchor.addDays(
      (floorDiv(last.daysSince(anchor), days) + 1) * days,
    );
    while (true) {
      yield day;
      day = day.addDays(days);
    }
  }
  for (final stamp in _series(rule, anchor, _near(rule, anchor, last))) {
    if (stamp > last) yield stamp;
  }
}

/// The due dates from [since] to [end] that follow an occurrence due on
/// [after], were each occurrence closed on its due date
/// (`recurrence.py:278-338`). Only the dates in the range are worked out.
List<Day> coming(
  Rule rule, {
  required Day? anchor,
  required Day after,
  required Day since,
  required Day end,
}) {
  if (!rule.repeats || after >= end) return [];
  final found = <Day>[];
  try {
    if (rule.mode == fixed && anchor != null && anchor < after) {
      final back = rule.seasonStart != null ? 366 : 1;
      var last = Day.max(after, since.addDays(-back));
      for (var day in _datesAfter(rule, anchor, last)) {
        day = _enterSeason(rule, day);
        if (day > end) break;
        if (day > last) {
          last = day;
          if (day >= since) found.add(day);
        }
      }
      return found;
    }
    var current = after;
    var reach = since.addDays(-1);
    if (rule.mode == fixed && anchor != null) reach = Day.min(reach, anchor);
    if (rule.seasonStart == null && reach > after) {
      current = _jump(rule, after, reach);
    }
    while (true) {
      current = _addInterval(rule, current);
      if (rule.seasonStart != null) current = _enterSeason(rule, current);
      if (current > end) break;
      if (current >= since) found.add(current);
      if (rule.mode == fixed && anchor != null && current > anchor) {
        return [
          ...found,
          ...coming(
            rule,
            anchor: anchor,
            after: current,
            since: since,
            end: end,
          ),
        ];
      }
    }
  } on DayOutOfRange {
    // As the web: the dates found before the end of the calendar.
  }
  return found;
}

/// The next [count] due dates, were each occurrence closed on its due date.
List<Day> preview(
  Rule rule, {
  required Day? anchor,
  required Day dueOn,
  required int count,
}) {
  final dates = <Day>[];
  Day? current = dueOn;
  while (current != null && dates.length < count) {
    current = nextDue(rule, anchor: anchor, dueOn: current, doneOn: current);
    if (current != null) dates.add(current);
  }
  return dates;
}
