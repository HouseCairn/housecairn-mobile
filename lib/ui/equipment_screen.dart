// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'item_screens.dart';
import 'messages.dart';
import 'parts.dart';

/// Equipment, the second tab of Rooms (`rooms/item_list.html`): every item
/// of the current home, all rooms together, by room then name, each with its
/// room, its brand, its next task and its warranty; filtered by a room and by
/// words of its name, brand, model or serial number.
class EquipmentList extends StatefulWidget {
  const EquipmentList({super.key, required this.home, required this.tabs});

  final HomeRow home;
  final Widget tabs;

  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  final _query = TextEditingController();
  String? _room;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = widget.home;
    final writable = home.archivedAt == null;
    // The search field and the room choice live in the outer view, keyed by
    // the home only, so that typing never rebuilds the field (it would lose
    // its focus and close the keyboard); only the list below is read again
    // when the words or the room change.
    return DataView<List<RoomRow>>(
      key: ValueKey(home.id),
      load: (r) => r.rooms(home.id),
      builder: (context, rooms) => HcScreenList(
        children: [
          widget.tabs,
          HcField(
            label: l10n.itemsSearch,
            child: TextField(
              key: const Key('equipment-search'),
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => setState(() {}),
              onChanged: (_) => setState(() {}),
            ),
          ),
          hcChoice<String?>(
            l10n.room,
            rooms.any((r) => r.id == _room) ? _room : null,
            [
              (null, l10n.itemsEveryRoom),
              for (final r in rooms) (r.id, r.name),
            ],
            (v) => setState(() => _room = v),
            key: const Key('equipment-room'),
          ),
          DataView<List<ItemListEntry>>(
            key: ValueKey('${home.id}|${_query.text}|$_room'),
            load: (r) => r.itemList(home.id, roomId: _room, query: _query.text),
            builder: (context, entries) {
              final everything = _query.text.trim().isEmpty && _room == null;
              // After the list, as on the other lists; an item needs a room,
              // so the button waits for the first one. The room being
              // filtered is the one the form starts with. With the button
              // under it, the empty state does not send the reader to the
              // page of a room.
              final canAdd = writable && rooms.isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (entries.isEmpty)
                    HcEmpty(
                      !everything
                          ? l10n.itemsNoMatch
                          : canAdd
                          ? l10n.itemsEmptyShort
                          : l10n.itemsAllEmpty,
                    )
                  else
                    HcCardList(
                      children: [
                        for (final entry in entries) _row(context, l10n, entry),
                      ],
                    ),
                  if (canAdd)
                    HcAddButton(
                      key: const Key('equipment-add'),
                      label: l10n.addItem,
                      primary: false,
                      gap: entries.isEmpty ? HcSpace.s2 : HcSpace.s3,
                      onPressed: () => Navigator.of(context).push(
                        hcRoute(
                          ItemFormScreen(
                            homeId: home.id,
                            roomId: _room,
                            chooseRoom: true,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    AppLocalizations l10n,
    ItemListEntry entry,
  ) {
    final item = entry.item;
    final next = entry.next;
    final ends = item.warrantyEndsOn;
    return HcRow(
      key: Key('equipment-${item.id}'),
      title: item.name,
      text: [
        entry.room.name,
        if (item.brand.isNotEmpty) item.brand,
      ].join(' · '),
      moreText: next == null
          ? l10n.itemsNoTask
          : [
              l10n.itemsNext(next.task.title),
              if (next.dueOn != null) formatDay(context, next.dueOn!),
            ].join(' · '),
      pills: [
        if (ends != null)
          entry.warranty == 'expired'
              ? HcPill(
                  l10n.itemsWarrantyEnded(formatDay(context, Day.parse(ends))),
                  tone: HcPillTone.danger,
                )
              : HcPill(
                  l10n.itemsWarrantyUntil(formatDay(context, Day.parse(ends))),
                  tone: HcPillTone.sand,
                ),
      ],
      onTap: () => Navigator.of(context)
          .push(hcRoute(ItemScreen(homeId: widget.home.id, itemId: item.id))),
    );
  }
}
