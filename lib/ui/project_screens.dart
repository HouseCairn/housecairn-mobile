// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/adaptive.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/day.dart';
import '../domain/durations.dart' as durations;
import '../domain/recurrence.dart' as recurrence;
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'stock_format.dart';
import 'home_selector.dart';
import 'messages.dart';
import 'parts.dart';
import 'state.dart';
import 'rooms.dart';
import 'task_screen.dart';
import 'help_button.dart';

/// The statuses of each tab of Projects, as on the web (`PROJECT_VIEWS` of
/// `core/templatetags/tabs.py`): what is going on, the ideas, what is over.
const projectTabs = [
  ['in_progress', 'planned'],
  ['idea'],
  ['done', 'abandoned'],
];

void _open(BuildContext context, Widget screen) =>
    Navigator.of(context).push(hcRoute(screen));

/// Projects (`projects/project_list.html`): the tabs by status, the envelope
/// of the year, the projects of the tab with their budget and gap.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _tab = 0;

  /// The mode of comparison (`?compare=1`): the rows are ticked instead of
  /// opened (web `design/patterns.md`, Platform adaptations, row 12).
  bool _comparing = false;
  final _ticked = <String>{};

  void _leaveComparison() => setState(() {
    _comparing = false;
    _ticked.clear();
  });

  void _tick(String id) => setState(() {
    if (!_ticked.remove(id)) _ticked.add(id);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = AppScope.of(context).current;
    if (home == null) {
      return HcScaffold(
        title: l10n.navProjects,
        brand: true,
        belowTitle: const HomeSelector(),
        actions: const [HelpButton(page: HelpPages.projects)],
      );
    }
    final ios = hcCupertino(Theme.of(context).platform);
    return DataView<(List<ProjectEntry>, Map<int, Decimal>)>(
      key: ValueKey('${home.id}|$_tab'),
      load: (r) async =>
          (await r.projects(home.id), await r.envelopesOf(home.id)),
      builder: (context, data) {
        final (all, envelopes) = data;
        final year = AppScope.of(context).repository.today().year;
        final envelope = envelopes[year];
        final active = _activeTotal(all);
        final shown = [
          for (final e in all)
            if (projectTabs[_tab].contains(e.project.status)) e,
        ];
        final writable = home.archivedAt == null;
        final currency = home.currency;
        String m(Decimal v) => moneyIn(context, currency, v);
        // As on the web, the comparison is offered from two projects in the
        // tab on (`len(projects) > 1`).
        final canCompare = shown.length > 1;
        final comparing = _comparing && canCompare;
        return HcScaffold(
          title: l10n.navProjects,
          brand: true,
          belowTitle: const HomeSelector(),
          actions: [
            // iPhone: Select in the bar starts the selection (row 12).
            if (ios && canCompare && !comparing)
              HcBarAction(
                key: const Key('projects-select'),
                label: l10n.selectRows,
                besideBrand: true,
                onPressed: () => setState(() => _comparing = true),
              ),
            const HelpButton(page: HelpPages.projects),
          ],
          body: HcScreenList(
            children: [
              HcTabs(
                key: const Key('projects-tabs'),
                labels: [
                  l10n.projectsInProgress,
                  l10n.projectsIdeas,
                  l10n.projectsFinished,
                ],
                current: _tab,
                onSelect: (i) => setState(() {
                  _tab = i;
                  _comparing = false;
                  _ticked.clear();
                }),
              ),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The `h2` of the card, in small capitals as every
                    // `h2` of the web, with its margins.
                    HcSectionHeading(
                      l10n.envelopeOfYear(year),
                      key: const Key('projects-envelope-heading'),
                    ),
                    if (envelope == null)
                      Text(l10n.envelopeNone, style: HcText.bodySmall)
                    else
                      HcValueList(
                        children: [
                          HcValueRow(l10n.envelope, m(envelope)),
                          HcValueRow(
                            l10n.envelopePlannedActive,
                            m(active.planned),
                          ),
                          HcValueRow(l10n.envelopePaidSoFar, m(active.paid)),
                          HcValueRow(
                            l10n.envelopeLeft,
                            envelope - active.planned < budget.zero
                                ? l10n.overTheEnvelope(
                                    m(envelope - active.planned),
                                  )
                                : m(envelope - active.planned),
                          ),
                        ],
                      ),
                    if (writable)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton(
                          key: const Key('envelope-set'),
                          onPressed: () => _open(
                            context,
                            EnvelopeFormScreen(homeId: home.id),
                          ),
                          child: Text(l10n.envelopeSet),
                        ),
                      ),
                  ],
                ),
              ),
              if (shown.isEmpty)
                HcEmpty(
                  all.isEmpty ? l10n.projectsEmpty : l10n.projectsNoneInTab,
                )
              else
                // A group per status, under its heading, in the order
                // of the web (`STATUS_ORDER`), as the list gives them.
                for (final status in budget.projectStatuses)
                  if (shown.any((e) => e.project.status == status)) ...[
                    HcSectionHeading(
                      projectStatusLabel(l10n, status),
                      key: Key('projects-group-$status'),
                    ),
                    HcCardList(
                      children: [
                        for (final e in shown)
                          if (e.project.status == status)
                            _projectRow(
                              context,
                              e,
                              home.id,
                              currency,
                              comparing: comparing,
                              // Android: a long press starts the
                              // selection with the row (row 12).
                              onLongPress: !ios && canCompare && !comparing
                                  ? () => setState(() {
                                      _comparing = true;
                                      _ticked.add(e.project.id);
                                    })
                                  : null,
                            ),
                      ],
                    ),
                  ],
              if (comparing)
                Padding(
                  padding: const EdgeInsets.only(top: HcSpace.s3),
                  child: Wrap(
                    spacing: HcSpace.s2,
                    runSpacing: HcSpace.s2,
                    children: [
                      FilledButton(
                        key: const Key('projects-compare-ticked'),
                        onPressed: () => _compare(context, home.id, [
                          for (final e in shown)
                            if (_ticked.contains(e.project.id)) e.project.id,
                        ]),
                        child: Text(
                          l10n.compareTicked,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      OutlinedButton(
                        key: const Key('projects-compare-cancel'),
                        onPressed: _leaveComparison,
                        child: Text(l10n.cancel),
                      ),
                    ],
                  ),
                )
              else if (canCompare)
                HcAddButton(
                  key: const Key('projects-compare'),
                  label: l10n.compareProjects,
                  primary: false,
                  onPressed: () => setState(() => _comparing = true),
                ),
              if (writable)
                HcAddButton(
                  key: const Key('project-add'),
                  label: l10n.addProject,
                  primary: false,
                  gap: shown.isEmpty ? HcSpace.s2 : HcSpace.s3,
                  onPressed: () => _add(context, home.id),
                ),
            ],
          ),
        );
      },
    );
  }

  /// A row of the list: it opens its project, or in the mode of comparison
  /// it is ticked from anywhere (the web's `label.row` around its box), one
  /// target, said as one check box with the title.
  Widget _projectRow(
    BuildContext context,
    ProjectEntry e,
    String homeId,
    String currency, {
    required bool comparing,
    VoidCallback? onLongPress,
  }) {
    final l10n = AppLocalizations.of(context);
    String m(Decimal v) => moneyIn(context, currency, v);
    final ticked = _ticked.contains(e.project.id);
    final row = HcRow(
      key: Key('project-${e.project.id}'),
      title: e.project.title,
      text: [
        if (e.amounts.planned != budget.zero ||
            e.amounts.committed != budget.zero ||
            e.amounts.paid != budget.zero)
          l10n.plannedAmount(m(e.amounts.planned))
        else
          l10n.noBudgetYet,
        if (e.project.priority == 'high') l10n.highPriority,
      ].join(' · '),
      pills: gapPills(e.amounts, currency),
      trailing: comparing
          ? ExcludeSemantics(
              child: Checkbox.adaptive(
                key: Key('project-tick-${e.project.id}'),
                value: ticked,
                activeColor: HcColors.primary,
                // The border of a field (`--hc-color-border-strong`), so the
                // empty box stands out as a control, 3:1 at least.
                side: const BorderSide(
                  color: HcColors.borderStrong,
                  width: HcComponent.iconStroke,
                ),
                onChanged: (_) => _tick(e.project.id),
              ),
            )
          : null,
      onTap: comparing
          ? () => _tick(e.project.id)
          : () => _open(
              context,
              ProjectScreen(homeId: homeId, projectId: e.project.id),
            ),
      onLongPress: onLongPress,
    );
    if (!comparing) return row;
    return Semantics(
      checked: ticked,
      inMutuallyExclusiveGroup: false,
      child: row,
    );
  }

  /// Opens the comparison of [ids], in the order of the list (the web sends
  /// the boxes of its form in the order of the page).
  Future<void> _compare(
    BuildContext context,
    String homeId,
    List<String> ids,
  ) =>
      Navigator.of(context)
          .push(hcRoute(ProjectCompareScreen(homeId: homeId, projectIds: ids)));

  /// Created from the list of its own section, the new project opens (web
  /// design guide, After a form): the next step is there, a quote or a
  /// budget line. Back from it returns to this list, on the same tab.
  Future<void> _add(BuildContext context, String homeId) async {
    final navigator = Navigator.of(context);
    final id = await navigator.push(
      hcRouteOf<String?>(ProjectFormScreen(homeId: homeId)),
    );
    if (id == null || !mounted) return;
    await navigator.push(hcRoute(ProjectScreen(homeId: homeId, projectId: id)));
  }

  /// What the projects going on plan and paid (`envelope_summary`).
  static budget.Amounts _activeTotal(List<ProjectEntry> all) => budget.sumOf([
    for (final e in all)
      if (const ['in_progress', 'planned', 'idea'].contains(e.project.status))
        e.amounts,
  ]);
}

/// Compare projects (`projects/compare.html`): the projects ticked in the
/// list side by side, at most six, in a table read column by column (web
/// design guide, Tables on a phone): status, planned cost, what accepted
/// quotes commit, duration, priority and season, in the currency of the home.
/// A row opens its project. With fewer than two, it asks to tick more.
class ProjectCompareScreen extends StatelessWidget {
  const ProjectCompareScreen({
    super.key,
    required this.homeId,
    required this.projectIds,
  });

  final String homeId;
  final List<String> projectIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<(HomeRow?, List<ProjectEntry>)>(
      load: (r) async =>
          (await r.home(homeId), await r.compareProjects(homeId, projectIds)),
      builder: (context, data) {
        final (home, rows) = data;
        if (home == null) return HcScaffold();
        String m(Decimal v) => moneyIn(context, home.currency, v);
        String? season(String code) => switch (code) {
          recurrence.spring => l10n.seasonSpring,
          recurrence.summer => l10n.seasonSummer,
          recurrence.autumn => l10n.seasonAutumn,
          recurrence.winter => l10n.seasonWinter,
          recurrence.custom => l10n.seasonCustom,
          _ => null,
        };
        String priority(String code) => switch (code) {
          'high' => l10n.priorityHigh,
          'low' => l10n.priorityLow,
          _ => l10n.priorityNormal,
        };
        const none = '\u2014';
        return HcScaffold(
          title: l10n.compareProjects,
          actions: const [HelpButton(page: HelpPages.projects)],
          body: HcScreenList(
            children: [
              if (rows.length < 2)
                HcEmpty(l10n.compareTickTwo)
              else
                HcColumnTable(
                  key: const Key('project-compare-table'),
                  label: l10n.compareCaption,
                  head: [
                    l10n.compareProject,
                    l10n.status,
                    l10n.comparePlannedCost,
                    l10n.amountCommitted,
                    l10n.compareDuration,
                    l10n.priority,
                    l10n.season,
                  ],
                  rows: [
                    for (final e in rows)
                      HcTableRow(
                        key: Key('compare-${e.project.id}'),
                        head: e.project.title,
                        cells: [
                          projectStatusLabel(l10n, e.project.status),
                          m(e.amounts.planned),
                          m(e.amounts.committed),
                          switch (e.project.estimatedMinutes) {
                            final int minutes when minutes > 0 => durationLabel(
                              l10n,
                              minutes,
                            ),
                            _ => none,
                          },
                          priority(e.project.priority),
                          season(e.project.season) ?? none,
                        ],
                        onTap: () => _open(
                          context,
                          ProjectScreen(
                            homeId: homeId,
                            projectId: e.project.id,
                          ),
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

class _ProjectData {
  _ProjectData(
    this.home,
    this.project,
    this.rooms,
    this.lines,
    this.quotes,
    this.tasks,
    this.links,
    this.files,
    this.attachable,
  );

  final HomeRow home;
  final ProjectRow project;
  final List<RoomRow> rooms;
  final List<LineEntry> lines;
  final List<QuoteEntry> quotes;
  final List<TaskEntry> tasks;
  final List<ProjectLinkRow> links;
  final List<ProjectFileRow> files;
  final List<TaskRow> attachable;
}

/// A project (`projects/project_detail.html`): its pills, title, goal and
/// rooms, then, in the order of the web, its tasks, its budget lines with
/// the three amounts and the gap, its quotes, its links of inspiration
/// (opened in the browser of the phone, never read) and its files.
class ProjectScreen extends StatelessWidget {
  const ProjectScreen({
    super.key,
    required this.homeId,
    required this.projectId,
  });

  final String homeId;
  final String projectId;

  Future<_ProjectData?> _load(Repository r) async {
    final home = await r.home(homeId);
    final project = await r.project(projectId);
    if (home == null || project == null) return null;
    return _ProjectData(
      home,
      project,
      await r.roomsOfProject(projectId),
      await r.linesOf(projectId),
      await r.quotesOf(projectId),
      await r.tasksOfProject(projectId),
      await r.linksOf(projectId),
      await r.filesOf(projectId),
      await r.attachableTasks(homeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<_ProjectData?>(
      load: _load,
      builder: (context, data) {
        if (data == null) return HcScaffold();
        final p = data.project;
        final currency = data.home.currency;
        final writable = data.home.archivedAt == null;
        String m(Decimal v) => moneyIn(context, currency, v);
        final total = budget.sumOf(data.lines.map((l) => l.amounts));
        return HcScaffold(
          title: p.title,
          // The title is drawn under the pills, as on the web.
          drawsTitle: false,
          actions: const [HelpButton(page: HelpPages.project)],
          body: HcScreenList(
            children: [
              // The head of the record (`projects/project_detail.html`): the
              // pills (status, priority, what is left of the budget), the
              // title, the goal as a paragraph, the rooms as links, then the
              // action row.
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      key: const Key('project-pills'),
                      spacing: HcSpace.s2,
                      runSpacing: HcSpace.s1,
                      children: [
                        HcPill(
                          projectStatusLabel(l10n, p.status),
                          tone: projectStatusTone(p.status),
                        ),
                        if (p.priority == 'high')
                          HcPill(l10n.highPriority, tone: HcPillTone.warning),
                        if (p.priority == 'low')
                          HcPill(l10n.lowPriority, tone: HcPillTone.ghost),
                        ...gapPills(total, currency),
                      ],
                    ),
                    const SizedBox(height: HcSpace.s2),
                    Semantics(
                      header: true,
                      child: Text(p.title, style: HcText.pageTitle),
                    ),
                    if (p.goal.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: HcSpace.s2),
                        child: Text(
                          p.goal,
                          key: const Key('project-goal'),
                          style: HcText.body,
                        ),
                      ),
                    if (data.rooms.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: HcSpace.s3),
                        child: HcValueList(
                          children: [
                            HcValueRow(
                              l10n.roomsConcerned,
                              '',
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  for (final (i, room)
                                      in data.rooms.indexed) ...[
                                    if (i > 0)
                                      Text(', ', style: HcValueText.value),
                                    HcValueLink(
                                      room.name,
                                      key: Key('project-room-${room.id}'),
                                      onTap: () => _open(
                                        context,
                                        RoomScreen(
                                          homeId: homeId,
                                          roomId: room.id,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (writable)
                      RecordActions(
                        children: [
                          OutlinedButton(
                            key: const Key('project-edit'),
                            onPressed: () => _open(
                              context,
                              ProjectFormScreen(
                                homeId: homeId,
                                projectId: p.id,
                              ),
                            ),
                            child: Text(l10n.editProject),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // The sections in the order of the web: tasks, budget, quotes,
              // inspiration, then the files.
              HcSectionHeading(l10n.tasksHeading),
              if (data.tasks.isEmpty)
                HcEmpty(l10n.projectTasksEmpty)
              else
                HcCardList(
                  children: [
                    for (final t in data.tasks)
                      HcRow(
                        key: Key('project-task-${t.task.id}'),
                        title: t.task.title,
                        text: t.occurrence?.dueOn == null
                            ? (t.occurrence == null
                                  ? l10n.taskDoneLabel
                                  : l10n.todayNoDate)
                            : l10n.dueOn(
                                formatDay(
                                  context,
                                  Day.parse(t.occurrence!.dueOn!),
                                ),
                              ),
                        onTap: () => _open(
                          context,
                          TaskScreen(homeId: homeId, taskId: t.task.id),
                        ),
                      ),
                  ],
                ),
              if (writable) ...[
                HcAddButton(
                  key: const Key('project-task-add'),
                  label: l10n.addProjectTask,
                  primary: false,
                  gap: HcSpace.s3,
                  onPressed: () => _addTask(context, p.id),
                ),
                if (data.attachable.isNotEmpty)
                  HcAddButton(
                    key: const Key('project-task-attach'),
                    label: l10n.attachTask,
                    primary: false,
                    gap: HcSpace.s2,
                    onPressed: () => _attach(context, p.id, data.attachable),
                  ),
              ],
              HcSectionHeading(l10n.budgetHeading),
              if (data.lines.isEmpty)
                HcEmpty(l10n.linesEmpty)
              else
                HcCardList(
                  children: [
                    for (final line in data.lines)
                      Semantics(
                        button: writable,
                        hint: writable ? l10n.editLine : null,
                        child: AmountCard(
                          key: Key('line-${line.line.id}'),
                          title: line.line.label,
                          subtitle: natureLabel(l10n, line.line.nature),
                          amounts: line.amounts,
                          currency: currency,
                          lines: true,
                          chevron: true,
                          onTap: writable
                              ? () => _open(
                                  context,
                                  LineFormScreen(
                                    homeId: homeId,
                                    projectId: p.id,
                                    lineId: line.line.id,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    if (data.lines.length > 1)
                      AmountCard(
                        key: const Key('lines-total'),
                        title: l10n.total,
                        amounts: total,
                        currency: currency,
                        lines: true,
                      ),
                  ],
                ),
              smallNote(l10n.committedExplained),
              if (writable)
                HcAddButton(
                  key: const Key('line-add'),
                  label: l10n.addLine,
                  primary: false,
                  gap: HcSpace.s3,
                  onPressed: () => _open(
                    context,
                    LineFormScreen(homeId: homeId, projectId: p.id),
                  ),
                ),
              HcSectionHeading(l10n.quotes),
              if (data.quotes.isEmpty)
                HcEmpty(l10n.quotesEmpty)
              else
                HcCardList(
                  children: [
                    for (final q in data.quotes)
                      HcRow(
                        key: Key('quote-${q.quote.id}'),
                        title: [
                          q.contractor ?? l10n.noContractor,
                          m(budget.readMoney(q.quote.amount)),
                        ].join(' · '),
                        text: [
                          quoteStatusLabel(l10n, q.quote.status),
                          if (q.line != null) l10n.committedOn(q.line!),
                          if (q.quote.issuedOn != null)
                            formatDay(context, Day.parse(q.quote.issuedOn!)),
                          if (q.files > 0) l10n.filesCount(q.files),
                        ].join(' · '),
                        onTap: () => _open(
                          context,
                          QuoteFormScreen(
                            homeId: homeId,
                            projectId: p.id,
                            quoteId: q.quote.id,
                          ),
                        ),
                      ),
                  ],
                ),
              if (writable && data.lines.isEmpty)
                smallNote(l10n.addLineToAccept),
              if (writable)
                HcAddButton(
                  key: const Key('quote-add'),
                  label: l10n.addQuote,
                  primary: false,
                  gap: HcSpace.s3,
                  onPressed: () => _open(
                    context,
                    QuoteFormScreen(homeId: homeId, projectId: p.id),
                  ),
                ),
              HcSectionHeading(l10n.inspiration),
              if (data.links.isEmpty)
                HcEmpty(l10n.linksEmpty)
              else
                HcCardList(
                  children: [
                    for (final link in data.links)
                      HcRow(
                        key: Key('link-${link.id}'),
                        title: link.title.isEmpty ? link.url : link.title,
                        text: link.title.isEmpty ? null : link.url,
                        trailing: writable
                            ? IconButton(
                                tooltip: l10n.deleteLinkOf(
                                  link.title.isEmpty ? link.url : link.title,
                                ),
                                icon: const Icon(Icons.close),
                                onPressed: () => runChange(
                                  context,
                                  (r) => r.deleteLink(link.id),
                                ),
                              )
                            : null,
                        onTap: () =>
                            AppScope.of(context).openUrl(Uri.parse(link.url)),
                      ),
                  ],
                ),
              smallNote(l10n.linkNotRead),
              if (writable)
                HcAddButton(
                  key: const Key('link-add'),
                  label: l10n.addLink,
                  primary: false,
                  gap: HcSpace.s3,
                  onPressed: () => _addLink(context, p.id),
                ),
              if (data.files.isNotEmpty) ...[
                HcSectionHeading(l10n.projectFiles),
                HcCardList(
                  children: [
                    for (final f in data.files)
                      HcRow(
                        key: Key('file-${f.id}'),
                        title: f.name,
                        text: f.quoteId == null ? l10n.photo : l10n.quoteFile,
                      ),
                  ],
                ),
              ],
              if (writable) ...[
                HcDeleteButton(
                  key: const Key('project-delete'),
                  label: l10n.deleteProject,
                  onPressed: () => _delete(context, p.id),
                ),
              ],
              const SizedBox(height: HcSpace.s5),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteProject,
      body: l10n.deleteProjectBody,
    )) {
      return;
    }
    if (!context.mounted) return;
    if (await runChange(context, (r) => r.deleteProject(id))) navigator.pop();
  }

  Future<void> _addTask(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context);
    final title = await _ask(context, l10n.addProjectTask, l10n.newTask);
    if (title == null || !context.mounted) return;
    await runChange(
      context,
      (r) => r.addProjectTask(id, TaskInput(title: title)),
    );
  }

  Future<void> _attach(
    BuildContext context,
    String id,
    List<TaskRow> tasks,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showHcChoices<String>(
      context,
      title: l10n.attachTask,
      choices: [for (final t in tasks) (Key('attach-${t.id}'), t.id, t.title)],
    );
    if (chosen == null || !context.mounted) return;
    await runChange(context, (r) => r.attachTask(id, chosen));
  }

  Future<void> _addLink(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context);
    final url = TextEditingController();
    final title = TextEditingController();
    final ok = await showHcDialog<bool>(
      context,
      (context) => HcDialog(
        title: l10n.addLink,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            hcText(
              l10n.linkPageAddress,
              url,
              key: const Key('link-url'),
              keyboard: TextInputType.url,
              sentences: false,
            ),
            hcText(l10n.linkTitle, title, key: const Key('link-title')),
          ],
        ),
        actions: [
          HcDialogAction(
            label: l10n.cancel,
            kind: HcDialogKind.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          HcDialogAction(
            key: const Key('link-save'),
            label: l10n.addLinkButton,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await runChange(
        context,
        (r) => r.addLink(id, url: url.text, title: title.text),
      );
    }
    url.dispose();
    title.dispose();
  }
}

/// A text asked in a dialog; `null` when cancelled or empty.
Future<String?> _ask(BuildContext context, String title, String label) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  final text = await showHcDialog<String>(
    context,
    (context) => HcDialog(
      title: title,
      content: hcText(label, controller, key: const Key('ask-text')),
      actions: [
        HcDialogAction(
          label: l10n.cancel,
          kind: HcDialogKind.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        HcDialogAction(
          key: const Key('ask-save'),
          label: l10n.save,
          onPressed: () => Navigator.of(context).pop(controller.text),
        ),
      ],
    ),
  );
  controller.dispose();
  return text == null || text.trim().isEmpty ? null : text;
}

/// The form of a project (`projects/project_form.html`): only the title is
/// required; a budget on creation becomes its first line.
class ProjectFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const ProjectFormScreen({super.key, required this.homeId, this.projectId});

  final String homeId;
  final String? projectId;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _goal = TextEditingController();
  final _budget = TextEditingController();
  final _duration = TextEditingController();
  String _status = 'idea';
  String _priority = 'normal';
  String _durationUnit = durations.day;
  String _season = '';
  int? _seasonStart;
  int? _seasonEnd;
  String _hemisphere = recurrence.north;
  final _rooms = <String>{};
  List<RoomRow> _choices = const [];
  String _currency = '';
  bool _loaded = false;

  /// Set once the project is read: the section opens on what it holds.
  bool _ready = false;

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
    final id = widget.projectId;
    final p = id == null ? null : await r.project(id);
    final linked = id == null ? <RoomRow>[] : await r.roomsOfProject(id);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      _hemisphere = home?.hemisphere ?? recurrence.north;
      _choices = rooms;
      if (p != null) {
        _title.text = p.title;
        _goal.text = p.goal;
        _status = p.status;
        _priority = p.priority;
        _rooms.addAll(linked.map((r) => r.id));
        final minutes = p.estimatedMinutes;
        if (minutes != null) {
          final (value, unit) = durations.split(minutes);
          _duration.text = '$value';
          _durationUnit = unit;
        }
        _season = p.season;
        _seasonStart = p.seasonStartMonth;
        _seasonEnd = p.seasonEndMonth;
      }
      _ready = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _goal, _budget, _duration]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final typed = int.tryParse(_duration.text.trim());
    final input = ProjectInput(
      title: _title.text,
      goal: _goal.text,
      status: _status,
      priority: _priority,
      estimatedMinutes: typed == null
          ? null
          : durations.toMinutes(typed, _durationUnit),
      season: _season,
      seasonStartMonth: _seasonStart,
      seasonEndMonth: _seasonEnd,
      roomIds: _rooms.toList(),
      budget: fieldAmount(context, _budget),
      budgetLabel: l10n.budgetHeading,
    );
    String? added;
    final saved = await runChange(context, (r) async {
      if (widget.projectId == null) {
        added = await r.createProject(widget.homeId, input);
      } else {
        await r.updateProject(widget.projectId!, input);
      }
    });
    // A new project is given back, for the list that opened the form to
    // open it.
    if (saved) navigator.pop(added);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: widget.projectId == null ? l10n.addProject : l10n.editProject,
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
                    l10n.taskTitle,
                    _title,
                    key: const Key('project-title'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcText(l10n.projectGoal, _goal, minLines: 2, maxLines: 6),
                  hcChoice<String>(
                    l10n.status,
                    _status,
                    projectStatusChoices(l10n),
                    (v) => setState(() => _status = v),
                    key: const Key('project-status'),
                  ),
                  hcChoice<String>(l10n.priority, _priority, [
                    ('high', l10n.priorityHigh),
                    ('normal', l10n.priorityNormal),
                    ('low', l10n.priorityLow),
                  ], (v) => setState(() => _priority = v)),
                  if (widget.projectId == null) ...[
                    hcAmount(
                      context,
                      l10n.budgetHeading,
                      _budget,
                      key: const Key('project-budget'),
                    ),
                    fieldHelp(l10n.amountsAreIn(_currency)),
                  ],
                ],
              ),
            ),
            // Folded, as the web's `details`: closed on a new project, open
            // on a project that holds one of its fields.
            if (_ready) _roomsDurationSeason(l10n),
          ],
        ),
      ),
    );
  }

  /// Rooms, duration and season: what is optional, folded as on the web. The
  /// rooms are chips, closed with the section.
  Widget _roomsDurationSeason(AppLocalizations l10n) {
    final wide = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return HcFoldSection(
      key: const Key('project-section-rooms'),
      title: l10n.projectSectionRooms,
      open:
          _rooms.isNotEmpty ||
          _duration.text.trim().isNotEmpty ||
          _season.isNotEmpty,
      children: [
        if (_choices.isNotEmpty)
          choiceChips(
            l10n.roomsConcerned,
            [for (final r in _choices) (r.id, r.name)],
            _rooms,
            (id, on) => setState(() => on ? _rooms.add(id) : _rooms.remove(id)),
            keyPrefix: 'project-room',
          ),
        HcField(
          label: l10n.taskDuration,
          child: Flex(
            direction: wide ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pair(
                wide,
                TextFormField(
                  key: const Key('project-duration'),
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return null;
                    final n = int.tryParse(text);
                    return n == null ||
                            !durations.withinBounds(
                              durations.toMinutes(n, _durationUnit),
                            )
                        ? l10n.errDuration
                        : null;
                  },
                ),
              ),
              const SizedBox(width: HcSpace.s2, height: HcSpace.s2),
              _pair(
                wide,
                Semantics(
                  label: l10n.taskDurationUnit,
                  child: HcSelect<String>(
                    key: const Key('project-duration-unit'),
                    value: _durationUnit,
                    choices: [
                      (durations.minute, l10n.unitMinutes),
                      (durations.hour, l10n.unitHours),
                      (durations.day, l10n.unitDays),
                      (durations.week, l10n.unitWeeks),
                      (durations.month, l10n.unitMonths),
                      (durations.year, l10n.unitYears),
                    ],
                    onChanged: (v) => setState(() => _durationUnit = v),
                  ),
                ),
              ),
            ],
          ),
        ),
        hcChoice<String>(
          l10n.projectSeason,
          _season,
          [
            ('', l10n.projectSeasonAnyTime),
            (recurrence.spring, l10n.seasonSpring),
            (recurrence.summer, l10n.seasonSummer),
            (recurrence.autumn, l10n.seasonAutumn),
            (recurrence.winter, l10n.seasonWinter),
            // Months typed on the web are kept, not edited here.
            if (_season == recurrence.custom)
              (recurrence.custom, l10n.seasonCustom),
          ],
          (v) => setState(() => _season = v),
          key: const Key('project-season'),
        ),
        fieldHelp(
          l10n.projectSeasonHemisphereHelp(
            // In lower case, as the web words it: "(northern)", "(nord)".
            (_hemisphere == recurrence.south
                    ? l10n.hemisphereSouth
                    : l10n.hemisphereNorth)
                .toLowerCase(),
          ),
        ),
      ],
    );
  }
}

/// One field of a pair: half the line, or the whole line when they stack.
Widget _pair(bool stacked, Widget field) =>
    stacked ? field : Expanded(child: field);

/// The form of a budget line (`projects/line_form.html`).
class LineFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const LineFormScreen({
    super.key,
    required this.homeId,
    required this.projectId,
    this.lineId,
  });

  final String homeId;
  final String projectId;
  final String? lineId;

  @override
  State<LineFormScreen> createState() => _LineFormScreenState();
}

class _LineFormScreenState extends State<LineFormScreen> {
  final _form = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _planned = TextEditingController();
  final _paid = TextEditingController();
  String _nature = budget.other;
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
    final line = widget.lineId == null
        ? null
        : await r.budgetLine(widget.lineId!);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      if (line != null) {
        _label.text = line.label;
        _nature = line.nature;
        _planned.text = moneyFieldText(
          Localizations.localeOf(context).toLanguageTag(),
          budget.readMoney(line.planned),
        );
        _paid.text = moneyFieldText(
          Localizations.localeOf(context).toLanguageTag(),
          budget.readMoney(line.paid),
        );
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_label, _planned, _paid]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final input = LineInput(
      label: _label.text,
      nature: _nature,
      planned: fieldAmount(context, _planned),
      paid: fieldAmount(context, _paid),
    );
    final saved = await runChange(
      context,
      (r) => widget.lineId == null
          ? r.createLine(widget.projectId, input)
          : r.updateLine(widget.lineId!, input),
    );
    if (saved) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteLine,
      body: l10n.deleteLineBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(context, (r) => r.deleteLine(widget.lineId!))) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: widget.lineId == null ? l10n.addLine : l10n.editLine,
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
                    l10n.lineLabel,
                    _label,
                    key: const Key('line-label'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errTitleRequired : null,
                  ),
                  hcChoice<String>(
                    l10n.nature,
                    _nature,
                    natureChoices(l10n),
                    (v) => setState(() => _nature = v),
                    key: const Key('line-nature'),
                  ),
                  hcAmount(
                    context,
                    l10n.amountPlanned,
                    _planned,
                    key: const Key('line-planned'),
                  ),
                  hcAmount(
                    context,
                    l10n.amountPaid,
                    _paid,
                    key: const Key('line-paid'),
                  ),
                  fieldHelp(l10n.linePaidHelp),
                  fieldHelp(l10n.amountsAreIn(_currency)),
                ],
              ),
            ),
            if (widget.lineId != null) ...[
              HcDeleteButton(
                key: const Key('line-delete'),
                label: l10n.deleteLine,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The form of a quote (`projects/quote_form.html`): an accepted quote is
/// committed on a line of its project and cannot be saved without one. Its
/// files: a PDF from the Files app or the document picker, or a photo.
class QuoteFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const QuoteFormScreen({
    super.key,
    required this.homeId,
    required this.projectId,
    this.quoteId,
  });

  final String homeId;
  final String projectId;
  final String? quoteId;

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _status = 'requested';
  String? _line;
  String? _contractor;
  Day? _issued;
  Day? _validUntil;
  List<LineEntry> _lines = const [];
  List<ContractorRow> _contractors = const [];
  List<ProjectFileRow> _files = const [];
  String _currency = '';
  bool _loaded = false;
  bool _writable = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load(AppScope.of(context).repository);
  }

  Future<void> _load(Repository r) async {
    final home = await r.home(widget.homeId);
    final lines = await r.linesOf(widget.projectId);
    final contractors = await r.contractors(widget.homeId);
    final q = widget.quoteId == null ? null : await r.quote(widget.quoteId!);
    final files = [
      for (final f in await r.filesOf(widget.projectId))
        if (q != null && f.quoteId == q.id) f,
    ];
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      _writable = home?.archivedAt == null;
      _lines = lines;
      _contractors = contractors;
      _files = files;
      if (q != null) {
        final input = QuoteInput.of(q);
        _amount.text = moneyFieldText(
          Localizations.localeOf(context).toLanguageTag(),
          budget.readMoney(q.amount),
        );
        _note.text = input.note;
        _status = input.status;
        _line = input.budgetLineId;
        _contractor = input.contractorId;
        _issued = input.issuedOn;
        _validUntil = input.validUntil;
      }
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  QuoteInput _input() => QuoteInput(
    contractorId: _contractor,
    amount: fieldAmount(context, _amount),
    issuedOn: _issued,
    validUntil: _validUntil,
    status: _status,
    budgetLineId: _status == budget.accepted ? _line : null,
    note: _note.text,
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(
      context,
      (r) => widget.quoteId == null
          ? r.createQuote(widget.projectId, _input())
          : r.updateQuote(widget.quoteId!, _input()),
    );
    if (saved) navigator.pop();
  }

  Future<void> _attach() async {
    final source = AppScope.of(context).documentSource;
    if (source == null || widget.quoteId == null) return;
    final picked = await source.pickDocument();
    if (picked == null || !mounted) return;
    final ok = await runChange(
      context,
      (r) => r.addProjectFile(
        widget.projectId,
        name: picked.name,
        bytes: picked.bytes,
        contentType: picked.contentType,
        quoteId: widget.quoteId,
      ),
    );
    if (ok && mounted) await _load(AppScope.of(context).repository);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.deleteQuote,
      body: l10n.deleteQuoteBody,
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(context, (r) => r.deleteQuote(widget.quoteId!))) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: widget.quoteId == null ? l10n.addQuote : l10n.editQuote,
      actions: [if (_writable) HcBarAction(label: l10n.save, onPressed: _save)],
      body: Form(
        key: _form,
        child: HcScreenList(
          children: [
            const SizedBox(height: HcSpace.s2),
            HcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hcChoice<String?>(
                    l10n.contractor,
                    _contractor,
                    [(null, '—'), for (final c in _contractors) (c.id, c.name)],
                    (v) => setState(() => _contractor = v),
                    key: const Key('quote-contractor'),
                  ),
                  hcAmount(
                    context,
                    l10n.amount,
                    _amount,
                    key: const Key('quote-amount'),
                  ),
                  fieldHelp(l10n.amountIsIn(_currency)),
                  HcDateField(
                    label: l10n.quoteDate,
                    value: _issued,
                    noDate: l10n.todayNoDate,
                    onChanged: (d) => setState(() => _issued = d),
                  ),
                  HcDateField(
                    label: l10n.validUntil,
                    value: _validUntil,
                    noDate: l10n.todayNoDate,
                    onChanged: (d) => setState(() => _validUntil = d),
                  ),
                  hcChoice<String>(
                    l10n.status,
                    _status,
                    quoteStatusChoices(l10n),
                    (v) => setState(() => _status = v),
                    key: const Key('quote-status'),
                  ),
                  if (_status == budget.accepted) ...[
                    HcField(
                      label: l10n.committedOnLabel,
                      child: HcSelect<String?>(
                        key: const Key('quote-line'),
                        value: _line,
                        choices: [
                          (null, '—'),
                          for (final l in _lines) (l.line.id, l.line.label),
                        ],
                        validator: (v) =>
                            v == null ? l10n.errQuoteNeedsLine : null,
                        onChanged: (v) => setState(() => _line = v),
                      ),
                    ),
                    fieldHelp(l10n.committedOnHelp),
                  ],
                  hcText(l10n.note, _note, key: const Key('quote-note')),
                ],
              ),
            ),
            if (widget.quoteId != null) ...[
              HcSectionHeading(l10n.quoteFiles),
              if (_files.isEmpty)
                HcEmpty(l10n.quoteFilesEmpty)
              else
                HcCardList(
                  children: [
                    for (final f in _files)
                      HcRow(
                        key: Key('quote-file-${f.id}'),
                        title: f.name,
                        text: f.isImage ? l10n.photo : 'PDF',
                      ),
                  ],
                ),
              if (_writable)
                HcAddButton(
                  key: const Key('quote-file-add'),
                  label: l10n.attachQuoteFile,
                  primary: false,
                  gap: HcSpace.s3,
                  onPressed: _attach,
                ),
              const SizedBox(height: HcSpace.s4),
              if (_writable)
                HcDeleteButton(
                  key: const Key('quote-delete'),
                  label: l10n.deleteQuote,
                  onPressed: _delete,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The annual envelope (`projects/envelope_form.html`): what the household
/// wants to spend on work in a year, in the currency of the home.
class EnvelopeFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const EnvelopeFormScreen({super.key, required this.homeId});

  final String homeId;

  @override
  State<EnvelopeFormScreen> createState() => _EnvelopeFormScreenState();
}

class _EnvelopeFormScreenState extends State<EnvelopeFormScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  int? _year;
  String _currency = '';
  Map<int, Decimal> _envelopes = const {};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final r = AppScope.of(context).repository;
    _year = r.today().year;
    _load(r);
  }

  Future<void> _load(Repository r) async {
    final home = await r.home(widget.homeId);
    final envelopes = await r.envelopesOf(widget.homeId);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      _envelopes = envelopes;
      _fill();
    });
  }

  void _fill() {
    final value = _envelopes[_year];
    _amount.text = value == null
        ? ''
        : moneyFieldText(
            Localizations.localeOf(context).toLanguageTag(),
            value,
          );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final saved = await runChange(
      context,
      (r) =>
          r.setEnvelope(widget.homeId, _year!, fieldAmount(context, _amount)),
    );
    if (saved) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = AppScope.of(context).repository.today().year;
    return HcScaffold(
      title: l10n.annualEnvelope,
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
                  if (_year != null)
                    hcChoice<int>(
                      l10n.budgetYear,
                      _year!,
                      [for (var y = now - 2; y <= now + 3; y++) (y, '$y')],
                      (v) => setState(() {
                        _year = v;
                        _fill();
                      }),
                      key: const Key('envelope-year'),
                    ),
                  hcAmount(
                    context,
                    l10n.envelope,
                    _amount,
                    key: const Key('envelope-amount'),
                  ),
                  fieldHelp(l10n.envelopeHelp),
                  fieldHelp(l10n.amountsAreIn(_currency)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
