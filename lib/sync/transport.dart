// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

/// One operation of docs/protocol.md section 2.2 (`t`, `h`, `id`, `k`, `c`,
/// `f`), as the map of its fields. The engine of lot 4 gives it a class.
typedef SyncOperation = Map<String, Object?>;

/// A position in the change feed (`pos` of docs/protocol.md): the cursor of
/// the phone.
typedef SyncPosition = int;

/// What a transport says about itself: the version of what it talks to and
/// its limits (batch size, file size, rate), by name.
class SyncCapabilities {
  const SyncCapabilities({required this.version, this.limits = const {}});

  final String version;
  final Map<String, int> limits;
}

/// The answer to a push: the operations that lost against another change,
/// each as the value that won (docs/adr/0010, `SyncTransport`).
class PushResult {
  const PushResult({this.lost = const []});

  final List<SyncOperation> lost;
}

/// The answer to a pull.
class PullResult {
  const PullResult({
    this.operations = const [],
    required this.position,
    this.more = false,
    this.restart = false,
  });

  /// The changes after the cursor asked for.
  final List<SyncOperation> operations;

  /// The cursor to give next time.
  final SyncPosition position;

  /// Whether there are more changes after these.
  final bool more;

  /// The cursor is older than what is kept (410): the phone starts again
  /// from the snapshot of the relay or of the server.
  final bool restart;
}

/// The only seam between the sync engine and the network
/// (docs/adr/0010-three-ways-to-use-the-app.md, "Architecture"): nothing
/// else in the app knows the network. The relay (lots 5 and 6) and a
/// Housecairn server (lot 4b) each implement it; lot 2c defines it only, as
/// lot 1 did for `Store`, and the tests give a fake.
abstract interface class SyncTransport {
  /// What the other side is and allows (relay: `GET /v1/info`; server: its
  /// version and sync capabilities).
  Future<SyncCapabilities> capabilities();

  /// Sends [operations]. A relay takes one sealed batch; a server applies the
  /// request as a whole and says which fields lost.
  Future<PushResult> push(List<SyncOperation> operations);

  /// The changes after [after] (`null`: from the start).
  Future<PullResult> pull({SyncPosition? after});

  /// Stores the file [id] (a photo or an attachment).
  Future<void> putFile(String id, Uint8List bytes);

  /// Reads the file [id].
  Future<Uint8List> getFile(String id);

  /// Deletes the file [id].
  Future<void> deleteFile(String id);

  /// The ids of the homes deleted on the other side, or no longer covered by
  /// the access of this phone.
  Future<List<String>> homesGone();
}
