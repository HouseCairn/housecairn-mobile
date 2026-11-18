// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../domain/guide.dart';
import '../l10n/app_localizations.dart';
import 'homes_screen.dart';
import 'item_screens.dart';
import 'parts.dart';
import 'project_screens.dart';
import 'report_screens.dart';
import 'rooms.dart';
import 'state.dart';
import 'task_form_screen.dart';
import 'today.dart';

/// The screens of the interactive guide on the phone (web ADR 0084, lot A3):
/// the five scenarios, the steps of one, the banner of the example home and
/// its deletion in one gesture. Every text of the guide is read from
/// `design/guide.json` and the terms it cites from `design/glossary.json`, in
/// the language of the phone; the words around them are the chrome of the
/// ARB files. The guide stores no current step: it reads the ticks of the
/// example home, which [AppState.refresh] brings up to date after every
/// change (`guide/views.py` of the web).

/// The values of a form opened by **Fill in for me**, by the name of the
/// field in the file (`name`, `kind`, `brand`...), a reference already the id
/// of its row, a text in the language of the phone, a day as a [Day]. A form
/// reads the names it knows and checks each value as input; it shows them
/// only on the example home (`guide.prefill` of the web).
typedef GuideFill = Map<String, Object?>;

/// The name of the route of the guide; a scenario's is `/guide/<id>`. The
/// deletion of the example home goes back to the nearest of them.
const guideRouteName = '/guide';

/// The route of [page], a screen of the guide named [name].
Route<void> guideRoute(Widget page, String name) =>
    hcRoute(page, settings: RouteSettings(name: name));

/// Opens the list of the scenarios.
void openGuide(BuildContext context) =>
    Navigator.of(context).push(guideRoute(const GuideScreen(), guideRouteName));

/// Whether a form of [homeId] takes the values of a [GuideFill]: only the
/// forms of the example home do, so that no value of the file ever reaches a
/// real home, nor an edit form that saves as it is changed (web ADR 0082).
bool fillsHere(BuildContext context, String homeId, GuideFill fill) =>
    fill.isNotEmpty && AppScope.of(context).isExample(homeId);

/// The language of the file that serves the phone (`fr-CA` reads `fr`).
String guideLanguage(BuildContext context, Guide guide) =>
    guide.languageFor(Localizations.localeOf(context).toLanguageTag());

/// A text of the guide, its cited terms in bold (`terms.render` of the web).
class GuideText extends StatelessWidget {
  const GuideText(
    this.text, {
    super.key,
    required this.content,
    this.style = HcText.body,
  });

  final String text;
  final GuideContent content;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final language = guideLanguage(context, content.guide);
    return Text.rich(
      TextSpan(
        children: [
          for (final piece in guidePieces(text, content.glossary, language))
            TextSpan(
              text: piece.text,
              style: piece.term
                  ? style.copyWith(fontWeight: HcFont.bold)
                  : null,
            ),
        ],
      ),
      style: style,
    );
  }
}

/// [text] with its terms written, for a line that has no bold (a row).
String guidePlain(String text, GuideContent content, String language) =>
    [for (final p in guidePieces(text, content.glossary, language)) p.text]
        .join();

// ---------- what the pages read ----------

/// The guide as a page shows it: its content, the example home and the
/// steps ticked.
class GuideView {
  const GuideView({
    required this.content,
    required this.home,
    required this.ticked,
    required this.links,
  });

  final GuideContent content;
  final HomeRow? home;
  final Set<String> ticked;

  /// The links of each step, by its id.
  final Map<String, StepLinks> links;

  Guide get guide => content.guide;

  /// The steps a scenario counts in its progress: an optional one does not.
  static List<GuideStep> counted(GuideScenario scenario) => [
    for (final s in scenario.steps)
      if (s.raw['optional'] != true) s,
  ];

  int done(GuideScenario scenario) =>
      counted(scenario).where((s) => ticked.contains(s.id)).length;

  bool finished(GuideScenario scenario) =>
      done(scenario) == counted(scenario).length;

  /// Whether scenario [number] (from 1) offers "Add what the earlier
  /// scenarios make": no example home yet, or a step of an earlier scenario
  /// that ticks by itself is not ticked (`ScenarioView` of the web).
  bool catchUp(int number) {
    if (number <= 1) return false;
    if (home == null) return true;
    return [for (final s in guide.scenarios.take(number - 1)) ...counted(s)]
        .any((step) => step.doneWhen != null && !ticked.contains(step.id));
  }
}

/// Reads the guide for a page: the example home's ticks brought up to date
/// first (`_home_of` of the web), then the links of the steps.
Future<GuideView> readGuide(AppState state, String language) async {
  final content = await state.guideContent();
  final repository = state.repository;
  final home = await repository.exampleHome();
  if (home != null) await repository.tickGuide(content.guide, home.id);
  final ticked = home == null
      ? <String>{}
      : await repository.guideTicks(home.id);
  final links = await stepLinks(repository, content.guide, home, language);
  return GuideView(content: content, home: home, ticked: ticked, links: links);
}

/// Where a step leads in the example home: its screen, and the same with
/// the values of the file in it (`guide.links.Links` of the web). `null`:
/// no button.
class StepLinks {
  const StepLinks({this.open, this.fill});

  final Widget Function()? open;
  final Widget Function()? fill;
}

/// The links of every step of [guide] in [home], the example home (`null`
/// before scenario 1 is done), as `guide.links.for_step` of the web: a step
/// on a row already there opens the form of that row (its brand, its
/// repetition, its payment), else the form that adds it; a budget line or a
/// quote has no link before its project exists.
Future<Map<String, StepLinks>> stepLinks(
  Repository repository,
  Guide guide,
  HomeRow? home,
  String language,
) async {
  final found = home == null
      ? const <String, String>{}
      : await repository.exampleRowIds(guide, home.id, language: language);
  final report = home == null ? null : await repository.latestReport(home.id);
  final rows = {for (final r in guide.rows) r.key: r};
  final today = repository.today();
  return {
    for (final step in guide.steps)
      step.id: _linksOf(
        step,
        home,
        rows,
        found,
        report,
        guide,
        language,
        today,
      ),
  };
}

StepLinks _linksOf(
  GuideStep step,
  HomeRow? home,
  Map<String, ExampleRow> rows,
  Map<String, String> found,
  String? report,
  Guide guide,
  String language,
  Day today,
) {
  final screen = step.raw['screen'];
  if (screen == 'new-home') {
    return StepLinks(
      open: home == null ? () => const HomeScreen(guide: true) : null,
    );
  }
  if (home == null) return const StepLinks();
  final id = home.id;
  final suggest = step.raw['suggest'] as String?;
  if (suggest == null) {
    return StepLinks(
      open: switch (screen) {
        'home' => () => HomeScreen(homeId: id),
        'today' => () => TodayScreen(homeId: id),
        'report' =>
          report == null
              ? () => ReportsScreen(homeId: id)
              : () => ReportScreen(homeId: id, reportId: report),
        _ => null,
      },
    );
  }
  final row = rows[suggest]!;
  final existing = found[suggest];
  final project = found[row.fields['project']];
  final Widget Function(GuideFill fill)? form = switch (row.entity) {
    'rooms.room' => (f) => RoomFormScreen(
      homeId: id,
      roomId: existing,
      fill: f,
    ),
    'rooms.item' =>
      (f) => existing != null
          ? ItemFormScreen(
              homeId: id,
              roomId: found[row.fields['room']],
              itemId: existing,
              fill: f,
            )
          : ItemFormScreen(
              homeId: id,
              chooseRoom: true,
              roomId: f['room'] as String?,
              fill: f,
            ),
    'tasks.task' => (f) => TaskFormScreen(
      homeId: id,
      taskId: existing,
      fill: f,
    ),
    'reports.report' => (f) => ReportFormScreen(homeId: id, fill: f),
    'projects.project' => (f) => ProjectFormScreen(
      homeId: id,
      projectId: existing,
      fill: f,
    ),
    'projects.annualenvelope' => (f) => EnvelopeFormScreen(homeId: id, fill: f),
    'projects.budgetline' when project != null => (f) => LineFormScreen(
      homeId: id,
      projectId: project,
      lineId: existing,
      fill: f,
    ),
    'projects.quote' when project != null => (f) => QuoteFormScreen(
      homeId: id,
      projectId: project,
      quoteId: existing,
      fill: f,
    ),
    _ => null,
  };
  if (form == null) return const StepLinks();
  final wanted = [
    for (final name in (step.raw['suggest_fields'] as List?) ?? row.fields.keys)
      name as String,
  ];
  final values = fillOf(row, wanted, found, rows, guide, language, today);
  return StepLinks(open: () => form(const {}), fill: () => form(values));
}

/// The values of [row] for the fields [wanted] of its step, as its form takes
/// them (`guide.links._query` of the web): a reference becomes the id of the
/// row found, a contractor its name, a number of days a day from [today], the
/// current year a year, a text the one of [language].
GuideFill fillOf(
  ExampleRow row,
  List<String> wanted,
  Map<String, String> found,
  Map<String, ExampleRow> rows,
  Guide guide,
  String language,
  Day today,
) {
  final fields = row.fields;
  final fill = <String, Object?>{};
  for (final name in wanted) {
    final raw = fields[name];
    switch (name) {
      case 'room' || 'item' || 'budget_line':
        if (found[raw] case final id?) fill[name] = id;
      case 'rooms':
        fill[name] = [
          for (final key in (raw as List? ?? const [])) ?found[key],
        ];
      case 'project' || 'task':
        break; // in the screen the form belongs to
      case 'contractor':
        if (rows[raw] case final contractor?) {
          fill['contractor_name'] = guide.text(
            contractor.fields['name'],
            language,
          );
        }
      case 'due_offset_days':
        fill['due_on'] = today.addDays((raw! as num).toInt());
      case 'issued_offset_days':
        fill['issued_on'] = today.addDays((raw! as num).toInt());
      case 'valid_days':
        final issued = (fields['issued_offset_days'] as num? ?? 0).toInt();
        fill['valid_until'] = today.addDays(issued + (raw! as num).toInt());
      case 'year':
        fill[name] = raw == 'current' ? today.year : raw;
      default:
        fill[name] = guide.text(raw, language);
    }
  }
  return fill;
}

// ---------- the list of the scenarios ----------

/// The guide (`/guide/` of the web, `docs/screens/guide.md`): the five
/// scenarios, each with its progress, then the card of the example home with
/// **Delete the example home**.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

/// The data of a page of the guide, read again at every change of the app.
mixin _GuideReader<T extends StatefulWidget> on State<T> {
  Future<GuideView>? view;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (state.revision != _revision) {
      _revision = state.revision;
      view = readGuide(state, Localizations.localeOf(context).toLanguageTag());
    }
  }
}

class _GuideScreenState extends State<GuideScreen>
    with _GuideReader<GuideScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: l10n.guide,
      body: FutureBuilder<GuideView>(
        future: view,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return const SizedBox.shrink();
          final language = guideLanguage(context, data.guide);
          String text(Object? value) => '${data.guide.text(value, language)}';
          final home = data.home;
          return HcScreenList(
            children: [
              Text(l10n.guideLead, style: HcText.body),
              const SizedBox(height: HcSpace.s3),
              HcCardList(
                children: [
                  for (final (i, scenario) in data.guide.scenarios.indexed)
                    HcRow(
                      key: Key('guide-scenario-${scenario.id}'),
                      title: l10n.guideNumbered(
                        i + 1,
                        text(scenario.raw['title']),
                      ),
                      text: guidePlain(
                        text(scenario.raw['summary']),
                        data.content,
                        language,
                      ),
                      pills: [
                        if (data.finished(scenario))
                          HcPill(
                            l10n.guideScenarioDone,
                            tone: HcPillTone.success,
                          )
                        else
                          HcPill(
                            l10n.guideProgress(
                              data.done(scenario),
                              GuideView.counted(scenario).length,
                            ),
                            tone: HcPillTone.ghost,
                          ),
                      ],
                      onTap: () => Navigator.of(context).push(
                        guideRoute(
                          GuideScenarioScreen(scenarioId: scenario.id),
                          '$guideRouteName/${scenario.id}',
                        ),
                      ),
                    ),
                ],
              ),
              if (home != null) ...[
                HcSectionHeading(l10n.exampleHome),
                HcCardList(
                  children: [
                    HcRow(
                      key: const Key('guide-example-home'),
                      title: home.name,
                      text: home.currency,
                      onTap: () =>
                          Navigator.of(context)
                              .push(hcRoute(HomeScreen(homeId: home.id))),
                    ),
                  ],
                ),
                const ExampleDeleteButton(),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ---------- one scenario ----------

/// One scenario (`/guide/<scenario>/` of the web,
/// `docs/screens/guide-scenario.md`): its steps, ticked by the evaluator,
/// each with **Fill in for me** and **Open**, or **Mark as done** for a step
/// that leaves no trace; "Add what the earlier scenarios make" when an
/// earlier step is not ticked; the previous and the next scenario.
class GuideScenarioScreen extends StatefulWidget {
  const GuideScenarioScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  State<GuideScenarioScreen> createState() => _GuideScenarioScreenState();
}

class _GuideScenarioScreenState extends State<GuideScenarioScreen>
    with _GuideReader<GuideScenarioScreen> {
  Future<void> _catchUp(GuideView data, int number) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final language = guideLanguage(context, data.guide);
    final done = await runChange(context, (r) async {
      final home =
          data.home?.id ??
          await r.createExampleHome(data.guide, language: language);
      await r.fillExample(data.guide, home, upTo: number, language: language);
    });
    if (done) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.guideCaughtUp)));
    }
  }

  void _open(Widget Function() screen) =>
      Navigator.of(context).push(hcRoute(screen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<GuideView>(
      future: view,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const HcScaffold();
        final scenarios = data.guide.scenarios;
        final index = scenarios.indexWhere((s) => s.id == widget.scenarioId);
        if (index < 0) {
          return HcScaffold(
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        final number = index + 1;
        final scenario = scenarios[index];
        final language = guideLanguage(context, data.guide);
        String text(Object? value) => '${data.guide.text(value, language)}';
        final home = data.home;
        GuideScenario? at(int i) =>
            i >= 0 && i < scenarios.length ? scenarios[i] : null;
        final previous = at(index - 1), following = at(index + 1);
        void goTo(GuideScenario other) => Navigator.of(context).pushReplacement(
          guideRoute(
            GuideScenarioScreen(scenarioId: other.id),
            '$guideRouteName/${other.id}',
          ),
        );
        return HcScaffold(
          title: l10n.guideNumbered(number, text(scenario.raw['title'])),
          body: HcScreenList(
            children: [
              GuideText(text(scenario.raw['summary']), content: data.content),
              const SizedBox(height: HcSpace.s3),
              if (data.catchUp(number))
                Padding(
                  padding: const EdgeInsets.only(bottom: HcSpace.s3),
                  child: HcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          home == null
                              ? l10n.guideCatchUpNoHome
                              : l10n.guideCatchUpText,
                          style: HcText.body,
                        ),
                        const SizedBox(height: HcSpace.s3),
                        OutlinedButton(
                          key: const Key('guide-catch-up'),
                          onPressed: () => _catchUp(data, number),
                          child: Text(
                            l10n.guideCatchUp,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              for (final step in scenario.steps)
                _StepCard(
                  key: Key('guide-step-${step.id}'),
                  number: number,
                  step: step,
                  data: data,
                  onOpen: _open,
                ),
              const SizedBox(height: HcSpace.s2),
              Wrap(
                spacing: HcSpace.s2,
                runSpacing: HcSpace.s2,
                children: [
                  if (previous != null)
                    OutlinedButton(
                      key: const Key('guide-previous'),
                      onPressed: () => goTo(previous),
                      child: Text(
                        l10n.guidePrevious(text(previous.raw['title'])),
                      ),
                    ),
                  if (following != null)
                    FilledButton(
                      key: const Key('guide-next'),
                      onPressed: () => goTo(following),
                      child: Text(l10n.guideNext(text(following.raw['title']))),
                    )
                  else
                    FilledButton(
                      key: const Key('guide-back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.guideBack),
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

/// A step: its tick, its number and title, its sentence, and what leads to
/// its screen (`guide/scenario.html` of the web).
class _StepCard extends StatelessWidget {
  const _StepCard({
    super.key,
    required this.number,
    required this.step,
    required this.data,
    required this.onOpen,
  });

  final int number;
  final GuideStep step;
  final GuideView data;
  final void Function(Widget Function() screen) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = guideLanguage(context, data.guide);
    String text(Object? value) => '${data.guide.text(value, language)}';
    final ticked = data.ticked.contains(step.id);
    final links = data.links[step.id] ?? const StepLinks();
    final home = data.home;
    final fill = links.fill, open = links.open;
    return Padding(
      padding: const EdgeInsets.only(bottom: HcSpace.s3),
      child: HcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ticked || step.raw['optional'] == true) ...[
              Wrap(
                spacing: HcSpace.s2,
                runSpacing: HcSpace.s1,
                children: [
                  if (ticked)
                    HcPill(l10n.guideStepDone, tone: HcPillTone.success),
                  if (step.raw['optional'] == true)
                    HcPill(l10n.guideOptional, tone: HcPillTone.ghost),
                ],
              ),
              const SizedBox(height: HcSpace.s2),
            ],
            Semantics(
              header: true,
              child: Text(
                l10n.guideStepNumbered(
                  number,
                  step.id.split('.').last,
                  text(step.raw['title']),
                ),
                style: HcText.cardTitle,
              ),
            ),
            const SizedBox(height: HcSpace.s2),
            GuideText(text(step.raw['explain']), content: data.content),
            if (open != null || fill != null) ...[
              const SizedBox(height: HcSpace.s3),
              Wrap(
                spacing: HcSpace.s2,
                runSpacing: HcSpace.s2,
                children: [
                  if (fill != null)
                    FilledButton(
                      key: Key('guide-fill-${step.id}'),
                      onPressed: () => onOpen(fill),
                      child: Text(l10n.guideFill),
                    ),
                  if (open != null)
                    fill == null
                        ? FilledButton(
                            key: Key('guide-open-${step.id}'),
                            onPressed: () => onOpen(open),
                            child: Text(l10n.guideOpen),
                          )
                        : OutlinedButton(
                            key: Key('guide-open-${step.id}'),
                            onPressed: () => onOpen(open),
                            child: Text(l10n.guideOpen),
                          ),
                ],
              ),
            ] else if (home == null && !ticked) ...[
              const SizedBox(height: HcSpace.s2),
              Text(l10n.guideNeedsHome, style: HcText.bodySmall),
            ],
            if (step.manual && home != null && !ticked) ...[
              const SizedBox(height: HcSpace.s2),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(
                  key: Key('guide-tick-${step.id}'),
                  onPressed: () => runChange(
                    context,
                    (r) => r.tickByHand(data.guide, home.id, step.id),
                  ),
                  child: Text(l10n.guideMarkDone),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- the example home on its screens ----------

/// The banner of every screen of the example home (`guide/_banner.html` of
/// the web): what the home is, **Back to the guide** and **Delete the
/// example home**. Nothing on the screens of a real home.
class ExampleHomeBanner extends StatelessWidget {
  const ExampleHomeBanner({super.key, required this.homeId});

  final String? homeId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.isExample(homeId)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    // The banner of the page (`HcBanner`: sage-soft on a border), its text,
    // the link back and the button under one another, so that each keeps
    // the width of the column at every text size.
    return Padding(
      key: const Key('example-banner'),
      padding: const EdgeInsets.only(top: HcSpace.s2, bottom: HcSpace.s3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HcColors.sageSoft,
          border: Border.all(color: HcColors.border),
          borderRadius: BorderRadius.circular(HcRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            HcSpace.s4,
            HcSpace.s3,
            HcSpace.s4,
            HcSpace.s4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.exampleHome,
                      style: HcText.body.copyWith(fontWeight: HcFont.bold),
                    ),
                    TextSpan(text: ' · ${l10n.exampleBannerText}'),
                  ],
                ),
                style: HcText.body,
              ),
              HcLink(
                l10n.guideBack,
                key: const Key('example-banner-guide'),
                onTap: () => _backToGuide(context),
              ),
              const ExampleDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back to the guide page under this screen, or to the guide when it is not
/// under it (a screen of the example home opened from My homes).
void _backToGuide(BuildContext context) {
  final navigator = Navigator.of(context);
  var below = false;
  navigator.popUntil((route) {
    if (route.settings.name?.startsWith(guideRouteName) ?? false) {
      below = true;
      return true;
    }
    return route.isFirst;
  });
  if (!below) openGuide(navigator.context);
}

/// **Delete the example home**: one press, one confirmation in a dialog, no
/// name to type, no export (web ADR 0084, decision 2). The one style of
/// Delete of the app, on the guide and in the banner.
class ExampleDeleteButton extends StatelessWidget {
  const ExampleDeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcDeleteButton(
      key: const Key('example-delete'),
      label: l10n.exampleDelete,
      onPressed: () => deleteExampleHome(context),
    );
  }
}

/// Asks once, then deletes the example home: its rows, its files and its
/// ticks go (`Repository.removeExample`). Lands on the guide page under the
/// screen, or the root of the section.
Future<void> deleteExampleHome(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final state = AppScope.of(context);
  final example = state.exampleHome;
  if (example == null) return;
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (!await confirmDelete(
    context,
    title: l10n.exampleDeleteTitle,
    body: l10n.exampleDeleteBody,
  )) {
    return;
  }
  if (!context.mounted) return;
  if (!await runChange(context, (r) => r.removeExample(example.id))) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.exampleDeleted)));
  navigator.popUntil(
    (route) =>
        route.isFirst ||
        (route.settings.name?.startsWith(guideRouteName) ?? false),
  );
}

/// The card of an empty Today (`tasks/today.html` of the web): the guide,
/// for a person who does not know where to start.
class GuideTodayCard extends StatelessWidget {
  const GuideTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      key: const Key('today-guide'),
      padding: const EdgeInsets.only(top: HcSpace.s3),
      child: HcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.guide, style: HcText.cardTitle),
            ),
            const SizedBox(height: HcSpace.s2),
            Text(l10n.todayGuideText, style: HcText.body),
            const SizedBox(height: HcSpace.s3),
            OutlinedButton(
              key: const Key('today-guide-open'),
              onPressed: () => openGuide(context),
              child: Text(l10n.todayGuideOpen, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
