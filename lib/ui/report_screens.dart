// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../core/photo_source.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../domain/photos.dart';
import '../l10n/app_localizations.dart';
import 'parts.dart';
import 'messages.dart';
import 'state.dart';
import 'task_screen.dart';

String reportStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      reportTask => l10n.reportMadeTask,
      reportResolved => l10n.reportResolved,
      reportNoAction => l10n.reportNoAction,
      _ => l10n.reportOpen,
    };

/// The tone of the pill of a report, as the web's `reports/report_detail.html`
/// has it: open is `warning`, made a task `info`, the rest `ghost`.
HcPillTone reportStatusTone(String status) => switch (status) {
  reportTask => HcPillTone.info,
  reportResolved || reportNoAction => HcPillTone.ghost,
  _ => HcPillTone.warning,
};

Day _dayOf(int millis) =>
    Day.of(DateTime.fromMillisecondsSinceEpoch(millis).toLocal());

/// The open reports of Today (`reports/_today.html`): how many problems are
/// waiting, a way to see them, and a way to report one.
class TodayReports extends StatelessWidget {
  const TodayReports({super.key, required this.count, required this.homeId});

  final int count;
  final String homeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open(Widget screen) => Navigator.of(context).push(hcRoute(screen));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (count > 0)
          Semantics(
            liveRegion: true,
            child: HcCard(
              child: Wrap(
                spacing: HcSpace.s3,
                runSpacing: HcSpace.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.problemsReported(count),
                    key: const Key('today-reports-count'),
                    style: HcText.body,
                  ),
                  OutlinedButton(
                    key: const Key('today-reports-see'),
                    onPressed: () => open(ReportsScreen(homeId: homeId)),
                    child: Text(l10n.seeReports),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: HcSpace.s2),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              key: const Key('today-report-add'),
              onPressed: () => open(ReportFormScreen(homeId: homeId)),
              child: Text(l10n.reportProblem),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reports (`reports/report_list.html`): Open, Closed, All.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.homeId});

  final String homeId;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const keys = [reportOpen, 'closed', ''];
    return HcScaffold(
      title: l10n.reports,
      body: DataView<List<ReportEntry>>(
        key: ValueKey('${widget.homeId}|$_filter'),
        load: (r) => r.reportsOf(widget.homeId, status: keys[_filter]),
        builder: (context, entries) => HcScreenList(
          children: [
            HcTabs(
              key: const Key('reports-tabs'),
              labels: [l10n.reportsOpen, l10n.reportsClosed, l10n.reportsAll],
              current: _filter,
              onSelect: (i) => setState(() => _filter = i),
            ),
            if (entries.isEmpty)
              HcEmpty(l10n.reportsEmpty)
            else
              HcCardList(
                children: [
                  for (final e in entries)
                    HcRow(
                      key: Key('report-${e.report.id}'),
                      title: e.report.title,
                      text: [
                        if (e.report.place.isNotEmpty) e.report.place,
                        reportStatusLabel(l10n, e.report.status),
                        formatDay(context, _dayOf(e.report.createdAt)),
                      ].join(' · '),
                      onTap: () => Navigator.of(context).push(
                        hcRoute(
                          ReportScreen(
                            homeId: widget.homeId,
                            reportId: e.report.id,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            HcAddButton(
              key: const Key('report-add'),
              label: l10n.reportProblem,
              gap: HcSpace.s3,
              onPressed: () =>
                  Navigator.of(context)
                      .push(hcRoute(ReportFormScreen(homeId: widget.homeId))),
            ),
          ],
        ),
      ),
    );
  }
}

/// A report (`reports/report_detail.html`): what, where, when, its photo,
/// and the actions: make it a task, close it, reopen it.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.homeId, required this.reportId});

  final String homeId;
  final String reportId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<(ReportRow?, TaskRow?, HomeRow?)>(
      load: (r) async {
        final report = await r.report(reportId);
        final task = report?.taskId == null
            ? null
            : await r.task(report!.taskId!);
        return (report, task, await r.home(homeId));
      },
      builder: (context, data) {
        final (report, task, home) = data;
        if (report == null || home == null) return HcScaffold();
        final repository = AppScope.of(context).repository;
        final writable = home.archivedAt == null;
        final closed = reportClosedStatuses.contains(report.status);
        final photo = repository.reportPhoto(report);
        return HcScaffold(
          title: report.title,
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: HcSpace.s3),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: HcPill(
                          reportStatusLabel(l10n, report.status),
                          tone: reportStatusTone(report.status),
                        ),
                      ),
                    ),
                    if (report.place.isNotEmpty)
                      HcFact(l10n.reportWhere, factText(report.place)),
                    HcFact(
                      l10n.reportedOn,
                      factText(formatDay(context, _dayOf(report.createdAt))),
                    ),
                    if (report.closedAt != null)
                      HcFact(
                        l10n.closedOn,
                        factText(formatDay(context, _dayOf(report.closedAt!))),
                      ),
                    if (task != null)
                      HcFact(
                        l10n.reportTask,
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            hcRoute(
                              TaskScreen(homeId: homeId, taskId: task.id),
                            ),
                          ),
                          child: Text(
                            task.title,
                            style: HcText.body.copyWith(
                              color: HcColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (report.photo != null && photo.existsSync()) ...[
                const SizedBox(height: HcSpace.s3),
                Semantics(
                  image: true,
                  label: l10n.reportPhoto,
                  child: Image.file(photo, key: const Key('report-photo')),
                ),
              ],
              if (writable) ...[
                const SizedBox(height: HcSpace.s4),
                if (report.status == reportOpen)
                  FilledButton(
                    key: const Key('report-make-task'),
                    onPressed: () async {
                      await runChange(context, (r) => r.makeTask(reportId));
                    },
                    child: Text(l10n.makeItATask),
                  ),
                if (!closed) ...[
                  const SizedBox(height: HcSpace.s2),
                  OutlinedButton(
                    key: const Key('report-resolve'),
                    onPressed: () => runChange(
                      context,
                      (r) => r.closeReport(reportId, reportResolved),
                    ),
                    child: Text(l10n.markResolved),
                  ),
                  const SizedBox(height: HcSpace.s2),
                  OutlinedButton(
                    key: const Key('report-no-action'),
                    onPressed: () => runChange(
                      context,
                      (r) => r.closeReport(reportId, reportNoAction),
                    ),
                    child: Text(l10n.closeWithoutAction),
                  ),
                ] else
                  OutlinedButton(
                    key: const Key('report-reopen'),
                    onPressed: () =>
                        runChange(context, (r) => r.reopenReport(reportId)),
                    child: Text(l10n.reopen),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Report a problem (`reports/report_form.html`): what is wrong, where (a
/// room, optional) and a photo (optional), re-encoded without metadata.
class ReportFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const ReportFormScreen({super.key, required this.homeId});

  final String homeId;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  String? _room;
  List<RoomRow> _rooms = const [];
  ProcessedPhoto? _photo;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.of(context).repository.rooms(widget.homeId).then((rooms) {
      if (mounted) setState(() => _rooms = rooms);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final source = state.photoSource;
    if (source == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await source.pickPhoto();
      if (bytes == null) return;
      final photo = await state.photoProcessor(bytes);
      if (mounted) setState(() => _photo = photo);
    } on PhotoPermissionDenied {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoDenied)));
    } on PhotoRefused {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errPhotoUnreadable)));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final place = _room == null
        ? ''
        : _rooms.firstWhere((r) => r.id == _room).name;
    final saved = await runChange(
      context,
      (r) => r.createReport(
        widget.homeId,
        title: _title.text,
        roomId: _room,
        place: place,
        photo: _photo,
      ),
    );
    if (saved) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: l10n.reportProblem,
      actions: [HcBarAction(label: l10n.sendReport, onPressed: _save)],
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
                    l10n.whatIsWrong,
                    _title,
                    key: const Key('report-title'),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l10n.errSayWhatIsWrong
                        : null,
                  ),
                  hcChoice<String?>(
                    l10n.reportWhere,
                    _room,
                    [(null, '—'), for (final r in _rooms) (r.id, r.name)],
                    (v) => setState(() => _room = v),
                    key: const Key('report-room'),
                  ),
                  if (AppScope.of(context).photoSource != null) ...[
                    Text(l10n.reportPhotoHelp, style: HcText.bodySmall),
                    const SizedBox(height: HcSpace.s2),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: OutlinedButton(
                        key: const Key('report-photo-add'),
                        onPressed: _addPhoto,
                        child: Text(
                          _photo == null ? l10n.addPhoto : l10n.photoChosen,
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
    );
  }
}
