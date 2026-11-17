// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'home_selector.dart';
import 'messages.dart';
import 'parts.dart';
import 'project_screens.dart';
import 'state.dart';
import 'help_button.dart';

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
    return HcScaffold(
      // The `h1` of each tab of the web: Budget, Budget by room, by project,
      // of the upkeep.
      title: switch (_tab) {
        1 => l10n.budgetByRoom,
        2 => l10n.budgetByProject,
        3 => l10n.budgetOfUpkeep,
        _ => l10n.navBudget,
      },
      brand: true,
      belowTitle: const HomeSelector(),
      actions: const [HelpButton(page: HelpPages.budget)],
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
            // The `h2` of the card, in small capitals as every `h2` of the
            // web, with its margins.
            HcSectionHeading(
              l10n.envelopeYear(year),
              key: const Key('envelope-heading'),
            ),
            if (e.envelope == null)
              Text(l10n.envelopeNoneSummary, style: HcText.bodySmall),
            HcValueList(
              children: [
                HcValueRow(
                  e.envelope == null ? l10n.amountPlanned : l10n.envelope,
                  m(e.setAside),
                ),
                HcValueRow(l10n.spent, m(e.spent)),
                HcValueRow(
                  l10n.left,
                  e.left < budget.zero ? l10n.overBy(m(e.leftOver)) : m(e.left),
                ),
              ],
            ),
            if (e.percent != null)
              Padding(
                padding: const EdgeInsets.only(top: HcSpace.s3),
                child: HcProgress(
                  key: const Key('envelope-gauge'),
                  percent: e.left < budget.zero ? e.percent! : e.gaugeValue,
                  text: e.left < budget.zero
                      ? l10n.percentSpentOver(e.percent!)
                      : l10n.percentSpent(e.percent!),
                  label: l10n.spentAgainst,
                ),
              ),
            // A folded section, as the forms (`details.form-section`).
            HcFoldSection(
              key: const Key('envelope-details'),
              title: l10n.detailsOfYear,
              children: [
                HcValueList(
                  children: [
                    if (e.envelope != null) ...[
                      HcValueRow(l10n.plannedAll, m(e.total.planned)),
                      HcValueRow(
                        l10n.leftToPlan,
                        e.leftToPlan! < budget.zero
                            ? l10n.plansExceed(m(e.leftToPlan!))
                            : m(e.leftToPlan!),
                      ),
                    ],
                    HcValueRow(l10n.amountPaid, m(e.total.paid)),
                    HcValueRow(
                      l10n.budgetProjects,
                      l10n.plannedPaid(
                        m(e.projects.planned),
                        m(e.projects.paid),
                      ),
                    ),
                    HcValueRow(
                      l10n.budgetUpkeep,
                      l10n.plannedPaid(m(e.upkeep.planned), m(e.upkeep.paid)),
                    ),
                  ],
                ),
                smallNote(l10n.spentExplained),
              ],
            ),
            if (writable)
              Padding(
                padding: const EdgeInsets.only(top: HcSpace.s3),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton(
                    key: const Key('budget-envelope-set'),
                    onPressed: () =>
                        Navigator.of(context)
                            .push(hcRoute(EnvelopeFormScreen(homeId: homeId))),
                    child: Text(l10n.envelopeSet),
                  ),
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
            HcValueList(
              children: [
                HcValueRow(l10n.amountPlanned, m(r.upkeep.planned)),
                HcValueRow(l10n.amountPaid, m(r.upkeep.paid)),
                if (gapPills(r.upkeep, c).isNotEmpty)
                  HcValueRow(
                    l10n.whereItStands,
                    '',
                    child: GapPill(r.upkeep, c),
                  ),
              ],
            ),
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
      // What the tab counts, under the year, as the web.
      smallNote(l10n.roomsExplained(year)),
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
    ];
  }

  List<Widget> _projects(BuildContext context, budget.Ledger ledger) {
    final l10n = AppLocalizations.of(context);
    final c = ledger.currency;
    final report = budget.byProject(ledger);
    final home = AppScope.of(context).current!;
    return [
      smallNote(l10n.projectsCountedExplained),
      smallNote(l10n.projectsPlannedExplained),
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
                  hcRoute(ProjectScreen(homeId: home.id, projectId: line.id!)),
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
      smallNote(l10n.upkeepExplained(year)),
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
                    HcValueList(
                      dense: true,
                      children: [
                        if (line.extra['estimate'] case final Decimal estimate)
                          HcValueRow(
                            l10n.estimateEachTime,
                            m(estimate),
                            dense: true,
                          ),
                        if (line.extra['stock_estimate'] case final Decimal s
                            when s != budget.zero)
                          HcValueRow(l10n.ofWhichStock, m(s), dense: true),
                        if (line.extra['annual_cost'] case final Decimal a)
                          HcValueRow(l10n.costAYear, m(a), dense: true),
                        HcValueRow(
                          l10n.paidInAll,
                          m(line.extra['total_paid']! as Decimal),
                          dense: true,
                        ),
                      ],
                    ),
                    AmountFacts(line.amounts, c),
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
