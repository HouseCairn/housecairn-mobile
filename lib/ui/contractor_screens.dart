// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import 'guide_screens.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import 'choices.dart';
import 'parts.dart';
import 'state.dart';
import 'task_screen.dart';

/// What the list and the card say of the trade of a contractor: the list's
/// word, or what Other stands for (`Contractor.trade_label`).
String contractorTrade(AppLocalizations l10n, ContractorRow c) {
  if (c.trade == 'other') {
    return c.tradeOther.isEmpty ? l10n.tradeOther : c.tradeOther;
  }
  return tradeLabel(l10n, c.trade);
}

/// Contractors (docs/spec.md, "Screens of v1", 10): the people and companies
/// who work in the current home, by name.
class ContractorsScreen extends StatelessWidget {
  const ContractorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = AppScope.of(context).current;
    final writable = home != null && home.archivedAt == null;
    return HcScaffold(
      title: l10n.contractors,
      actions: const [HelpButton(page: HelpPages.contractors)],
      body: home == null
          ? const SizedBox.shrink()
          : DataView<List<ContractorRow>>(
              key: ValueKey(home.id),
              load: (r) => r.contractors(home.id),
              builder: (context, contractors) => HcScreenList(
                children: [
                  const SizedBox(height: HcSpace.s2),
                  if (contractors.isEmpty)
                    HcEmpty(l10n.contractorsEmpty)
                  else
                    HcCardList(
                      children: [
                        for (final c in contractors)
                          HcRow(
                            title: c.name,
                            text: [
                              contractorTrade(l10n, c),
                              c.phone,
                            ].where((t) => t.isNotEmpty).join(' · '),
                            onTap: () => Navigator.of(context).push(
                              hcRoute(
                                ContractorScreen(
                                  homeId: home.id,
                                  contractorId: c.id,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  // After the list, as on the web
                  // (`tasks/contractor_list.html`).
                  if (writable)
                    HcAddButton(
                      key: const Key('contractor-add'),
                      label: l10n.addContractor,
                      onPressed: () => Navigator.of(context)
                          .push(hcRoute(ContractorFormScreen(homeId: home.id))),
                    ),
                ],
              ),
            ),
    );
  }
}

/// A contractor's card: how to reach them, with a button to call and one to
/// write (they hand over to the phone's own apps), and the tasks that name
/// them.
class ContractorScreen extends StatelessWidget {
  const ContractorScreen({
    super.key,
    required this.homeId,
    required this.contractorId,
  });

  final String homeId;
  final String contractorId;

  Future<void> _open(BuildContext context, Uri address) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await state.openUrl(address)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.contractorCannotOpen)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.homes.where((h) => h.id == homeId).firstOrNull;
    final writable = home != null && home.archivedAt == null;
    return DataView<(ContractorRow?, List<TaskRow>)>(
      load: (r) async => (
        await r.contractor(contractorId),
        await r.tasksOfContractor(contractorId),
      ),
      builder: (context, data) {
        final (c, tasks) = data;
        if (c == null) {
          return HcScaffold(
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        final trade = contractorTrade(l10n, c);
        return HcScaffold(
          title: c.name,
          belowTitle: ExampleHomeBanner(homeId: homeId),
          actions: actionsOrHelp([
            if (writable)
              HcBarAction(
                label: l10n.edit,
                onPressed: () => Navigator.of(context).push(
                  hcRoute(
                    ContractorFormScreen(
                      homeId: homeId,
                      contractorId: contractorId,
                    ),
                  ),
                ),
              ),
          ], HelpPages.contractor),
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (trade.isNotEmpty)
                      HcFact(l10n.contractorTrade, factText(trade)),
                    if (c.phone.isNotEmpty)
                      HcFact(l10n.contractorPhone, factText(c.phone)),
                    if (c.email.isNotEmpty)
                      HcFact(l10n.contractorEmail, factText(c.email)),
                    if (c.address.isNotEmpty)
                      HcFact(l10n.contractorAddress, factText(c.address)),
                    if (c.note.isNotEmpty)
                      HcFact(l10n.contractorNote, factText(c.note)),
                    Wrap(
                      spacing: HcSpace.s2,
                      runSpacing: HcSpace.s2,
                      children: [
                        if (c.phone.isNotEmpty)
                          FilledButton(
                            key: const Key('contractor-call'),
                            onPressed: () => _open(
                              context,
                              Uri(scheme: 'tel', path: c.phone),
                            ),
                            child: Text(l10n.contractorCall),
                          ),
                        if (c.email.isNotEmpty)
                          OutlinedButton(
                            key: const Key('contractor-write'),
                            onPressed: () => _open(
                              context,
                              Uri(scheme: 'mailto', path: c.email),
                            ),
                            child: Text(l10n.contractorWrite),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              HcSectionHeading(l10n.tasks),
              if (tasks.isEmpty)
                HcEmpty(l10n.contractorNoTasks)
              else
                HcCardList(
                  children: [
                    for (final task in tasks)
                      HcRow(
                        title: task.title,
                        onTap: () => Navigator.of(context).push(
                          hcRoute(TaskScreen(homeId: homeId, taskId: task.id)),
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

/// The form of a contractor.
class ContractorFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const ContractorFormScreen({
    super.key,
    required this.homeId,
    this.contractorId,
  });

  final String homeId;

  /// `null` for a new contractor.
  final String? contractorId;

  @override
  State<ContractorFormScreen> createState() => _ContractorFormScreenState();
}

class _ContractorFormScreenState extends State<ContractorFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _tradeOther = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  String _trade = '';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded || widget.contractorId == null) return;
    _loaded = true;
    AppScope.of(context).repository.contractor(widget.contractorId!).then((c) {
      if (c == null || !mounted) return;
      setState(() {
        _name.text = c.name;
        _trade = c.trade;
        _tradeOther.text = c.tradeOther;
        _phone.text = c.phone;
        _email.text = c.email;
        _address.text = c.address;
        _note.text = c.note;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _tradeOther, _phone, _email, _address, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  ContractorInput _input() => ContractorInput(
    name: _name.text,
    trade: _trade,
    tradeOther: _tradeOther.text,
    phone: _phone.text,
    email: _email.text,
    address: _address.text,
    note: _note.text,
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(
      context,
      (r) => widget.contractorId == null
          ? r.addContractor(widget.homeId, _input())
          : r.updateContractor(widget.contractorId!, _input()),
    );
    if (saved) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteContractor,
      body: l10n.deleteContractorBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(
      context,
      (r) => r.deleteContractor(widget.contractorId!),
    )) {
      navigator.pop();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: widget.contractorId == null ? l10n.newContractor : l10n.contractor,
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
                    key: const Key('contractor-name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcChoice<String>(
                    l10n.contractorTrade,
                    _trade,
                    [
                      ('', ''),
                      for (final t in trades) (t, tradeLabel(l10n, t)),
                    ],
                    (v) => setState(() => _trade = v),
                    key: const Key('contractor-trade'),
                  ),
                  if (_trade == 'other')
                    hcText(
                      l10n.contractorTradeOther,
                      _tradeOther,
                      key: const Key('contractor-trade-other'),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? l10n.errTradeOther : null,
                    ),
                  hcText(
                    l10n.contractorPhone,
                    _phone,
                    key: const Key('contractor-phone'),
                    keyboard: TextInputType.phone,
                    sentences: false,
                    validator: (v) {
                      final text = (v ?? '').trim();
                      return text.isEmpty || phonePattern.hasMatch(text)
                          ? null
                          : l10n.errPhoneInvalid;
                    },
                  ),
                  hcText(
                    l10n.contractorEmail,
                    _email,
                    key: const Key('contractor-email'),
                    keyboard: TextInputType.emailAddress,
                    sentences: false,
                    validator: (v) {
                      final text = (v ?? '').trim();
                      return text.isEmpty || emailPattern.hasMatch(text)
                          ? null
                          : l10n.errEmailInvalid;
                    },
                  ),
                  hcText(
                    l10n.contractorAddress,
                    _address,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  hcText(l10n.contractorNote, _note, minLines: 2, maxLines: 6),
                ],
              ),
            ),
            if (widget.contractorId != null) ...[
              HcDeleteButton(
                key: const Key('contractor-delete'),
                label: l10n.deleteContractor,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
