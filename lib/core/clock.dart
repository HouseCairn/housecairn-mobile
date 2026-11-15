// SPDX-License-Identifier: AGPL-3.0-only

/// The time of the phone, behind an interface so that tests choose it.
///
/// A due date is a calendar day in the time zone of the phone (docs/spec.md);
/// instants are UTC (docs/adr/0002-local-storage-and-migrations.md). The
/// hybrid logical clock of sync (docs/adr/0003-sync-protocol.md) reads
/// [now] and is built on it in lot 4.
abstract interface class Clock {
  /// The current instant, in UTC.
  DateTime now();

  /// The calendar day of [now] in the time zone of the phone, at midnight,
  /// as a local [DateTime] with no time part.
  DateTime today();
}

/// The clock of the operating system.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();

  @override
  DateTime today() {
    final local = DateTime.now();
    return DateTime(local.year, local.month, local.day);
  }
}

/// A clock that returns a fixed instant, for tests.
class FixedClock implements Clock {
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  DateTime _instant;

  /// Sets the clock to [instant].
  void set(DateTime instant) => _instant = instant.toUtc();

  /// Moves the clock by [duration].
  void advance(Duration duration) => _instant = _instant.add(duration);

  @override
  DateTime now() => _instant;

  @override
  DateTime today() {
    final local = _instant.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
