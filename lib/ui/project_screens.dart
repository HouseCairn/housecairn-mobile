// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/budget.dart' as budget;
import '../domain/day.dart';
import '../domain/stock.dart' as stock;
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'home_selector.dart';
import 'messages.dart';
import 'parts.dart';
import 'state.dart';
import 'task_screen.dart';

/// The statuses of each tab of Projects, as on the web (`PROJECT_VIEWS` of
/// `core/templatetags/tabs.py`): what is going on, the ideas, what is over.
const projectTabs = [
  ['in_progress', 'planned'],
  ['idea'],
  ['done', 'abandoned'],
];

void _open(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

/// Projects (`projects/project_list.html`): the tabs by status, the envelope
/// of the year, the projects of the tab with their budget and gap.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = AppScope.of(context).current;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProjects),
        actions: const [HomeSelector()],
      ),
      body: home == null
          ? const SizedBox.shrink()
          : DataView<(List<ProjectEntry>, Map<int, Decimal>)>(
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
                return HcScreenList(
                  children: [
                    HcTabs(
                      key: const Key('projects-tabs'),
                      labels: [
                        l10n.projectsInProgress,
                        l10n.projectsIdeas,
                        l10n.projectsFinished,
                      ],
                      current: _tab,
                      onSelect: (i) => setState(() => _tab = i),
                    ),
                    HcCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.envelopeOfYear(year),
                            style: HcText.cardTitle,
                          ),
                          const SizedBox(height: HcSpace.s2),
                          if (envelope == null)
                            Text(l10n.envelopeNone, style: HcText.bodySmall)
                          else ...[
                            HcFact(l10n.envelope, factText(m(envelope))),
                            HcFact(
                              l10n.envelopePlannedActive,
                              factText(m(active.planned)),
                            ),
                            HcFact(
                              l10n.envelopePaidSoFar,
                              factText(m(active.paid)),
                            ),
                            HcFact(
                              l10n.envelopeLeft,
                              factText(
                                envelope - active.planned < budget.zero
                                    ? l10n.overTheEnvelope(
                                        m(envelope - active.planned),
                                      )
                                    : m(envelope - active.planned),
                              ),
                            ),
                          ],
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
                        all.isEmpty
                            ? l10n.projectsEmpty
                            : l10n.projectsNoneInTab,
                      )
                    else
                      HcCardList(
                        children: [
                          for (final e in shown)
                            HcRow(
                              key: Key('project-${e.project.id}'),
                              title: e.project.title,
                              text: [
                                if (e.amounts.planned != budget.zero ||
                                    e.amounts.committed != budget.zero ||
                                    e.amounts.paid != budget.zero)
                                  l10n.plannedAmount(m(e.amounts.planned))
                                else
                                  l10n.noBudgetYet,
                                if (e.project.priority == 'high')
                                  l10n.highPriority,
                              ].join(' · '),
                              pills: gapPills(e.amounts, currency),
                              onTap: () => _open(
                                context,
                                ProjectScreen(
                                  homeId: home.id,
                                  projectId: e.project.id,
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (writable)
                      HcAddButton(
                        key: const Key('project-add'),
                        label: l10n.addProject,
                        primary: false,
                        gap: shown.isEmpty ? HcSpace.s2 : HcSpace.s3,
                        onPressed: () =>
                            _open(context, ProjectFormScreen(homeId: home.id)),
                      ),
                  ],
                );
              },
            ),
    );
  }

  /// What the projects going on plan and paid (`envelope_summary`).
  static budget.Amounts _activeTotal(List<ProjectEntry> all) => budget.sumOf([
    for (final e in all)
      if (const ['in_progress', 'planned', 'idea'].contains(e.project.status))
        e.amounts,
  ]);
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

/// A project (`projects/project_detail.html`): its facts, its budget lines
/// with the three amounts and the gap, its quotes, its tasks, its links of
/// inspiration (opened in the browser of the phone, never read) and its
/// files.
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
        if (data == null) return Scaffold(appBar: AppBar());
        final p = data.project;
        final currency = data.home.currency;
        final writable = data.home.archivedAt == null;
        String m(Decimal v) => moneyIn(context, currency, v);
        final total = budget.sumOf(data.lines.map((l) => l.amounts));
        return Scaffold(
          appBar: AppBar(title: Text(p.title)),
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: HcSpace.s3),
                      child: Wrap(
                        spacing: HcSpace.s2,
                        runSpacing: HcSpace.s1,
                        children: [
                          HcPill(projectStatusLabel(l10n, p.status)),
                          if (p.priority == 'high')
                            HcPill(l10n.highPriority, tone: HcPillTone.warning),
                          if (p.priority == 'low')
                            HcPill(l10n.lowPriority, tone: HcPillTone.ghost),
                        ],
                      ),
                    ),
                    if (p.goal.isNotEmpty)
                      HcFact(l10n.projectGoal, factText(p.goal)),
                    if (data.rooms.isNotEmpty)
                      HcFact(
                        l10n.roomsConcerned,
                        factText(data.rooms.map((r) => r.name).join(', ')),
                      ),
                    if (writable)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton(
                          key: const Key('project-edit'),
                          onPressed: () => _open(
                            context,
                            ProjectFormScreen(homeId: homeId, projectId: p.id),
                          ),
                          child: Text(l10n.editProject),
                        ),
                      ),
                  ],
                ),
              ),
              HcSectionHeading(l10n.budgetHeading),
              if (data.lines.isEmpty)
                HcEmpty(l10n.linesEmpty)
              else
                HcCardList(
                  children: [
                    for (final line in data.lines)
                      AmountCard(
                        key: Key('line-${line.line.id}'),
                        title: line.line.label,
                        subtitle: natureLabel(l10n, line.line.nature),
                        amounts: line.amounts,
                        currency: currency,
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
                    if (data.lines.length > 1)
                      AmountCard(
                        key: const Key('lines-total'),
                        title: l10n.total,
                        amounts: total,
                        currency: currency,
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
                const SizedBox(height: HcSpace.s4),
                OutlinedButton(
                  key: const Key('project-delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HcColors.danger,
                  ),
                  onPressed: () => _delete(context, p.id),
                  child: Text(l10n.deleteProject),
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
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.attachTask),
        children: [
          for (final t in tasks)
            SimpleDialogOption(
              key: Key('attach-${t.id}'),
              onPressed: () => Navigator.of(context).pop(t.id),
              child: Text(t.title, style: HcText.body),
            ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return;
    await runChange(context, (r) => r.attachTask(id, chosen));
  }

  Future<void> _addLink(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context);
    final url = TextEditingController();
    final title = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addLink),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const Key('link-save'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.addLinkButton),
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
  final text = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: hcText(label, controller, key: const Key('ask-text')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          key: const Key('ask-save'),
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  return text == null || text.trim().isEmpty ? null : text;
}

/// The form of a project (`projects/project_form.html`): only the title is
/// required; a budget on creation becomes its first line.
class ProjectFormScreen extends StatefulWidget {
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
  String _status = 'idea';
  String _priority = 'normal';
  final _rooms = <String>{};
  List<RoomRow> _choices = const [];
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
    final id = widget.projectId;
    final p = id == null ? null : await r.project(id);
    final linked = id == null ? <RoomRow>[] : await r.roomsOfProject(id);
    if (!mounted) return;
    setState(() {
      _currency = home?.currency ?? '';
      _choices = rooms;
      if (p != null) {
        _title.text = p.title;
        _goal.text = p.goal;
        _status = p.status;
        _priority = p.priority;
        _rooms.addAll(linked.map((r) => r.id));
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _goal, _budget]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final input = ProjectInput(
      title: _title.text,
      goal: _goal.text,
      status: _status,
      priority: _priority,
      roomIds: _rooms.toList(),
      budget: _budget.text,
      budgetLabel: l10n.budgetHeading,
    );
    final saved = await runChange(
      context,
      (r) => widget.projectId == null
          ? r.createProject(widget.homeId, input)
          : r.updateProject(widget.projectId!, input),
    );
    if (saved) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectId == null ? l10n.addProject : l10n.editProject,
        ),
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
                  if (_choices.isNotEmpty)
                    choiceChips(
                      l10n.roomsConcerned,
                      [for (final r in _choices) (r.id, r.name)],
                      _rooms,
                      (id, on) => setState(
                        () => on ? _rooms.add(id) : _rooms.remove(id),
                      ),
                      keyPrefix: 'project-room',
                    ),
                  if (widget.projectId == null) ...[
                    hcText(
                      l10n.budgetHeading,
                      _budget,
                      key: const Key('project-budget'),
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      sentences: false,
                      validator: moneyCheck(l10n),
                    ),
                    fieldHelp(l10n.amountsAreIn(_currency)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The form of a budget line (`projects/line_form.html`).
class LineFormScreen extends StatefulWidget {
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
        _planned.text = budget.readMoney(line.planned).toStringAsFixed(2);
        _paid.text = budget.readMoney(line.paid).toStringAsFixed(2);
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
      planned: _planned.text,
      paid: _paid.text,
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
    const number = TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lineId == null ? l10n.addLine : l10n.editLine),
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
                  hcText(
                    l10n.amountPlanned,
                    _planned,
                    key: const Key('line-planned'),
                    keyboard: number,
                    sentences: false,
                    validator: moneyCheck(l10n),
                  ),
                  hcText(
                    l10n.amountPaid,
                    _paid,
                    key: const Key('line-paid'),
                    keyboard: number,
                    sentences: false,
                    validator: moneyCheck(l10n),
                  ),
                  fieldHelp(l10n.linePaidHelp),
                  fieldHelp(l10n.amountsAreIn(_currency)),
                ],
              ),
            ),
            if (widget.lineId != null) ...[
              const SizedBox(height: HcSpace.s4),
              OutlinedButton(
                key: const Key('line-delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HcColors.danger,
                ),
                onPressed: _delete,
                child: Text(l10n.deleteLine),
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
class QuoteFormScreen extends StatefulWidget {
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
        _amount.text = budget.readMoney(q.amount).toStringAsFixed(2);
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
    amount: _amount.text,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quoteId == null ? l10n.addQuote : l10n.editQuote),
        actions: [
          if (_writable) HcBarAction(label: l10n.save, onPressed: _save),
        ],
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
                  hcChoice<String?>(
                    l10n.contractor,
                    _contractor,
                    [(null, '—'), for (final c in _contractors) (c.id, c.name)],
                    (v) => setState(() => _contractor = v),
                    key: const Key('quote-contractor'),
                  ),
                  hcText(
                    l10n.amount,
                    _amount,
                    key: const Key('quote-amount'),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    sentences: false,
                    validator: moneyCheck(l10n),
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
                      child: DropdownButtonFormField<String?>(
                        key: const Key('quote-line'),
                        initialValue: _line,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('—')),
                          for (final l in _lines)
                            DropdownMenuItem(
                              value: l.line.id,
                              child: Text(l.line.label),
                            ),
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
                OutlinedButton(
                  key: const Key('quote-delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HcColors.danger,
                  ),
                  onPressed: _delete,
                  child: Text(l10n.deleteQuote),
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
class EnvelopeFormScreen extends StatefulWidget {
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
    _amount.text = value == null ? '' : stock.plain(value);
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
      (r) => r.setEnvelope(widget.homeId, _year!, _amount.text),
    );
    if (saved) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = AppScope.of(context).repository.today().year;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.annualEnvelope),
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
                  hcText(
                    l10n.envelope,
                    _amount,
                    key: const Key('envelope-amount'),
                    keyboard: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    sentences: false,
                    validator: moneyCheck(l10n),
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
