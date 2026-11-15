// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/icons.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'occurrence_actions.dart';
import 'task_screen.dart';

enum _RowAction { skip, postpone }

/// A row of a list of open tasks (`tasks/_occurrence_row.html`): the task, its
/// home on All homes, its date in a pill, Done in one tap, and skip and
/// postpone in its menu.
class OpenTaskRow extends StatelessWidget {
  const OpenTaskRow({
    super.key,
    required this.entry,
    required this.today,
    this.namesHome = false,
  });

  final TodayEntry entry;
  final Day today;
  final bool namesHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = entry.dueOn;
    final place = [
      if (namesHome) entry.home.name,
      ?entry.roomName,
      ?entry.itemName,
    ];
    return HcTaskRow(
      key: Key('today-${entry.occurrence.id}'),
      title: entry.task.title,
      // The room and the item under the title, as the web's row; on All
      // homes, the home first.
      text: place.isEmpty ? null : place.join(' · '),
      pill: duePill(
        context,
        due,
        today,
        postponed: entry.occurrence.status == 'postponed',
      ),
      overdue: due != null && due < today,
      doneLabel: l10n.actionDone,
      onDone: () => markDone(context, entry.occurrence.id, entry.task.title),
      onTap: () => Navigator.of(
        context,
      ).push(hcRoute(TaskScreen(homeId: entry.home.id, taskId: entry.task.id))),
      more: PopupMenuButton<_RowAction>(
        tooltip: l10n.actionMore,
        icon: const HcIcon(HcIcons.more, color: HcColors.textMuted),
        onSelected: (action) => switch (action) {
          _RowAction.skip => markSkipped(
            context,
            entry.occurrence.id,
            entry.task.title,
          ),
          _RowAction.postpone => postponeOccurrence(
            context,
            entry.occurrence.id,
          ),
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: _RowAction.skip, child: Text(l10n.actionSkip)),
          PopupMenuItem(
            value: _RowAction.postpone,
            child: Text(l10n.actionPostpone),
          ),
        ],
      ),
    );
  }
}
