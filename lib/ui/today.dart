// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import 'home_selector.dart';
import 'open_task_row.dart';
import 'state.dart';
import 'report_screens.dart';
import 'task_list_screen.dart';
import 'task_screen.dart';
import 'help_button.dart';

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
  List<TodayEntry> _season = const [];
  int _reports = 0;
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
    final homeId = state.todayAllHomes ? null : state.current?.id;
    final entries = await state.repository.todayEntries(homeId: homeId);
    final season = await state.repository.seasonEntries(homeId: homeId);
    final current = state.current;
    final reports = current == null
        ? 0
        : await state.repository.reportsWaiting(current.id);
    if (mounted) {
      setState(() {
        // A task of a season that is on, without a date, is in the section In
        // season and not in No date (`today_sections`).
        final seasonal = {for (final e in season) e.occurrence.id};
        _entries = [
          for (final e in entries)
            if (!seasonal.contains(e.occurrence.id)) e,
        ];
        _season = season;
        _reports = reports;
      });
    }
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
      l10n.seasonSection: _season,
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
    return HcScaffold(
      title: l10n.navToday,
      brand: true,
      belowTitle: const HomeSelector(withAllHomes: true),
      actions: const [HelpButton(page: HelpPages.today)],
      body: entries == null
          ? const SizedBox.shrink()
          : HcScreenList(
              children: [
                // The open reports of the current home, under the title, as
                // the web's `open_reports_line` (`reports/_today.html`).
                if (state.current != null)
                  Padding(
                    padding: const EdgeInsets.only(top: HcSpace.s3),
                    child: TodayReports(
                      count: _reports,
                      homeId: state.current!.id,
                    ),
                  ),
                // Today beside All, the list of every task of the home
                // (`tab_bar "today"`); across homes there is no such list.
                if (state.current != null && !state.todayAllHomes)
                  Padding(
                    padding: const EdgeInsets.only(top: HcSpace.s3),
                    child: HcTabs(
                      key: const Key('today-tabs'),
                      labels: [l10n.navToday, l10n.tasksTabAll],
                      current: 0,
                      onSelect: (_) => Navigator.of(context).push(
                        hcRoute(TaskListScreen(homeId: state.current!.id)),
                      ),
                    ),
                  ),
                if (entries.isEmpty && _season.isEmpty)
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
                          OpenTaskRow(
                            entry: entry,
                            today: today,
                            namesHome: named,
                          ),
                      ],
                    ),
                  ],
                // After the list, as on the web (`tasks/today.html`).
                if (state.current != null)
                  HcAddButton(
                    key: const Key('today-add'),
                    label: l10n.addTask,
                    onPressed: () => Navigator.of(context)
                        .push(hcRoute(TaskScreen(homeId: state.current!.id))),
                  ),
              ],
            ),
    );
  }
}
