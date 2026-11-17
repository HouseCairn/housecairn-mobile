// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../core/photo_source.dart';
import '../data/database.dart';
import '../data/repository.dart' hide maxFileBytes;
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/values.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../domain/photos.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import 'budget_parts.dart';
import 'parts.dart';
import 'photos.dart' show ReportPhoto;
import 'messages.dart';
import 'state.dart';
import 'item_screens.dart';
import 'rooms.dart';
import 'stock_screens.dart';
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
            // The web's `.undo-banner` of the open reports line: the count
            // at the left and the button at the right on the same line
            // (`reports/_today.html`).
            child: HcBanner(
              key: const Key('today-reports'),
              action: OutlinedButton(
                key: const Key('today-reports-see'),
                onPressed: () => open(ReportsScreen(homeId: homeId)),
                child: Text(l10n.seeReports),
              ),
              child: Text(
                l10n.problemsReported(count),
                key: const Key('today-reports-count'),
                style: HcText.body,
              ),
            ),
          ),
        // The banner has its own space under it (`HcBanner`).
        if (count == 0) const SizedBox(height: HcSpace.s2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: const Key('today-report-add'),
            onPressed: () => open(ReportFormScreen(homeId: homeId)),
            child: Text(l10n.reportProblem),
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
      actions: const [HelpButton(page: HelpPages.reports)],
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

/// What the page of a report shows: the report, its task, its home, and the
/// room, item or stock item it is about, when it still exists.
class _ReportData {
  _ReportData(this.report, this.task, this.home, this.where);

  final ReportRow report;
  final TaskRow? task;
  final HomeRow home;

  /// The page of the place, to open from Where.
  final Widget? where;
}

/// A report (`reports/report_detail.html`), on the pattern of a record page:
/// its state pill, its title, Where, Reported on, Closed on and Task as lines
/// of label and value, its photo, then the action row: make it a task, close
/// it, or reopen it.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.homeId, required this.reportId});

  final String homeId;
  final String reportId;

  Future<_ReportData?> _load(Repository r) async {
    final report = await r.report(reportId);
    final home = await r.home(homeId);
    if (report == null || home == null) return null;
    final task = report.taskId == null ? null : await r.task(report.taskId!);
    Widget? where;
    if (report.roomId != null && await r.room(report.roomId!) != null) {
      where = RoomScreen(homeId: homeId, roomId: report.roomId!);
    } else if (report.itemId != null && await r.item(report.itemId!) != null) {
      where = ItemScreen(homeId: homeId, itemId: report.itemId!);
    } else if (report.articleId != null &&
        await r.article(report.articleId!) != null) {
      where = ArticleScreen(homeId: homeId, articleId: report.articleId!);
    }
    return _ReportData(report, task, home, where);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<_ReportData?>(
      load: _load,
      builder: (context, data) {
        if (data == null) return HcScaffold();
        final report = data.report;
        final task = data.task;
        final where = data.where;
        final writable = data.home.archivedAt == null;
        final closed = reportClosedStatuses.contains(report.status);
        void open(Widget screen) => Navigator.of(context).push(hcRoute(screen));
        Future<void> change(Future<void> Function(Repository) action) async {
          await runChange(context, action);
        }

        return HcScaffold(
          title: report.title,
          // The title is drawn under the pill, as on the web.
          drawsTitle: false,
          actions: const [HelpButton(page: HelpPages.report)],
          body: HcScreenList(
            children: [
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: HcPill(
                        reportStatusLabel(l10n, report.status),
                        key: const Key('report-status'),
                        tone: reportStatusTone(report.status),
                      ),
                    ),
                    const SizedBox(height: HcSpace.s2),
                    Semantics(
                      header: true,
                      child: Text(report.title, style: HcText.pageTitle),
                    ),
                    const SizedBox(height: HcSpace.s3),
                    HcValueList(
                      key: const Key('report-facts'),
                      children: [
                        if (report.place.isNotEmpty)
                          HcValueRow(
                            l10n.reportWhereFact,
                            report.place,
                            child: where == null
                                ? null
                                : HcValueLink(
                                    report.place,
                                    key: const Key('report-where'),
                                    onTap: () => open(where),
                                  ),
                          ),
                        HcValueRow(
                          l10n.reportedOn,
                          formatDay(context, _dayOf(report.createdAt)),
                        ),
                        if (report.closedAt != null)
                          HcValueRow(
                            l10n.closedOn,
                            formatDay(context, _dayOf(report.closedAt!)),
                          ),
                        if (task != null)
                          HcValueRow(
                            l10n.reportTask,
                            task.title,
                            child: HcValueLink(
                              task.title,
                              key: const Key('report-task'),
                              onTap: () => open(
                                TaskScreen(homeId: homeId, taskId: task.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (report.photo != null) ...[
                      const SizedBox(height: HcSpace.s3),
                      // Until its file has come from the server (lot 4d,
                      // docs/adr/0013), the photo is the plain tile of a
                      // photo, said as such.
                      ReportPhoto(report: report),
                    ],
                    // The action row: one primary action at most, the others
                    // secondary, as wide as their label, on lines that wrap.
                    if (writable)
                      RecordActions(
                        children: [
                          if (report.status == reportOpen)
                            FilledButton(
                              key: const Key('report-make-task'),
                              onPressed: () =>
                                  change((r) => r.makeTask(reportId)),
                              child: Text(l10n.makeItATask),
                            ),
                          if (!closed) ...[
                            OutlinedButton(
                              key: const Key('report-resolve'),
                              onPressed: () => change(
                                (r) => r.closeReport(reportId, reportResolved),
                              ),
                              child: Text(l10n.markResolved),
                            ),
                            OutlinedButton(
                              key: const Key('report-no-action'),
                              onPressed: () => change(
                                (r) => r.closeReport(reportId, reportNoAction),
                              ),
                              child: Text(l10n.closeWithoutAction),
                            ),
                          ] else
                            OutlinedButton(
                              key: const Key('report-reopen'),
                              onPressed: () =>
                                  change((r) => r.reopenReport(reportId)),
                              child: Text(l10n.reopen),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Report a problem (`reports/report_form.html`): what is wrong, where (a
/// room, an item or a stock item, optional) and a photo (optional),
/// re-encoded without metadata. Opened from the page of a room, an item or a
/// stock item, Where starts with it, as the web's `?room=`, `?item=` and
/// `?article=`.
class ReportFormScreen extends StatefulWidget implements HcFormScreen {
  @override
  bool get opensAsSheet => true;

  const ReportFormScreen({
    super.key,
    required this.homeId,
    this.roomId,
    this.itemId,
    this.articleId,
  });

  final String homeId;

  /// The place Where starts with: one at most.
  final String? roomId;
  final String? itemId;
  final String? articleId;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();

  /// The place chosen, `room:<id>`, `item:<id>` or `article:<id>`, as the
  /// web's field `place`; null for none.
  String? _place;

  /// The places of the home, in the order of the web's list: the rooms, the
  /// items ("Room · Item"), then the stock items.
  List<(String, String)> _places = const [];
  ProcessedPhoto? _photo;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _place = widget.roomId != null
        ? 'room:${widget.roomId}'
        : widget.itemId != null
        ? 'item:${widget.itemId}'
        : widget.articleId != null
        ? 'article:${widget.articleId}'
        : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadPlaces(AppScope.of(context).repository);
  }

  Future<void> _loadPlaces(Repository r) async {
    final rooms = await r.rooms(widget.homeId);
    final names = {for (final room in rooms) room.id: room.name};
    final items = await r.itemsOfHome(widget.homeId);
    final articles = await r.articles(widget.homeId);
    if (!mounted) return;
    setState(() {
      _places = [
        for (final room in rooms) ('room:${room.id}', room.name),
        for (final item in items)
          ('item:${item.id}', [?names[item.roomId], item.name].join(' · ')),
        for (final a in articles) ('article:${a.article.id}', a.article.name),
      ];
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
    final chosen = _places.where((p) => p.$1 == _place).firstOrNull;
    final parts = chosen?.$1.split(':') ?? const ['', ''];
    final kind = parts.first, id = parts.last;
    final saved = await runChange(
      context,
      (r) => r.createReport(
        widget.homeId,
        title: _title.text,
        roomId: kind == 'room' ? id : null,
        itemId: kind == 'item' ? id : null,
        articleId: kind == 'article' ? id : null,
        place: chosen?.$2 ?? '',
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
                    _places.any((p) => p.$1 == _place) ? _place : null,
                    [(null, '—'), ..._places],
                    (v) => setState(() => _place = v),
                    key: const Key('report-room'),
                  ),
                  if (AppScope.of(context).photoSource != null) ...[
                    HcField(
                      label: l10n.photo,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton(
                          key: const Key('report-photo-add'),
                          onPressed: _addPhoto,
                          child: Text(
                            _photo == null ? l10n.addPhoto : l10n.photoChosen,
                          ),
                        ),
                      ),
                    ),
                    fieldHelp(
                      l10n.reportPhotoHelpSize(
                        l10n.sizeMegabytes(maxFileBytes ~/ (1024 * 1024)),
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
