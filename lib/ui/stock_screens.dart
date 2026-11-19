// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/filters.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/barcode_lookup.dart';
import '../domain/day.dart';
import '../domain/gtin.dart';
import '../domain/stock.dart' as stock;
import 'guide_screens.dart';
import 'help_button.dart';
import '../domain/labels.dart';
import '../l10n/app_localizations.dart';
import 'autosave.dart';
import 'barcode_field.dart';
import 'item_screens.dart';
import 'label_screens.dart';
import 'messages.dart';
import 'parts.dart';
import 'photos.dart' show MissingPhotoTile;
import 'rooms.dart';
import 'state.dart';
import 'budget_parts.dart';
import 'stock_format.dart';
import 'report_screens.dart';
import 'task_screen.dart';

/// The language tag the amounts are written in.
String localeOf(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// The tabs of the section Rooms, as on the web (`{% tab_bar "rooms" %}`):
/// Rooms and Stock.
class RoomsTabs extends StatelessWidget {
  const RoomsTabs({super.key, required this.current, required this.onSelect});

  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcTabs(
      key: const Key('rooms-tabs'),
      // Rooms, Equipment and Stock, in the web's order (`tab_bar "rooms"`).
      labels: [l10n.navRooms, l10n.equipmentTab, l10n.stock],
      current: current,
      onSelect: onSelect,
    );
  }
}

/// Stock (docs/spec.md, "Screens of v1", 6; `stock/article_list.html`): the
/// articles of the current home by name, each with its stock and its place,
/// the low ones flagged; a search by name, reference or supplier, and the
/// low ones only.
class StockList extends StatefulWidget {
  const StockList({super.key, required this.home, required this.tabs});

  final HomeRow home;
  final Widget tabs;

  @override
  State<StockList> createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  final _query = TextEditingController();

  /// What the list was last asked: the field's text, after a pause.
  String _search = '';
  bool _low = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _clearAll() => setState(() {
    _query.clear();
    _search = '';
    _low = false;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = localeOf(context);
    final home = widget.home;
    final writable = home.archivedAt == null;
    // The tabs and the search stay where they are while the list under them
    // is read again, so that the field keeps its focus as the person types.
    return HcScreenList(
      children: [
        widget.tabs,
        // All and Low stock as tabs, the search under them (web ADR on
        // filters, `stock/article_list.html`).
        HcFilterBar(
          tabsKey: const Key('stock-tabs'),
          tabLabels: [l10n.stockTabAll, l10n.articleLowStock],
          currentTab: _low ? 1 : 0,
          onTab: (index) => setState(() => _low = index == 1),
          searchController: _query,
          searchKey: const Key('stock-search'),
          searchLabel: l10n.stockSearch,
          onSearch: (text) {
            if (text != _search) setState(() => _search = text);
          },
        ),
        DataView<List<ArticleEntry>>(
          key: ValueKey(home.id),
          reloadKey: (_search, _low),
          load: (r) => r.articles(home.id, query: _search, low: _low),
          builder: (context, entries) {
            final everything = _search.trim().isEmpty && !_low;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (entries.isEmpty && everything)
                  HcEmpty(l10n.stockEmpty)
                else if (entries.isEmpty)
                  HcNoMatch(text: l10n.stockNoMatch, onClear: _clearAll)
                else
                  HcCardList(
                    children: [
                      for (final entry in entries)
                        HcRow(
                          key: Key('article-${entry.article.id}'),
                          title: entry.article.name,
                          text: [
                            amountOf(l10n, locale, entry.article, entry.level),
                            if (entry.article.storageLocation.isNotEmpty)
                              entry.article.storageLocation,
                          ].join(' · '),
                          pills: [
                            if (entry.low)
                              HcPill(
                                l10n.articleLowStock,
                                tone: HcPillTone.warning,
                              ),
                          ],
                          onTap: () => Navigator.of(context).push(
                            hcRoute(
                              ArticleScreen(
                                homeId: home.id,
                                articleId: entry.article.id,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                if (writable)
                  HcAddButton(
                    key: const Key('article-add'),
                    label: l10n.addArticle,
                    primary: false,
                    gap: entries.isEmpty ? HcSpace.s2 : HcSpace.s3,
                    onPressed: () => _add(context),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Created from the list of its own section, the new stock item opens (web
  /// design guide, After a form); Back from it returns to this list, still
  /// filtered.
  Future<void> _add(BuildContext context) async {
    final navigator = Navigator.of(context);
    final id = await navigator.push(
      hcRouteOf<String?>(ArticleFormScreen(homeId: widget.home.id)),
    );
    if (id == null || !mounted) return;
    await navigator.push(
      hcRoute(ArticleScreen(homeId: widget.home.id, articleId: id)),
    );
  }
}

/// What the screen of an article shows.
class _ArticleData {
  _ArticleData({
    required this.home,
    required this.article,
    required this.level,
    required this.movements,
    required this.suppliers,
    required this.items,
    required this.rooms,
    required this.tasks,
  });

  final HomeRow home;
  final ArticleRow article;
  final Decimal level;
  final List<MovementEntry> movements;
  final List<SupplierRow> suppliers;
  final List<ItemRow> items;
  final List<RoomRow> rooms;
  final List<TaskRow> tasks;
}

/// The photo of the label of an article, or its tile while the file is not
/// on this phone.
class _ArticleLabel extends StatelessWidget {
  const _ArticleLabel({required this.article});

  final ArticleRow article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final file = AppScope.of(context).repository
        .fileOfRow('articles', article.homeId, article.id);
    final label = l10n.articleLabelPhoto(article.name);
    if (!file.existsSync()) {
      return MissingPhotoTile(
        key: const Key('article-label-missing'),
        label: label,
      );
    }
    final credit = readAttribution(article.labelAttribution);
    final photo = Semantics(
      image: true,
      label: label,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HcRadius.sm),
        child: Image.file(
          file,
          key: const Key('article-label'),
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    if (credit == null) return photo;
    // A photo from an open database shows its credit under it (web ADR
    // 0083, CC BY-SA 3.0).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        photo,
        const SizedBox(height: HcSpace.s1),
        PhotoCredit(credit),
      ],
    );
  }
}

/// An article (`stock/article_detail.html`): its stock and facts, the photo
/// of its label, the form that records a movement, the items it fits, its
/// rooms, the tasks that need it, its suppliers and its ledger.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({
    super.key,
    required this.homeId,
    required this.articleId,
  });

  final String homeId;
  final String articleId;

  Future<_ArticleData?> _load(Repository r) async {
    final article = await r.article(articleId);
    final home = await r.home(homeId);
    if (article == null || home == null) return null;
    return _ArticleData(
      home: home,
      article: article,
      level: await r.stockLevel(articleId),
      movements: await r.movementsOf(articleId),
      suppliers: await r.suppliersOf(articleId),
      items: await r.compatibleItemsOf(articleId),
      rooms: await r.roomsOfArticle(articleId),
      tasks: await r.tasksUsing(articleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = localeOf(context);
    return DataView<_ArticleData?>(
      load: _load,
      builder: (context, data) {
        if (data == null) return HcScaffold();
        final a = data.article;
        final writable = data.home.archivedAt == null;
        final threshold = a.threshold == null
            ? null
            : stock.readQuantity(a.threshold!);
        final low = stock.isLow(data.level, threshold);
        final unit = unitAfter(l10n, a, data.level);
        String? money(String? stored) => stored == null
            ? null
            : formatMoney(
                locale,
                data.home.currency,
                stock.readQuantity(stored),
              );
        void open(Widget screen) => Navigator.of(context).push(hcRoute(screen));
        return HcScaffold(
          title: a.name,
          belowTitle: ExampleHomeBanner(homeId: homeId),
          actions: const [HelpButton(page: HelpPages.stockItem)],
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: HcSpace.s3),
                      child: HcFigure(
                        formatQuantity(locale, data.level),
                        key: const Key('article-level'),
                        unit: unit,
                        pill: low
                            ? HcPill(
                                l10n.articleLowStock,
                                tone: HcPillTone.warning,
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: HcSpace.s3),
                      child: HcValueList(
                        children: [
                          if (threshold != null)
                            HcValueRow(
                              l10n.articleThreshold,
                              formatQuantity(locale, threshold),
                            ),
                          if (money(a.unitPrice) case final price?)
                            HcValueRow(l10n.articleUnitPrice, price),
                          if (a.manufacturerReference.isNotEmpty)
                            HcValueRow(
                              l10n.articleReference,
                              a.manufacturerReference,
                            ),
                          if (a.dimensions.isNotEmpty)
                            HcValueRow(l10n.articleDimensions, a.dimensions),
                          if (a.storageLocation.isNotEmpty)
                            HcValueRow(l10n.articleStorage, a.storageLocation),
                        ],
                      ),
                    ),
                    if (a.notes.isNotEmpty)
                      HcFact(l10n.fieldNotes, factText(a.notes)),
                    // The photo of its label, under the facts as on the web
                    // (`stock/article_detail.html`); the tile of a photo
                    // until its file has come from the server (lot 4d).
                    if (a.label != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: HcSpace.s3),
                        child: _ArticleLabel(article: a),
                      ),
                    // The action row (`stock/article_detail.html`): Edit,
                    // then Report a problem (`labels/_tools.html`).
                    RecordActions(
                      children: [
                        if (writable)
                          OutlinedButton(
                            key: const Key('article-edit'),
                            onPressed: () => open(
                              ArticleFormScreen(
                                homeId: homeId,
                                articleId: a.id,
                              ),
                            ),
                            child: Text(l10n.editArticle),
                          ),
                        LabelButton(
                          homeId: homeId,
                          kind: LabelKind.article,
                          targetId: a.id,
                        ),
                        OutlinedButton(
                          key: const Key('article-report'),
                          onPressed: () => open(
                            ReportFormScreen(homeId: homeId, articleId: a.id),
                          ),
                          child: Text(l10n.reportProblem),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (writable) ...[
                HcSectionHeading(l10n.recordMovement),
                MovementForm(articleId: a.id),
              ],
              HcSectionHeading(l10n.articleCompatible),
              if (data.items.isEmpty)
                HcEmpty(l10n.articleNoCompatible)
              else
                HcCardList(
                  children: [
                    for (final item in data.items)
                      HcRow(
                        title: item.name,
                        onTap: () =>
                            open(ItemScreen(homeId: homeId, itemId: item.id)),
                      ),
                  ],
                ),
              if (data.rooms.isNotEmpty) ...[
                HcSectionHeading(l10n.navRooms),
                HcCardList(
                  children: [
                    for (final room in data.rooms)
                      HcRow(
                        title: room.name,
                        onTap: () =>
                            open(RoomScreen(homeId: homeId, roomId: room.id)),
                      ),
                  ],
                ),
              ],
              if (data.tasks.isNotEmpty) ...[
                HcSectionHeading(l10n.articleTasks),
                HcCardList(
                  children: [
                    for (final task in data.tasks)
                      HcRow(
                        title: task.title,
                        onTap: () =>
                            open(TaskScreen(homeId: homeId, taskId: task.id)),
                      ),
                  ],
                ),
              ],
              HcSectionHeading(l10n.suppliers),
              if (data.suppliers.isEmpty)
                HcEmpty(l10n.suppliersEmpty)
              else
                HcCardList(
                  children: [
                    for (final s in data.suppliers)
                      Padding(
                        padding: const EdgeInsets.all(HcSpace.s4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: HcSpace.s3,
                              ),
                              child: Text(s.name, style: HcText.cardTitle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: HcSpace.s3,
                              ),
                              child: HcValueList(
                                children: [
                                  if (s.reference.isNotEmpty)
                                    HcValueRow(
                                      l10n.supplierReference,
                                      s.reference,
                                    ),
                                  if (money(s.lastPrice) case final price?)
                                    HcValueRow(l10n.supplierLastPrice, price),
                                ],
                              ),
                            ),
                            if (s.url.isNotEmpty)
                              HcFact(l10n.supplierUrl, factText(s.url)),
                            if (writable)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Semantics(
                                  label: l10n.editSupplierOf(s.name),
                                  excludeSemantics: true,
                                  button: true,
                                  child: OutlinedButton(
                                    key: Key('supplier-edit-${s.id}'),
                                    onPressed: () => open(
                                      SupplierFormScreen(
                                        homeId: homeId,
                                        articleId: a.id,
                                        supplierId: s.id,
                                      ),
                                    ),
                                    child: Text(l10n.editSupplier),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              if (writable)
                HcAddButton(
                  key: const Key('supplier-add'),
                  label: l10n.addSupplier,
                  primary: false,
                  gap: data.suppliers.isEmpty ? HcSpace.s2 : HcSpace.s3,
                  onPressed: () =>
                      open(SupplierFormScreen(homeId: homeId, articleId: a.id)),
                ),
              HcSectionHeading(l10n.movements),
              if (data.movements.isEmpty)
                HcEmpty(l10n.movementsEmpty)
              else
                HcCardList(
                  children: [
                    for (final m in data.movements)
                      HcRow(
                        title:
                            '${movementKindLabel(l10n, m.movement.kind)} · '
                            '${m.effect > stock.zero ? '+' : ''}'
                            '${amountOf(l10n, locale, a, m.effect)}',
                        text: [
                          formatDay(context, Day.parse(m.movement.occurredOn)),
                          if (m.movement.kind == stock.inventoryKind)
                            l10n.movementCounted(
                              formatQuantity(locale, m.quantity),
                            ),
                          if (m.movement.note.isNotEmpty) m.movement.note,
                          if (m.task != null) m.task!,
                        ].join(' · '),
                        onTap: m.taskId == null
                            ? null
                            : () => open(
                                TaskScreen(homeId: homeId, taskId: m.taskId),
                              ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The quick form of an article's screen (`MovementForm` of the web): a
/// quantity, a date and a note, and the three buttons that say what it is.
class MovementForm extends StatefulWidget {
  const MovementForm({super.key, required this.articleId});

  final String articleId;

  @override
  State<MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<MovementForm> {
  final _quantity = TextEditingController(text: '1');
  final _note = TextEditingController();
  Day? _on;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _record(String kind) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final state = AppScope.of(context);
    try {
      await state.repository.recordMovement(
        widget.articleId,
        kind: kind,
        quantity: _quantity.text,
        on: _on,
        note: _note.text,
      );
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
      return;
    }
    _note.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.movementRecorded)));
    await state.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = AppScope.of(context).repository.today();
    return HcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hcText(
            l10n.movementQuantity,
            _quantity,
            key: const Key('movement-quantity'),
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            sentences: false,
          ),
          HcDateField(
            label: l10n.movementDate,
            value: _on ?? today,
            noDate: formatDay(context, today),
            clearable: false,
            onChanged: (day) => setState(() => _on = day),
          ),
          hcText(l10n.movementNote, _note, key: const Key('movement-note')),
          Wrap(
            spacing: HcSpace.s2,
            runSpacing: HcSpace.s2,
            children: [
              FilledButton(
                key: const Key('movement-entry'),
                onPressed: () => _record(stock.entryKind),
                child: Text(l10n.movementEntryAction),
              ),
              OutlinedButton(
                key: const Key('movement-exit'),
                onPressed: () => _record(stock.exitKind),
                child: Text(l10n.movementExitAction),
              ),
              OutlinedButton(
                key: const Key('movement-inventory'),
                onPressed: () => _record(stock.inventoryKind),
                child: Text(l10n.movementInventoryAction),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: HcSpace.s3),
            child: Text(l10n.movementHelp, style: HcText.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// A help line under a field, as the web's `.helptext`.
Widget _help(String text) => Padding(
  padding: const EdgeInsets.only(bottom: HcSpace.s3),
  child: Text(text, style: HcText.bodySmall),
);

/// Chips to tick several choices, with the label above.
Widget _chips(
  String label,
  List<(String, String)> choices,
  Set<String> selected,
  void Function(String id, bool on) onChanged, {
  required String keyPrefix,
}) => HcField(
  label: label,
  child: Wrap(
    spacing: HcSpace.s2,
    runSpacing: HcSpace.s2,
    children: [
      for (final (id, text) in choices)
        FilterChip(
          key: Key('$keyPrefix-$id'),
          label: Text(text),
          selected: selected.contains(id),
          onSelected: (on) => onChanged(id, on),
        ),
    ],
  ),
);

/// The form of an article (`stock/article_form.html`).
class ArticleFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const ArticleFormScreen({super.key, required this.homeId, this.articleId});

  final String homeId;

  /// `null` for a new article.
  final String? articleId;

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen>
    with AutosaveSheet<ArticleFormScreen> {
  final _form = GlobalKey<FormState>();

  @override
  GlobalKey<FormState> get sheetForm => _form;

  @override
  bool get existing => widget.articleId != null;

  @override
  Future<void> writeSheet(Repository repository) =>
      repository.updateArticle(widget.articleId!, _input());
  final _name = TextEditingController();
  final _reference = TextEditingController();
  final _dimensions = TextEditingController();
  final _storage = TextEditingController();
  final _unitOther = TextEditingController();
  final _threshold = TextEditingController();
  final _unitPrice = TextEditingController();
  final _notes = TextEditingController();
  final _ean = TextEditingController();
  String _unit = '';

  /// Whether the article has a label photo: a photo found by its barcode is
  /// then never offered (web ADR 0083, `attach_to_article`).
  bool _hasLabel = false;

  /// The answer whose photo the person chose to keep as the label.
  BarcodeAnswer? _foundPhoto;
  final _rooms = <String>{};
  final _items = <String>{};
  List<RoomRow> _roomChoices = const [];
  List<ItemRow> _itemChoices = const [];
  String _currency = '';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load(AppScope.of(context).repository);
  }

  Future<void> _load(Repository r) async {
    final home = await r.home(widget.homeId);
    final rooms = await r.rooms(widget.homeId);
    final items = await r.itemsOfHome(widget.homeId);
    final id = widget.articleId;
    final a = id == null ? null : await r.article(id);
    final linkedRooms = id == null ? <RoomRow>[] : await r.roomsOfArticle(id);
    final linkedItems = id == null
        ? <ItemRow>[]
        : await r.compatibleItemsOf(id);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      _roomChoices = rooms;
      _itemChoices = items;
      if (a != null) {
        _name.text = a.name;
        _reference.text = a.manufacturerReference;
        _dimensions.text = a.dimensions;
        _storage.text = a.storageLocation;
        _unit = a.unit;
        _unitOther.text = a.unitOther;
        _threshold.text = a.threshold == null
            ? ''
            : stock.plain(stock.readQuantity(a.threshold!));
        _unitPrice.text = a.unitPrice == null
            ? ''
            : moneyFieldText(
                Localizations.localeOf(context).toLanguageTag(),
                stock.readQuantity(a.unitPrice!),
              );
        _notes.text = a.notes;
        _ean.text = a.ean;
        _hasLabel = a.label != null;
        _rooms.addAll(linkedRooms.map((r) => r.id));
        _items.addAll(linkedItems.map((i) => i.id));
      }
    });
    sheetLoaded();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _reference,
      _dimensions,
      _storage,
      _unitOther,
      _threshold,
      _unitPrice,
      _notes,
      _ean,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ArticleInput _input() => ArticleInput(
    name: _name.text,
    manufacturerReference: _reference.text,
    dimensions: _dimensions.text,
    storageLocation: _storage.text,
    unit: _unit,
    unitOther: _unitOther.text,
    threshold: _threshold.text,
    unitPrice: fieldAmount(context, _unitPrice),
    notes: _notes.text,
    ean: _ean.text,
    roomIds: _rooms.toList(),
    itemIds: _items.toList(),
  );

  Future<void> _save() async {
    cancelAutosave();
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    String? added;
    final found = _foundPhoto;
    final kept = found != null && cleanGtin(_ean.text) == found.code
        ? await processFoundPhoto(AppScope.of(context), found)
        : null;
    if (!mounted) return;
    final saved = await runChange(context, (r) async {
      if (widget.articleId == null) {
        added = await r.addArticle(widget.homeId, _input());
      } else {
        await r.updateArticle(widget.articleId!, _input());
      }
      // The photo of the product as the label, with its credit, only when
      // the article still has none (`setFoundLabel` checks).
      if (kept != null) {
        await r.setFoundLabel(
          added ?? widget.articleId!,
          kept,
          found!.attribution,
        );
      }
    });
    // A new stock item is given back, for the list that opened the form to
    // open it.
    if (saved) navigator.pop(added);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteArticle,
      body: l10n.deleteArticleBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(context, (r) => r.deleteArticle(widget.articleId!))) {
      navigator.pop();
      navigator.pop();
    }
  }

  /// The values a lookup found, in the fields that are empty only.
  void _fill(Map<String, String> values, BarcodeAnswer? photo) {
    setState(() {
      for (final (field, controller) in [
        ('name', _name),
        ('manufacturer_reference', _reference),
        ('notes', _notes),
      ]) {
        final value = values[field];
        if (value != null && controller.text.trim().isEmpty) {
          controller.text = value;
        }
      }
      if (photo != null) _foundPhoto = photo;
    });
    sheetChanged(now: true);
  }

  /// A room or an item ticked or unticked: kept, and saved at once.
  void _toggle(void Function() change) {
    setState(change);
    sheetChanged(now: true);
  }

  String? _quantityCheck(String? value, AppLocalizations l10n) {
    final text = (value ?? '').trim();
    return text.isEmpty || stock.parseQuantity(text) != null
        ? null
        : l10n.errQuantityInvalid;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const number = TextInputType.numberWithOptions(decimal: true);
    return HcScaffold(
      title: widget.articleId == null ? l10n.addArticle : l10n.editArticle,
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
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
                  hcText(
                    l10n.fieldName,
                    _name,
                    key: const Key('article-name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcText(
                    l10n.articleReference,
                    _reference,
                    key: const Key('article-reference'),
                    sentences: false,
                  ),
                  BarcodeField(
                    controller: _ean,
                    homeId: widget.homeId,
                    target: LookupTarget.article,
                    hasPhoto: _hasLabel,
                    onFill: _fill,
                  ),
                  hcText(l10n.articleDimensions, _dimensions),
                  hcText(
                    l10n.articleStorage,
                    _storage,
                    key: const Key('article-storage'),
                  ),
                  _help(l10n.articleStorageHelp),
                  hcChoice<String>(
                    l10n.articleUnit,
                    _unit,
                    unitChoices(l10n),
                    (v) => setState(() => _unit = v),
                    key: const Key('article-unit'),
                  ),
                  if (_unit == 'other') ...[
                    hcText(
                      l10n.articleUnitOther,
                      _unitOther,
                      key: const Key('article-unit-other'),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? l10n.errUnitOther : null,
                    ),
                    _help(l10n.articleUnitOtherHelp),
                  ],
                  hcText(
                    l10n.articleThreshold,
                    _threshold,
                    key: const Key('article-threshold'),
                    keyboard: number,
                    sentences: false,
                    validator: (v) => _quantityCheck(v, l10n),
                  ),
                  _help(l10n.articleThresholdHelp),
                  hcAmount(
                    context,
                    l10n.articleUnitPrice,
                    _unitPrice,
                    key: const Key('article-unit-price'),
                    parse: stock.parseQuantity,
                  ),
                  _help(l10n.articleUnitPriceHelp(_currency)),
                  if (_itemChoices.isNotEmpty) ...[
                    _chips(
                      l10n.articleCompatible,
                      [for (final i in _itemChoices) (i.id, i.name)],
                      _items,
                      (id, on) => _toggle(
                        () => on ? _items.add(id) : _items.remove(id),
                      ),
                      keyPrefix: 'article-item',
                    ),
                    _help(l10n.articleCompatibleHelp),
                  ],
                  if (_roomChoices.isNotEmpty) ...[
                    _chips(
                      l10n.navRooms,
                      [for (final r in _roomChoices) (r.id, r.name)],
                      _rooms,
                      (id, on) => _toggle(
                        () => on ? _rooms.add(id) : _rooms.remove(id),
                      ),
                      keyPrefix: 'article-room',
                    ),
                    _help(l10n.articleRoomsHelp),
                  ],
                  hcText(l10n.fieldNotes, _notes, minLines: 2, maxLines: 6),
                ],
              ),
            ),
            if (widget.articleId != null) ...[
              HcDeleteButton(
                key: const Key('article-delete'),
                label: l10n.deleteArticle,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The form of a supplier of an article (`stock/supplier_form.html`).
class SupplierFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const SupplierFormScreen({
    super.key,
    required this.homeId,
    required this.articleId,
    this.supplierId,
  });

  final String homeId;
  final String articleId;

  /// `null` for a new supplier.
  final String? supplierId;

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _reference = TextEditingController();
  final _url = TextEditingController();
  final _lastPrice = TextEditingController();
  String _currency = '';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load(AppScope.of(context).repository);
  }

  Future<void> _load(Repository r) async {
    final home = await r.home(widget.homeId);
    final id = widget.supplierId;
    final s = id == null ? null : await r.supplier(id);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      if (s != null) {
        final input = SupplierInput.of(s);
        _name.text = input.name;
        _reference.text = input.reference;
        _url.text = input.url;
        _lastPrice.text = s.lastPrice == null
            ? ''
            : moneyFieldText(
                Localizations.localeOf(context).toLanguageTag(),
                stock.readQuantity(s.lastPrice!),
              );
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _reference, _url, _lastPrice]) {
      c.dispose();
    }
    super.dispose();
  }

  SupplierInput _input() => SupplierInput(
    name: _name.text,
    reference: _reference.text,
    url: _url.text,
    lastPrice: fieldAmount(context, _lastPrice),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(
      context,
      (r) => widget.supplierId == null
          ? r.addSupplier(widget.articleId, _input())
          : r.updateSupplier(widget.supplierId!, _input()),
    );
    if (saved) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteSupplier,
      body: l10n.deleteSupplierBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(context, (r) => r.deleteSupplier(widget.supplierId!))) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: widget.supplierId == null ? l10n.addSupplier : l10n.editSupplier,
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      actions: [HcBarAction(label: l10n.save, onPressed: _save)],
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
                    key: const Key('supplier-name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcText(
                    l10n.supplierReference,
                    _reference,
                    key: const Key('supplier-reference'),
                    sentences: false,
                  ),
                  hcText(
                    l10n.supplierUrl,
                    _url,
                    key: const Key('supplier-url'),
                    keyboard: TextInputType.url,
                    sentences: false,
                  ),
                  hcAmount(
                    context,
                    l10n.supplierLastPrice,
                    _lastPrice,
                    key: const Key('supplier-last-price'),
                    parse: stock.parseQuantity,
                    invalid: l10n.errQuantityInvalid,
                  ),
                  _help(l10n.supplierHelp(_currency)),
                ],
              ),
            ),
            if (widget.supplierId != null) ...[
              HcDeleteButton(
                key: const Key('supplier-delete'),
                label: l10n.deleteSupplier,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The materials of a task (`tasks/_materials.html`): the articles it needs
/// with the quantity and the stock now, flagged when the stock is short; a
/// line to add one, and a button to remove each.
class TaskMaterialsSection extends StatefulWidget {
  const TaskMaterialsSection({
    super.key,
    required this.homeId,
    required this.taskId,
    required this.writable,
  });

  final String homeId;
  final String taskId;
  final bool writable;

  @override
  State<TaskMaterialsSection> createState() => _TaskMaterialsState();
}

class _TaskMaterialsState extends State<TaskMaterialsSection> {
  final _quantity = TextEditingController(text: '1');
  String? _article;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = localeOf(context);
    return DataView<(List<MaterialEntry>, List<ArticleEntry>)>(
      load: (r) async =>
          (await r.materialsOf(widget.taskId), await r.articles(widget.homeId)),
      builder: (context, data) {
        final (lines, articles) = data;
        final listed = {for (final l in lines) l.article.id};
        final choices = [
          for (final a in articles)
            if (!listed.contains(a.article.id)) a.article,
        ];
        final chosen = choices.any((a) => a.id == _article)
            ? _article
            : (choices.isEmpty ? null : choices.first.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HcSectionHeading(l10n.materials),
            if (lines.isEmpty)
              HcEmpty(l10n.materialsEmpty)
            else
              HcCardList(
                children: [
                  for (final line in lines)
                    HcRow(
                      key: Key('material-${line.article.id}'),
                      title: line.article.name,
                      text: l10n.materialNeeds(
                        amountOf(l10n, locale, line.article, line.quantity),
                        formatQuantity(locale, line.level),
                      ),
                      pills: [
                        if (line.level < line.quantity)
                          HcPill(l10n.materialShort, tone: HcPillTone.warning),
                      ],
                      trailing: widget.writable
                          ? Semantics(
                              label: l10n.removeMaterial(line.article.name),
                              button: true,
                              excludeSemantics: true,
                              child: TextButton(
                                key: Key('material-remove-${line.article.id}'),
                                onPressed: () => runChange(
                                  context,
                                  (r) => r.removeMaterial(
                                    widget.taskId,
                                    line.article.id,
                                  ),
                                ),
                                child: Text(l10n.remove),
                              ),
                            )
                          : null,
                    ),
                ],
              ),
            if (widget.writable) ...[
              const SizedBox(height: HcSpace.s3),
              if (articles.isEmpty)
                Text(l10n.materialsNoArticle, style: HcText.bodySmall)
              else if (choices.isNotEmpty)
                HcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      hcChoice<String>(
                        l10n.materialArticle,
                        chosen!,
                        [for (final a in choices) (a.id, a.name)],
                        (v) => setState(() => _article = v),
                        key: const Key('material-article'),
                      ),
                      hcText(
                        l10n.movementQuantity,
                        _quantity,
                        key: const Key('material-quantity'),
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        sentences: false,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        // One line to fill, and « + » for the next one, as
                        // the web's form has it since its lot of 2026-11-15.
                        child: OutlinedButton.icon(
                          key: const Key('material-add'),
                          icon: const HcIcon(
                            HcIcons.add,
                            color: HcColors.primary,
                          ),
                          onPressed: () async {
                            if (await runChange(
                              context,
                              (r) => r.addMaterial(
                                widget.taskId,
                                chosen,
                                _quantity.text,
                              ),
                            )) {
                              _quantity.text = '1';
                            }
                          },
                          label: Text(l10n.addMaterial),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: HcSpace.s2),
                child: Text(l10n.materialsHelp, style: HcText.bodySmall),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// "Not enough in stock" after a closing, with the articles and what is
/// missing (`tasks/views.py`, "Not enough in stock, the stock is at zero").
String shortageMessage(
  AppLocalizations l10n,
  String locale,
  List<Shortage> short,
) => l10n.stockShortAfterDone(
  short
      .map(
        (s) =>
            '${s.article.name} (${amountOf(l10n, locale, s.article, s.missing)})',
      )
      .join(', '),
);
