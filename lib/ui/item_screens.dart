// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import '../domain/day.dart';
import '../domain/warranty.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'choices.dart';
import 'autosave.dart';
import 'contractor_screens.dart';
import 'messages.dart';
import 'parts.dart';
import 'photos.dart';
import 'report_screens.dart';
import 'rooms.dart';
import 'guide_screens.dart';
import 'state.dart';

/// An item (docs/spec.md, "Screens of v1", 5; `rooms/item_detail.html`):
/// what it is, its warranty, its maintenance contract and Report a problem,
/// then its links, its photos and its tasks.
class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key, required this.homeId, required this.itemId});

  final String homeId;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.homes.where((h) => h.id == homeId).firstOrNull;
    final writable = home != null && home.archivedAt == null;
    final today = state.repository.today();
    return DataView<(ItemRow?, RoomRow?, ContractorRow?)>(
      load: (r) async {
        final item = await r.item(itemId);
        return (
          item,
          item == null ? null : await r.room(item.roomId),
          item?.contractContractorId == null
              ? null
              : await r.contractor(item!.contractContractorId!),
        );
      },
      builder: (context, data) {
        final (item, room, provider) = data;
        if (item == null) {
          return HcScaffold(
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        final warranty = Repository.warrantyState(item, today);
        final links = Repository.linksOf(item);
        final hasContract =
            provider != null ||
            item.contractNumber.isNotEmpty ||
            item.contractUrl.isNotEmpty;
        return HcScaffold(
          belowTitle: ExampleHomeBanner(homeId: homeId),
          title: item.name,
          actions: actionsOrHelp([
            if (writable)
              HcBarAction(
                label: l10n.edit,
                onPressed: () => Navigator.of(context).push(
                  hcRoute(
                    ItemFormScreen(
                      homeId: homeId,
                      roomId: item.roomId,
                      itemId: itemId,
                    ),
                  ),
                ),
              ),
          ], HelpPages.item),
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      [?room?.name, itemKindLabel(l10n, item.kind)].join(' · '),
                      style: HcText.rowText,
                    ),
                    const SizedBox(height: HcSpace.s3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: HcSpace.s3),
                      child: HcValueList(
                        children: [
                          if (item.brand.isNotEmpty || item.model.isNotEmpty)
                            HcValueRow(
                              l10n.itemBrandModel,
                              [
                                item.brand,
                                item.model,
                              ].where((t) => t.isNotEmpty).join(' · '),
                            ),
                          if (item.serialNumber.isNotEmpty)
                            HcValueRow(l10n.itemSerial, item.serialNumber),
                          if (item.purchasedOn != null)
                            HcValueRow(
                              l10n.itemPurchasedOn,
                              formatDay(context, Day.parse(item.purchasedOn!)),
                            ),
                          if (item.installedOn != null)
                            HcValueRow(
                              l10n.itemInstalledOn,
                              formatDay(context, Day.parse(item.installedOn!)),
                            ),
                          if (warranty != 'none' ||
                              item.warrantyDuration != null)
                            HcValueRow(
                              l10n.itemManufacturerWarranty,
                              '',
                              child: _WarrantyValue(
                                item: item,
                                state: warranty,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (hasContract)
                      HcFact(
                        l10n.maintenanceContract,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (provider != null)
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  hcRoute(
                                    ContractorScreen(
                                      homeId: homeId,
                                      contractorId: provider.id,
                                    ),
                                  ),
                                ),
                                child: Text(provider.name),
                              ),
                            if (item.contractNumber.isNotEmpty)
                              factText(item.contractNumber),
                            if (item.contractUrl.isNotEmpty)
                              _LinkRow(
                                label: item.contractUrl,
                                address: item.contractUrl,
                              ),
                          ],
                        ),
                      ),
                    if (item.notes.isNotEmpty)
                      HcFact(l10n.fieldNotes, factText(item.notes)),
                    // The action row (`labels/_tools.html`): Edit is the
                    // action of the bar.
                    RecordActions(
                      children: [
                        OutlinedButton(
                          key: const Key('item-report'),
                          onPressed: () => Navigator.of(context).push(
                            hcRoute(
                              ReportFormScreen(homeId: homeId, itemId: itemId),
                            ),
                          ),
                          child: Text(l10n.reportProblem),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (links.isNotEmpty) ...[
                HcSectionHeading(l10n.links),
                HcCardList(
                  children: [
                    for (final link in links)
                      _LinkRow(
                        label: link.label.isEmpty ? link.url : link.label,
                        text: link.label.isEmpty ? null : link.url,
                        address: link.url,
                      ),
                  ],
                ),
              ],
              PhotoSection(homeId: homeId, itemId: itemId, writable: writable),
              TaskRows(homeId: homeId, itemId: itemId, writable: writable),
            ],
          ),
        );
      },
    );
  }
}

/// The manufacturer's warranty of an item, as `rooms/_warranty.html` draws
/// it: the pill of its end, then its duration from its start, then who gives
/// it.
class _WarrantyValue extends StatelessWidget {
  const _WarrantyValue({required this.item, required this.state});

  final ItemRow item;
  final String state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ends = item.warrantyEndsOn;
    final start = warrantyStart(
      item.warrantyStartsOn == null ? null : Day.parse(item.warrantyStartsOn!),
      item.purchasedOn == null ? null : Day.parse(item.purchasedOn!),
    );
    final duration = item.warrantyDuration;
    final provider = switch (item.warrantyProvider) {
      'manufacturer' => l10n.warrantyByManufacturer,
      'shop' => l10n.warrantyByShop,
      _ => '',
    };
    final who = [
      provider,
      item.warrantyProviderName,
    ].where((t) => t.isNotEmpty).join(': ');
    final details = [
      if (duration != null)
        [
          item.warrantyDurationUnit == warrantyMonth
              ? l10n.warrantyMonths(duration)
              : l10n.warrantyYears(duration),
          if (start != null) l10n.warrantyFrom(formatDay(context, start)),
        ].join(' · '),
      if (who.isNotEmpty) who,
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ends != null)
          HcPill(
            state == 'expired'
                ? l10n.warrantyEnded(formatDay(context, Day.parse(ends)))
                : l10n.warrantyUntil(formatDay(context, Day.parse(ends))),
            tone: state == 'expired' ? HcPillTone.danger : HcPillTone.sand,
          ),
        if (details.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: HcSpace.s1),
            child: Text(details, style: HcText.bodySmall),
          ),
      ],
    );
  }
}

/// A link of an item. It opens in the browser of the phone, and only when the
/// person taps it: the page is never fetched by the app.
class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.address, this.text});

  final String label;
  final String? text;
  final String address;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return HcRow(
      title: label,
      text: text,
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final uri = Uri.tryParse(address);
        if (uri == null || !await state.openUrl(uri)) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.contractorCannotOpen)),
          );
        }
      },
    );
  }
}

/// The form of an item.
class ItemFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const ItemFormScreen({
    super.key,
    required this.homeId,
    this.roomId,
    this.chooseRoom = false,
    this.itemId,
    this.fill = const {},
  });

  final String homeId;

  /// The values of **Fill in for me** of the guide: `name`, `kind`, `brand`
  /// and `model`, and the `room` a new item starts in when [roomId] does not
  /// say it, shown on the example home only.
  final GuideFill fill;

  /// The room of the item; for a new item opened from Equipment, the room
  /// the form starts with, `null` for the first one.
  final String? roomId;

  /// Whether the form asks for the room (a new item opened from Equipment).
  final bool chooseRoom;

  /// `null` for a new item.
  final String? itemId;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen>
    with AutosaveSheet<ItemFormScreen> {
  final _form = GlobalKey<FormState>();

  @override
  GlobalKey<FormState> get sheetForm => _form;

  @override
  bool get existing => widget.itemId != null;

  @override
  Future<void> writeSheet(Repository repository) =>
      repository.updateItem(widget.itemId!, _input());
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _serial = TextEditingController();
  final _contractNumber = TextEditingController();
  final _contractUrl = TextEditingController();
  final _notes = TextEditingController();
  final _warrantyDuration = TextEditingController();
  final _warrantyProviderName = TextEditingController();
  final _links = <(TextEditingController, TextEditingController)>[];
  String _kind = 'equipment';
  Day? _installedOn;
  Day? _warrantyEndsOn;
  Day? _purchasedOn;
  Day? _warrantyStartsOn;
  String _warrantyUnit = warrantyYear;
  String _warrantyProvider = '';
  String? _contractor;
  List<ContractorRow> _contractors = const [];
  List<RoomRow> _rooms = const [];
  String? _room;
  bool _loaded = false;

  /// The values of the guide that this form takes (`prefill_fields` of the
  /// web's item form): a kind the list has, texts that are not empty.
  void _applyFill() {
    final fill = widget.fill;
    if (!fillsHere(context, widget.homeId, fill)) return;
    if (fill['kind'] case final String kind when itemKinds.contains(kind)) {
      _kind = kind;
    }
    for (final (name, controller) in [
      ('name', _name),
      ('brand', _brand),
      ('model', _model),
    ]) {
      if (fill[name] case final String value when value.trim().isNotEmpty) {
        controller.text = value;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    // The end worked out follows the duration as it is typed.
    _warrantyDuration.addListener(() => setState(() {}));
    _load(AppScope.of(context).repository);
  }

  Future<void> _load(Repository repository) async {
    final contractors = await repository.contractors(widget.homeId);
    final rooms = widget.chooseRoom
        ? await repository.rooms(widget.homeId)
        : const <RoomRow>[];
    final item = widget.itemId == null
        ? null
        : await repository.item(widget.itemId!);
    if (!mounted) return;
    // The room the guide fills in, for a new item of the example home only.
    final start =
        widget.roomId ??
        (item == null && fillsHere(context, widget.homeId, widget.fill)
            ? widget.fill['room'] as String?
            : null);
    setState(() {
      _contractors = contractors;
      _rooms = rooms;
      _room = !widget.chooseRoom
          ? widget.roomId
          : rooms.any((r) => r.id == start)
          ? start
          : (rooms.isEmpty ? null : rooms.first.id);
      if (item == null) {
        _applyFill();
        return;
      }
      _name.text = item.name;
      _kind = item.kind;
      _brand.text = item.brand;
      _model.text = item.model;
      _serial.text = item.serialNumber;
      _installedOn = item.installedOn == null
          ? null
          : Day.parse(item.installedOn!);
      _warrantyEndsOn = item.warrantyEndsOn == null
          ? null
          : Day.parse(item.warrantyEndsOn!);
      _purchasedOn = item.purchasedOn == null
          ? null
          : Day.parse(item.purchasedOn!);
      _warrantyStartsOn = item.warrantyStartsOn == null
          ? null
          : Day.parse(item.warrantyStartsOn!);
      _warrantyDuration.text = item.warrantyDuration?.toString() ?? '';
      _warrantyUnit = item.warrantyDurationUnit.isEmpty
          ? warrantyYear
          : item.warrantyDurationUnit;
      _warrantyProvider = item.warrantyProvider;
      _warrantyProviderName.text = item.warrantyProviderName;
      _contractor = item.contractContractorId;
      _contractNumber.text = item.contractNumber;
      _contractUrl.text = item.contractUrl;
      _notes.text = item.notes;
      for (final link in Repository.linksOf(item)) {
        _links.add((
          TextEditingController(text: link.label),
          TextEditingController(text: link.url),
        ));
      }
      _applyFill();
    });
    sheetLoaded();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _brand,
      _model,
      _serial,
      _contractNumber,
      _contractUrl,
      _notes,
      _warrantyDuration,
      _warrantyProviderName,
      for (final (a, b) in _links) ...[a, b],
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ItemInput _input() => ItemInput(
    name: _name.text,
    kind: _kind,
    brand: _brand.text,
    model: _model.text,
    serialNumber: _serial.text,
    installedOn: _installedOn,
    warrantyEndsOn: _warrantyEndsOn,
    purchasedOn: _purchasedOn,
    warrantyDuration: int.tryParse(_warrantyDuration.text.trim()),
    warrantyDurationUnit: _warrantyUnit,
    warrantyProvider: _warrantyProvider,
    warrantyProviderName: _warrantyProviderName.text,
    warrantyStartsOn: _warrantyStartsOn,
    contractContractorId: _contractor,
    contractNumber: _contractNumber.text,
    contractUrl: _contractUrl.text,
    links: [
      for (final (label, url) in _links)
        if (url.text.trim().isNotEmpty)
          ItemLink(url: url.text, label: label.text),
    ],
    notes: _notes.text,
  );

  Future<void> _save() async {
    cancelAutosave();
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    String? added;
    final saved = await runChange(context, (r) async {
      if (widget.itemId == null) {
        added = await r.addItem(_room ?? widget.roomId!, _input());
      } else {
        await r.updateItem(widget.itemId!, _input());
      }
    });
    // A new item is given back, for the list that opened the form to open it.
    if (saved) navigator.pop(added);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteItem,
      body: l10n.deleteItemBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(context, (r) => r.deleteItem(widget.itemId!))) {
      navigator.pop();
      navigator.pop();
    }
  }

  /// The manufacturer's warranty (web ADR 0080): its duration in months or
  /// years, who gives it, its start and its end, worked out when a duration
  /// and a start are known, typed otherwise.
  Widget _warrantyFields(AppLocalizations l10n) {
    final computed = warrantyEnd(
      warrantyStart(_warrantyStartsOn, _purchasedOn),
      int.tryParse(_warrantyDuration.text.trim()),
      _warrantyUnit,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hcText(
          l10n.warrantyDuration,
          _warrantyDuration,
          key: const Key('item-warranty-duration'),
          keyboard: TextInputType.number,
          sentences: false,
          validator: (v) {
            final text = (v ?? '').trim();
            if (text.isEmpty) return null;
            final n = int.tryParse(text);
            return n == null || n < 1 || n > maxWarrantyDuration
                ? l10n.errWarrantyDuration
                : null;
          },
        ),
        fieldHelp(l10n.warrantyDurationHelp),
        hcChoice<String>(
          l10n.warrantyDurationUnit,
          _warrantyUnit,
          [
            (warrantyMonth, l10n.warrantyMonthsChoice),
            (warrantyYear, l10n.warrantyYearsChoice),
          ],
          (v) => setState(() => _warrantyUnit = v),
          key: const Key('item-warranty-unit'),
        ),
        hcChoice<String>(
          l10n.warrantyProvider,
          _warrantyProvider,
          [
            ('', l10n.contractNone),
            ('manufacturer', l10n.warrantyByManufacturer),
            ('shop', l10n.warrantyByShop),
          ],
          (v) => setState(() => _warrantyProvider = v),
          key: const Key('item-warranty-provider'),
        ),
        hcText(l10n.warrantyProviderName, _warrantyProviderName),
        fieldHelp(l10n.warrantyProviderNameHelp),
        HcDateField(
          label: l10n.warrantyStartsOn,
          value: _warrantyStartsOn,
          noDate: l10n.todayNoDate,
          onChanged: (d) {
            setState(() => _warrantyStartsOn = d);
            sheetChanged(now: true);
          },
        ),
        fieldHelp(l10n.warrantyStartsOnHelp),
        if (computed != null)
          HcField(
            label: l10n.itemWarrantyEndsOn,
            child: Text(
              formatDay(context, computed),
              key: const Key('item-warranty-end'),
              style: HcText.body,
            ),
          )
        else
          HcDateField(
            label: l10n.itemWarrantyEndsOn,
            value: _warrantyEndsOn,
            noDate: l10n.todayNoDate,
            onChanged: (d) {
              setState(() => _warrantyEndsOn = d);
              sheetChanged(now: true);
            },
          ),
        fieldHelp(l10n.warrantyEndsOnHelp),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      title: widget.itemId == null ? l10n.newItem : l10n.editItem,
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
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.chooseRoom && widget.itemId == null) ...[
                    hcChoice<String?>(
                      l10n.room,
                      _room,
                      [for (final r in _rooms) (r.id, r.name)],
                      (v) => setState(() => _room = v),
                      key: const Key('item-room'),
                    ),
                    fieldHelp(l10n.itemRoomHelp),
                  ],
                  hcText(
                    l10n.fieldName,
                    _name,
                    key: const Key('item-name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcChoice<String>(
                    l10n.fieldType,
                    _kind,
                    [for (final k in itemKinds) (k, itemKindLabel(l10n, k))],
                    (v) => setState(() => _kind = v),
                    key: const Key('item-kind'),
                  ),
                  hcText(l10n.itemBrand, _brand),
                  hcText(l10n.itemModel, _model),
                  hcText(l10n.itemSerial, _serial, sentences: false),
                  HcDateField(
                    label: l10n.itemPurchasedOn,
                    value: _purchasedOn,
                    noDate: l10n.todayNoDate,
                    onChanged: (d) {
                      setState(() => _purchasedOn = d);
                      sheetChanged(now: true);
                    },
                  ),
                  HcDateField(
                    label: l10n.itemInstalledOn,
                    value: _installedOn,
                    noDate: l10n.todayNoDate,
                    onChanged: (d) {
                      setState(() => _installedOn = d);
                      sheetChanged(now: true);
                    },
                  ),
                  hcText(l10n.fieldNotes, _notes, minLines: 2, maxLines: 6),
                ],
              ),
            ),
            HcSectionHeading(l10n.itemManufacturerWarranty),
            HcCard(child: _warrantyFields(l10n)),
            HcSectionHeading(l10n.maintenanceContract),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcChoice<String?>(
                    l10n.contractProvider,
                    _contractor,
                    [
                      (null, l10n.contractNone),
                      for (final c in _contractors) (c.id, c.name),
                    ],
                    (v) => setState(() => _contractor = v),
                    key: const Key('item-contractor'),
                  ),
                  hcText(
                    l10n.contractNumber,
                    _contractNumber,
                    sentences: false,
                  ),
                  hcText(
                    l10n.contractLink,
                    _contractUrl,
                    keyboard: TextInputType.url,
                    sentences: false,
                  ),
                ],
              ),
            ),
            HcSectionHeading(l10n.links),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, (label, url)) in _links.indexed) ...[
                    hcText(l10n.linkLabel, label),
                    hcText(
                      l10n.linkAddress,
                      url,
                      key: Key('item-link-$i'),
                      keyboard: TextInputType.url,
                      sentences: false,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            final removed = _links.removeAt(i);
                            removed.$1.dispose();
                            removed.$2.dispose();
                          });
                          sheetChanged(now: true);
                        },
                        child: Text(l10n.removeLink),
                      ),
                    ),
                  ],
                  if (_links.length < maxLinks)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: OutlinedButton.icon(
                        key: const Key('item-link-add'),
                        onPressed: () => setState(
                          () => _links.add((
                            TextEditingController(),
                            TextEditingController(),
                          )),
                        ),
                        icon: const HcIcon(
                          HcIcons.add,
                          color: HcColors.primary,
                        ),
                        label: Text(l10n.addLink),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.itemId != null) ...[
              HcDeleteButton(
                key: const Key('item-delete'),
                label: l10n.deleteItem,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
