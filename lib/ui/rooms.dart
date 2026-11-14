// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import '../l10n/app_localizations.dart';
import 'choices.dart';
import 'home_selector.dart';
import 'item_screens.dart';
import 'messages.dart';
import 'parts.dart';
import 'photos.dart';
import 'state.dart';
import 'task_screen.dart';
import 'templates_screen.dart';

/// Rooms (docs/spec.md, "Screens of v1"): the rooms of the current home in the
/// household's order, each with its kind and how many items it holds.
class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.current;
    final writable = home != null && home.archivedAt == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navRooms),
        actions: const [HomeSelector()],
      ),
      floatingActionButton: writable
          ? FloatingActionButton.extended(
              key: const Key('room-add'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RoomFormScreen(homeId: home.id),
                ),
              ),
              icon: const HcIcon(HcIcons.add),
              label: Text(l10n.addRoom),
            )
          : null,
      body: home == null
          ? const SizedBox.shrink()
          : DataView<(List<RoomRow>, Map<String, int>)>(
              key: ValueKey(home.id),
              load: (r) async =>
                  (await r.rooms(home.id), await r.itemCounts(home.id)),
              builder: (context, data) {
                final (rooms, counts) = data;
                return HcScreenList(
                  children: [
                    const SizedBox(height: HcSpace.s2),
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
                                MaterialPageRoute<void>(
                                  builder: (_) => RoomScreen(
                                    homeId: home.id,
                                    roomId: room.id,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
    final repository = AppScope.of(context).repository;
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
                    pills: [
                      if (entry.occurrence != null)
                        duePill(
                          context,
                          entry.dueOn,
                          repository.today(),
                          postponed: entry.occurrence!.status == 'postponed',
                        ),
                    ],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            TaskScreen(homeId: homeId, taskId: entry.task.id),
                      ),
                    ),
                  ),
              ],
            ),
          if (writable) ...[
            const SizedBox(height: HcSpace.s3),
            Wrap(
              spacing: HcSpace.s2,
              runSpacing: HcSpace.s2,
              children: [
                OutlinedButton(
                  key: const Key('task-add'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TaskScreen(
                        homeId: homeId,
                        roomId: roomId,
                        itemId: itemId,
                      ),
                    ),
                  ),
                  child: Text(l10n.newTask),
                ),
                OutlinedButton(
                  key: const Key('task-from-template'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TemplatesScreen(roomId: roomId),
                    ),
                  ),
                  child: Text(l10n.addFromTemplate),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A room: what it is, its memory, its items, its photos and its tasks.
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
    return DataView<(RoomRow?, List<ItemRow>)>(
      load: (r) async => (await r.room(roomId), await r.itemsOf(roomId)),
      builder: (context, data) {
        final (room, items) = data;
        if (room == null) {
          // Deleted meanwhile (here or on another phone): back to the list.
          return Scaffold(
            appBar: AppBar(),
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        final memory = [
          (l10n.paintColour, room.paintColour),
          (l10n.paintBrand, room.paintBrand),
          (l10n.paintReference, room.paintReference),
          (l10n.paintBatch, room.paintBatch),
          (l10n.floorCovering, room.floorCovering),
          (l10n.wallCovering, room.wallCovering),
          (l10n.memoryNotes, room.memoryNotes),
        ].where((m) => m.$2.isNotEmpty).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(room.name),
            actions: [
              if (writable)
                HcBarAction(
                  label: l10n.edit,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          RoomFormScreen(homeId: homeId, roomId: roomId),
                    ),
                  ),
                ),
            ],
          ),
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HcFact(
                      l10n.fieldType,
                      factText(roomKindLabel(l10n, room.kind)),
                    ),
                    if (room.notes.isNotEmpty)
                      HcFact(l10n.fieldNotes, factText(room.notes)),
                  ],
                ),
              ),
              HcSectionHeading(l10n.roomMemory),
              HcCard(
                child: memory.isEmpty
                    ? Text(l10n.roomMemoryEmpty, style: HcText.rowText)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (label, value) in memory)
                            HcFact(label, factText(value)),
                        ],
                      ),
              ),
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
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ItemScreen(homeId: homeId, itemId: item.id),
                          ),
                        ),
                      ),
                  ],
                ),
              if (writable) ...[
                const SizedBox(height: HcSpace.s3),
                OutlinedButton(
                  key: const Key('item-add'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ItemFormScreen(homeId: homeId, roomId: roomId),
                    ),
                  ),
                  child: Text(l10n.addItem),
                ),
              ],
              PhotoSection(homeId: homeId, roomId: roomId, writable: writable),
              TaskRows(homeId: homeId, roomId: roomId, writable: writable),
            ],
          ),
        );
      },
    );
  }
}

/// The form of a room: its name, kind and notes, and its memory (what was
/// used and fitted in it).
class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key, required this.homeId, this.roomId});

  final String homeId;

  /// `null` for a new room.
  final String? roomId;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _form = GlobalKey<FormState>();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded || widget.roomId == null) return;
    _loaded = true;
    AppScope.of(context).repository.room(widget.roomId!).then((room) {
      if (room == null || !mounted) return;
      final input = RoomInput.of(room);
      setState(() {
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
      });
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
      } else {
        await r.updateRoom(widget.roomId!, _input());
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomId == null ? l10n.newRoom : l10n.editRoom),
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
                  hcText(
                    l10n.fieldName,
                    _name,
                    key: const Key('room-name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcChoice<String>(
                    l10n.fieldType,
                    _kind,
                    [for (final k in roomKinds) (k, roomKindLabel(l10n, k))],
                    (v) => setState(() => _kind = v),
                    key: const Key('room-kind'),
                  ),
                  hcText(l10n.fieldNotes, _notes, minLines: 2, maxLines: 6),
                ],
              ),
            ),
            HcSectionHeading(l10n.roomMemory),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcText(l10n.paintColour, _paintColour),
                  hcText(l10n.paintBrand, _paintBrand),
                  hcText(l10n.paintReference, _paintReference),
                  hcText(l10n.paintBatch, _paintBatch),
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
            if (widget.roomId != null) ...[
              const SizedBox(height: HcSpace.s4),
              OutlinedButton(
                key: const Key('room-delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HcColors.danger,
                ),
                onPressed: _delete,
                child: Text(l10n.deleteRoom),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
