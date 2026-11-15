// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../l10n/app_localizations.dart';
import 'parts.dart';
import 'stock_format.dart';

/// [value] in [currency], in the language of the phone (never `double`).
String moneyIn(BuildContext context, String currency, Decimal value) =>
    formatMoney(
      Localizations.localeOf(context).toLanguageTag(),
      currency,
      value,
    );

String projectStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'in_progress' => l10n.projectInProgress,
      'planned' => l10n.projectPlanned,
      'done' => l10n.projectFinished,
      'abandoned' => l10n.projectAbandoned,
      _ => l10n.projectIdea,
    };

List<(String, String)> projectStatusChoices(AppLocalizations l10n) => [
  for (final s in const ['idea', 'planned', 'in_progress', 'done', 'abandoned'])
    (s, projectStatusLabel(l10n, s)),
];

String natureLabel(AppLocalizations l10n, String nature) => switch (nature) {
  budget.material => l10n.natureMaterial,
  budget.labour => l10n.natureLabour,
  budget.rental => l10n.natureRental,
  _ => l10n.natureOther,
};

List<(String, String)> natureChoices(AppLocalizations l10n) => [
  for (final n in budget.natures) (n, natureLabel(l10n, n)),
];

String quoteStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'received' => l10n.quoteReceived,
      'accepted' => l10n.quoteAccepted,
      'rejected' => l10n.quoteRejected,
      _ => l10n.quoteRequested,
    };

List<(String, String)> quoteStatusChoices(AppLocalizations l10n) => [
  for (final s in budget.quoteStatuses) (s, quoteStatusLabel(l10n, s)),
];

/// The gap in words, never by colour alone (`projects/_gap.html`); nothing
/// when nothing is planned, committed nor paid.
class GapPill extends StatelessWidget {
  const GapPill(this.amounts, this.currency, {super.key});

  final budget.Amounts amounts;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = amounts;
    if (a.planned == budget.zero &&
        a.committed == budget.zero &&
        a.paid == budget.zero) {
      return const SizedBox.shrink();
    }
    return switch (a.state) {
      'over' => HcPill(
        l10n.overBudgetBy(moneyIn(context, currency, a.overBy)),
        tone: HcPillTone.warning,
      ),
      'under' => HcPill(
        l10n.amountLeft(moneyIn(context, currency, a.gap)),
        tone: HcPillTone.success,
      ),
      _ => HcPill(l10n.onBudget, tone: HcPillTone.info),
    };
  }
}

List<Widget> gapPills(budget.Amounts amounts, String currency) => [
  if (amounts.planned != budget.zero ||
      amounts.committed != budget.zero ||
      amounts.paid != budget.zero)
    GapPill(amounts, currency),
];

/// The amounts of a row of a budget table (`budget/_row_amounts.html`), as
/// the stacked table of the web reads on a phone: one fact per column.
class AmountFacts extends StatelessWidget {
  const AmountFacts(this.amounts, this.currency, {super.key, this.toPay});

  final budget.Amounts amounts;
  final String currency;

  /// Shows Still to pay too (the table of the projects).
  final bool? toPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String m(Decimal v) => moneyIn(context, currency, v);
    final a = amounts;
    final used = budget.usedPercent(a);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HcFact(l10n.amountPlanned, factText(m(a.planned))),
        HcFact(l10n.amountCommitted, factText(m(a.committed))),
        HcFact(l10n.amountPaid, factText(m(a.paid))),
        HcFact(
          l10n.amountUsed,
          factText(
            used == null
                ? m(a.engaged)
                : '${m(a.engaged)} · ${l10n.percentUsed(used)}',
          ),
        ),
        if (toPay ?? false) HcFact(l10n.stillToPay, factText(m(a.toPay))),
        if (gapPills(a, currency).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: HcSpace.s1),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: GapPill(a, currency),
            ),
          ),
      ],
    );
  }
}

/// A card with a title and the amounts under it.
class AmountCard extends StatelessWidget {
  const AmountCard({
    super.key,
    required this.title,
    required this.amounts,
    required this.currency,
    this.subtitle,
    this.toPay = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final budget.Amounts amounts;
  final String currency;
  final bool toPay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(HcSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: HcText.cardTitle),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: HcSpace.s1),
              child: Text(subtitle!, style: HcText.bodySmall),
            ),
          const SizedBox(height: HcSpace.s2),
          AmountFacts(amounts, currency, toPay: toPay),
        ],
      ),
    );
    return onTap == null ? body : InkWell(onTap: onTap, child: body);
  }
}

/// The help under a field.
Widget fieldHelp(String text) => Padding(
  padding: const EdgeInsets.only(bottom: HcSpace.s3),
  child: Text(text, style: HcText.bodySmall),
);

/// A validator of an optional amount of money.
String? Function(String?) moneyCheck(AppLocalizations l10n) => (value) {
  final text = (value ?? '').trim();
  return text.isEmpty || budget.parseMoney(text) != null
      ? null
      : l10n.errMoneyInvalid;
};

/// Chips to choose several among [choices].
Widget choiceChips(
  String label,
  List<(String, String)> choices,
  Set<String> chosen,
  void Function(String id, bool on) onChanged, {
  required String keyPrefix,
}) => HcField(
  label: label,
  child: Wrap(
    spacing: HcSpace.s2,
    runSpacing: HcSpace.s2,
    children: [
      for (final (id, name) in choices)
        FilterChip(
          key: Key('$keyPrefix-$id'),
          label: Text(name),
          selected: chosen.contains(id),
          onSelected: (on) => onChanged(id, on),
        ),
    ],
  ),
);

/// The years of the budget, the latest first, to choose one.
class YearChoice extends StatelessWidget {
  const YearChoice({
    super.key,
    required this.years,
    required this.year,
    required this.onChanged,
  });

  final List<int> years;
  final int year;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return hcChoice<int>(
      l10n.budgetYear,
      year,
      [for (final y in years) (y, '$y')],
      onChanged,
      key: const Key('budget-year'),
    );
  }
}

/// A small line of text under a table.
Widget smallNote(String text) => Padding(
  padding: const EdgeInsets.only(top: HcSpace.s2),
  child: Text(
    text,
    style: HcText.bodySmall.copyWith(color: HcColors.textMuted),
  ),
);
