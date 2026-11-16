// SPDX-License-Identifier: AGPL-3.0-only

import '../data/repository.dart';
import 'transport.dart';

/// What one round of sync did.
class SyncReport {
  const SyncReport({
    required this.sent,
    required this.received,
    required this.notices,
    required this.readOnly,
  });

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
  SyncEngine(this.repository, this.transport);

  final Repository repository;
  final SyncTransport transport;

  /// One round: the homes gone are purged, this phone's operations are
  /// sent (unless the space asks for a newer app), the changes after the
  /// cursor are applied, repaired, and what the repair wrote is sent.
  Future<SyncReport> sync() async {
    final notices = <SyncNotice>[];
    await repository.retryPending();
    await repository.dropOldVersions();
    await _purgeGone();
    var sent = await _push(notices);
    var received = 0;
    var cursor = await repository.syncCursor();
    var restarted = false;
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
          notices.addAll(await repository.reconcileAfterRestart(home, rows));
        }
      }
      received += page.operations.length;
      cursor = page.position;
      await repository.setSyncCursor(cursor);
      if (!page.more) break;
    }
    await _purgeGone();
    sent += await _push(notices);
    final readOnly = await repository.updateRequired();
    if (readOnly) notices.add(const SyncNotice(SyncNoticeKind.updateRequired));
    return SyncReport(
      sent: sent,
      received: received,
      notices: notices,
      readOnly: readOnly,
    );
  }

  Future<void> _purgeGone() async {
    for (final home in await transport.homesGone()) {
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
