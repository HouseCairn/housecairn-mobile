// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import '../data/repository.dart';
import '../domain/file_reference.dart';
import '../domain/photos.dart' show makeThumbnail;
import 'server_transport.dart';
import 'transport.dart';

/// The thumbnail of a photo fetched, or `null` when it cannot be read as an
/// image; the app runs it in an isolate.
typedef Thumbnailer = Future<Uint8List?> Function(Uint8List image);

Future<Uint8List?> thumbnailHere(Uint8List image) async => makeThumbnail(image);

/// What the files of one round did.
class FileSyncReport {
  const FileSyncReport({this.sent = 0, this.fetched = 0});

  final int sent;
  final int fetched;
}

/// The files of a round of sync (docs/adr/0012-files-with-a-server.md): the
/// photos and files this phone made go to the server **before** the push
/// whose rows refer to them (web ADR 0077, need 10), the ones other phones
/// made come after the pull, and what was deleted is swept. One file failing
/// never stops the rows: each is tried on its own, its failure is written
/// down with its wait, and only a stop of the server itself ([ServerStopped])
/// goes up.
class FileSyncer {
  FileSyncer(this.repository, this.transport, {Thumbnailer? thumbnailer})
    : _thumbnailer = thumbnailer ?? thumbnailHere;

  final Repository repository;
  final SyncTransport transport;
  final Thumbnailer _thumbnailer;

  /// Requests per minute a round takes of what the server announces
  /// (`pushes_per_minute`, `reads_per_minute`): half, so that the push and
  /// the pull of the same round keep theirs.
  static const _defaultPerMinute = 60;

  Future<Map<String, int>> _limits() async {
    try {
      return (await transport.capabilities()).limits;
    } on ServerStopped {
      rethrow;
    } on Object {
      // The push that follows says why the server cannot be reached.
      return const {};
    }
  }

  /// Sends the files made on this phone and not sent yet.
  Future<int> upload() async {
    await repository.scanFiles();
    final due = await repository.filesDue(FileWay.up);
    if (due.isEmpty) return 0;
    final limits = await _limits();
    final maxBytes = limits['file_max_bytes'] ?? maxFileBytes;
    final budget = (limits['pushes_per_minute'] ?? _defaultPerMinute) ~/ 2;
    var sent = 0;
    for (final job in due.take(budget < 1 ? 1 : budget)) {
      if (!job.file.existsSync()) continue;
      final Uint8List bytes;
      try {
        bytes = await job.file.readAsBytes();
      } on Object {
        await repository.fileLater(job, code: 'unreadable');
        continue;
      }
      if (bytes.length > maxBytes) {
        // Not sent: the server would refuse it, and says its limit in `info`.
        await repository.fileFailed(job.fileId, 'too_large');
        continue;
      }
      final digest = await sha256HexOffMain(bytes);
      if (job.reference.sha256 != null && digest != job.reference.sha256) {
        // The file is not the one the row names: the server would refuse
        // the row too (`malformed`), and sending these bytes would make
        // the two sides disagree.
        await repository.fileFailed(job.fileId, 'malformed');
        continue;
      }
      try {
        await transport.putFile(
          job.homeId,
          job.fileId,
          bytes,
          sha256: digest,
          type: job.reference.type,
        );
        await repository.fileDone(job.fileId);
        sent++;
      } on FileRefused catch (refused) {
        await repository.fileFailed(job.fileId, refused.code);
      } on FileNotFound {
        await repository.fileLater(job, code: 'not_found');
      } on ServerStopped {
        rethrow;
      } on Object {
        // Out of reach or too busy (408 and 429 included): this one waits, and so do the others
        // until the next round.
        await repository.fileLater(job);
        break;
      }
    }
    return sent;
  }

  /// Fetches the files other phones made, newest first, as many as a round
  /// may read.
  Future<int> download() async {
    // The rows the pull just brought have no entry yet.
    await repository.scanFiles();
    final due = await repository.filesDue(FileWay.down);
    if (due.isEmpty) return 0;
    final limits = await _limits();
    final budget = (limits['reads_per_minute'] ?? 10 * _defaultPerMinute) ~/ 2;
    var fetched = 0;
    for (final job in due.take(budget < 1 ? 1 : budget)) {
      try {
        final bytes = await transport.getFile(job.homeId, job.fileId);
        if (bytes.isEmpty) {
          await repository.fileLater(job, code: 'not_found');
          continue;
        }
        final thumbnail = job.holder == 'photos'
            ? await _thumbnailer(bytes)
            : null;
        await repository.storeFetched(job, bytes, thumbnail: thumbnail);
        fetched++;
      } on FileNotFound {
        // The server does not have it (yet): not an error, the row waits
        // for its file and the phone asks again later.
        await repository.fileLater(job, code: 'not_found');
      } on FileRefused catch (refused) {
        await repository.fileFailed(job.fileId, refused.code);
      } on ServerStopped {
        rethrow;
      } on Object {
        await repository.fileLater(job);
        break;
      }
    }
    return fetched;
  }
}
