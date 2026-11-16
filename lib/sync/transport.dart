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
  const PushResult({
    this.lost = const [],
    this.held = false,
    this.refused = const [],
  });

  final List<SyncOperation> lost;

  /// The operations the other side refused for good: the phone keeps them
  /// aside with their reason, and the person sends them again or drops them
  /// (docs/protocol.md section 2.10, "A push refused"). None is lost in
  /// silence.
  final List<RefusedOperation> refused;

  /// Nothing was sent: the other side will answer the pull with a restart
  /// (410), and the operations wait in `op_log` for the rule that follows it
  /// (docs/protocol.md section 2.10), which may drop some.
  final bool held;
}

/// A push stopped part way (the other side busy, `429` or `5xx`): what it
/// settled before is in [partial], so that the operations already refused
/// for good are kept aside and the fields that lost are applied; the rest
/// waits in `op_log` (lot 4b review).
abstract interface class PushCutShort implements Exception {
  PushResult get partial;
}

/// An operation the other side refused, with the code it gave (`forbidden`,
/// `malformed`, `too_large`...).
class RefusedOperation {
  const RefusedOperation(this.operation, this.code, {this.detail});

  final SyncOperation operation;
  final String code;

  /// What the other side said of it, as it said it; never shown as is.
  final String? detail;
}

/// A file the other side refused for good: it does not take it as it is, so
/// the phone does not send it again by itself ([code]: `malformed` for a
/// digest that is not the one of the bytes, `forbidden`, `file_conflict`,
/// `too_large`, `quota_exceeded`, `unsupported_type`).
class FileRefused implements Exception {
  const FileRefused(this.code);

  final String code;

  @override
  String toString() => 'FileRefused($code)';
}

/// The other side does not have the file, or the home of it (`404`).
class FileNotFound implements Exception {
  const FileNotFound();

  @override
  String toString() => 'FileNotFound';
}

/// The answer to a pull.
class PullResult {
  const PullResult({
    this.operations = const [],
    required this.position,
    this.more = false,
    this.restart = false,
    this.complete = const {},
  });

  /// The homes whose whole snapshot is in [operations], each with every row
  /// of it (`(t, id)`, tombstones included): a row of such a home the phone
  /// holds and that is not listed is not on the other side. A server gives
  /// it from a snapshot; the engine uses it after a [restart]
  /// (docs/protocol.md section 2.10, "Starting again after 410").
  final Map<String, Set<(String, String)>> complete;

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

  /// Stores the file [id] (a photo or an attachment) of [home]; [sha256] is
  /// the digest of [bytes] in lower-case hexadecimal and [type] their media
  /// type. Throws [FileRefused] when the other side refuses it for good and
  /// [FileNotFound] when the home is not there (any more); a busy or
  /// unreachable other side throws what the transport throws for any request.
  Future<void> putFile(
    String home,
    String id,
    Uint8List bytes, {
    required String sha256,
    required String type,
  });

  /// Reads the file [id] of [home]. Throws [FileNotFound] when the other
  /// side does not have it.
  Future<Uint8List> getFile(String home, String id);

  /// Deletes the file [id] of [home]. A server has no route for it: it
  /// removes a file no row refers to by itself (web ADR 0077, need 10), so
  /// this does nothing there; the relay deletes the blob.
  Future<void> deleteFile(String home, String id);

  /// The ids of the homes deleted on the other side, or no longer covered by
  /// the access of this phone.
  Future<List<String>> homesGone();
}
