// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'choices.dart';
import 'contractor_screens.dart';
import 'messages.dart';
import 'parts.dart';
import 'photos.dart';
import 'rooms.dart';
import 'state.dart';

/// An item (docs/spec.md, "Screens of v1", 5): what it is, its warranty, its
/// maintenance contract, its links, its photos and its tasks.
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
          return Scaffold(
            appBar: AppBar(),
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        final warranty = Repository.warrantyState(item, today);
        final links = Repository.linksOf(item);
        final hasContract =
            provider != null ||
            item.contractNumber.isNotEmpty ||
            item.contractUrl.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              if (writable)
                HcBarAction(
                  label: l10n.edit,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ItemFormScreen(
                        homeId: homeId,
                        roomId: item.roomId,
                        itemId: itemId,
                      ),
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
                    Text(
                      [?room?.name, itemKindLabel(l10n, item.kind)].join(' · '),
                      style: HcText.rowText,
                    ),
                    const SizedBox(height: HcSpace.s3),
                    if (item.brand.isNotEmpty || item.model.isNotEmpty)
                      HcFact(
                        l10n.itemBrandModel,
                        factText(
                          [
                            item.brand,
                            item.model,
                          ].where((t) => t.isNotEmpty).join(' · '),
                        ),
                      ),
                    if (item.serialNumber.isNotEmpty)
                      HcFact(l10n.itemSerial, factText(item.serialNumber)),
                    if (item.installedOn != null)
                      HcFact(
                        l10n.itemInstalledOn,
                        factText(
                          formatDay(context, Day.parse(item.installedOn!)),
                        ),
                      ),
                    if (warranty != 'none')
                      HcFact(
                        l10n.itemWarranty,
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: HcPill(
                            warranty == 'expired'
                                ? l10n.warrantyEnded(
                                    formatDay(
                                      context,
                                      Day.parse(item.warrantyEndsOn!),
                                    ),
                                  )
                                : l10n.warrantyUntil(
                                    formatDay(
                                      context,
                                      Day.parse(item.warrantyEndsOn!),
                                    ),
                                  ),
                            tone: warranty == 'expired'
                                ? HcPillTone.danger
                                : HcPillTone.sand,
                          ),
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
                                  MaterialPageRoute<void>(
                                    builder: (_) => ContractorScreen(
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
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({
    super.key,
    required this.homeId,
    required this.roomId,
    this.itemId,
  });

  final String homeId;
  final String roomId;

  /// `null` for a new item.
  final String? itemId;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _serial = TextEditingController();
  final _contractNumber = TextEditingController();
  final _contractUrl = TextEditingController();
  final _notes = TextEditingController();
  final _links = <(TextEditingController, TextEditingController)>[];
  String _kind = 'equipment';
  Day? _installedOn;
  Day? _warrantyEndsOn;
  String? _contractor;
  List<ContractorRow> _contractors = const [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load(AppScope.of(context).repository);
  }

  Future<void> _load(Repository repository) async {
    final contractors = await repository.contractors(widget.homeId);
    final item = widget.itemId == null
        ? null
        : await repository.item(widget.itemId!);
    if (!mounted) return;
    setState(() {
      _contractors = contractors;
      if (item == null) return;
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
    });
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
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(
      context,
      (r) => widget.itemId == null
          ? r.addItem(widget.roomId, _input())
          : r.updateItem(widget.itemId!, _input()),
    );
    if (saved) navigator.pop();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemId == null ? l10n.newItem : l10n.editItem),
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
                    label: l10n.itemInstalledOn,
                    value: _installedOn,
                    noDate: l10n.todayNoDate,
                    onChanged: (d) => setState(() => _installedOn = d),
                  ),
                  HcDateField(
                    label: l10n.itemWarrantyEndsOn,
                    value: _warrantyEndsOn,
                    noDate: l10n.todayNoDate,
                    onChanged: (d) => setState(() => _warrantyEndsOn = d),
                  ),
                  hcText(l10n.fieldNotes, _notes, minLines: 2, maxLines: 6),
                ],
              ),
            ),
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
                        onPressed: () => setState(() {
                          final removed = _links.removeAt(i);
                          removed.$1.dispose();
                          removed.$2.dispose();
                        }),
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
              const SizedBox(height: HcSpace.s4),
              OutlinedButton(
                key: const Key('item-delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HcColors.danger,
                ),
                onPressed: _delete,
                child: Text(l10n.deleteItem),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
