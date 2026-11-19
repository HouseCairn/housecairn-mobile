// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/day.dart';
import '../domain/durations.dart' as durations;
import '../domain/recurrence.dart' as recurrence;
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import 'attachments.dart';
import 'budget_parts.dart';
import 'contractor_screens.dart';
import 'item_screens.dart';
import 'messages.dart';
import 'occurrence_actions.dart';
import 'occurrence_screen.dart';
import 'parts.dart';
import 'photos.dart';
import 'report_screens.dart' show ReportScreen;
import 'rooms.dart';
import 'guide_screens.dart';
import 'state.dart';
import 'stock_screens.dart';
import 'task_form_screen.dart';

export 'task_form_screen.dart' show TaskFormScreen;

/// A task (docs/spec.md, "Screens of v1"; `tasks/task_detail.html`). An
/// existing task opens on its page, to read, as on the web: its pills, its
/// title, its place, the row of actions (Done, Postpone, Skip this time or
/// Undo, then Edit the task), then When, How to do it, Details, Cost,
/// Materials, the photos of its place, its Photos and files and its History.
/// The form opens from
/// Edit the task; without [taskId], this is the form of a new task, which
/// opens as a sheet on iOS (lot D4).
class TaskScreen extends StatelessWidget implements HcFormScreen {
  const TaskScreen({
    super.key,
    required this.homeId,
    this.taskId,
    this.roomId,
    this.itemId,
  });

  final String homeId;

  /// The room or the item a new task starts attached to, when it is added from
  /// their screen.
  final String? roomId;
  final String? itemId;

  /// `null` for a new task.
  final String? taskId;

  @override
  bool get opensAsSheet => taskId == null;

  @override
  Widget build(BuildContext context) => taskId == null
      ? TaskFormScreen(homeId: homeId, roomId: roomId, itemId: itemId)
      : TaskPage(homeId: homeId, taskId: taskId!);
}

/// The rule of a task in a sentence, as the web's `repeat_summary`
/// (`tasks/templatetags/tasks_extras.py`): "Every 3 months", "A month after
/// the last time", then its season and its months when it has some.
String repeatSummary(BuildContext context, TaskRow task) {
  final l10n = AppLocalizations.of(context);
  final n = task.repeatInterval;
  if (task.repeatMode == recurrence.once) return l10n.repeatOnce;
  final fixed = task.repeatMode == recurrence.fixed;
  var text = switch (task.repeatUnit) {
    recurrence.dayUnit =>
      fixed ? l10n.repeatEveryDay(n) : l10n.repeatDaysAfter(n),
    recurrence.weekUnit =>
      fixed ? l10n.repeatEveryWeek(n) : l10n.repeatWeeksAfter(n),
    recurrence.yearUnit =>
      fixed ? l10n.repeatEveryYear(n) : l10n.repeatYearsAfter(n),
    _ => fixed ? l10n.repeatEveryMonth(n) : l10n.repeatMonthsAfter(n),
  };
  final start = task.seasonStartMonth, end = task.seasonEndMonth;
  if (start != null && end != null) {
    final season = switch (task.season) {
      recurrence.spring => l10n.seasonSpring,
      recurrence.summer => l10n.seasonSummer,
      recurrence.autumn => l10n.seasonAutumn,
      recurrence.winter => l10n.seasonWinter,
      _ => null,
    };
    if (season != null) text += ', $season';
    final locale = Localizations.localeOf(context).toLanguageTag();
    String month(int m) => DateFormat.MMMM(locale).format(DateTime(2000, m));
    text += ', ${l10n.repeatMonths(month(start), month(end))}';
  }
  return text;
}

/// An estimated duration as people say it, as the web's `durations.label`:
/// "45 min", "1 h 30", "2 days", "1 month 1 week".
String durationLabel(AppLocalizations l10n, int minutes) {
  final parts = <String>[];
  var rest = minutes;
  for (final (unit, say) in [
    (durations.year, l10n.durationYears),
    (durations.month, l10n.durationMonths),
    (durations.week, l10n.durationWeeks),
    (durations.day, l10n.durationDays),
  ]) {
    final size = durations.minutesIn[unit]!;
    final count = rest ~/ size;
    rest = rest % size;
    if (count > 0) parts.add(say(count));
  }
  if (rest > 0 || parts.isEmpty) {
    if (rest < 60) {
      parts.add(l10n.durationMin(rest));
    } else {
      final hours = rest ~/ 60, left = rest % 60;
      parts.add(
        left == 0
            ? l10n.durationHours(hours)
            : l10n.durationHoursMinutes(hours, left.toString().padLeft(2, '0')),
      );
    }
  }
  return parts.join(' ');
}

/// The page of a task, to read (`tasks/task_detail.html`).
class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.homeId, required this.taskId});

  final String homeId;
  final String taskId;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  TaskRow? _task;
  RoomRow? _room;
  ItemRow? _item;
  ContractorRow? _contractor;
  String _currency = '';
  OccurrenceRow? _current;
  OccurrenceRow? _lastClosed;
  List<OccurrenceRow> _history = const [];
  List<ReportRow> _reports = const [];
  budget.TaskBudget? _cost;
  bool _loaded = false;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (!_loaded) {
      _loaded = true;
      _revision = state.revision;
      _load();
    } else if (state.revision != _revision) {
      // A change made from here (Done, Skip, Undo, the form) or from the bar
      // of Today.
      _revision = state.revision;
      _load();
    }
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final task = await repository.task(widget.taskId);
    if (task == null) return;
    final home = await repository.home(widget.homeId);
    final room = task.roomId == null
        ? null
        : await repository.room(task.roomId!);
    final item = task.itemId == null
        ? null
        : await repository.item(task.itemId!);
    final contractor = task.contractorId == null
        ? null
        : await repository.contractor(task.contractorId!);
    final open = await repository.openOccurrencesOf(widget.taskId);
    final all = await repository.occurrencesOf(widget.taskId);
    final ledger = await repository.ledger(widget.homeId);
    final reports = await repository.reportsOfTask(widget.taskId);
    if (!mounted) return;
    final closed = all.where((o) => closedStatuses.contains(o.status)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    setState(() {
      _task = task;
      _room = room;
      _item = item;
      _contractor = contractor;
      _currency = home?.currency ?? '';
      _current = open.isEmpty ? null : open.first;
      _lastClosed = closed.isEmpty ? null : closed.first;
      _history = all.where((o) => closedStatuses.contains(o.status)).toList();
      _reports = reports;
      // A task of a project has its money in the lines of the project.
      _cost = ledger.tasks
          .where((budget.TaskBudget t) => t.task.id == task.id)
          .firstOrNull;
    });
  }

  /// The form of the task; when it deletes the task, the page closes too.
  Future<void> _edit() async {
    final navigator = Navigator.of(context);
    final kept = await navigator.push<bool>(
      hcRouteOf<bool>(
        TaskFormScreen(homeId: widget.homeId, taskId: widget.taskId),
      ),
    );
    if (kept == false && mounted) navigator.pop();
  }

  void _open(Widget screen) => Navigator.of(context).push(hcRoute(screen));

  String _money(String amount) =>
      moneyIn(context, _currency, budget.readMoney(amount));

  /// Pills, title, place and the row of actions: the head of the page.
  Widget _head(AppLocalizations l10n, bool writable) {
    final task = _task!;
    final today = AppScope.of(context).repository.today();
    final current = _current;
    final closed = _lastClosed;
    final room = _room, item = _item;
    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: HcSpace.s2,
            runSpacing: HcSpace.s1,
            children: [
              if (current != null) ...[
                duePill(
                  context,
                  current.dueOn == null ? null : Day.parse(current.dueOn!),
                  today,
                  postponed: current.status == 'postponed',
                ),
                if (current.status == 'postponed')
                  HcPill(l10n.taskPostponedPill, tone: HcPillTone.info),
              ] else if (closed != null)
                HcPill(
                  [
                    closed.status == 'done'
                        ? l10n.actionDone
                        : l10n.historyOutcomeSkipped,
                    if (closed.completedOn != null)
                      formatDay(context, Day.parse(closed.completedOn!)),
                  ].join(' · '),
                  tone: closed.status == 'done'
                      ? HcPillTone.success
                      : HcPillTone.ghost,
                ),
              if (task.priority == 'high')
                HcPill(l10n.taskHighPriority, tone: HcPillTone.warning)
              else if (task.priority == 'low')
                HcPill(l10n.taskLowPriority, tone: HcPillTone.ghost),
              if (task.repeatMode != recurrence.once)
                HcPill(repeatSummary(context, task), tone: HcPillTone.info),
            ],
          ),
          const SizedBox(height: HcSpace.s2),
          Semantics(
            header: true,
            child: Text(task.title, style: HcText.pageTitle),
          ),
          if (room != null || item != null)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (room != null)
                  HcLink(
                    room.name,
                    key: const Key('task-room-link'),
                    onTap: () => _open(
                      RoomScreen(homeId: widget.homeId, roomId: room.id),
                    ),
                  ),
                if (room != null && item != null)
                  Text(' · ', style: HcText.rowText),
                if (item != null)
                  HcLink(
                    item.name,
                    key: const Key('task-item-link'),
                    onTap: () => _open(
                      ItemScreen(homeId: widget.homeId, itemId: item.id),
                    ),
                  ),
              ],
            ),
          if (writable) ...[
            const SizedBox(height: HcSpace.s3),
            // One primary action, then the secondary ones, on lines that
            // wrap (design/patterns.md of the web, Record page).
            Wrap(
              spacing: HcSpace.s2,
              runSpacing: HcSpace.s2,
              children: [
                if (current != null) ...[
                  FilledButton(
                    key: const Key('task-done'),
                    onPressed: () => markDone(context, current.id, task.title),
                    child: Text(l10n.actionDone),
                  ),
                  OutlinedButton(
                    key: const Key('task-postpone'),
                    onPressed: () => postponeOccurrence(context, current.id),
                    child: Text(l10n.actionPostpone),
                  ),
                  OutlinedButton(
                    key: const Key('task-skip'),
                    onPressed: () =>
                        markSkipped(context, current.id, task.title),
                    child: Text(l10n.actionSkip),
                  ),
                ] else if (closed != null)
                  OutlinedButton(
                    key: const Key('task-undo'),
                    onPressed: () => undoOccurrence(context, closed.id),
                    child: Text(l10n.undo),
                  ),
                OutlinedButton(
                  key: const Key('task-edit'),
                  onPressed: _edit,
                  child: Text(l10n.taskEditTask),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// The report or reports the task was made from, under the head
  /// (`tasks/task_detail.html`): when it was reported, its title, which opens
  /// it, and its photo, which opens full width. The web adds who reported
  /// it; the app does not hold that.
  Widget? _reported(AppLocalizations l10n) {
    if (_reports.isEmpty) return null;
    return _section(
      l10n.taskReportedProblem,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final report in _reports) ...[
            HcCard(
              key: Key('task-report-${report.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.taskReportedOn(
                      formatDay(
                        context,
                        Day.of(
                          DateTime.fromMillisecondsSinceEpoch(report.createdAt)
                              .toLocal(),
                        ),
                      ),
                    ),
                    style: HcText.bodySmall,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: HcLink(
                      report.title,
                      key: Key('task-report-link-${report.id}'),
                      onTap: () => _open(
                        ReportScreen(
                          homeId: widget.homeId,
                          reportId: report.id,
                        ),
                      ),
                    ),
                  ),
                  if (report.photo != null && report.photo!.isNotEmpty) ...[
                    const SizedBox(height: HcSpace.s2),
                    ReportPhoto(report: report, keySuffix: '-${report.id}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: HcSpace.s2),
          ],
        ],
      ),
    );
  }

  /// When: the rule, the date, the first date of a postponed one, how long
  /// it stays hidden, and the next three dates (`services.upcoming_dates`).
  Widget _when(AppLocalizations l10n) {
    final task = _task!;
    final current = _current;
    final due = current?.dueOn == null ? null : Day.parse(current!.dueOn!);
    final next = <Day>[];
    if (task.repeatMode != recurrence.once && due != null) {
      final rule = recurrence.Rule(
        mode: task.repeatMode,
        unit: task.repeatUnit,
        interval: task.repeatInterval,
        seasonStart: task.seasonStartMonth,
        seasonEnd: task.seasonEndMonth,
      );
      if (recurrence.problems(rule).isEmpty) {
        final anchor = task.seriesStart;
        next.addAll(
          recurrence.preview(
            rule,
            anchor: anchor == null ? due : Day.parse(anchor),
            dueOn: due,
            count: 3,
          ),
        );
      }
    }
    return _section(
      l10n.taskWhen,
      HcCard(
        child: HcValueList(
          children: [
            HcValueRow(l10n.repeat, repeatSummary(context, task)),
            if (due != null)
              HcValueRow(l10n.taskDueOn, formatDay(context, due)),
            if (current?.postponedFrom != null)
              HcValueRow(
                l10n.taskPostponedFrom,
                formatDay(context, Day.parse(current!.postponedFrom!)),
              ),
            if (task.hideDaysBefore > 0)
              HcValueRow(
                l10n.taskHiddenUntil,
                l10n.taskHiddenDays(task.hideDaysBefore),
              ),
            if (next.isNotEmpty)
              // One date a line: three dates do not hold on one line of a
              // phone.
              HcValueRow(
                l10n.taskThen,
                '',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in next)
                      Text(formatDay(context, day), style: HcValueText.value),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Details: duration, budgets, contractor and notes, when there are some.
  Widget? _details(AppLocalizations l10n) {
    final task = _task!;
    final contractor = _contractor;
    final minutes = task.estimatedMinutes;
    final rows = <Widget>[
      if (minutes != null && minutes > 0)
        HcValueRow(l10n.taskDuration, durationLabel(l10n, minutes)),
      if (task.labourBudget != null)
        HcValueRow(l10n.labourBudget, _money(task.labourBudget!)),
      if (task.materialBudget != null)
        HcValueRow(l10n.materialBudget, _money(task.materialBudget!)),
      if (contractor != null)
        HcValueRow(
          l10n.contractor,
          '',
          child: HcLink(
            [
              contractor.name,
              if (contractor.trade.isNotEmpty)
                contractorTrade(l10n, contractor),
            ].join(' · '),
            key: const Key('task-contractor-link'),
            onTap: () => _open(
              ContractorScreen(
                homeId: widget.homeId,
                contractorId: contractor.id,
              ),
            ),
          ),
        ),
    ];
    if (rows.isEmpty && task.notes.isEmpty) return null;
    return _section(
      l10n.taskDetails,
      HcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rows.isNotEmpty) HcValueList(children: rows),
            // A long text goes under its label, as a paragraph.
            if (task.notes.isNotEmpty) ...[
              if (rows.isNotEmpty) const Divider(height: HcSpace.s6),
              Text(l10n.taskNotes, style: HcValueText.label),
              const SizedBox(height: HcSpace.s1),
              Text(task.notes, style: HcText.body),
            ],
          ],
        ),
      ),
    );
  }

  /// Cost: what is planned (the estimate of one time, its materials when
  /// they come from the stock, a year of it), then what was really paid,
  /// each under its own pill (`budget/_task_cost.html`, web ADR 0081).
  Widget? _costSection(AppLocalizations l10n) {
    final row = _cost;
    if (row == null) return null;
    final paid = row.figures(budget.anytime).paid;
    if (!row.hasEstimate && paid == budget.zero) return null;
    String money(Decimal value) => moneyIn(context, _currency, value);
    final annual = row.annualCost;
    Widget kind(String label, HcPillTone tone, Key key) => Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.s2),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          header: true,
          child: HcPill(label, key: key, tone: tone),
        ),
      ),
    );
    return _section(
      l10n.taskCost,
      HcCard(
        key: const Key('task-cost'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (row.hasEstimate) ...[
              kind(
                l10n.taskCostPlanned,
                HcPillTone.sand,
                const Key('task-cost-planned'),
              ),
              HcValueList(
                children: [
                  HcValueRow(l10n.estimateEachTime, money(row.estimate)),
                  if (row.materialFromStock)
                    HcValueRow(
                      l10n.taskMaterialsFromStock,
                      money(row.stock.amount),
                      key: const Key('task-materials-from-stock'),
                    ),
                  if (annual != null) HcValueRow(l10n.costAYear, money(annual)),
                ],
              ),
              if (row.materialFromStock)
                smallNote(l10n.taskMaterialsFromStockHelp),
              const SizedBox(height: HcSpace.s4),
            ],
            kind(
              l10n.taskCostReal,
              HcPillTone.neutral,
              const Key('task-cost-real'),
            ),
            HcValueList(
              children: [HcValueRow(l10n.taskPaidSoFar, money(paid))],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String heading, Widget body) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [HcSectionHeading(heading), body],
  );

  /// The photos of the item of the task, else of its room, read only, with a
  /// way to their sheet (`task_detail.html`).
  Widget _placePhotos(AppLocalizations l10n) {
    final task = _task!;
    final isItem = task.itemId != null;
    final place = task.itemId ?? task.roomId;
    if (place == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhotoSection(
          key: Key('task-photos-$place'),
          homeId: widget.homeId,
          itemId: isItem ? place : null,
          roomId: isItem ? null : place,
          writable: false,
          hideEmpty: true,
          heading: isItem ? l10n.taskPhotosOfItem : l10n.taskPhotosOfRoom,
        ),
        DataView<int>(
          load: (r) async => (await r.photosOf(
            roomId: isItem ? null : place,
            itemId: isItem ? place : null,
          )).length,
          builder: (context, count) => count == 0
              ? const SizedBox.shrink()
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    key: const Key('task-photos-link'),
                    onPressed: () => _open(
                      isItem
                          ? ItemScreen(homeId: widget.homeId, itemId: place)
                          : RoomScreen(homeId: widget.homeId, roomId: place),
                    ),
                    child: Text(
                      isItem
                          ? l10n.taskAllPhotosOfItem
                          : l10n.taskAllPhotosOfRoom,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _historyList(AppLocalizations l10n, bool writable) => _section(
    l10n.taskHistory,
    HcCardList(
      children: [
        for (final o in _history)
          HcRow(
            key: Key('history-${o.id}'),
            title: o.status == 'done' && o.completedOn != null
                ? l10n.historyDone(
                    formatDay(context, Day.parse(o.completedOn!)),
                  )
                : l10n.historySkipped,
            text: o.status != 'done'
                ? null
                : o.actualCost == null
                ? l10n.costNotTyped
                : l10n.realCost(_money(o.actualCost!)),
            moreText: o.completionNote.isEmpty ? null : o.completionNote,
            onTap: o.status == 'done' && writable
                ? () => _open(
                    OccurrenceScreen(homeId: widget.homeId, occurrenceId: o.id),
                  )
                : null,
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.homes.where((h) => h.id == widget.homeId).firstOrNull;
    final writable = home?.archivedAt == null;
    final task = _task;
    final details = task == null ? null : _details(l10n);
    final cost = task == null ? null : _costSection(l10n);
    // The h1 is drawn under the pills of the head (lot D2); on iOS it still
    // folds into the bar once scrolled away (lot D4).
    return HcScaffold(
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      title: task?.title,
      drawsTitle: false,
      actions: const [HelpButton(page: HelpPages.task)],
      body: task == null
          ? const SizedBox.shrink()
          : HcScreenList(
              children: [
                _head(l10n, writable),
                ?_reported(l10n),
                _when(l10n),
                if (task.procedure.trim().isNotEmpty)
                  _section(
                    l10n.taskProcedure,
                    HcCard(
                      child: Text(
                        task.procedure,
                        key: const Key('task-procedure-text'),
                        style: HcText.body,
                      ),
                    ),
                  ),
                ?details,
                ?cost,
                TaskMaterialsSection(
                  homeId: widget.homeId,
                  taskId: widget.taskId,
                  writable: writable,
                ),
                _placePhotos(l10n),
                AttachmentSection(
                  homeId: widget.homeId,
                  taskId: widget.taskId,
                  writable: writable,
                ),
                if (_history.isNotEmpty) _historyList(l10n, writable),
              ],
            ),
    );
  }
}
