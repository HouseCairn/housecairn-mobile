// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'home_selector.dart';
import 'messages.dart';
import 'parts.dart';
import 'project_screens.dart';
import 'state.dart';

/// Budget (`budget/overview.html`, `rooms.html`, `projects.html`,
/// `tasks.html`): the tabs Summary, Rooms, Projects and Upkeep of the web,
/// for one year of the current home, in its currency. Every figure is worked
/// out by lib/domain/budget.dart, as the web does; two homes are never added.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _tab = 0;
  int? _year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final home = state.current;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navBudget),
        actions: const [HomeSelector()],
      ),
      body: home == null
          ? const SizedBox.shrink()
          : DataView<budget.Ledger>(
              key: ValueKey('${home.id}|$_tab|$_year'),
              load: (r) => r.ledger(home.id),
              builder: (context, ledger) {
                final years = ledger.years();
                final year = years.contains(_year) ? _year! : ledger.today.year;
                final tabs = HcTabs(
                  key: const Key('budget-tabs'),
                  labels: [
                    l10n.budgetSummary,
                    l10n.budgetRooms,
                    l10n.budgetProjects,
                    l10n.budgetUpkeep,
                  ],
                  current: _tab,
                  onSelect: (i) => setState(() => _tab = i),
                );
                final choice = YearChoice(
                  years: years,
                  year: year,
                  onChanged: (y) => setState(() => _year = y),
                );
                return HcScreenList(
                  children: [
                    tabs,
                    ...switch (_tab) {
                      1 => _rooms(context, ledger, year, choice),
                      2 => _projects(context, ledger),
                      3 => _upkeep(context, ledger, year, choice),
                      _ => _summary(context, ledger, year, choice, home.id),
                    },
                    const SizedBox(height: HcSpace.s5),
                  ],
                );
              },
            ),
    );
  }

  List<Widget> _summary(
    BuildContext context,
    budget.Ledger ledger,
    int year,
    Widget choice,
    String homeId,
  ) {
    final l10n = AppLocalizations.of(context);
    final c = ledger.currency;
    String m(Decimal v) => moneyIn(context, c, v);
    final e = budget.envelope(ledger, year);
    final writable = AppScope.of(context).current?.archivedAt == null;
    final r = budget.rolling(ledger);
    return [
      choice,
      HcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.envelopeYear(year), style: HcText.cardTitle),
            const SizedBox(height: HcSpace.s2),
            if (e.envelope == null)
              Text(l10n.envelopeNoneSummary, style: HcText.bodySmall),
            HcFact(
              e.envelope == null ? l10n.amountPlanned : l10n.envelope,
              factText(m(e.setAside)),
            ),
            HcFact(l10n.spent, factText(m(e.spent))),
            HcFact(
              l10n.left,
              factText(
                e.left < budget.zero ? l10n.overBy(m(e.leftOver)) : m(e.left),
              ),
            ),
            if (e.percent != null)
              Padding(
                padding: const EdgeInsets.only(top: HcSpace.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: l10n.spentAgainst,
                      value: '${e.percent} %',
                      child: LinearProgressIndicator(
                        key: const Key('envelope-gauge'),
                        value: e.gaugeValue / 100,
                        minHeight: HcSpace.s2,
                      ),
                    ),
                    const SizedBox(height: HcSpace.s1),
                    Text(
                      e.left < budget.zero
                          ? l10n.percentSpentOver(e.percent!)
                          : l10n.percentSpent(e.percent!),
                      style: HcText.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: HcSpace.s2),
            _Details(
              key: const Key('envelope-details'),
              title: l10n.detailsOfYear,
              children: [
                if (e.envelope != null) ...[
                  HcFact(l10n.plannedAll, factText(m(e.total.planned))),
                  HcFact(
                    l10n.leftToPlan,
                    factText(
                      e.leftToPlan! < budget.zero
                          ? l10n.plansExceed(m(e.leftToPlan!))
                          : m(e.leftToPlan!),
                    ),
                  ),
                ],
                HcFact(l10n.amountPaid, factText(m(e.total.paid))),
                HcFact(
                  l10n.budgetProjects,
                  factText(
                    l10n.plannedPaid(m(e.projects.planned), m(e.projects.paid)),
                  ),
                ),
                HcFact(
                  l10n.budgetUpkeep,
                  factText(
                    l10n.plannedPaid(m(e.upkeep.planned), m(e.upkeep.paid)),
                  ),
                ),
                smallNote(l10n.spentExplained),
              ],
            ),
            if (writable)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(
                  key: const Key('budget-envelope-set'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EnvelopeFormScreen(homeId: homeId),
                    ),
                  ),
                  child: Text(l10n.envelopeSet),
                ),
              ),
          ],
        ),
      ),
      HcSectionHeading(l10n.byNature(year)),
      HcCardList(
        children: [
          for (final line in budget.byNature(ledger, year))
            AmountCard(
              key: Key('nature-${line.label}'),
              title: natureLabel(l10n, line.label),
              amounts: line.amounts,
              currency: c,
            ),
        ],
      ),
      smallNote(l10n.natureExplained),
      HcSectionHeading(l10n.byYear),
      HcCardList(
        children: [
          for (final line in budget.byYear(ledger))
            AmountCard(
              key: Key('year-${line.year}'),
              title: '${line.year}',
              subtitle:
                  '${l10n.envelope} : '
                  '${line.envelope == null ? '—' : m(line.envelope!)}',
              amounts: line.total,
              currency: c,
            ),
        ],
      ),
      HcSectionHeading(l10n.last12Months),
      HcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.rollingExplained(
                formatDay(context, r.since),
                formatDay(context, r.until),
              ),
              style: HcText.bodySmall,
            ),
            const SizedBox(height: HcSpace.s2),
            HcFact(l10n.amountPlanned, factText(m(r.upkeep.planned))),
            HcFact(l10n.amountPaid, factText(m(r.upkeep.paid))),
            if (gapPills(r.upkeep, c).isNotEmpty)
              HcFact(l10n.whereItStands, GapPill(r.upkeep, c)),
            if (r.missing > 0) smallNote(l10n.missingCosts(r.missing)),
          ],
        ),
      ),
    ];
  }

  List<Widget> _rooms(
    BuildContext context,
    budget.Ledger ledger,
    int year,
    Widget choice,
  ) {
    final l10n = AppLocalizations.of(context);
    final report = budget.byRoom(ledger, year);
    return [
      choice,
      if (report.lines.isEmpty)
        HcEmpty(l10n.roomsBudgetEmpty)
      else
        HcCardList(
          children: [
            for (final line in report.lines)
              AmountCard(
                key: Key('budget-room-${line.id ?? 'none'}'),
                title: line.id == null ? l10n.noRoom : line.label,
                amounts: line.amounts,
                currency: ledger.currency,
              ),
            AmountCard(
              key: const Key('budget-rooms-total'),
              title: l10n.total,
              amounts: report.total,
              currency: ledger.currency,
            ),
          ],
        ),
      smallNote(l10n.roomsExplained(year)),
    ];
  }

  List<Widget> _projects(BuildContext context, budget.Ledger ledger) {
    final l10n = AppLocalizations.of(context);
    final c = ledger.currency;
    final report = budget.byProject(ledger);
    final home = AppScope.of(context).current!;
    return [
      if (report.lines.isEmpty)
        HcEmpty(l10n.projectsEmptyShort)
      else
        HcCardList(
          children: [
            for (final line in report.lines)
              AmountCard(
                key: Key('budget-project-${line.id}'),
                title: line.label,
                subtitle: [
                  projectStatusLabel(l10n, line.extra['status']! as String),
                  l10n.countedIn(line.extra['year']! as int),
                  if (line.extra['tasks_planned'] != budget.zero)
                    l10n.plannedByTasks(
                      moneyIn(
                        context,
                        c,
                        line.extra['tasks_planned']! as Decimal,
                      ),
                    ),
                ].join(' · '),
                amounts: line.amounts,
                currency: c,
                toPay: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ProjectScreen(homeId: home.id, projectId: line.id!),
                  ),
                ),
              ),
            AmountCard(
              key: const Key('budget-projects-total'),
              title: l10n.total,
              amounts: report.total,
              currency: c,
              toPay: true,
            ),
          ],
        ),
      smallNote(l10n.projectsCountedExplained),
      smallNote(l10n.projectsPlannedExplained),
    ];
  }

  List<Widget> _upkeep(
    BuildContext context,
    budget.Ledger ledger,
    int year,
    Widget choice,
  ) {
    final l10n = AppLocalizations.of(context);
    final c = ledger.currency;
    String m(Decimal v) => moneyIn(context, c, v);
    final report = budget.byTask(ledger, year);
    return [
      choice,
      if (report.lines.isEmpty)
        HcEmpty(l10n.upkeepEmpty)
      else
        HcCardList(
          children: [
            for (final line in report.lines)
              Padding(
                key: Key('budget-task-${line.id}'),
                padding: const EdgeInsets.all(HcSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(line.label, style: HcText.cardTitle),
                    const SizedBox(height: HcSpace.s2),
                    if (line.extra['estimate'] case final Decimal estimate)
                      HcFact(l10n.estimateEachTime, factText(m(estimate))),
                    if (line.extra['stock_estimate'] case final Decimal s
                        when s != budget.zero)
                      HcFact(l10n.ofWhichStock, factText(m(s))),
                    if (line.extra['annual_cost'] case final Decimal a)
                      HcFact(l10n.costAYear, factText(m(a))),
                    AmountFacts(line.amounts, c),
                    HcFact(
                      l10n.paidInAll,
                      factText(m(line.extra['total_paid']! as Decimal)),
                    ),
                    if ((line.extra['missing_costs']! as int) > 0)
                      smallNote(
                        l10n.missingCosts(line.extra['missing_costs']! as int),
                      ),
                    if ((line.extra['unpriced_materials']! as int) > 0)
                      smallNote(
                        l10n.unpricedMaterials(
                          line.extra['unpriced_materials']! as int,
                        ),
                      ),
                  ],
                ),
              ),
            AmountCard(
              key: const Key('budget-tasks-total'),
              title: l10n.total,
              amounts: report.total,
              currency: c,
            ),
          ],
        ),
      if ((report.note['unlisted'] ?? 0) > 0)
        smallNote(l10n.unlistedTasks(report.note['unlisted']!)),
      smallNote(l10n.costAYearExplained),
    ];
  }
}

/// A part that unfolds, as the web's `<details>`: its title is a button
/// that says whether it is open.
class _Details extends StatefulWidget {
  const _Details({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        button: true,
        expanded: _open,
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HcLayout.touchTargetLg,
            ),
            child: Row(
              children: [
                Icon(_open ? Icons.expand_less : Icons.expand_more),
                const SizedBox(width: HcSpace.s2),
                Expanded(child: Text(widget.title, style: HcText.body)),
              ],
            ),
          ),
        ),
      ),
      if (_open) ...widget.children,
    ],
  );
}
