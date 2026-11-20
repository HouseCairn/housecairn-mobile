// SPDX-License-Identifier: AGPL-3.0-only

import '../data/repository.dart';
import 'files.dart';
import 'server_transport.dart';
import 'transport.dart';

/// What one round of sync did.
class SyncReport {
  const SyncReport({
    required this.sent,
    required this.received,
    required this.notices,
    required this.readOnly,
    this.filesSent = 0,
    this.filesFetched = 0,
  });

  /// Files of this phone the server took, and files of other phones fetched.
  final int filesSent;
  final int filesFetched;

  /// Operations of this phone the other side took.
  final int sent;

  /// Operations received and applied (duplicates included).
  final int received;

  /// What the person must be told (an undo taken back, a long text kept, an
  /// update asked for).
  final List<SyncNotice> notices;

  /// The space asks for a newer app: nothing was sent.
  final bool readOnly;
}

/// The sync engine of docs/adr/0010-three-ways-to-use-the-app.md
/// ("Architecture"): outgoing operations from `op_log`, incoming ones
/// applied by the field rules of docs/adr/0003-sync-protocol.md, repair
/// rules, purge of a home, `sv`, `extra`, `pending`. It knows no network:
/// the relay (lots 5 and 6) and a Housecairn server (lot 4b) are each a
/// [SyncTransport].
class SyncEngine {
  SyncEngine(this.repository, this.transport, {Thumbnailer? thumbnailer})
    : _files = FileSyncer(repository, transport, thumbnailer: thumbnailer);

  final Repository repository;
  final SyncTransport transport;
  final FileSyncer _files;

  /// One round: the homes gone are purged, this phone's operations are
  /// sent (unless the space asks for a newer app), the changes after the
  /// cursor are applied, repaired, and what the repair wrote is sent.
  Future<SyncReport> sync() async {
    final notices = <SyncNotice>[];
    // Once after an update: what the server refused goes again as this
    // version writes it.
    await repository.settleAfterUpdate();
    await repository.retryPending();
    await repository.dropOldVersions();
    await _purgeGone();
    // The files first: the push whose rows refer to them finds them on the
    // server. A file that fails waits for the next round and never holds the
    // rows back.
    final filesSent = await _filesStep(_files.upload);
    var sent = await _push(notices);
    var received = 0;
    var cursor = await repository.syncCursor();
    var restarted = false;
    var viewNoticed = false;
    while (true) {
      final page = await transport.pull(after: cursor);
      if (page.restart) {
        // The cursor is older than what the other side keeps: start again
        // from its snapshot, which a pull from the start gives.
        if (restarted || cursor == null) {
          throw StateError('The transport asked to start again twice.');
        }
        restarted = true;
        cursor = null;
        continue;
      }
      notices.addAll(await repository.applyOperations(page.operations));
      if (restarted) {
        // Rows the phone holds that the snapshot does not have: deleted and
        // purged there, or never sent (docs/protocol.md section 2.10).
        for (final MapEntry(key: home, value: rows) in page.complete.entries) {
          for (final n in await repository.reconcileAfterRestart(home, rows)) {
            // One notice for the whole restart, whatever the homes.
            if (n.kind == SyncNoticeKind.viewChanged) {
              if (viewNoticed) continue;
              viewNoticed = true;
            }
            notices.add(n);
          }
        }
      }
      received += page.operations.length;
      cursor = page.position;
      await repository.setSyncCursor(cursor);
      if (!page.more) break;
    }
    await _purgeGone();
    sent += await _push(notices);
    final filesFetched = await _filesStep(_files.download);
    await _filesStep(repository.sweepFiles);
    final readOnly = await repository.updateRequired();
    if (readOnly) notices.add(const SyncNotice(SyncNoticeKind.updateRequired));
    return SyncReport(
      sent: sent,
      received: received,
      notices: notices,
      readOnly: readOnly,
      filesSent: filesSent,
      filesFetched: filesFetched,
    );
  }

  /// One step of the files: what goes wrong in it never stops the rows of
  /// the round, except the server stopping the phone.
  Future<int> _filesStep(Future<int> Function() step) async {
    try {
      return await step();
    } on ServerStopped {
      rethrow;
    } on Object {
      return 0;
    }
  }

  Future<void> _purgeGone() async {
    for (final home in await transport.homesGone()) {
      // The example home of the guide stays on the phone beside the homes of
      // the other side, which never had it (web ADR 0084).
      if (await repository.isExampleHome(home)) continue;
      if (!await repository.isPurged(home)) await repository.purgeHome(home);
    }
  }

  Future<int> _push(List<SyncNotice> notices) async {
    if (await repository.updateRequired()) return 0;
    final out = await repository.outgoing();
    if (out.isEmpty) return 0;
    final PushResult result;
    try {
      result = await transport.push([for (final o in out) o.operation]);
    } on PushCutShort catch (cut) {
      // Stopped part way: what was refused for good leaves op_log for the
      // list aside, the rest waits there for the next round.
      final refused = cut.partial.refused;
      if (refused.isNotEmpty) {
        await repository.setAsideAndAcknowledge(
          refused,
          seqs: [
            for (final o in out)
              if (refused.any((r) => identical(r.operation, o.operation)))
                o.seq,
          ],
        );
      }
      if (cut.partial.lost.isNotEmpty) {
        notices.addAll(await repository.applyOperations(cut.partial.lost));
      }
      rethrow;
    }
    if (result.held) return 0;
    // What the other side refused for good is kept aside as it leaves
    // op_log, in one transaction: the person sends it again or drops it,
    // nothing goes silently, and nothing is listed twice.
    await repository.setAsideAndAcknowledge(result.refused, upTo: out.last.seq);
    // What won on the other side, for each field that lost there.
    if (result.lost.isNotEmpty) {
      notices.addAll(await repository.applyOperations(result.lost));
    }
    return out.length;
  }
}
