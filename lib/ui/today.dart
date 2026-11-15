// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/icons.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'home_selector.dart';
import 'messages.dart';
import 'state.dart';
import 'stock_screens.dart';
import 'task_screen.dart';

/// Today (docs/spec.md, "Screens of v1"): overdue, today, coming up within a
/// week, and without a date, each with its count as the web's headings, of
/// the current home or of All homes, where each row names its home. Done is
/// one tap, with an undo bar; skip and postpone from the menu of the same
/// row.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<TodayEntry>? _entries;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (state.revision != _revision) {
      _revision = state.revision;
      _load(state);
    }
  }

  Future<void> _load(AppState state) async {
    final entries = await state.repository.todayEntries(
      homeId: state.todayAllHomes ? null : state.current?.id,
    );
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _run(Future<void> Function() action) async {
    final state = AppScope.of(context);
    try {
      await action();
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
    }
    await state.refresh();
  }

  void _offerUndo(String message, String occurrenceId) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => _run(() => state.repository.undo(occurrenceId)),
          ),
        ),
      );
  }

  Future<void> _done(TodayEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final repository = AppScope.of(context).repository;
    Closing? closed;
    await _run(() async {
      closed = await repository.complete(entry.occurrence.id);
    });
    if (closed != null && mounted) {
      final short = closed!.short;
      _offerUndo(
        [
          l10n.doneMessage(entry.task.title),
          if (short.isNotEmpty)
            shortageMessage(
              l10n,
              Localizations.localeOf(context).toLanguageTag(),
              short,
            ),
        ].join(' '),
        entry.occurrence.id,
      );
    }
  }

  Future<void> _skip(TodayEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final repository = AppScope.of(context).repository;
    var closed = false;
    await _run(() async {
      await repository.skip(entry.occurrence.id);
      closed = true;
    });
    if (closed && mounted) {
      _offerUndo(l10n.skippedMessage(entry.task.title), entry.occurrence.id);
    }
  }

  Future<void> _postpone(TodayEntry entry) async {
    final repository = AppScope.of(context).repository;
    final today = repository.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: asDateTime(today.addDays(1)),
      firstDate: asDateTime(today),
      lastDate: asDateTime(today.addYears(dateSpanYears)),
    );
    if (picked == null || !mounted) return;
    await _run(() => repository.postpone(entry.occurrence.id, Day.of(picked)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final entries = _entries;
    final today = state.repository.today();
    final named = state.todayAllHomes;
    final groups = <String, List<TodayEntry>>{
      l10n.todayOverdue: [],
      l10n.todayToday: [],
      l10n.todayComingUp: [],
      l10n.todayNoDate: [],
    };
    for (final entry in entries ?? const <TodayEntry>[]) {
      final due = entry.dueOn;
      final group = due == null
          ? l10n.todayNoDate
          : due < today
          ? l10n.todayOverdue
          : due == today
          ? l10n.todayToday
          : l10n.todayComingUp;
      groups[group]!.add(entry);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navToday),
        actions: const [HomeSelector(withAllHomes: true)],
      ),
      body: entries == null
          ? const SizedBox.shrink()
          : HcScreenList(
              children: [
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: HcSpace.s4),
                    child: HcEmpty(l10n.todayEmpty),
                  ),
                for (final MapEntry(key: heading, value: rows)
                    in groups.entries)
                  if (rows.isNotEmpty) ...[
                    // The count after the title, as the web's `h2`.
                    HcSectionHeading(
                      '$heading (${rows.length})',
                      danger: heading == l10n.todayOverdue,
                    ),
                    HcCardList(
                      children: [
                        for (final entry in rows)
                          _TodayRow(
                            entry: entry,
                            today: today,
                            namesHome: named,
                            onDone: () => _done(entry),
                            onSkip: () => _skip(entry),
                            onPostpone: () => _postpone(entry),
                          ),
                      ],
                    ),
                  ],
                // After the list, as on the web (`tasks/today.html`).
                if (state.current != null)
                  HcAddButton(
                    key: const Key('today-add'),
                    label: l10n.addTask,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TaskScreen(homeId: state.current!.id),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

enum _RowAction { skip, postpone }

/// A row of Today: the task, its home on All homes, its date in a pill, Done
/// in one tap, and skip and postpone in its menu.
class _TodayRow extends StatelessWidget {
  const _TodayRow({
    required this.entry,
    required this.today,
    required this.namesHome,
    required this.onDone,
    required this.onSkip,
    required this.onPostpone,
  });

  final TodayEntry entry;
  final Day today;
  final bool namesHome;
  final VoidCallback onDone;
  final VoidCallback onSkip;
  final VoidCallback onPostpone;

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
      onDone: onDone,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              TaskScreen(homeId: entry.home.id, taskId: entry.task.id),
        ),
      ),
      more: PopupMenuButton<_RowAction>(
        tooltip: l10n.actionMore,
        icon: const HcIcon(HcIcons.more, color: HcColors.textMuted),
        onSelected: (action) => switch (action) {
          _RowAction.skip => onSkip(),
          _RowAction.postpone => onPostpone(),
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
