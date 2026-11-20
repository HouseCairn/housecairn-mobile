// SPDX-License-Identifier: AGPL-3.0-only

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import '../sync/mode.dart';
import '../sync/operation.dart';
import '../sync/server_transport.dart';
import 'server_screens.dart';
import 'state.dart';

/// Why the server refused a change, in words (codes of the web's
/// docs/api/sync.md, "The codes of a rejected operation" and "Errors").
String refusedReason(AppLocalizations l10n, String code) => switch (code) {
  'forbidden' => l10n.syncRefusedForbidden,
  'invalid_reference' || 'wrong_home' => l10n.syncRefusedReference,
  'clock_ahead' => l10n.syncRefusedClock,
  'id_taken' => l10n.syncRefusedIdTaken,
  'malformed' => l10n.syncRefusedMalformed,
  'too_large' => l10n.syncRefusedTooLarge,
  'wrong_device' => l10n.syncRefusedDevice,
  'sso_required' => l10n.syncRefusedSignIn,
  'push_conflict' => l10n.syncRefusedConflict,
  _ => l10n.syncRefusedOther(code),
};

/// The name of the row a refused change is about: its `name` or `title` as
/// the phone sent it.
String refusedName(AppLocalizations l10n, RefusedChange change) {
  final fields = (change.operation[Op.fields] as Map?) ?? const {};
  final name = fields['name'] ?? fields['title'];
  return name is String && name.isNotEmpty ? name : l10n.syncRefusedUnnamed;
}

/// What kind of thing a refused change is about, in words (its name is the
/// title of its line); `null` for a type without a word of its own.
String? refusedThing(AppLocalizations l10n, RefusedChange change) {
  final fields = (change.operation[Op.fields] as Map?) ?? const {};
  return switch (change.operation[Op.type]) {
    'rooms.item' =>
      fields['kind'] == 'surface'
          ? l10n.itemKindSurface
          : l10n.itemKindEquipment,
    'rooms.room' => l10n.room,
    'rooms.photo' => l10n.photo,
    'tasks.task' => l10n.task,
    'tasks.contractor' => l10n.contractor,
    'projects.project' => l10n.compareProject,
    'projects.annualenvelope' => l10n.envelope,
    _ => null,
  };
}

String _notice(AppLocalizations l10n, SyncNotice notice) =>
    switch (notice.kind) {
      SyncNoticeKind.droppedAfterRestart => l10n.syncNoticeDropped,
      SyncNoticeKind.viewChanged => l10n.syncNoticeViewChanged,
      _ => l10n.syncNoticeUndoReverted,
    };

/// What stops or holds the sync, in one line; `null` when all is well.
String? syncProblem(AppLocalizations l10n, ServerSyncStatus status) {
  if (status.stopped case final reason?) {
    return serverProblem(l10n, ServerStopped(reason));
  }
  if (status.unreachable) return l10n.syncUnreachable;
  if (status.failed) return l10n.syncFailed;
  return null;
}

/// The line above the bar of sections in the third way when the sync needs
/// the person: the server stopped the phone, cannot be reached, refused
/// changes, or has notices to read. It opens [ServerSyncScreen].
class ServerSyncBanner extends StatelessWidget {
  const ServerSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    if (state.syncMode != SyncMode.server) return const SizedBox.shrink();
    final status = state.serverSync;
    final lines = [
      ?syncProblem(l10n, status),
      if (status.refused.isNotEmpty)
        l10n.syncRefusedCount(status.refused.length),
      if (status.notices.isNotEmpty)
        l10n.syncNoticesCount(status.notices.length),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    final stopped = status.stopped != null || status.refused.isNotEmpty;
    return Semantics(
      key: const Key('sync-banner'),
      button: true,
      child: Material(
        color: stopped ? HcColors.warningSoft : HcColors.infoSoft,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ServerSyncScreen()),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: HcLayout.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HcSpace.s4,
                vertical: HcSpace.s2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in lines)
                          Text(
                            line,
                            style: HcText.bodySmall.copyWith(
                              color: stopped ? HcColors.warning : HcColors.info,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const HcIcon(HcIcons.chevron),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The sync with the server: its state, "Sync now", the notices to read,
/// and each change the server refused, on its own line with its reason, to
/// send again or to stop sending (lot 4b, decision A).
class ServerSyncScreen extends StatelessWidget {
  const ServerSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final status = state.serverSync;
    final problem = syncProblem(l10n, status);
    final last = status.lastSync;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HcSpace.s4),
          children: [
            Text(l10n.syncText, style: HcText.body),
            const SizedBox(height: HcSpace.s3),
            Text(
              key: const Key('sync-state'),
              status.running
                  ? l10n.syncRunning
                  : last == null
                  ? l10n.syncNever
                  : l10n.syncLast(
                      DateFormat.yMMMd(l10n.localeName)
                          .add_Hm()
                          .format(last.toLocal()),
                    ),
              style: HcText.bodySmall,
            ),
            if (problem != null) ...[
              const SizedBox(height: HcSpace.s2),
              Text(
                problem,
                key: const Key('sync-problem'),
                style: HcText.body.copyWith(color: HcColors.warning),
              ),
            ],
            const SizedBox(height: HcSpace.s3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                key: const Key('sync-now'),
                onPressed: status.running ? null : state.syncWithServer,
                child: Text(l10n.syncNow),
              ),
            ),
            if (status.notices.isNotEmpty) ...[
              HcSectionHeading(l10n.syncNoticesTitle),
              HcCardList(
                children: [
                  for (final notice in status.notices)
                    HcRow(title: _notice(l10n, notice)),
                ],
              ),
              const SizedBox(height: HcSpace.s2),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  key: const Key('sync-notices-read'),
                  onPressed: state.dismissNotices,
                  child: Text(l10n.syncNoticesRead),
                ),
              ),
            ],
            if (status.refused.isNotEmpty) ...[
              HcSectionHeading(l10n.syncRefusedTitle),
              Text(l10n.syncRefusedHelp, style: HcText.bodySmall),
              const SizedBox(height: HcSpace.s2),
              HcCardList(
                children: [
                  for (final change in status.refused)
                    _RefusedRow(key: Key('refused-${change.id}'), change),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RefusedRow extends StatelessWidget {
  const _RefusedRow(this.change, {super.key});

  final RefusedChange change;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final thing = refusedThing(l10n, change);
    final detail = change.detail?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.all(HcSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(refusedName(l10n, change), style: HcText.cardTitle),
          if (thing != null) ...[
            const SizedBox(height: HcSpace.s1),
            Text(
              l10n.syncRefusedConcerns(thing),
              key: Key('refused-thing-${change.id}'),
              style: HcText.bodySmall,
            ),
          ],
          const SizedBox(height: HcSpace.s1),
          Text(refusedReason(l10n, change.code), style: HcText.bodySmall),
          // What the server said, as it said it: the value or the field at
          // fault ("links is not a valid value.").
          if (detail.isNotEmpty) ...[
            const SizedBox(height: HcSpace.s1),
            Text(
              l10n.syncRefusedAnswer(detail),
              key: Key('refused-answer-${change.id}'),
              style: HcText.bodySmall,
            ),
          ],
          const SizedBox(height: HcSpace.s2),
          Wrap(
            spacing: HcSpace.s2,
            runSpacing: HcSpace.s2,
            children: [
              OutlinedButton(
                key: Key('refused-again-${change.id}'),
                onPressed: () => state.sendAgain(change.id),
                child: Text(l10n.syncSendAgain),
              ),
              TextButton(
                key: Key('refused-drop-${change.id}'),
                onPressed: () => state.dropRefused(change.id),
                child: Text(l10n.syncStopSending),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
