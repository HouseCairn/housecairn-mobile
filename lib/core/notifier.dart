// SPDX-License-Identifier: AGPL-3.0-only

/// Local notifications, behind an interface
/// (docs/adr/0001-flutter-stack-and-packages.md, "Consequences").
///
/// Lot 2 implements it with `flutter_local_notifications` and schedules the
/// rolling window of reminders of docs/spec.md ("Reminders"). Lot 1 defines
/// the interface only.
abstract interface class Notifier {
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
