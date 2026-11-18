// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import '../l10n/app_localizations.dart';
import 'autosave.dart';
import 'budget_parts.dart';
import 'choices.dart';
import 'equipment_screen.dart';
import 'home_selector.dart';
import 'item_screens.dart';
import 'messages.dart';
import 'parts.dart';
import 'photos.dart';
import 'report_screens.dart';
import 'guide_screens.dart';
import 'state.dart';
import 'stock_format.dart';
import 'stock_screens.dart';
import 'task_screen.dart';
import 'templates_screen.dart';
import 'help_button.dart';

/// Rooms (docs/spec.md, "Screens of v1"): the rooms of the current home in the
/// household's order, each with its kind and how many items it holds; its
/// second tab, every item of the home (lib/ui/equipment_screen.dart), and its
/// third, the stock of the home (lib/ui/stock_screens.dart), as the web's
/// section Rooms has the tabs Rooms, Equipment and Stock.
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.current;
    final writable = home != null && home.archivedAt == null;
    final tabs = RoomsTabs(
      current: _tab,
      onSelect: (i) => setState(() => _tab = i),
    );
    return HcScaffold(
      title: switch (_tab) {
        0 => l10n.navRooms,
        1 => l10n.equipmentTab,
        _ => l10n.stock,
      },
      brand: true,
      belowTitle: const HomeSelector(),
      actions: const [HelpButton(page: HelpPages.rooms)],
      body: home == null
          ? const SizedBox.shrink()
          : _tab == 1
          ? EquipmentList(
              key: ValueKey('equipment-${home.id}'),
              home: home,
              tabs: tabs,
            )
          : _tab == 2
          ? StockList(key: ValueKey('stock-${home.id}'), home: home, tabs: tabs)
          : DataView<(List<RoomRow>, Map<String, int>)>(
              key: ValueKey(home.id),
              load: (r) async =>
                  (await r.rooms(home.id), await r.itemCounts(home.id)),
              builder: (context, data) {
                final (rooms, counts) = data;
                return HcScreenList(
                  children: [
                    tabs,
                    if (rooms.isEmpty)
                      HcEmpty(l10n.roomsEmpty)
                    else
                      HcCardList(
                        children: [
                          for (final room in rooms)
                            HcRow(
                              title: room.name,
                              text: l10n.roomSummary(
                                roomKindLabel(l10n, room.kind),
                                counts[room.id] ?? 0,
                              ),
                              onTap: () => Navigator.of(context).push(
                                hcRoute(
                                  RoomScreen(homeId: home.id, roomId: room.id),
                                ),
                              ),
                            ),
                        ],
                      ),
                    // After the list, secondary and as wide as its label,
                    // as on the web (`rooms/room_list.html`).
                    if (writable)
                      HcAddButton(
                        key: const Key('room-add'),
                        label: l10n.addRoom,
                        primary: false,
                        block: false,
                        onPressed: () =>
                            Navigator.of(context)
                                .push(hcRoute(RoomFormScreen(homeId: home.id))),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

/// The tasks of a room or an item, each with its due date; and the buttons
/// that add one.
class TaskRows extends StatelessWidget {
  const TaskRows({
    super.key,
    required this.homeId,
    this.roomId,
    this.itemId,
    required this.writable,
  });

  final String homeId;
  final String? roomId;
  final String? itemId;
  final bool writable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<List<TaskEntry>>(
      load: (r) => r.tasksOf(roomId: roomId, itemId: itemId),
      builder: (context, entries) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HcSectionHeading(l10n.tasks),
          if (entries.isEmpty)
            HcEmpty(l10n.tasksEmpty)
          else
            HcCardList(
              children: [
                for (final entry in entries)
                  HcRow(
                    title: entry.task.title,
                    // The date as plain text under the title, as the web's
                    // rows of a room and of an item (`rooms/room_detail.html`).
                    text: entry.occurrence == null
                        ? null
                        : entry.dueOn == null
                        ? l10n.todayNoDate
                        : formatDay(context, entry.dueOn!),
                    onTap: () => Navigator.of(context).push(
                      hcRoute(
                        TaskScreen(homeId: homeId, taskId: entry.task.id),
                      ),
                    ),
                  ),
              ],
            ),
          // After the tasks, secondary and the width of the column, as on
          // the web (`rooms/room_detail.html`, `rooms/item_detail.html`).
          if (writable) ...[
            HcAddButton(
              key: const Key('task-add'),
              label: l10n.addTask,
              primary: false,
              gap: entries.isEmpty ? HcSpace.s2 : HcSpace.s3,
              onPressed: () => Navigator.of(context).push(
                hcRoute(
                  TaskScreen(homeId: homeId, roomId: roomId, itemId: itemId),
                ),
              ),
            ),
            HcAddButton(
              key: const Key('task-from-template'),
              label: l10n.addFromTemplate,
              primary: false,
              onPressed: () => Navigator.of(
                context,
              ).push(hcRoute(TemplatesScreen(homeId: homeId, roomId: roomId))),
            ),
          ],
        ],
      ),
    );
  }
}

/// A room (`rooms/room_detail.html`): what it is and Report a problem, its
/// memory, its photos, its items and its tasks.
class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key, required this.homeId, required this.roomId});

  final String homeId;
  final String roomId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.homes.where((h) => h.id == homeId).firstOrNull;
    final writable = home != null && home.archivedAt == null;
    return DataView<(RoomRow?, List<ItemRow>, ArticleEntry?)>(
      load: (r) async {
        final room = await r.room(roomId);
        final paint = room?.paintArticleId == null
            ? null
            : await r.article(room!.paintArticleId!);
        return (
          room,
          await r.itemsOf(roomId),
          paint == null
              ? null
              : ArticleEntry(paint, await r.stockLevel(paint.id)),
        );
      },
      builder: (context, data) {
        final (room, items, paint) = data;
        if (room == null) {
          // Deleted meanwhile (here or on another phone): back to the list.
          return HcScaffold(
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        // The short values of the memory on lines of label and value, in
        // the order of the web; its notes, a long text, under their label.
        final memory = [
          (l10n.paintColour, room.paintColour),
          (l10n.paintBrand, room.paintBrand),
          (l10n.paintReference, room.paintReference),
          (l10n.paintBatch, room.paintBatch),
        ].where((m) => m.$2.isNotEmpty).toList();
        final coverings = [
          (l10n.floorCovering, room.floorCovering),
          (l10n.wallCovering, room.wallCovering),
        ].where((m) => m.$2.isNotEmpty).toList();
        void open(Widget screen) => Navigator.of(context).push(hcRoute(screen));
        return HcScaffold(
          belowTitle: ExampleHomeBanner(homeId: homeId),
          title: room.name,
          actions: actionsOrHelp([
            if (writable)
              HcBarAction(
                label: l10n.edit,
                onPressed: () =>
                    open(RoomFormScreen(homeId: homeId, roomId: roomId)),
              ),
          ], HelpPages.room),
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              // The head of the record (`rooms/room_detail.html`): the type
              // on a line of label and value, the notes under their label,
              // then the action row; Edit is the action of the bar.
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HcValueList(
                      children: [
                        HcValueRow(
                          l10n.fieldType,
                          roomKindLabel(l10n, room.kind),
                        ),
                      ],
                    ),
                    if (room.notes.isNotEmpty) ...[
                      const SizedBox(height: HcSpace.s3),
                      HcFact(l10n.fieldNotes, factText(room.notes)),
                    ],
                    RecordActions(
                      children: [
                        OutlinedButton(
                          key: const Key('room-report'),
                          onPressed: () => open(
                            ReportFormScreen(homeId: homeId, roomId: roomId),
                          ),
                          child: Text(l10n.reportProblem),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // The sections in the order of the web: memory, photos, items,
              // tasks. The stock of a room is a web feature (ADR 0011).
              HcSectionHeading(l10n.roomMemory),
              HcCard(
                key: const Key('room-memory'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (memory.isEmpty &&
                        coverings.isEmpty &&
                        paint == null &&
                        room.memoryNotes.isEmpty)
                      Text(l10n.roomMemoryEmpty, style: HcText.rowText)
                    else if (memory.isNotEmpty ||
                        coverings.isNotEmpty ||
                        paint != null)
                      HcValueList(
                        children: [
                          for (final (label, value) in memory)
                            HcValueRow(label, value),
                          // The paint left over, from the stock (lot 3b),
                          // after the batch as on the web.
                          if (paint != null)
                            HcValueRow(
                              l10n.paintArticle,
                              '',
                              child: HcValueLink(
                                '${paint.article.name} · ${amountOf(l10n, localeOf(context), paint.article, paint.level)}',
                                key: const Key('room-paint'),
                                onTap: () => open(
                                  ArticleScreen(
                                    homeId: homeId,
                                    articleId: paint.article.id,
                                  ),
                                ),
                              ),
                            ),
                          for (final (label, value) in coverings)
                            HcValueRow(label, value),
                        ],
                      ),
                    if (room.memoryNotes.isNotEmpty) ...[
                      if (memory.isNotEmpty ||
                          coverings.isNotEmpty ||
                          paint != null)
                        const SizedBox(height: HcSpace.s3),
                      HcFact(l10n.memoryNotes, factText(room.memoryNotes)),
                    ],
                    if (writable)
                      RecordActions(
                        children: [
                          OutlinedButton(
                            key: const Key('room-memory-edit'),
                            onPressed: () => open(
                              RoomFormScreen(
                                homeId: homeId,
                                roomId: roomId,
                                memory: true,
                              ),
                            ),
                            child: Text(l10n.editMemory),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              PhotoSection(homeId: homeId, roomId: roomId, writable: writable),
              HcSectionHeading(l10n.items),
              if (items.isEmpty)
                HcEmpty(l10n.itemsEmpty)
              else
                HcCardList(
                  children: [
                    for (final item in items)
                      HcRow(
                        title: item.name,
                        text: [
                          item.brand,
                          item.model,
                        ].where((t) => t.isNotEmpty).join(' · '),
                        pills: [
                          if (Repository.warrantyState(
                                item,
                                state.repository.today(),
                              ) ==
                              'active')
                            HcPill(l10n.itemWarranty, tone: HcPillTone.sand),
                        ],
                        onTap: () =>
                            open(ItemScreen(homeId: homeId, itemId: item.id)),
                      ),
                  ],
                ),
              if (writable) ...[
                const SizedBox(height: HcSpace.s3),
                OutlinedButton(
                  key: const Key('item-add'),
                  onPressed: () =>
                      open(ItemFormScreen(homeId: homeId, roomId: roomId)),
                  child: Text(l10n.addItem),
                ),
              ],
              TaskRows(homeId: homeId, roomId: roomId, writable: writable),
            ],
          ),
        );
      },
    );
  }
}

/// The action row of a record page (design/patterns.md of the web, Record
/// page): buttons as wide as their label, on lines that wrap, never stacked
/// to the full width.
class RecordActions extends StatelessWidget {
  const RecordActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: HcSpace.s3),
    child: Wrap(
      spacing: HcSpace.s2,
      runSpacing: HcSpace.s2,
      children: children,
    ),
  );
}

/// The form of a room, as the web has two: its name, kind and notes (Edit),
/// or its memory, what was used and fitted in it (Edit the memory,
/// `rooms/room_memory_form.html`).
class RoomFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const RoomFormScreen({
    super.key,
    required this.homeId,
    this.roomId,
    this.memory = false,
    this.fill = const {},
  });

  final String homeId;

  /// The values of **Fill in for me** of the guide: `name` and `kind`, shown
  /// on the example home only.
  final GuideFill fill;

  /// `null` for a new room.
  final String? roomId;

  /// Whether the form is the memory of the room (an existing room only).
  final bool memory;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen>
    with AutosaveSheet<RoomFormScreen> {
  final _form = GlobalKey<FormState>();

  @override
  GlobalKey<FormState> get sheetForm => _form;

  @override
  bool get existing => widget.roomId != null;

  @override
  Future<void> writeSheet(Repository repository) async {
    await repository.updateRoom(widget.roomId!, _input());
    await repository.setPaintArticle(widget.roomId!, _paintArticle);
  }

  final _name = TextEditingController();
  final _notes = TextEditingController();
  final _paintColour = TextEditingController();
  final _paintBrand = TextEditingController();
  final _paintReference = TextEditingController();
  final _paintBatch = TextEditingController();
  final _floor = TextEditingController();
  final _wall = TextEditingController();
  final _memoryNotes = TextEditingController();
  String _kind = 'other';
  bool _loaded = false;

  /// The stock article of the paint left over (`paint_article`), and the
  /// articles of the home to choose it from.
  String? _paintArticle;
  List<ArticleEntry> _articles = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final repository = AppScope.of(context).repository;
    repository.articles(widget.homeId).then((articles) {
      if (mounted) setState(() => _articles = articles);
    });
    if (widget.roomId == null) {
      _applyFill();
      return;
    }
    repository.room(widget.roomId!).then((room) {
      if (room == null || !mounted) return;
      final input = RoomInput.of(room);
      setState(() {
        _paintArticle = room.paintArticleId;
        _name.text = input.name;
        _kind = input.kind;
        _notes.text = input.notes;
        _paintColour.text = input.paintColour;
        _paintBrand.text = input.paintBrand;
        _paintReference.text = input.paintReference;
        _paintBatch.text = input.paintBatch;
        _floor.text = input.floorCovering;
        _wall.text = input.wallCovering;
        _memoryNotes.text = input.memoryNotes;
        _applyFill();
      });
      sheetLoaded();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _notes,
      _paintColour,
      _paintBrand,
      _paintReference,
      _paintBatch,
      _floor,
      _wall,
      _memoryNotes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The values of the guide that this form takes (`prefill_fields` of the
  /// web's room form): a type the list has, a name that is not empty.
  void _applyFill() {
    final fill = widget.fill;
    if (!fillsHere(context, widget.homeId, fill)) return;
    if (fill['kind'] case final String kind when roomKinds.contains(kind)) {
      _kind = kind;
    }
    if (fill['name'] case final String name when name.trim().isNotEmpty) {
      _name.text = name;
    }
  }

  /// Choosing a type fills the name in with the label of the type, as the web
  /// does, while the name is empty or still the label of the previous type;
  /// a name that was typed stays.
  void _chooseKind(String kind) {
    final l10n = AppLocalizations.of(context);
    final typed = _name.text.trim();
    final automatic = typed.isEmpty || typed == roomKindLabel(l10n, _kind);
    setState(() {
      _kind = kind;
      if (automatic && kind != 'other') _name.text = roomKindLabel(l10n, kind);
    });
    sheetChanged();
  }

  RoomInput _input() => RoomInput(
    name: _name.text,
    kind: _kind,
    notes: _notes.text,
    paintColour: _paintColour.text,
    paintBrand: _paintBrand.text,
    paintReference: _paintReference.text,
    paintBatch: _paintBatch.text,
    floorCovering: _floor.text,
    wallCovering: _wall.text,
    memoryNotes: _memoryNotes.text,
  );

  Future<void> _save() async {
    cancelAutosave();
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(context, (r) async {
      if (widget.roomId == null) {
        final input = _input();
        final position = (await r.rooms(widget.homeId)).length;
        final id = await r.createRoom(
          widget.homeId,
          name: input.name,
          kind: input.kind,
          position: position,
        );
        await r.updateRoom(id, input);
        await r.setPaintArticle(id, _paintArticle);
      } else {
        await r.updateRoom(widget.roomId!, _input());
        await r.setPaintArticle(widget.roomId!, _paintArticle);
      }
    });
    if (saved) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteRoom,
      body: l10n.deleteRoomBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(context, (r) => r.deleteRoom(widget.roomId!))) {
      // The form and the room it was opened from.
      navigator.pop();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      title: widget.memory
          ? l10n.roomMemory
          : widget.roomId == null
          ? l10n.newRoom
          : l10n.editRoom,
      actions: [
        Center(child: savedStatus()),
        HcBarAction(label: l10n.save, onPressed: _save),
      ],
      body: Form(
        key: _form,
        onChanged: sheetChanged,
        child: HcScreenList(
          children: [
            const SizedBox(height: HcSpace.s2),
            if (!widget.memory)
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    hcChoice<String>(
                      l10n.fieldType,
                      _kind,
                      [for (final k in roomKinds) (k, roomKindLabel(l10n, k))],
                      _chooseKind,
                      key: const Key('room-kind'),
                    ),
                    fieldHelp(l10n.roomKindHelp),
                    hcText(
                      l10n.fieldName,
                      _name,
                      key: const Key('room-name'),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? l10n.errTitleRequired
                          : null,
                    ),
                    fieldHelp(l10n.roomNameHelp),
                    hcText(l10n.fieldNotes, _notes, minLines: 2, maxLines: 6),
                  ],
                ),
              ),
            if (widget.memory)
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    hcText(l10n.paintColour, _paintColour),
                    hcText(l10n.paintBrand, _paintBrand),
                    hcText(l10n.paintReference, _paintReference),
                    hcText(l10n.paintBatch, _paintBatch),
                    if (_articles.isNotEmpty)
                      hcChoice<String?>(
                        l10n.paintArticle,
                        _articles.any((a) => a.article.id == _paintArticle)
                            ? _paintArticle
                            : null,
                        [
                          (null, l10n.paintArticleNone),
                          for (final a in _articles)
                            (a.article.id, a.article.name),
                        ],
                        (v) => setState(() => _paintArticle = v),
                        key: const Key('room-paint-article'),
                      ),
                    hcText(l10n.floorCovering, _floor),
                    hcText(l10n.wallCovering, _wall),
                    hcText(
                      l10n.memoryNotes,
                      _memoryNotes,
                      minLines: 2,
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            if (widget.roomId != null && !widget.memory) ...[
              HcDeleteButton(
                key: const Key('room-delete'),
                label: l10n.deleteRoom,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
