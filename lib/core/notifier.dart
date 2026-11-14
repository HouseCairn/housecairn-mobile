// SPDX-License-Identifier: AGPL-3.0-only

/// Local notifications, behind an interface
/// (docs/adr/0001-flutter-stack-and-packages.md, "Consequences").
///
/// Implemented by `LocalNotifier` (`flutter_local_notifications`,
/// lib/core/local_notifier.dart); lot 2b schedules the rolling window of
/// reminders of docs/spec.md ("Reminders") through it. Nothing is ever sent
/// from the phone: a notification is a local alarm.
abstract interface class Notifier {
  /// Whether the person allowed notifications. Does not ask.
  Future<bool> permitted();

  /// Asks the person to allow notifications, at the moment they turn
  /// reminders on (never at start). `false` when they refuse; the app then
  /// leaves reminders off and says so.
  Future<bool> requestPermission();

  /// Schedules a notification [id] at [at] (an instant), inexactly: Android
  /// may deliver it a little later (no exact-alarm permission is asked).
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    String? payload,
  });

  /// Cancels the notification [id], if it is pending.
  Future<void> cancel(int id);

  /// Cancels every pending notification of the app.
  Future<void> cancelAll();

  /// Identifiers of the notifications still pending.
  Future<List<int>> pending();
}
