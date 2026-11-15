// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'messages.dart';
import 'open_task_row.dart';
import 'parts.dart';
import 'state.dart';
import 'task_screen.dart';
import 'templates_screen.dart';

/// All the tasks of a home (`tasks/task_list.html`, web ADR 0017): the open
/// ones, the oldest date first and 30 to a page, filtered by room, with the
/// ones hidden until their date gets closer a tap away; or, under Done, the
/// history of what was done or skipped, filtered, with what it really cost.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.homeId});

  final String homeId;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _history = false;
  String? _roomId;
  bool _showHidden = false;
  int _page = 1;

  // The filters of the history.
  final _query = TextEditingController();
  String? _itemId;
  String? _contractorId;
  String _outcome = '';
  Day? _after;
  Day? _before;
  bool _filtersOpen = false;

  TaskListPage? _list;
  HistoryPage? _past;
  List<RoomRow> _rooms = const [];
  List<ItemRow> _items = const [];
  List<ContractorRow> _contractors = const [];
  HomeRow? _home;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (state.revision != _revision) {
      _revision = state.revision;
      _load();
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  HistoryFilter get _filter => HistoryFilter(
    roomId: _roomId,
    itemId: _itemId,
    contractorId: _contractorId,
    query: _query.text,
    status: _outcome,
    after: _after,
    before: _before,
  );

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final rooms = await repository.rooms(widget.homeId);
    final items = await repository.itemsOfHome(widget.homeId);
    final contractors = await repository.contractors(widget.homeId);
    final home = await repository.home(widget.homeId);
    final list = _history
        ? null
        : await repository.openTasks(
            widget.homeId,
            roomId: _roomId,
            showHidden: _showHidden,
            page: _page,
          );
    final past = _history
        ? await repository.history(widget.homeId, _filter, page: _page)
        : null;
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _items = items;
      _contractors = contractors;
      _home = home;
      _list = list;
      _past = past;
    });
  }

  /// A change of filter shows the first page again.
  void _change(VoidCallback change) {
    setState(() {
      change();
      _page = 1;
    });
    _load();
  }

  void _goTo(int page) {
    setState(() => _page = page);
    _load();
  }

  Widget _pager(AppLocalizations l10n, int page, int pages) {
    if (pages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: HcSpace.s3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (page > 1)
            OutlinedButton(
              key: const Key('page-previous'),
              onPressed: () => _goTo(page - 1),
              child: Text(l10n.pagePrevious),
            )
          else
            const SizedBox.shrink(),
          Text(l10n.pageOf(page, pages), style: HcText.rowText),
          if (page < pages)
            OutlinedButton(
              key: const Key('page-next'),
              onPressed: () => _goTo(page + 1),
              child: Text(l10n.pageNext),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _statusAndRoom(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      hcChoice<bool>(
        l10n.tasksFilterShow,
        _history,
        [(false, l10n.tasksToDo), (true, l10n.tasksDoneFilter)],
        (value) => _change(() => _history = value),
        key: const Key('tasks-status'),
      ),
      if (!_history)
        hcChoice<String?>(
          l10n.room,
          _rooms.any((r) => r.id == _roomId) ? _roomId : null,
          [
            (null, l10n.tasksAllRooms),
            for (final room in _rooms) (room.id, room.name),
          ],
          (value) => _change(() => _roomId = value),
          key: const Key('tasks-room'),
        ),
    ],
  );

  Widget _openList(AppLocalizations l10n, TaskListPage list) {
    final today = AppScope.of(context).repository.today();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (list.rows.isEmpty)
          HcEmpty(l10n.tasksNone)
        else
          HcCardList(
            children: [
              for (final entry in list.rows)
                OpenTaskRow(entry: entry, today: today),
            ],
          ),
        _pager(l10n, list.page, list.pages),
        if (list.hidden > 0)
          Padding(
            key: const Key('tasks-hidden'),
            padding: const EdgeInsets.only(top: HcSpace.s3),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: HcSpace.s2,
              children: [
                Text(l10n.tasksHidden(list.hidden), style: HcText.rowText),
                TextButton(
                  key: const Key('tasks-show-hidden'),
                  onPressed: () => _change(() => _showHidden = true),
                  child: Text(l10n.tasksShowHidden),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dayField(String label, Day? value, ValueChanged<Day?> onChanged) =>
      HcDateField(
        label: label,
        value: value,
        noDate: '—',
        onChanged: (day) => _change(() => onChanged(day)),
      );

  Widget _filters(AppLocalizations l10n) {
    final clear = _filter.active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HcCardList(
          children: [
            HcRow(
              key: const Key('filters-toggle'),
              title: l10n.historyFilters,
              onTap: () => setState(() => _filtersOpen = !_filtersOpen),
            ),
          ],
        ),
        if (_filtersOpen || clear) ...[
          const SizedBox(height: HcSpace.s3),
          HcField(
            label: l10n.historySearch,
            child: TextField(
              key: const Key('history-query'),
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _change(() {}),
            ),
          ),
          hcChoice<String?>(
            l10n.room,
            _rooms.any((r) => r.id == _roomId) ? _roomId : null,
            [
              (null, l10n.tasksAllRooms),
              for (final room in _rooms) (room.id, room.name),
            ],
            (value) => _change(() => _roomId = value),
            key: const Key('history-room'),
          ),
          hcChoice<String?>(
            l10n.item,
            _items.any((i) => i.id == _itemId) ? _itemId : null,
            [
              (null, l10n.historyAllItems),
              for (final item in _items) (item.id, item.name),
            ],
            (value) => _change(() => _itemId = value),
            key: const Key('history-item'),
          ),
          hcChoice<String?>(
            l10n.contractor,
            _contractors.any((c) => c.id == _contractorId)
                ? _contractorId
                : null,
            [
              (null, l10n.historyEveryone),
              for (final c in _contractors) (c.id, c.name),
            ],
            (value) => _change(() => _contractorId = value),
            key: const Key('history-contractor'),
          ),
          hcChoice<String>(
            l10n.historyOutcome,
            _outcome,
            [
              ('', l10n.historyDoneOrSkipped),
              ('done', l10n.historyOutcomeDone),
              ('skipped', l10n.historyOutcomeSkipped),
            ],
            (value) => _change(() => _outcome = value),
            key: const Key('history-outcome'),
          ),
          _dayField(l10n.historyFrom, _after, (day) => _after = day),
          _dayField(l10n.historyTo, _before, (day) => _before = day),
          Row(
            children: [
              FilledButton(
                key: const Key('history-apply'),
                onPressed: () => _change(() {}),
                child: Text(l10n.tasksFilterShow),
              ),
              const SizedBox(width: HcSpace.s2),
              if (clear)
                OutlinedButton(
                  key: const Key('history-clear'),
                  onPressed: () => _change(() {
                    _query.clear();
                    _roomId = null;
                    _itemId = null;
                    _contractorId = null;
                    _outcome = '';
                    _after = null;
                    _before = null;
                  }),
                  child: Text(l10n.historyClear),
                ),
            ],
          ),
          const SizedBox(height: HcSpace.s3),
        ],
      ],
    );
  }

  Widget _historyList(AppLocalizations l10n, HistoryPage past) {
    final currency = _home?.currency ?? '';
    final cost = past.cost;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filters(l10n),
        // The count and the real cost of the whole selection, as the web's
        // `history-total` (a status for assistive technology).
        Semantics(
          liveRegion: true,
          child: Text(
            [
              l10n.historyEntries(cost.count),
              if (cost.withCost > 0)
                l10n.historyCost(
                  moneyIn(context, currency, cost.total),
                  cost.withCost,
                ),
            ].join(' · '),
            key: const Key('history-total'),
            style: HcText.rowText,
          ),
        ),
        const SizedBox(height: HcSpace.s3),
        if (past.rows.isEmpty)
          HcEmpty(
            _filter.active
                ? l10n.historyNothingMatches
                : l10n.historyNothingDone,
          )
        else
          HcCardList(
            children: [
              for (final entry in past.rows)
                HcRow(
                  key: Key('history-${entry.occurrence.id}'),
                  title: entry.task.title,
                  text: entry.whereAndWho,
                  pills: [
                    HcPill(
                      '${entry.occurrence.status == 'done' ? l10n.actionDone : l10n.historyOutcomeSkipped}'
                      ' · ${formatDay(context, entry.closedOn)}',
                      tone: entry.occurrence.status == 'done'
                          ? HcPillTone.success
                          : HcPillTone.ghost,
                    ),
                  ],
                  moreText: entry.occurrence.actualCost == null
                      ? null
                      : moneyIn(
                          context,
                          currency,
                          budget.readMoney(entry.occurrence.actualCost!),
                        ),
                  onTap: () => Navigator.of(context).push(
                    hcRoute(
                      TaskScreen(homeId: widget.homeId, taskId: entry.task.id),
                    ),
                  ),
                ),
            ],
          ),
        _pager(l10n, past.page, past.pages),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = _list;
    final past = _past;
    final writable = _home != null && _home!.archivedAt == null;
    return HcScaffold(
      title: l10n.tasksTitle,
      body: (list == null && past == null)
          ? const SizedBox.shrink()
          : HcScreenList(
              children: [
                const SizedBox(height: HcSpace.s2),
                HcTabs(
                  key: const Key('tasks-tabs'),
                  labels: [l10n.navToday, l10n.tasksTabAll],
                  current: 1,
                  onSelect: (_) => Navigator.of(context).pop(),
                ),
                _statusAndRoom(l10n),
                if (list != null) _openList(l10n, list),
                if (past != null) _historyList(l10n, past),
                if (writable && !_history) ...[
                  HcAddButton(
                    key: const Key('tasks-add'),
                    label: l10n.addTask,
                    // Under the line of the hidden tasks, 8 as on the web.
                    gap: (list?.hidden ?? 0) > 0 ? HcSpace.s2 : HcSpace.s3,
                    onPressed: () => Navigator.of(context).push(
                      hcRoute(
                        TaskScreen(homeId: widget.homeId, roomId: _roomId),
                      ),
                    ),
                  ),
                  HcAddButton(
                    key: const Key('tasks-add-template'),
                    label: l10n.addFromTemplate,
                    primary: false,
                    onPressed: () =>
                        Navigator.of(context)
                            .push(hcRoute(TemplatesScreen(roomId: _roomId))),
                  ),
                ],
              ],
            ),
    );
  }
}
