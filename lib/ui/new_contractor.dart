// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import '../l10n/app_localizations.dart';
import 'choices.dart';
import 'parts.dart';

/// The choice Add a contractor…, the last of a list of contractors: the
/// fields of a new contractor open under the list, and it is made with the
/// row the form saves (`AddInPlaceChoiceField` of the web).
const newContractorChoice = '+new';

/// The choices of a list of contractors of a home: None, the contractors,
/// then Add a contractor… (`contract_contractor` of the web's item form,
/// `contractor` of its task form).
List<(String?, String)> contractorChoices(
  AppLocalizations l10n,
  List<ContractorRow> contractors,
) => [
  (null, l10n.contractNone),
  for (final c in contractors) (c.id, c.name),
  (newContractorChoice, l10n.taskAddContractor),
];

/// The value a list of [contractors] shows for [chosen]: a contractor that is
/// no longer in the home shows None.
String? shownContractor(String? chosen, List<ContractorRow> contractors) =>
    chosen == newContractorChoice || contractors.any((c) => c.id == chosen)
    ? chosen
    : null;

/// The name typed for a new contractor, its spaces as the web keeps them
/// (`" ".join(name.split())`).
String newContractorName(String typed) =>
    typed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).join(' ');

/// The fields of a contractor added in place, shared by every form that picks
/// a contractor (the task, the maintenance contract of an item), so that they
/// ask the same things in the same words (`new_contractor_fields` of the
/// web), and check them as `clean_new_contractor` does: a name, one that is
/// not already a contractor of the home whatever its case, and the words of
/// the trade Other.
class NewContractorFields {
  final name = TextEditingController();
  final other = TextEditingController();
  String trade = '';

  void dispose() {
    name.dispose();
    other.dispose();
  }

  /// What to create, once the form is valid.
  ContractorInput input() => ContractorInput(
    name: newContractorName(name.text),
    trade: trade,
    tradeOther: trade == 'other' ? other.text : '',
  );

  /// The heading and the fields, with keys `<prefix>-new-contractor-name`,
  /// `-trade` and `-other`; [contractors] are those of the home, for a name
  /// already taken.
  List<Widget> build(
    AppLocalizations l10n, {
    required String prefix,
    required List<ContractorRow> contractors,
    required void Function(VoidCallback change) setState,
  }) => [
    HcSectionHeading(l10n.taskNewContractor),
    hcText(
      l10n.taskNewContractorName,
      name,
      key: Key('$prefix-new-contractor-name'),
      validator: (value) {
        final typed = newContractorName(value ?? '');
        if (typed.isEmpty) return l10n.errNewContractorName;
        final folded = typed.toLowerCase();
        if (contractors.any((c) => c.name.toLowerCase() == folded)) {
          return l10n.errNewContractorTaken(typed);
        }
        return null;
      },
    ),
    hcChoice<String>(
      l10n.contractorTrade,
      trade,
      [('', ''), for (final t in trades) (t, tradeLabel(l10n, t))],
      (value) => setState(() => trade = value),
      key: Key('$prefix-new-contractor-trade'),
    ),
    if (trade == 'other')
      hcText(
        l10n.contractorTradeOther,
        other,
        key: Key('$prefix-new-contractor-other'),
        validator: (v) => (v ?? '').trim().isEmpty ? l10n.errTradeOther : null,
      ),
  ];
}
