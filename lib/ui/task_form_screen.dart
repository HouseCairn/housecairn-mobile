// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/adaptive.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/choices.dart';
import '../domain/day.dart';
import '../domain/durations.dart' as durations;
import '../domain/recurrence.dart' as recurrence;
import '../domain/stock.dart' as stock;
import '../l10n/app_localizations.dart';
import 'autosave.dart';
import 'budget_parts.dart';
import 'stock_format.dart';
import 'choices.dart';
import 'messages.dart';
import 'parts.dart';
import 'guide_screens.dart';
import 'state.dart';

/// The choice that adds a room, an item or a contractor with the task: the
/// last of their lists (`AddInPlaceChoiceField`).
const _newChoice = '+new';

/// The form of a task (`tasks/task_form.html`), opened by Edit the task from
/// its page, or to add a task. Title, Room, Item and Due date first (the place
/// before the date), then what is optional in folded sections, as on the web:
/// Repeat, with a preview of the next five dates
/// (`tasks/recurrence.py:341-351`); Who; Time and budget; Materials; How to
/// do it. Only
/// the title is required. The title of the form is in the page, under the
/// bar, so that it is never cut; Save and Cancel end the form, and Delete the
/// task comes under them, as on the web. The materials are lines of the form,
/// saved with the task (they are also changed on its page, line by line). On iOS the form opens as
/// a sheet (lot D4), with Cancel on the left of its bar.
class TaskFormScreen extends StatefulWidget implements HcFormScreen {
  const TaskFormScreen({
    super.key,
    required this.homeId,
    this.taskId,
    this.roomId,
    this.itemId,
    this.fill = const {},
  });

  final String homeId;

  /// The room or the item a new task starts attached to, when it is added from
  /// their screen.
  final String? roomId;
  final String? itemId;

  /// `null` for a new task.
  final String? taskId;

  /// The values of **Fill in for me** of the guide, shown on the example home
  /// only: the title, the procedure, the repetition, the first date and the
  /// duration (`prefill_fields` of the web's task form), and the room and the
  /// item a new task starts attached to (`?room=` and `?item=` of its
  /// `get_initial`), when [roomId] and [itemId] do not say them already.
  final GuideFill fill;

  @override
  bool get opensAsSheet => true;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen>
    with AutosaveSheet<TaskFormScreen> {
  final _form = GlobalKey<FormState>();

  @override
  GlobalKey<FormState> get sheetForm => _form;

  /// An existing task saves itself, unless a room, an item or a contractor
  /// is to be added with it: that waits for the button, all or none.
  @override
  bool get existing =>
      widget.taskId != null &&
      _roomId != _newChoice &&
      _itemId != _newChoice &&
      _contractorId != _newChoice;

  @override
  Future<void> writeSheet(Repository repository) async {
    final typed = int.tryParse(_duration.text.trim());
    final minutes = typed == null
        ? null
        : durations.toMinutes(typed, _durationUnit);
    final material = fieldAmount(context, _material);
    final labour = fieldAmount(context, _labour);
    await repository.atomic(() async {
      await repository.updateTask(
        widget.taskId!,
        _input(_roomId, _itemId, _contractorId, minutes),
      );
      await repository.setTaskBudgets(
        widget.taskId!,
        material: material,
        labour: labour,
      );
      await _writeMaterials(repository, widget.taskId!);
    });
  }

  /// Makes the materials of the task those of the lines of the form: a line
  /// without a stock item is the empty line the form offers, and is ignored.
  Future<void> _writeMaterials(Repository repository, String taskId) async {
    final wanted = {
      for (final line in _materials)
        if (line.article != null) line.article!: line.quantity.text,
    };
    for (final id in _listedMaterials.difference(wanted.keys.toSet())) {
      await repository.removeMaterial(taskId, id);
    }
    for (final MapEntry(key: id, value: quantity) in wanted.entries) {
      await repository.saveMaterial(taskId, id, quantity);
    }
    _listedMaterials = wanted.keys.toSet();
  }

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
  bool _loaded = false;

  /// The stock items of the home, the lines of the Materials section, and the
  /// articles the task lists in the data now (a line removed is removed from
  /// the task when it is saved).
  List<ArticleEntry> _articles = const [];
  final _materials = <_MaterialLine>[];
  Set<String> _listedMaterials = {};
  bool _materialsLoaded = false;

  /// Set once the task is read: the sections open on what it holds.
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _roomId = widget.roomId;
      _itemId = widget.itemId;
      _fillPlace();
      if (widget.taskId != null) {
        _load();
      } else {
        _applyFill();
        _ready = true;
        _loadPlaces();
      }
    }
  }

  /// The room and the item of the guide for a new task, as the web's
  /// `get_initial`: an item brings its room (`_loadPlaces`). The lists of
  /// the home then keep only a room and an item of this home.
  void _fillPlace() {
    if (widget.taskId != null || _roomId != null || _itemId != null) return;
    final fill = widget.fill;
    if (!fillsHere(context, widget.homeId, fill)) return;
    if (fill['item'] case final String item) {
      _itemId = item;
    } else if (fill['room'] case final String room) {
      _roomId = room;
    }
  }

  /// The values of the guide that this form takes, each checked as input: a
  /// repetition and a unit the form offers, an interval and a duration that
  /// are numbers.
  void _applyFill() {
    final fill = widget.fill;
    if (!fillsHere(context, widget.homeId, fill)) return;
    for (final (name, controller) in [
      ('title', _title),
      ('procedure', _procedure),
    ]) {
      if (fill[name] case final String value when value.trim().isNotEmpty) {
        controller.text = value;
      }
    }
    if (fill['repeat_mode'] case final String mode
        when recurrence.modes.contains(mode)) {
      _mode = mode;
    }
    if (fill['repeat_unit'] case final String unit
        when recurrence.units.contains(unit)) {
      _unit = unit;
    }
    if (fill['repeat_interval'] case final int interval when interval > 0) {
      _interval.text = '$interval';
    }
    if (fill['due_on'] case final Day due) _due = due;
    if (fill['estimated_minutes'] case final int minutes when minutes > 0) {
      final (value, unit) = durations.split(minutes);
      _duration.text = '$value';
      _durationUnit = unit;
    }
  }

  /// The rooms of the home, the contractors, and the items of the room chosen.
  Future<void> _loadPlaces() async {
    final repository = AppScope.of(context).repository;
    final rooms = await repository.rooms(widget.homeId);
    final contractors = await repository.contractors(widget.homeId);
    final home = await repository.home(widget.homeId);
    final articles = await repository.articles(widget.homeId);
    final listed = widget.taskId == null
        ? const <MaterialEntry>[]
        : await repository.materialsOf(widget.taskId!);
    var roomId = _roomId;
    if (roomId == null && _itemId != null) {
      roomId = (await repository.item(_itemId!))?.roomId;
    }
    // A new task starts only on a room and an item of this home (the web's
    // `_pick` reads them in the home).
    var itemId = _itemId;
    if (widget.taskId == null &&
        roomId != null &&
        roomId != _newChoice &&
        !rooms.any((r) => r.id == roomId)) {
      roomId = itemId = null;
    }
    final items = roomId == null || roomId == _newChoice
        ? <ItemRow>[]
        : await repository.itemsOf(roomId);
    if (widget.taskId == null &&
        itemId != null &&
        itemId != _newChoice &&
        !items.any((i) => i.id == itemId)) {
      itemId = null;
    }
    if (!mounted) return;
    setState(() {
      _itemId = itemId;
      _currency = home?.currency ?? '';
      _rooms = rooms;
      _contractors = contractors;
      _roomId = roomId;
      _items = items;
      _articles = articles;
      _materialsLoaded = true;
      if (_materials.isEmpty) {
        for (final entry in listed) {
          _materials.add(
            _MaterialLine(entry.article.id, entry.quantity.toString()),
          );
        }
        _listedMaterials = {for (final entry in listed) entry.article.id};
        // One empty line is offered, as on the web.
        if (_materials.isEmpty) _materials.add(_MaterialLine(null, '1'));
      }
    });
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final task = await repository.task(widget.taskId!);
    if (task == null || !mounted) return;
    // The date of the form follows the open occurrence, so that saving after
    // a Done does not move the next one back.
    final open = await repository.openOccurrencesOf(widget.taskId!);
    if (!mounted) return;
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
          : moneyFieldText(
              Localizations.localeOf(context).toLanguageTag(),
              budget.readMoney(task.materialBudget!),
            );
      _labour.text = task.labourBudget == null
          ? ''
          : moneyFieldText(
              Localizations.localeOf(context).toLanguageTag(),
              budget.readMoney(task.labourBudget!),
            );
      _mode = task.repeatMode;
      _unit = task.repeatUnit;
      _season = task.season;
      _priority = task.priority;
      _roomId = task.roomId;
      _itemId = task.itemId;
      _contractorId = task.contractorId;
      final due = open.isEmpty ? null : open.first.dueOn;
      _due = due == null ? null : Day.parse(due);
      _applyFill();
      _ready = true;
    });
    await _loadPlaces();
    sheetLoaded();
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
    for (final line in _materials) {
      line.quantity.dispose();
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
    cancelAutosave();
    if (!_form.currentState!.validate()) return;
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    final repository = state.repository;
    final typed = int.tryParse(_duration.text.trim());
    final minutes = typed == null
        ? null
        : durations.toMinutes(typed, _durationUnit);
    final material = fieldAmount(context, _material);
    final labour = fieldAmount(context, _labour);
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
        await repository.setTaskBudgets(id, material: material, labour: labour);
        await _writeMaterials(repository, id);
      });
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
      return;
    }
    await state.refresh();
    navigator.pop(true);
  }

  /// Deleted: the form and the page of the task both close.
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
      navigator.pop(false);
    }
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

  /// Title, Room (with a room added in place), Item, Due date: the card the
  /// web's form opens with.
  Widget _placeAndDate(AppLocalizations l10n) {
    final newRoom = _roomId == _newChoice;
    return HcCard(
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
          hcChoice<String?>(
            l10n.room,
            newRoom || _rooms.any((r) => r.id == _roomId) ? _roomId : null,
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
                AppScope.of(context).repository.itemsOf(value).then((items) {
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
              _itemId == _newChoice || _items.any((i) => i.id == _itemId)
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
          HcDateField(
            key: const Key('task-due'),
            label: l10n.taskDueDate,
            value: _due,
            noDate: l10n.todayNoDate,
            onChanged: (day) {
              setState(() => _due = day);
              sheetChanged(now: true);
            },
          ),
        ],
      ),
    );
  }

  /// Repeat: the rule, the season, how long before its date the task stays
  /// hidden, and the next dates it gives.
  Widget _repeat(AppLocalizations l10n, bool wide, List<Day> next) =>
      HcFoldSection(
        key: const Key('task-section-repeat'),
        title: l10n.repeat,
        open:
            _mode != recurrence.once ||
            _season.isNotEmpty ||
            _hide.text.trim() != '0',
        children: [
          hcChoice<String>(
            l10n.repeat,
            _mode,
            [
              (recurrence.once, l10n.repeatOnce),
              (recurrence.fixed, l10n.repeatFixed),
              (recurrence.afterLast, l10n.repeatAfterLast),
            ],
            (value) => setState(() => _mode = value),
            key: const Key('task-repeat'),
          ),
          if (_mode != recurrence.once)
            HcField(
              label: l10n.repeatEvery,
              // A number and its unit on one line, as `.field-pair`; with a
              // large text, the unit goes under the number.
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
                    HcSelect<String>(
                      value: _unit,
                      choices: [
                        (recurrence.dayUnit, l10n.unitDays),
                        (recurrence.weekUnit, l10n.unitWeeks),
                        (recurrence.monthUnit, l10n.unitMonths),
                        (recurrence.yearUnit, l10n.unitYears),
                      ],
                      onChanged: (value) => setState(() => _unit = value),
                    ),
                  ),
                ],
              ),
            ),
          HcField(
            label: l10n.season,
            child: HcSelect<String>(
              value: _season,
              choices: [
                ('', l10n.seasonWholeYear),
                (recurrence.spring, l10n.seasonSpring),
                (recurrence.summer, l10n.seasonSummer),
                (recurrence.autumn, l10n.seasonAutumn),
                (recurrence.winter, l10n.seasonWinter),
                if (_season == recurrence.custom)
                  (recurrence.custom, l10n.seasonCustom),
              ],
              onChanged: (value) => setState(() => _season = value),
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
              return n == null || n < 0 || n > 365 ? l10n.errHideDays : null;
            },
          ),
          fieldHelp(l10n.taskHideDaysHelp),
          if (next.isNotEmpty) ...[
            HcSectionHeading(l10n.taskNextDates),
            HcCardList(
              children: [
                for (final day in next)
                  HcRow(title: l10n.dueOn(formatDay(context, day))),
              ],
            ),
          ],
        ],
      );

  /// Who: the priority and the contractor, with a contractor added in place.
  Widget _who(AppLocalizations l10n) => HcFoldSection(
    key: const Key('task-section-who'),
    title: l10n.taskWho,
    open: _priority != 'normal' || _contractorId != null,
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
          [('', ''), for (final t in trades) (t, tradeLabel(l10n, t))],
          (value) => setState(() => _newContractorTrade = value),
          key: const Key('task-new-contractor-trade'),
        ),
        if (_newContractorTrade == 'other')
          hcText(
            l10n.contractorTradeOther,
            _newContractorOther,
            key: const Key('task-new-contractor-other'),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l10n.errTradeOther : null,
          ),
      ],
    ],
  );

  /// Time and budget: the duration, then the budgets of labour and material,
  /// in the order of the web.
  Widget _timeAndBudget(AppLocalizations l10n, bool wide) => HcFoldSection(
    key: const Key('task-section-budget'),
    title: l10n.taskTimeAndBudget,
    open:
        _duration.text.trim().isNotEmpty ||
        _labour.text.trim().isNotEmpty ||
        _material.text.trim().isNotEmpty,
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
                child: HcSelect<String>(
                  key: const Key('task-duration-unit'),
                  value: _durationUnit,
                  choices: [
                    (durations.minute, l10n.unitMinutes),
                    (durations.hour, l10n.unitHours),
                    (durations.day, l10n.unitDays),
                    (durations.week, l10n.unitWeeks),
                    (durations.month, l10n.unitMonths),
                    (durations.year, l10n.unitYears),
                  ],
                  onChanged: (value) => setState(() => _durationUnit = value),
                ),
              ),
            ),
          ],
        ),
      ),
      hcAmount(
        context,
        l10n.labourBudget,
        _labour,
        key: const Key('task-labour-budget'),
      ),
      ListenableBuilder(
        listenable: Listenable.merge([for (final l in _materials) l.quantity]),
        builder: (context, _) => _materialBudget(l10n),
      ),
      fieldHelp(l10n.taskBudgetHelp(_currency)),
    ],
  );

  /// What the stock items of the lines plan each time, at their unit prices
  /// (`stock_plan`, web ADR 0062): a line without a stock item or with a
  /// quantity that is not one counts for nothing.
  budget.StockPlan get _stockPlan {
    final byId = {for (final a in _articles) a.article.id: a.article};
    return budget.stockPlan([
      for (final line in _materials)
        if (byId[line.article] case final article?)
          if (stock.parseQuantity(line.quantity.text) case final quantity?
              when quantity > stock.zero)
            (
              quantity,
              article.unitPrice == null
                  ? null
                  : stock.readQuantity(article.unitPrice!),
            ),
    ]);
  }

  /// The material budget: typed, or calculated from the priced stock items
  /// of the task (`tasks/_material_budget.html`, web ADR 0081). Calculated,
  /// the field is not shown and the amount typed stays as it is, sent back
  /// unchanged when the task is saved: it counts again if the priced items
  /// go.
  Widget _materialBudget(AppLocalizations l10n) {
    final plan = _stockPlan;
    if (plan.priced == 0) {
      return hcAmount(
        context,
        l10n.materialBudget,
        _material,
        key: const Key('task-material-budget'),
      );
    }
    return Padding(
      key: const Key('task-material-from-stock'),
      padding: const EdgeInsets.only(bottom: HcSpace.s4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${l10n.materialBudget} ', style: HcText.fieldLabel),
            TextSpan(
              text: l10n.taskMaterialFromStockField(
                moneyIn(context, _currency, plan.amount),
              ),
            ),
          ],
        ),
        style: HcText.body,
      ),
    );
  }

  /// Materials: the stock items the task needs, a line each (the stock item
  /// and the quantity), as the web's section; one empty line is offered, `+`
  /// adds a line and the button of a line removes it, up to
  /// [stock.maxMaterialsPerTask]. Marking the task done takes the quantities
  /// from the stock. A stock item is added in Rooms, Stock, not in the form.
  Widget _materialsSection(AppLocalizations l10n) {
    final taken = {
      for (final line in _materials)
        if (line.article != null) line.article!,
    };
    final full = _materials.length >= stock.maxMaterialsPerTask;
    return HcFoldSection(
      key: const Key('task-section-materials'),
      title: l10n.materials,
      open: taken.isNotEmpty,
      children: [
        if (_articles.isEmpty)
          Text(l10n.materialsNoArticle, style: HcText.bodySmall)
        else ...[
          fieldHelp(l10n.materialsFormHelp),
          for (final (i, line) in _materials.indexed)
            Padding(
              key: ObjectKey(line),
              padding: const EdgeInsets.only(bottom: HcSpace.s2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcChoice<String?>(
                    l10n.materialArticle,
                    line.article,
                    [
                      (null, '—'),
                      for (final a in _articles)
                        if (a.article.id == line.article ||
                            !taken.contains(a.article.id))
                          (a.article.id, a.article.name),
                    ],
                    (v) => setState(() => line.article = v),
                    key: Key('task-material-article-$i'),
                  ),
                  hcText(
                    l10n.movementQuantity,
                    line.quantity,
                    key: Key('task-material-quantity-$i'),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    sentences: false,
                    validator: (v) {
                      if (line.article == null) return null;
                      final value = stock.parseQuantity(v ?? '');
                      if (value == null) return l10n.errQuantityInvalid;
                      return value <= stock.zero
                          ? l10n.errQuantityNotPositive
                          : null;
                    },
                  ),
                  if (_materials.length > 1 || line.article != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Semantics(
                        label: l10n.removeMaterialLine,
                        button: true,
                        excludeSemantics: true,
                        child: TextButton(
                          key: Key('task-material-remove-$i'),
                          onPressed: () {
                            setState(() {
                              final removed = _materials.removeAt(i);
                              removed.quantity.dispose();
                              if (_materials.isEmpty) {
                                _materials.add(_MaterialLine(null, '1'));
                              }
                            });
                            sheetChanged(now: true);
                          },
                          child: Text(l10n.remove),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (full)
            Text(
              l10n.materialsLimit(stock.maxMaterialsPerTask),
              style: HcText.bodySmall,
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const Key('task-material-add'),
                icon: const HcIcon(HcIcons.add, color: HcColors.primary),
                onPressed: () =>
                    setState(() => _materials.add(_MaterialLine(null, '1'))),
                label: Text(l10n.addMaterialLine),
              ),
            ),
        ],
      ],
    );
  }

  /// How to do it: the procedure and the notes.
  Widget _howTo(AppLocalizations l10n) => HcFoldSection(
    key: const Key('task-section-how'),
    title: l10n.taskProcedure,
    open: _procedure.text.trim().isNotEmpty || _notes.text.trim().isNotEmpty,
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
          key: const Key('task-notes'),
          controller: _notes,
          minLines: 2,
          maxLines: 6,
        ),
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
    // The text size of the phone at which a pair of fields stacks.
    final wide = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final title = widget.taskId == null ? l10n.taskAddTitle : l10n.taskEditTask;
    return HcScaffold(
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      title: title,
      actions: [Center(child: savedStatus())],
      body: Form(
        key: _form,
        onChanged: sheetChanged,
        child: HcScreenList(
          children: [
            const SizedBox(height: HcSpace.s2),
            // The sections open on what the task holds: they are drawn once
            // it is read.
            if (_ready) ...[
              _placeAndDate(l10n),
              _repeat(l10n, wide, _preview(hemisphere)),
              _who(l10n),
              _timeAndBudget(l10n, wide),
              if (_materialsLoaded) _materialsSection(l10n),
              _howTo(l10n),
              const SizedBox(height: HcSpace.s4),
              FilledButton(
                key: const Key('task-save'),
                onPressed: _save,
                child: Text(
                  widget.taskId == null ? l10n.taskAddSubmit : l10n.save,
                ),
              ),
              const SizedBox(height: HcSpace.s2),
              OutlinedButton(
                key: const Key('task-cancel'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              if (_task != null && writable)
                HcDeleteButton(
                  key: const Key('task-delete'),
                  label: l10n.taskDelete,
                  onPressed: _delete,
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

/// A line of the Materials section: a stock item (none on the empty line) and
/// the quantity typed.
class _MaterialLine {
  _MaterialLine(this.article, String quantity)
    : quantity = TextEditingController(text: quantity);

  String? article;
  final TextEditingController quantity;
}
