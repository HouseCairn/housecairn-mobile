// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/costs.dart' as costs;
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'guide_screens.dart';
import 'stock_format.dart';
import 'parts.dart';
import 'state.dart';

/// The details of what was done (`tasks/completion_form.html`): the day it
/// was done, what it really cost and a note, for an occurrence that is done.
class OccurrenceScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const OccurrenceScreen({
    super.key,
    required this.homeId,
    required this.occurrenceId,
  });

  final String homeId;
  final String occurrenceId;

  @override
  State<OccurrenceScreen> createState() => _OccurrenceScreenState();
}

class _OccurrenceScreenState extends State<OccurrenceScreen> {
  final _form = GlobalKey<FormState>();
  final _cost = TextEditingController();
  final _note = TextEditingController();
  Day? _doneOn;
  String _currency = '';
  OccurrenceRow? _occurrence;
  costs.OccurrenceCost _real = costs.noCost;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final found = await repository.occurrence(widget.occurrenceId);
    final home = await repository.home(widget.homeId);
    if (found == null) return;
    final real = await repository.costsOf(widget.homeId, [found]);
    if (!mounted) return;
    setState(() {
      _occurrence = found;
      _real = real[found.id] ?? costs.noCost;
      _currency = home?.currency ?? '';
      _doneOn = found.completedOn == null
          ? null
          : Day.parse(found.completedOn!);
      _cost.text = found.actualCost == null
          ? ''
          : moneyFieldText(
              Localizations.localeOf(context).toLanguageTag(),
              budget.readMoney(found.actualCost!),
            );
      _note.text = found.completionNote;
    });
  }

  @override
  void dispose() {
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(
      context,
      (r) => r.updateOccurrence(
        widget.occurrenceId,
        completedOn: _doneOn,
        actualCost: fieldAmount(context, _cost),
        note: _note.text,
      ),
    );
    if (saved) navigator.pop();
  }

  /// What the real cost counts besides the amount typed
  /// (`budget/_occurrence_cost.html`): the stock used at its prices when
  /// taken, and the plan kept, counted when nothing is typed.
  List<Widget> _costParts(AppLocalizations l10n) {
    String money(Decimal value) => moneyIn(context, _currency, value);
    final stock = _real.stock;
    final planned = _real.planned;
    return [
      if (stock.any) ...[
        Text(
          l10n.stockUsed(money(stock.amount)),
          style: HcText.body,
          key: const Key('cost-stock-used'),
        ),
        smallNote(l10n.stockUsedHelp),
        if (stock.unpriced > 0) smallNote(l10n.stockUnpriced(stock.unpriced)),
      ],
      if (planned.known) ...[
        if (planned.labour != null)
          Text(
            l10n.labourPlanned(money(planned.labour!)),
            style: HcText.body,
            key: const Key('cost-labour-planned'),
          ),
        if (planned.material != null)
          Text(
            l10n.materialsPlanned(money(planned.material!)),
            style: HcText.body,
            key: const Key('cost-materials-planned'),
          ),
        smallNote(
          stock.any ? l10n.plannedCountsHelpStock : l10n.plannedCountsHelp,
        ),
      ],
      if (_real.estimated) smallNote(l10n.realCostEstimated),
      if (stock.any || planned.known) const SizedBox(height: HcSpace.s3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: l10n.occurrenceTitle,
      belowTitle: ExampleHomeBanner(homeId: widget.homeId),
      actions: [HcBarAction(label: l10n.save, onPressed: _save)],
      body: _occurrence == null
          ? const SizedBox.shrink()
          : Form(
              key: _form,
              child: HcScreenList(
                children: [
                  const SizedBox(height: HcSpace.s2),
                  HcDateField(
                    label: l10n.occurrenceDoneOn,
                    value: _doneOn,
                    noDate: l10n.todayNoDate,
                    clearable: false,
                    onChanged: (day) => setState(() => _doneOn = day),
                  ),
                  ..._costParts(l10n),
                  hcAmount(
                    context,
                    _real.stock.any ? l10n.otherCostsTitle : l10n.realCostTitle,
                    _cost,
                    key: const Key('cost-amount'),
                  ),
                  if (_real.stock.any && _real.planned.known)
                    fieldHelp(l10n.otherCostsHelpPlanned)
                  else if (_real.stock.any)
                    fieldHelp(l10n.otherCostsHelp)
                  else if (_real.planned.known)
                    fieldHelp(l10n.costHelpPlanned),
                  fieldHelp(l10n.amountIsIn(_currency)),
                  hcText(
                    l10n.note,
                    _note,
                    key: const Key('occurrence-note'),
                    minLines: 3,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
    );
  }
}
