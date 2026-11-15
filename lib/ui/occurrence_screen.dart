// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'parts.dart';
import 'state.dart';

/// The details of what was done (`tasks/completion_form.html`): the day it
/// was done, what it really cost and a note, for an occurrence that is done.
class OccurrenceScreen extends StatefulWidget {
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
    if (found == null || !mounted) return;
    setState(() {
      _occurrence = found;
      _currency = home?.currency ?? '';
      _doneOn = found.completedOn == null
          ? null
          : Day.parse(found.completedOn!);
      _cost.text = found.actualCost == null
          ? ''
          : budget.readMoney(found.actualCost!).toStringAsFixed(2);
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
        actualCost: _cost.text,
        note: _note.text,
      ),
    );
    if (saved) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.occurrenceTitle),
        actions: [HcBarAction(label: l10n.save, onPressed: _save)],
      ),
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
                  hcText(
                    l10n.realCostTitle,
                    _cost,
                    key: const Key('cost-amount'),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    sentences: false,
                    validator: moneyCheck(l10n),
                  ),
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
