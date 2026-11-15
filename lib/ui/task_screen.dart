// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../domain/recurrence.dart' as recurrence;
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'parts.dart';
import 'state.dart';

/// Task (docs/spec.md, "Screens of v1"): a form where only the title is
/// required; the repetition with a preview of the next five dates
/// (`tasks/recurrence.py:341-351`); the history of a task that exists.
/// Rooms, items, materials and photos come with lot 2b and lot 3.
class TaskScreen extends StatefulWidget {
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
  String? _roomId;
  String? _itemId;
  List<RoomRow> _rooms = const [];
  List<ItemRow> _items = const [];
  List<OccurrenceRow> _history = const [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _roomId = widget.roomId;
      _itemId = widget.itemId;
      _loadPlaces();
      if (widget.taskId != null) _load();
    }
  }

  /// The rooms of the home, and the items of the room chosen.
  Future<void> _loadPlaces() async {
    final repository = AppScope.of(context).repository;
    final rooms = await repository.rooms(widget.homeId);
    var roomId = _roomId;
    if (roomId == null && _itemId != null) {
      roomId = (await repository.item(_itemId!))?.roomId;
    }
    final items = roomId == null
        ? <ItemRow>[]
        : await repository.itemsOf(roomId);
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _roomId = roomId;
      _items = items;
    });
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
      _roomId = task.roomId;
      _itemId = task.itemId;
      final due = open.isEmpty ? null : open.first.dueOn;
      _due = due == null ? null : Day.parse(due);
      _history = all.where((o) => closedStatuses.contains(o.status)).toList();
    });
    await _loadPlaces();
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
    roomId: _roomId,
    itemId: _itemId,
    priority: _task?.priority ?? 'normal',
    estimatedMinutes: _task?.estimatedMinutes,
    procedure: _task?.procedure ?? '',
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
    final repeats = _mode != recurrence.once;
    // The text size of the phone at which a pair of fields stacks.
    final wide = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final next = _preview(hemisphere);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? l10n.newTask : l10n.task),
        actions: [HcBarAction(label: l10n.save, onPressed: _save)],
      ),
      body: Form(
        key: _form,
        child: HcScreenList(
          children: [
            const SizedBox(height: HcSpace.s2),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HcField(
                    label: l10n.taskTitle,
                    child: TextFormField(
                      key: const Key('task-title'),
                      controller: _title,
                      autofocus: widget.taskId == null,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? l10n.errTitleRequired
                          : null,
                    ),
                  ),
                  Text(l10n.taskDueDate, style: HcText.fieldLabel),
                  const SizedBox(height: HcSpace.s1),
                  Wrap(
                    spacing: HcSpace.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _due == null
                            ? l10n.todayNoDate
                            : l10n.dueOn(formatDay(context, _due!)),
                        style: HcText.body,
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
                ],
              ),
            ),
            const SizedBox(height: HcSpace.s3),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcChoice<String?>(
                    l10n.room,
                    _rooms.any((r) => r.id == _roomId) ? _roomId : null,
                    [
                      (null, l10n.templatesNoRoom),
                      for (final room in _rooms) (room.id, room.name),
                    ],
                    (value) {
                      setState(() {
                        _roomId = value;
                        _itemId = null;
                        _items = const [];
                      });
                      if (value != null) {
                        AppScope.of(context).repository
                            .itemsOf(value)
                            .then((items) {
                              if (mounted && _roomId == value) {
                                setState(() => _items = items);
                              }
                            });
                      }
                    },
                    key: const Key('task-room'),
                  ),
                  if (_items.isNotEmpty)
                    hcChoice<String?>(
                      l10n.item,
                      _items.any((i) => i.id == _itemId) ? _itemId : null,
                      [
                        (null, l10n.contractNone),
                        for (final item in _items) (item.id, item.name),
                      ],
                      (value) => setState(() => _itemId = value),
                      key: const Key('task-item'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: HcSpace.s3),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HcField(
                    label: l10n.repeat,
                    child: DropdownButtonFormField<String>(
                      key: const Key('task-repeat'),
                      initialValue: _mode,
                      isExpanded: true,
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
                  ),
                  if (repeats)
                    HcField(
                      label: l10n.repeatEvery,
                      // A number and its unit on one line, as `.field-pair`;
                      // with a large text, the unit goes under the number.
                      child: Flex(
                        direction: wide ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pairPart(
                            wide,
                            TextFormField(
                              key: const Key('task-interval'),
                              controller: _interval,
                              keyboardType: TextInputType.number,
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
                          const SizedBox(width: HcSpace.s2, height: HcSpace.s2),
                          _pairPart(
                            wide,
                            DropdownButtonFormField<String>(
                              initialValue: _unit,
                              isExpanded: true,
                              items: [
                                for (final (unit, label) in [
                                  (recurrence.dayUnit, l10n.unitDays),
                                  (recurrence.weekUnit, l10n.unitWeeks),
                                  (recurrence.monthUnit, l10n.unitMonths),
                                  (recurrence.yearUnit, l10n.unitYears),
                                ])
                                  DropdownMenuItem(
                                    value: unit,
                                    child: Text(label),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _unit = value!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  HcField(
                    label: l10n.season,
                    child: DropdownButtonFormField<String>(
                      initialValue: _season,
                      isExpanded: true,
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
                  ),
                  HcField(
                    label: l10n.taskNotes,
                    child: TextFormField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 6,
                    ),
                  ),
                ],
              ),
            ),
            if (next.isNotEmpty) ...[
              HcSectionHeading(l10n.taskNextDates),
              HcCardList(
                children: [
                  for (final day in next)
                    HcRow(title: l10n.dueOn(formatDay(context, day))),
                ],
              ),
            ],
            if (_history.isNotEmpty) ...[
              HcSectionHeading(l10n.taskHistory),
              HcCardList(
                children: [
                  for (final o in _history)
                    HcRow(
                      title: o.status == 'done' && o.completedOn != null
                          ? l10n.historyDone(
                              formatDay(context, Day.parse(o.completedOn!)),
                            )
                          : l10n.historySkipped,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One field of a pair: half the line, or the whole line when they stack.
Widget _pairPart(bool stacked, Widget field) =>
    stacked ? field : Expanded(child: field);
