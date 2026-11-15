// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/choices.dart';
import '../domain/day.dart';
import '../domain/durations.dart' as durations;
import '../domain/recurrence.dart' as recurrence;
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'choices.dart';
import 'item_screens.dart';
import 'messages.dart';
import 'occurrence_actions.dart';
import 'occurrence_screen.dart';
import 'parts.dart';
import 'photos.dart';
import 'rooms.dart';
import 'state.dart';
import 'stock_screens.dart';

/// The choice that adds a room, an item or a contractor with the task: the
/// last of their lists (`AddInPlaceChoiceField`).
const _newChoice = '+new';

/// Task (docs/spec.md, "Screens of v1"): the page of a task that exists, with
/// what can be done to its open occurrence (Done, Postpone, Skip this time,
/// Undo), and a form where only the title is required; the repetition with a
/// preview of the next five dates (`tasks/recurrence.py:341-351`); the
/// photos of its place; the history, whose done lines open their details; the
/// deletion.
class TaskScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => taskId == null;

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
  final _procedure = TextEditingController();
  final _hide = TextEditingController(text: '0');
  final _duration = TextEditingController();
  final _material = TextEditingController();
  final _labour = TextEditingController();
  final _newRoomName = TextEditingController();
  final _newItemName = TextEditingController();
  final _newContractorName = TextEditingController();
  final _newContractorOther = TextEditingController();
  String _currency = '';
  Day? _due;
  String _mode = recurrence.once;
  String _unit = recurrence.monthUnit;
  String _season = '';
  String _priority = 'normal';
  String _durationUnit = durations.hour;
  String _newRoomKind = 'other';
  String _newContractorTrade = '';
  TaskRow? _task;
  String? _roomId;
  String? _itemId;
  String? _contractorId;
  List<RoomRow> _rooms = const [];
  List<ItemRow> _items = const [];
  List<ContractorRow> _contractors = const [];
  OccurrenceRow? _current;
  OccurrenceRow? _lastClosed;
  List<OccurrenceRow> _history = const [];
  bool _loaded = false;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (!_loaded) {
      _loaded = true;
      _revision = state.revision;
      _roomId = widget.roomId;
      _itemId = widget.itemId;
      _loadPlaces();
      if (widget.taskId != null) _load();
    } else if (state.revision != _revision) {
      // A change made from here (Done, Skip, Undo) or from the bar of Today.
      _revision = state.revision;
      if (widget.taskId != null) _loadOccurrences();
    }
  }

  /// The rooms of the home, the contractors, and the items of the room chosen.
  Future<void> _loadPlaces() async {
    final repository = AppScope.of(context).repository;
    final rooms = await repository.rooms(widget.homeId);
    final contractors = await repository.contractors(widget.homeId);
    final home = await repository.home(widget.homeId);
    var roomId = _roomId;
    if (roomId == null && _itemId != null) {
      roomId = (await repository.item(_itemId!))?.roomId;
    }
    final items = roomId == null || roomId == _newChoice
        ? <ItemRow>[]
        : await repository.itemsOf(roomId);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      _rooms = rooms;
      _contractors = contractors;
      _roomId = roomId;
      _items = items;
    });
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final task = await repository.task(widget.taskId!);
    if (task == null || !mounted) return;
    setState(() {
      _task = task;
      _title.text = task.title;
      _interval.text = '${task.repeatInterval}';
      _notes.text = task.notes;
      _procedure.text = task.procedure;
      _hide.text = '${task.hideDaysBefore}';
      final minutes = task.estimatedMinutes;
      if (minutes != null) {
        final (value, unit) = durations.split(minutes);
        _duration.text = '$value';
        _durationUnit = unit;
      }
      _material.text = task.materialBudget == null
          ? ''
          : budget.readMoney(task.materialBudget!).toStringAsFixed(2);
      _labour.text = task.labourBudget == null
          ? ''
          : budget.readMoney(task.labourBudget!).toStringAsFixed(2);
      _mode = task.repeatMode;
      _unit = task.repeatUnit;
      _season = task.season;
      _priority = task.priority;
      _roomId = task.roomId;
      _itemId = task.itemId;
      _contractorId = task.contractorId;
    });
    await _loadOccurrences();
    await _loadPlaces();
  }

  /// The open occurrence and the history of the task. The date of the form
  /// follows the open occurrence, so that saving after a Done does not move
  /// the next one back.
  Future<void> _loadOccurrences() async {
    final repository = AppScope.of(context).repository;
    final open = await repository.openOccurrencesOf(widget.taskId!);
    final all = await repository.occurrencesOf(widget.taskId!);
    if (!mounted) return;
    final closed = all.where((o) => closedStatuses.contains(o.status)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    setState(() {
      _current = open.isEmpty ? null : open.first;
      _lastClosed = closed.isEmpty ? null : closed.first;
      final due = _current?.dueOn;
      _due = due == null ? null : Day.parse(due);
      _history = all.where((o) => closedStatuses.contains(o.status)).toList();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _interval,
      _notes,
      _procedure,
      _hide,
      _duration,
      _material,
      _labour,
      _newRoomName,
      _newItemName,
      _newContractorName,
      _newContractorOther,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  TaskInput _input(
    String? roomId,
    String? itemId,
    String? contractorId,
    int? minutes,
  ) => TaskInput(
    title: _title.text,
    dueOn: _due,
    repeatMode: _mode,
    repeatUnit: _unit,
    repeatInterval: int.tryParse(_interval.text.trim()) ?? 0,
    season: _season,
    seasonStartMonth: _task?.seasonStartMonth,
    seasonEndMonth: _task?.seasonEndMonth,
    notes: _notes.text,
    hideDaysBefore: int.tryParse(_hide.text.trim()) ?? 0,
    roomId: roomId,
    itemId: itemId,
    priority: _priority,
    estimatedMinutes: minutes,
    procedure: _procedure.text,
    contractorId: contractorId,
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    final repository = state.repository;
    final typed = int.tryParse(_duration.text.trim());
    final minutes = typed == null
        ? null
        : durations.toMinutes(typed, _durationUnit);
    try {
      await repository.atomic(() async {
        // A room, an item and a contractor added with the task join the home
        // with it, or not at all.
        var roomId = _roomId;
        var itemId = _itemId;
        var contractorId = _contractorId;
        if (roomId == _newChoice) {
          roomId = await repository.createRoom(
            widget.homeId,
            name: _newRoomName.text,
            kind: _newRoomKind,
            position: _rooms.length,
          );
        }
        if (itemId == _newChoice) {
          itemId = await repository.addItem(
            roomId!,
            ItemInput(name: _newItemName.text),
          );
        }
        if (contractorId == _newChoice) {
          contractorId = await repository.addContractor(
            widget.homeId,
            ContractorInput(
              name: _newContractorName.text,
              trade: _newContractorTrade,
              tradeOther: _newContractorTrade == 'other'
                  ? _newContractorOther.text
                  : '',
            ),
          );
        }
        final input = _input(roomId, itemId, contractorId, minutes);
        final id = widget.taskId == null
            ? await repository.createTask(widget.homeId, input)
            : widget.taskId!;
        if (widget.taskId != null) await repository.updateTask(id, input);
        await repository.setTaskBudgets(
          id,
          material: _material.text,
          labour: _labour.text,
        );
      });
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
      return;
    }
    await state.refresh();
    navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.taskDeleteTitle(_task?.title ?? _title.text),
      body: l10n.taskDeleteBody,
    );
    if (!confirmed || !mounted) return;
    if (await runChange(context, (r) => r.deleteTask(widget.taskId!))) {
      navigator.pop();
    }
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

  String? _nameRequired(String? value, AppLocalizations l10n) =>
      (value ?? '').trim().isEmpty ? l10n.errTitleRequired : null;

  /// The task as a page, above its form: what is due, where, and what can be
  /// done to it (`tasks/task_detail.html`).
  Widget _summary(AppLocalizations l10n, bool writable) {
    final task = _task!;
    final today = AppScope.of(context).repository.today();
    final current = _current;
    final closed = _lastClosed;
    final room = _rooms.where((r) => r.id == task.roomId).firstOrNull;
    final item = _items.where((i) => i.id == task.itemId).firstOrNull;
    final place = [?room?.name, ?item?.name].join(' · ');
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
                HcPill(l10n.taskHighPriority, tone: HcPillTone.warning),
              if (task.priority == 'low')
                HcPill(l10n.taskLowPriority, tone: HcPillTone.ghost),
            ],
          ),
          const SizedBox(height: HcSpace.s2),
          Text(task.title, style: HcText.cardTitle),
          if (place.isNotEmpty) ...[
            const SizedBox(height: HcSpace.s1),
            Text(place, style: HcText.rowText),
          ],
          if (writable && (current != null || closed != null)) ...[
            const SizedBox(height: HcSpace.s3),
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
                ] else
                  OutlinedButton(
                    key: const Key('task-undo'),
                    onPressed: () => undoOccurrence(context, closed!.id),
                    child: Text(l10n.undo),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

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
                    onPressed: () => Navigator.of(context).push(
                      hcRoute(
                        isItem
                            ? ItemScreen(homeId: widget.homeId, itemId: place)
                            : RoomScreen(homeId: widget.homeId, roomId: place),
                      ),
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

  Widget _historyList(AppLocalizations l10n, bool writable) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      HcSectionHeading(l10n.taskHistory),
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
                  : l10n.realCost(
                      moneyIn(
                        context,
                        _currency,
                        budget.readMoney(o.actualCost!),
                      ),
                    ),
              moreText: o.completionNote.isEmpty ? null : o.completionNote,
              onTap: o.status == 'done' && writable
                  ? () => Navigator.of(context).push(
                      hcRoute(
                        OccurrenceScreen(
                          homeId: widget.homeId,
                          occurrenceId: o.id,
                        ),
                      ),
                    )
                  : null,
            ),
        ],
      ),
    ],
  );

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
    final writable = state.homes
        .where((h) => h.id == widget.homeId)
        .every((h) => h.archivedAt == null);
    final repeats = _mode != recurrence.once;
    // The text size of the phone at which a pair of fields stacks.
    final wide = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final next = _preview(hemisphere);
    final newRoom = _roomId == _newChoice;
    return HcScaffold(
      title: widget.taskId == null ? l10n.newTask : l10n.task,
      actions: [HcBarAction(label: l10n.save, onPressed: _save)],
      body: Form(
        key: _form,
        child: HcScreenList(
          children: [
            const SizedBox(height: HcSpace.s2),
            if (_task != null) ...[
              _summary(l10n, writable),
              const SizedBox(height: HcSpace.s3),
            ],
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
                      validator: (value) => _nameRequired(value, l10n),
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
                    newRoom || _rooms.any((r) => r.id == _roomId)
                        ? _roomId
                        : null,
                    [
                      (null, l10n.templatesNoRoom),
                      for (final room in _rooms) (room.id, room.name),
                      (_newChoice, l10n.taskAddRoom),
                    ],
                    (value) {
                      setState(() {
                        _roomId = value;
                        _itemId = null;
                        _items = const [];
                      });
                      if (value != null && value != _newChoice) {
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
                  if (newRoom) ...[
                    HcSectionHeading(l10n.taskNewRoom),
                    hcText(
                      l10n.taskNewRoomName,
                      _newRoomName,
                      key: const Key('task-new-room-name'),
                      validator: (v) => _nameRequired(v, l10n),
                    ),
                    hcChoice<String>(
                      l10n.taskNewRoomKind,
                      _newRoomKind,
                      [for (final k in roomKinds) (k, roomKindLabel(l10n, k))],
                      (value) => setState(() => _newRoomKind = value),
                      key: const Key('task-new-room-kind'),
                    ),
                  ],
                  if (_roomId != null)
                    hcChoice<String?>(
                      l10n.item,
                      _itemId == _newChoice ||
                              _items.any((i) => i.id == _itemId)
                          ? _itemId
                          : null,
                      [
                        (null, l10n.contractNone),
                        for (final item in _items) (item.id, item.name),
                        (_newChoice, l10n.taskAddItem),
                      ],
                      (value) => setState(() => _itemId = value),
                      key: const Key('task-item'),
                    ),
                  if (_itemId == _newChoice) ...[
                    HcSectionHeading(l10n.taskNewItem),
                    hcText(
                      l10n.taskNewItemName,
                      _newItemName,
                      key: const Key('task-new-item-name'),
                      validator: (v) => _nameRequired(v, l10n),
                    ),
                  ],
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
                  hcText(
                    l10n.taskHideDays,
                    _hide,
                    key: const Key('task-hide-days'),
                    keyboard: TextInputType.number,
                    sentences: false,
                    validator: (value) {
                      final n = int.tryParse((value ?? '').trim());
                      return n == null || n < 0 || n > 365
                          ? l10n.errHideDays
                          : null;
                    },
                  ),
                  fieldHelp(l10n.taskHideDaysHelp),
                ],
              ),
            ),
            const SizedBox(height: HcSpace.s3),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcChoice<String>(
                    l10n.priority,
                    _priority,
                    [
                      ('high', l10n.priorityHigh),
                      ('normal', l10n.priorityNormal),
                      ('low', l10n.priorityLow),
                    ],
                    (value) => setState(() => _priority = value),
                    key: const Key('task-priority'),
                  ),
                  hcChoice<String?>(
                    l10n.contractor,
                    _contractorId == _newChoice ||
                            _contractors.any((c) => c.id == _contractorId)
                        ? _contractorId
                        : null,
                    [
                      (null, l10n.contractNone),
                      for (final c in _contractors) (c.id, c.name),
                      (_newChoice, l10n.taskAddContractor),
                    ],
                    (value) => setState(() => _contractorId = value),
                    key: const Key('task-contractor'),
                  ),
                  if (_contractorId == _newChoice) ...[
                    HcSectionHeading(l10n.taskNewContractor),
                    hcText(
                      l10n.taskNewContractorName,
                      _newContractorName,
                      key: const Key('task-new-contractor-name'),
                      validator: (v) => _nameRequired(v, l10n),
                    ),
                    hcChoice<String>(
                      l10n.contractorTrade,
                      _newContractorTrade,
                      [
                        ('', ''),
                        for (final t in trades) (t, tradeLabel(l10n, t)),
                      ],
                      (value) => setState(() => _newContractorTrade = value),
                      key: const Key('task-new-contractor-trade'),
                    ),
                    if (_newContractorTrade == 'other')
                      hcText(
                        l10n.contractorTradeOther,
                        _newContractorOther,
                        key: const Key('task-new-contractor-other'),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.errTradeOther
                            : null,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: HcSpace.s3),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HcField(
                    label: l10n.taskDuration,
                    child: Flex(
                      direction: wide ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pairPart(
                          wide,
                          TextFormField(
                            key: const Key('task-duration'),
                            controller: _duration,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) return null;
                              final n = int.tryParse(text);
                              return n == null ||
                                      !durations.withinBounds(
                                        durations.toMinutes(n, _durationUnit),
                                      )
                                  ? l10n.errDuration
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: HcSpace.s2, height: HcSpace.s2),
                        _pairPart(
                          wide,
                          Semantics(
                            label: l10n.taskDurationUnit,
                            child: DropdownButtonFormField<String>(
                              key: const Key('task-duration-unit'),
                              initialValue: _durationUnit,
                              isExpanded: true,
                              items: [
                                for (final (unit, label) in [
                                  (durations.minute, l10n.unitMinutes),
                                  (durations.hour, l10n.unitHours),
                                  (durations.day, l10n.unitDays),
                                  (durations.week, l10n.unitWeeks),
                                  (durations.month, l10n.unitMonths),
                                  (durations.year, l10n.unitYears),
                                ])
                                  DropdownMenuItem(
                                    value: unit,
                                    child: Text(label),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _durationUnit = value!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  hcText(
                    l10n.materialBudget,
                    _material,
                    key: const Key('task-material-budget'),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    sentences: false,
                    validator: moneyCheck(l10n),
                  ),
                  hcText(
                    l10n.labourBudget,
                    _labour,
                    key: const Key('task-labour-budget'),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    sentences: false,
                    validator: moneyCheck(l10n),
                  ),
                  fieldHelp(l10n.taskBudgetHelp(_currency)),
                ],
              ),
            ),
            const SizedBox(height: HcSpace.s3),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcText(
                    l10n.taskProcedure,
                    _procedure,
                    key: const Key('task-procedure'),
                    minLines: 3,
                    maxLines: 10,
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
            if (widget.taskId != null)
              TaskMaterialsSection(
                homeId: widget.homeId,
                taskId: widget.taskId!,
                writable: state.current?.archivedAt == null,
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
            if (_task != null) _placePhotos(l10n),
            if (_history.isNotEmpty) _historyList(l10n, writable),
            if (_task != null && writable)
              Padding(
                padding: const EdgeInsets.only(top: HcSpace.s4),
                child: FilledButton(
                  key: const Key('task-delete'),
                  style: hcDangerStyle(),
                  onPressed: _delete,
                  child: Text(l10n.taskDelete),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One field of a pair: half the line, or the whole line when they stack.
Widget _pairPart(bool stacked, Widget field) =>
    stacked ? field : Expanded(child: field);
