// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/tokens.dart';
import '../domain/day.dart';
import '../domain/recurrence.dart' as recurrence;
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'state.dart';

/// Task (docs/spec.md, "Screens of v1"): a form where only the title is
/// required; the repetition with a preview of the next five dates
/// (`tasks/recurrence.py:341-351`); the history of a task that exists.
/// Rooms, items, materials and photos come with lot 2b and lot 3.
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.homeId, this.taskId});

  final String homeId;

  /// `null` for a new task.
  final String? taskId;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _interval = TextEditingController(text: '1');
  final _notes = TextEditingController();
  Day? _due;
  String _mode = recurrence.once;
  String _unit = recurrence.monthUnit;
  String _season = '';
  TaskRow? _task;
  List<OccurrenceRow> _history = const [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      if (widget.taskId != null) _load();
    }
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final task = await repository.task(widget.taskId!);
    if (task == null || !mounted) return;
    final open = await repository.openOccurrencesOf(task.id);
    final all = await repository.occurrencesOf(task.id);
    if (!mounted) return;
    setState(() {
      _task = task;
      _title.text = task.title;
      _interval.text = '${task.repeatInterval}';
      _notes.text = task.notes;
      _mode = task.repeatMode;
      _unit = task.repeatUnit;
      _season = task.season;
      final due = open.isEmpty ? null : open.first.dueOn;
      _due = due == null ? null : Day.parse(due);
      _history = all.where((o) => closedStatuses.contains(o.status)).toList();
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _interval.dispose();
    _notes.dispose();
    super.dispose();
  }

  TaskInput _input() => TaskInput(
    title: _title.text,
    dueOn: _due,
    repeatMode: _mode,
    repeatUnit: _unit,
    repeatInterval: int.tryParse(_interval.text.trim()) ?? 0,
    season: _season,
    seasonStartMonth: _task?.seasonStartMonth,
    seasonEndMonth: _task?.seasonEndMonth,
    notes: _notes.text,
    hideDaysBefore: _task?.hideDaysBefore ?? 0,
    roomId: _task?.roomId,
    itemId: _task?.itemId,
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    try {
      if (widget.taskId == null) {
        await state.repository.createTask(widget.homeId, _input());
      } else {
        await state.repository.updateTask(widget.taskId!, _input());
      }
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
      return;
    }
    await state.refresh();
    navigator.pop();
  }

  Future<void> _chooseDate() async {
    final today = AppScope.of(context).repository.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: asDateTime(_due ?? today),
      firstDate: asDateTime(today.addYears(-dateSpanYears)),
      lastDate: asDateTime(today.addYears(dateSpanYears)),
    );
    if (picked != null) setState(() => _due = Day.of(picked));
  }

  List<Day> _preview(String hemisphere) {
    final due = _due;
    final interval = int.tryParse(_interval.text.trim());
    if (due == null || _mode == recurrence.once || interval == null) {
      return const [];
    }
    final window = _season == recurrence.custom
        ? (_task?.seasonStartMonth, _task?.seasonEndMonth)
        : recurrence.seasonWindow(_season, hemisphere);
    final rule = recurrence.Rule(
      mode: _mode,
      unit: _unit,
      interval: interval,
      seasonStart: window?.$1,
      seasonEnd: window?.$2,
    );
    if (recurrence.problems(rule).isNotEmpty) return const [];
    final anchor = _task?.seriesStart;
    return recurrence.preview(
      rule,
      anchor: anchor == null ? due : Day.parse(anchor),
      dueOn: due,
      count: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final hemisphere =
        state.homes
            .where((h) => h.id == widget.homeId)
            .firstOrNull
            ?.hemisphere ??
        recurrence.north;
    final text = Theme.of(context).textTheme;
    final repeats = _mode != recurrence.once;
    final next = _preview(hemisphere);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? l10n.newTask : l10n.task),
        actions: [TextButton(onPressed: _save, child: Text(l10n.save))],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(HcSpace.s4),
          children: [
            TextFormField(
              key: const Key('task-title'),
              controller: _title,
              autofocus: widget.taskId == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.taskTitle),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
            ),
            const SizedBox(height: HcSpace.s2),
            Text(l10n.taskDueDate, style: text.labelLarge),
            Wrap(
              spacing: HcSpace.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _due == null
                      ? l10n.todayNoDate
                      : l10n.dueOn(formatDay(context, _due!)),
                  style: text.bodyLarge,
                ),
                TextButton(
                  onPressed: _chooseDate,
                  child: Text(l10n.taskChooseDate),
                ),
                if (_due != null)
                  TextButton(
                    onPressed: () => setState(() => _due = null),
                    child: Text(l10n.taskClearDate),
                  ),
              ],
            ),
            const SizedBox(height: HcSpace.s4),
            DropdownButtonFormField<String>(
              key: const Key('task-repeat'),
              initialValue: _mode,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.repeat),
              items: [
                DropdownMenuItem(
                  value: recurrence.once,
                  child: Text(l10n.repeatOnce),
                ),
                DropdownMenuItem(
                  value: recurrence.fixed,
                  child: Text(l10n.repeatFixed),
                ),
                DropdownMenuItem(
                  value: recurrence.afterLast,
                  child: Text(l10n.repeatAfterLast),
                ),
              ],
              onChanged: (value) => setState(() => _mode = value!),
            ),
            if (repeats) ...[
              const SizedBox(height: HcSpace.s4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('task-interval'),
                      controller: _interval,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.repeatEvery),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final n = int.tryParse((value ?? '').trim());
                        final max = recurrence.maxInterval[_unit]!;
                        return n == null || n < 1 || n > max
                            ? l10n.errIntervalOutOfRange
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: HcSpace.s4),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      isExpanded: true,
                      items: [
                        for (final (unit, label) in [
                          (recurrence.dayUnit, l10n.unitDays),
                          (recurrence.weekUnit, l10n.unitWeeks),
                          (recurrence.monthUnit, l10n.unitMonths),
                          (recurrence.yearUnit, l10n.unitYears),
                        ])
                          DropdownMenuItem(value: unit, child: Text(label)),
                      ],
                      onChanged: (value) => setState(() => _unit = value!),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: HcSpace.s4),
            DropdownButtonFormField<String>(
              initialValue: _season,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.season),
              items: [
                for (final (season, label) in [
                  ('', l10n.seasonWholeYear),
                  (recurrence.spring, l10n.seasonSpring),
                  (recurrence.summer, l10n.seasonSummer),
                  (recurrence.autumn, l10n.seasonAutumn),
                  (recurrence.winter, l10n.seasonWinter),
                  if (_season == recurrence.custom)
                    (recurrence.custom, l10n.seasonCustom),
                ])
                  DropdownMenuItem(value: season, child: Text(label)),
              ],
              onChanged: (value) => setState(() => _season = value!),
            ),
            const SizedBox(height: HcSpace.s4),
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l10n.taskNotes),
            ),
            if (next.isNotEmpty) ...[
              const SizedBox(height: HcSpace.s4),
              Text(l10n.taskNextDates, style: text.titleSmall),
              for (final day in next)
                Text(
                  l10n.dueOn(formatDay(context, day)),
                  style: text.bodyMedium,
                ),
            ],
            if (_history.isNotEmpty) ...[
              const SizedBox(height: HcSpace.s4),
              Text(l10n.taskHistory, style: text.titleSmall),
              for (final o in _history)
                Text(
                  o.status == 'done' && o.completedOn != null
                      ? l10n.historyDone(
                          formatDay(context, Day.parse(o.completedOn!)),
                        )
                      : l10n.historySkipped,
                  style: text.bodyMedium,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
