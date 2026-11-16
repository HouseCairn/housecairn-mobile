// SPDX-License-Identifier: AGPL-3.0-only

/// The way a phone is used, one at a time
/// (docs/adr/0010-three-ways-to-use-the-app.md): alone on the phone, in a
/// family on the relay, or on a Housecairn server. Stored in `local_settings`
/// under `sync_mode`, never synced.
enum SyncMode {
  alone,
  relay,
  server;

  /// The value written in `local_settings`.
  String get stored => name;

  /// The mode of a stored value; `null` for none or an unknown one.
  static SyncMode? parse(String? value) {
    for (final mode in values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}

/// The first way and, from lot 4b, the third (a Housecairn server); family
/// sync is shown, disabled, until its lots are merged (docs/plan.md, lots 5
/// to 7). A way that is not available is never in use, whatever
/// `local_settings` holds.
bool wayAvailable(SyncMode way) => way != SyncMode.relay;
