// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/tokens.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'home_selector.dart';
import 'messages.dart';
import 'state.dart';
import 'task_screen.dart';

/// Today (docs/spec.md, "Screens of v1"): overdue, coming up within a week,
/// and without a date, of the current home or of All homes, where each row
/// names its home. Done is one tap, with an undo bar; skip and postpone from
/// the menu of the same row.
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
    var closed = false;
    await _run(() async {
      await repository.complete(entry.occurrence.id);
      closed = true;
    });
    if (closed && mounted) {
      _offerUndo(l10n.doneMessage(entry.task.title), entry.occurrence.id);
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
      l10n.todayComingUp: [],
      l10n.todayNoDate: [],
    };
    for (final entry in entries ?? const <TodayEntry>[]) {
      final due = entry.dueOn;
      final group = due == null
          ? l10n.todayNoDate
          : due < today
          ? l10n.todayOverdue
          : l10n.todayComingUp;
      groups[group]!.add(entry);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navToday),
        actions: const [HomeSelector(withAllHomes: true)],
      ),
      floatingActionButton: state.current == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TaskScreen(homeId: state.current!.id),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.newTask),
            ),
      body: entries == null
          ? const SizedBox.shrink()
          : entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(HcSpace.s6),
                child: Text(
                  l10n.todayEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: HcColors.textMuted),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final MapEntry(key: heading, value: rows)
                    in groups.entries)
                  if (rows.isNotEmpty) ...[
                    _Heading(heading),
                    for (final entry in rows)
                      _TodayRow(
                        entry: entry,
                        namesHome: named,
                        onDone: () => _done(entry),
                        onSkip: () => _skip(entry),
                        onPostpone: () => _postpone(entry),
                      ),
                  ],
              ],
            ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      HcSpace.s4,
      HcSpace.s4,
      HcSpace.s4,
      HcSpace.s2,
    ),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: HcColors.textMuted),
      ),
    ),
  );
}

enum _RowAction { skip, postpone }

class _TodayRow extends StatelessWidget {
  const _TodayRow({
    required this.entry,
    required this.namesHome,
    required this.onDone,
    required this.onSkip,
    required this.onPostpone,
  });

  final TodayEntry entry;
  final bool namesHome;
  final VoidCallback onDone;
  final VoidCallback onSkip;
  final VoidCallback onPostpone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = entry.dueOn;
    final when = due == null
        ? l10n.todayNoDate
        : entry.occurrence.status == 'postponed'
        ? l10n.postponedTo(formatDay(context, due))
        : l10n.dueOn(formatDay(context, due));
    return ListTile(
      key: Key('today-${entry.occurrence.id}'),
      leading: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        tooltip: l10n.actionDone,
        onPressed: onDone,
      ),
      title: Text(entry.task.title),
      subtitle: Text(namesHome ? l10n.rowInHome(entry.home.name, when) : when),
      trailing: PopupMenuButton<_RowAction>(
        tooltip: l10n.actionMore,
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
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              TaskScreen(homeId: entry.home.id, taskId: entry.task.id),
        ),
      ),
    );
  }
}
