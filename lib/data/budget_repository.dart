// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// What a project is made of, as its form edits it (`projects/models.py`
/// `Project`). Only [title] is required; [budget], on creation only, becomes
/// its first budget line, "Budget", of nature Other (`create_project`).
class ProjectInput {
  const ProjectInput({
    required this.title,
    this.goal = '',
    this.status = 'idea',
    this.priority = 'normal',
    this.estimatedMinutes,
    this.season,
    this.seasonStartMonth,
    this.seasonEndMonth,
    this.roomIds = const [],
    this.budget = '',
    this.budgetLabel = 'Budget',
  });

  final String title;
  final String goal;
  final String status;
  final String priority;
  final int? estimatedMinutes;

  /// The preferred season: `''` for any time, a predefined season or custom
  /// months (`recurrence.custom`, with the two months). `null` leaves what
  /// the project holds as it is.
  final String? season;
  final int? seasonStartMonth;
  final int? seasonEndMonth;
  final List<String> roomIds;
  final String budget;

  /// The label of the first line, in the language of the phone.
  final String budgetLabel;
}

/// A budget line as its form edits it: amounts are typed text.
class LineInput {
  const LineInput({
    required this.label,
    this.nature = budget.other,
    this.planned = '',
    this.paid = '',
  });

  factory LineInput.of(BudgetLineRow row) => LineInput(
    label: row.label,
    nature: row.nature,
    planned: stock.plain(budget.readMoney(row.planned)),
    paid: stock.plain(budget.readMoney(row.paid)),
  );

  final String label;
  final String nature;
  final String planned;
  final String paid;
}

/// A quote as its form edits it (`projects/models.py` `Quote`). An accepted
/// quote needs [budgetLineId], a line of its project; any other has none.
class QuoteInput {
  const QuoteInput({
    this.contractorId,
    this.amount = '',
    this.issuedOn,
    this.validUntil,
    this.status = 'requested',
    this.budgetLineId,
    this.note = '',
  });

  factory QuoteInput.of(QuoteRow row) => QuoteInput(
    contractorId: row.contractorId,
    amount: stock.plain(budget.readMoney(row.amount)),
    issuedOn: row.issuedOn == null ? null : Day.parse(row.issuedOn!),
    validUntil: row.validUntil == null ? null : Day.parse(row.validUntil!),
    status: row.status,
    budgetLineId: row.budgetLineId,
    note: row.note,
  );

  final String? contractorId;
  final String amount;
  final Day? issuedOn;
  final Day? validUntil;
  final String status;
  final String? budgetLineId;
  final String note;
}

/// A project with its amounts (the sum of its lines, `amounts_of`).
class ProjectEntry {
  const ProjectEntry(this.project, this.amounts);

  final ProjectRow project;
  final budget.Amounts amounts;
}

/// A line with its amounts and the quotes accepted on it (`LineSummary`).
class LineEntry {
  const LineEntry(this.line, this.amounts, this.quotes);

  final BudgetLineRow line;
  final budget.Amounts amounts;
  final List<QuoteRow> quotes;
}

/// A quote with the name of its contractor and the label of its line.
class QuoteEntry {
  const QuoteEntry(this.quote, {this.contractor, this.line, this.files = 0});

  final QuoteRow quote;
  final String? contractor;
  final String? line;
  final int files;
}

/// A report with the task it was made into, if any.
class ReportEntry {
  const ReportEntry(this.report, {this.task});

  final ReportRow report;
  final TaskRow? task;

  bool get isOpen => report.status == reportOpen;
  bool get isClosed => reportClosedStatuses.contains(report.status);
}

const reportOpen = 'open';
const reportTask = 'task';
const reportResolved = 'resolved';
const reportNoAction = 'no_action';
const reportStatuses = [reportOpen, reportTask, reportResolved, reportNoAction];
const reportClosedStatuses = [reportResolved, reportNoAction];

/// Limits of the web (`projects/models.py:24-27`, `reports/models.py`).
const maxPhotosPerProject = 30;
const maxFilesPerQuote = 5;
const maxLinksPerProject = 30;
const maxFileBytes = 20 * 1024 * 1024;
const envelopeYears = (2000, 2200);

/// Projects, budget lines, quotes, files, links, tasks of projects, annual
/// envelopes, reports, the budgets of a task, the real cost of an occurrence
/// and the paint left of a room (`projects/services.py`, `reports/services.py`,
/// `budget/services.py`). Every rule is the web's; committed amounts and every
/// figure of the budget are computed on read, never stored.
extension BudgetRepository on Repository {
  // ---------- ids (docs/adr/0003-sync-protocol.md, "Deterministic ids") ----------

  static String projectRoomId(String home, String project, String room) =>
      Repository._uuid.v5(home, 'projects.project_rooms:$project:$room');

  /// A task is in one project at most: the id follows the task.
  static String projectTaskId(String home, String task) =>
      Repository._uuid.v5(home, 'projects.projecttask:$task');

  /// One envelope per year and home: `envelope:` and the year in four
  /// decimal digits (docs/adr/0003-sync-protocol.md, web ADR 0077). Schema 5
  /// named it `projects.annualenvelope:<year>`; the step to schema 6 gives
  /// the rows of then this id.
  static String envelopeId(String home, int year) => envelopeIdOf(home, year);

  // ---------- money ----------

  static String _money(String text) {
    final value = budget.parseMoney(text);
    if (value == null) throw const Refused(Refusal.moneyInvalid);
    return budget.storedMoney(value);
  }

  static String? _optionalMoney(String text) =>
      text.trim().isEmpty ? null : _money(text);

  // ---------- projects ----------

  Future<ProjectRow?> project(String id) =>
      (db.select(db.projects)
            ..where((p) => p.id.equalsValue(id) & p.deletedAt.isNull()))
          .getSingleOrNull();

  Future<ProjectRow> _writableProject(String id) async {
    final found = await project(id);
    if (found == null) throw const Refused(Refusal.notFound);
    await _writableHome(found.homeId);
    return found;
  }

  /// The projects of a home, the ones going on first, then by priority and
  /// creation (`search_projects`); [status] keeps one status.
  Future<List<ProjectEntry>> projects(
    String homeId, {
    String status = '',
  }) async {
    final rows =
        await (db.select(db.projects)..where(
              (p) =>
                  p.homeId.equalsValue(homeId) &
                  p.deletedAt.isNull() &
                  (status.isEmpty
                      ? const Constant(true)
                      : p.status.equals(status)),
            ))
            .get();
    int rank(ProjectRow p) => budget.projectStatuses.indexOf(p.status);
    int urgency(ProjectRow p) => switch (p.priority) {
      'high' => 0,
      'normal' => 1,
      _ => 2,
    };
    rows.sort((a, b) {
      for (final c in [
        rank(a).compareTo(rank(b)),
        urgency(a).compareTo(urgency(b)),
        a.createdAt.compareTo(b.createdAt),
      ]) {
        if (c != 0) return c;
      }
      return Uuid.parse(a.id).toString().compareTo(Uuid.parse(b.id).toString());
    });
    final totals = await _totals(homeId);
    return [
      for (final p in rows)
        ProjectEntry(p, totals[p.id] ?? budget.Amounts.none),
    ];
  }

  /// The total of each project of [homeId], line by line (`amounts_by_project`).
  Future<Map<String, budget.Amounts>> _totals(String homeId) async {
    final committed = await _committedByLine(homeId);
    final totals = <String, budget.Amounts>{};
    for (final line in await _lines(homeId: homeId)) {
      totals[line.projectId] =
          (totals[line.projectId] ?? budget.Amounts.none) +
          budget.Amounts.line(
            budget.readMoney(line.planned),
            committed[line.id],
            budget.readMoney(line.paid),
          );
    }
    return totals;
  }

  Future<List<BudgetLineRow>> _lines({String? homeId, String? projectId}) =>
      (db.select(db.budgetLines)
            ..where(
              (l) =>
                  l.deletedAt.isNull() &
                  (projectId != null
                      ? l.projectId.equalsValue(projectId)
                      : l.homeId.equalsValue(homeId!)),
            )
            ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
          .get();

  Future<List<QuoteRow>> _quotes({String? homeId, String? projectId}) =>
      (db.select(db.quotes)
            ..where(
              (q) =>
                  q.deletedAt.isNull() &
                  (projectId != null
                      ? q.projectId.equalsValue(projectId)
                      : q.homeId.equalsValue(homeId!)),
            )
            ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
          .get();

  Future<Map<String, Decimal>> _committedByLine(String homeId) async {
    final committed = <String, Decimal>{};
    for (final q in await _quotes(homeId: homeId)) {
      if (q.status != budget.accepted || q.budgetLineId == null) continue;
      committed[q.budgetLineId!] =
          (committed[q.budgetLineId!] ?? budget.zero) +
          budget.readMoney(q.amount);
    }
    return committed;
  }

  /// The rooms a project concerns, in the household's order.
  Future<List<RoomRow>> roomsOfProject(String projectId) async {
    final links =
        await (db.select(db.projectRooms)..where(
              (l) => l.projectId.equalsValue(projectId) & l.deletedAt.isNull(),
            ))
            .get();
    final ids = {for (final l in links) l.roomId};
    final found = await (db.select(
      db.rooms,
    )..where((r) => r.id.isInValues(ids) & r.deletedAt.isNull())).get();
    return found..sort((a, b) {
      final p = a.position.compareTo(b.position);
      return p != 0 ? p : a.name.compareTo(b.name);
    });
  }

  Map<String, Object?> _projectFields(ProjectInput input) {
    Repository._oneOf(input.status, budget.projectStatuses);
    Repository._oneOf(input.priority, const ['high', 'normal', 'low']);
    final minutes = input.estimatedMinutes;
    if (minutes != null && (minutes < 1 || minutes > 365 * 24 * 60)) {
      throw const Refused(Refusal.choiceInvalid);
    }
    if (input.goal.length > 5000) throw const Refused(Refusal.tooLong);
    final season = input.season;
    var start = input.seasonStartMonth;
    var end = input.seasonEndMonth;
    if (season != null) {
      Repository._oneOf(season, [
        '',
        ...recurrence.predefinedSeasons,
        recurrence.custom,
      ]);
      if (season != recurrence.custom) {
        start = end = null;
      } else if (start == null ||
          end == null ||
          start < 1 ||
          start > 12 ||
          end < 1 ||
          end > 12) {
        throw const Refused(Refusal.seasonMonthsRequired);
      }
    }
    return {
      'title': Repository._name(input.title, 200),
      'goal': input.goal.trim(),
      'status': input.status,
      'priority': input.priority,
      'estimated_minutes': minutes,
      if (season != null) ...{
        'season': season,
        'season_start_month': start,
        'season_end_month': end,
      },
    };
  }

  Future<void> _checkRooms(String homeId, List<String> roomIds) async {
    for (final id in roomIds) {
      if ((await room(id))?.homeId != homeId) {
        throw const Refused(Refusal.notInHome);
      }
    }
  }

  Future<void> _setProjectRooms(
    String homeId,
    String projectId,
    List<String> roomIds,
  ) async {
    final wanted = roomIds.toSet();
    final links = await (db.select(
      db.projectRooms,
    )..where((l) => l.projectId.equalsValue(projectId))).get();
    final now = _now();
    for (final link in links) {
      final keep = wanted.contains(link.roomId);
      if (keep && link.deletedAt != null) {
        await _put('project_rooms', link.id, {'deleted_at': null});
      } else if (!keep && link.deletedAt == null) {
        await _put('project_rooms', link.id, {'deleted_at': now});
      }
    }
    final known = {for (final l in links) l.roomId};
    for (final roomId in wanted.difference(known)) {
      await _put(
        'project_rooms',
        projectRoomId(homeId, projectId, roomId),
        {'project_id': projectId, 'room_id': roomId, 'deleted_at': null},
        homeId: homeId,
        create: true,
      );
    }
  }

  /// Creates a project (`create_project`); a [ProjectInput.budget] becomes
  /// its first line.
  Future<String> createProject(String homeId, ProjectInput input) async {
    await _writableHome(homeId);
    final fields = _projectFields(input);
    final first = _optionalMoney(input.budget);
    await _checkRooms(homeId, input.roomIds);
    final id = newId();
    await db.transaction(() async {
      await _put(
        'projects',
        id,
        {
          'season': '',
          'season_start_month': null,
          'season_end_month': null,
          ...fields,
          'deleted_at': null,
        },
        homeId: homeId,
        create: true,
      );
      await _setProjectRooms(homeId, id, input.roomIds);
      if (first != null) {
        await _put(
          'budget_lines',
          newId(),
          {
            'project_id': id,
            'label': Repository._name(input.budgetLabel, 120),
            'nature': budget.other,
            'planned': first,
            'paid': budget.storedMoney(budget.zero),
            'deleted_at': null,
          },
          homeId: homeId,
          create: true,
        );
      }
    });
    return id;
  }

  Future<void> updateProject(String id, ProjectInput input) async {
    final current = await _writableProject(id);
    final changes = _changes(current, _projectFields(input));
    await _checkRooms(current.homeId, input.roomIds);
    await db.transaction(() async {
      if (changes.isNotEmpty) await _put('projects', id, changes);
      await _setProjectRooms(current.homeId, id, input.roomIds);
    });
  }

  /// Soft-deletes a project with its lines, quotes, files, links and room
  /// links; its tasks stay, out of the project (`delete_project`).
  Future<void> deleteProject(String id) async {
    final current = await _writableProject(id);
    final now = _now();
    await db.transaction(() async {
      for (final (table, rows) in [
        ('project_tasks', await _projectTaskRows(id)),
        ('project_links', await linksOf(id)),
        ('project_files', await filesOf(id)),
        ('quotes', await _quotes(projectId: id)),
        ('budget_lines', await _lines(projectId: id)),
      ]) {
        for (final row in rows) {
          await _put(table, (row as dynamic).id as String, {'deleted_at': now});
        }
      }
      await _setProjectRooms(current.homeId, id, const []);
      await _put('projects', id, {'deleted_at': now});
    });
  }

  // ---------- budget lines ----------

  Future<BudgetLineRow?> budgetLine(String id) =>
      (db.select(db.budgetLines)
            ..where((l) => l.id.equalsValue(id) & l.deletedAt.isNull()))
          .getSingleOrNull();

  /// The lines of a project with their three amounts (`line_summaries`).
  Future<List<LineEntry>> linesOf(String projectId) async {
    final quotes = [
      for (final q in await _quotes(projectId: projectId))
        if (q.status == budget.accepted) q,
    ];
    return [
      for (final line in await _lines(projectId: projectId))
        () {
          final on = [
            for (final q in quotes)
              if (q.budgetLineId == line.id) q,
          ];
          return LineEntry(
            line,
            budget.Amounts.line(
              budget.readMoney(line.planned),
              on.fold<Decimal>(
                budget.zero,
                (sum, q) => sum + budget.readMoney(q.amount),
              ),
              budget.readMoney(line.paid),
            ),
            on,
          );
        }(),
    ];
  }

  Map<String, Object?> _lineFields(LineInput input) {
    Repository._oneOf(input.nature, budget.natures);
    return {
      'label': Repository._name(input.label, 120),
      'nature': input.nature,
      'planned': input.planned.trim().isEmpty
          ? budget.storedMoney(budget.zero)
          : _money(input.planned),
      'paid': input.paid.trim().isEmpty
          ? budget.storedMoney(budget.zero)
          : _money(input.paid),
    };
  }

  Future<String> createLine(String projectId, LineInput input) async {
    final owner = await _writableProject(projectId);
    final fields = _lineFields(input);
    final id = newId();
    await db.transaction(
      () => _put(
        'budget_lines',
        id,
        {...fields, 'project_id': projectId, 'deleted_at': null},
        homeId: owner.homeId,
        create: true,
      ),
    );
    return id;
  }

  Future<void> updateLine(String id, LineInput input) async {
    final current = await budgetLine(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableProject(current.projectId);
    final changes = _changes(current, _lineFields(input));
    if (changes.isEmpty) return;
    await db.transaction(() => _put('budget_lines', id, changes));
  }

  /// Soft-deletes a line; its accepted quotes go back to Received, committed
  /// on nothing (`delete_line`).
  Future<void> deleteLine(String id) async {
    final current = await budgetLine(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableProject(current.projectId);
    await db.transaction(() async {
      for (final q in await _quotes(projectId: current.projectId)) {
        if (q.budgetLineId != id) continue;
        await _put('quotes', q.id, {
          if (q.status == budget.accepted) 'status': 'received',
          'budget_line_id': null,
        });
      }
      await _put('budget_lines', id, {'deleted_at': _now()});
    });
  }

  // ---------- quotes ----------

  Future<QuoteRow?> quote(String id) =>
      (db.select(db.quotes)
            ..where((q) => q.id.equalsValue(id) & q.deletedAt.isNull()))
          .getSingleOrNull();

  /// The quotes of a project with their contractor, line and number of files.
  Future<List<QuoteEntry>> quotesOf(String projectId) async {
    final lines = {
      for (final l in await _lines(projectId: projectId)) l.id: l.label,
    };
    final files = await filesOf(projectId);
    final entries = <QuoteEntry>[];
    for (final q in await _quotes(projectId: projectId)) {
      final contractor = q.contractorId == null
          ? null
          : await this.contractor(q.contractorId!);
      entries.add(
        QuoteEntry(
          q,
          contractor: contractor?.name,
          line: q.budgetLineId == null ? null : lines[q.budgetLineId],
          files: files.where((f) => f.quoteId == q.id).length,
        ),
      );
    }
    return entries;
  }

  Future<Map<String, Object?>> _quoteFields(
    ProjectRow owner,
    QuoteInput input,
  ) async {
    Repository._oneOf(input.status, budget.quoteStatuses);
    _checkDate(input.issuedOn);
    _checkDate(input.validUntil);
    if (input.issuedOn != null &&
        input.validUntil != null &&
        input.validUntil! < input.issuedOn!) {
      throw const Refused(Refusal.validityBeforeDate);
    }
    if (input.contractorId != null &&
        (await contractor(input.contractorId!))?.homeId != owner.homeId) {
      throw const Refused(Refusal.notInHome);
    }
    // Only an accepted quote is committed on a line, and it needs one of its
    // project (`Quote.clean`, the `quote_accepted_has_line` constraint).
    String? line;
    if (input.status == budget.accepted) {
      if (input.budgetLineId == null) {
        throw const Refused(Refusal.quoteNeedsLine);
      }
      final found = await budgetLine(input.budgetLineId!);
      if (found == null || found.projectId != owner.id) {
        throw const Refused(Refusal.notInProject);
      }
      line = found.id;
    }
    if (input.note.length > 200) throw const Refused(Refusal.tooLong);
    return {
      'contractor_id': input.contractorId,
      'amount': input.amount.trim().isEmpty
          ? budget.storedMoney(budget.zero)
          : _money(input.amount),
      'issued_on': input.issuedOn,
      'valid_until': input.validUntil,
      'status': input.status,
      'budget_line_id': line,
      'note': input.note.trim(),
    };
  }

  Future<String> createQuote(String projectId, QuoteInput input) async {
    final owner = await _writableProject(projectId);
    final fields = await _quoteFields(owner, input);
    final id = newId();
    await db.transaction(
      () => _put(
        'quotes',
        id,
        {...fields, 'project_id': projectId, 'deleted_at': null},
        homeId: owner.homeId,
        create: true,
      ),
    );
    return id;
  }

  /// Changes a quote: leaving Accepted releases the line, entering it needs
  /// one (`update_quote`, `accept_quote`).
  Future<void> updateQuote(String id, QuoteInput input) async {
    final current = await quote(id);
    if (current == null) throw const Refused(Refusal.notFound);
    final owner = await _writableProject(current.projectId);
    final changes = _changes(current, await _quoteFields(owner, input));
    if (changes.isEmpty) return;
    await db.transaction(() => _put('quotes', id, changes));
  }

  /// Soft-deletes a quote with its files (`delete_quote`).
  Future<void> deleteQuote(String id) async {
    final current = await quote(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableProject(current.projectId);
    final now = _now();
    await db.transaction(() async {
      for (final f in await filesOf(current.projectId)) {
        if (f.quoteId == id) {
          await _put('project_files', f.id, {'deleted_at': now});
        }
      }
      await _put('quotes', id, {'deleted_at': now});
    });
  }

  // ---------- files and links ----------

  /// The photos of a project and the files of its quotes.
  Future<List<ProjectFileRow>> filesOf(String projectId) =>
      (db.select(db.projectFiles)
            ..where(
              (f) => f.projectId.equalsValue(projectId) & f.deletedAt.isNull(),
            )
            ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
          .get();

  /// The file of a project's photo or a quote's document, named by its id.
  File projectFile(ProjectFileRow row) =>
      File('${homeDirectory(row.homeId).path}/${row.id}');

  /// Stores a photo of a project ([quoteId] null) or a file of a quote (a PDF
  /// or a photo), then the row (`add_file`). A PDF is kept as picked; every
  /// image is re-encoded by [processPhoto] first (upright, no metadata, the
  /// location included, at most 2560 px), as the web does on upload. The name
  /// shown is cleaned of any path; it is never used on disk. A failure leaves
  /// no file.
  Future<String> addProjectFile(
    String projectId, {
    required String name,
    required Uint8List bytes,
    required String contentType,
    String? quoteId,
  }) async {
    final owner = await _writableProject(projectId);
    final existing = await filesOf(projectId);
    if (quoteId != null) {
      final q = await quote(quoteId);
      if (q == null || q.projectId != projectId) {
        throw const Refused(Refusal.notInProject);
      }
      if (existing.where((f) => f.quoteId == quoteId).length >=
          maxFilesPerQuote) {
        throw const Refused(Refusal.tooManyFiles);
      }
    } else if (existing.where((f) => f.quoteId == null).length >=
        maxPhotosPerProject) {
      throw const Refused(Refusal.tooManyPhotos);
    }
    if (bytes.isEmpty || bytes.length > maxFileBytes) {
      throw const Refused(Refusal.photoTooLarge);
    }
    final isImage = contentType.startsWith('image/');
    if (!isImage && contentType != 'application/pdf') {
      throw const Refused(Refusal.fileTypeRefused);
    }
    var stored = bytes;
    var storedType = contentType;
    if (isImage) {
      try {
        stored = processPhoto(bytes).image;
      } on PhotoRefused catch (refused) {
        throw Refused(
          refused.problem == PhotoProblem.unreadable
              ? Refusal.photoUnreadable
              : Refusal.photoTooLarge,
        );
      }
      storedType = 'image/jpeg';
    }
    final shown = _fileName(name);
    final id = newId();
    final directory = homeDirectory(owner.homeId)..createSync(recursive: true);
    final file = File('${directory.path}/$id');
    try {
      file.writeAsBytesSync(stored, flush: true);
      await db.transaction(
        () => _put(
          'project_files',
          id,
          {
            'project_id': projectId,
            'quote_id': quoteId,
            'name': shown,
            'file': FileReference.fresh(stored, type: storedType).encode(),
            'content_type': storedType,
            'is_image': isImage,
            'size_bytes': stored.length,
            'deleted_at': null,
          },
          homeId: owner.homeId,
          create: true,
        ),
      );
    } catch (_) {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    }
    return id;
  }

  /// A name to show: the last part of a path, without control characters,
  /// at most 120 characters (`ProjectFile.name`).
  static String _fileName(String name) {
    final last = name.split(RegExp(r'[/\\]')).last;
    final clean = last.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '').trim();
    final shown = clean.isEmpty ? 'file' : clean;
    return shown.length > 120 ? shown.substring(0, 120) : shown;
  }

  Future<void> deleteProjectFile(String id) async {
    final current =
        await (db.select(db.projectFiles)
              ..where((f) => f.id.equalsValue(id) & f.deletedAt.isNull()))
            .getSingleOrNull();
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableProject(current.projectId);
    await db.transaction(
      () => _put('project_files', id, {'deleted_at': _now()}),
    );
  }

  /// The links of inspiration of a project, oldest first.
  Future<List<ProjectLinkRow>> linksOf(String projectId) =>
      (db.select(db.projectLinks)
            ..where(
              (l) => l.projectId.equalsValue(projectId) & l.deletedAt.isNull(),
            )
            ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
          .get();

  /// Adds a link of inspiration: an `http(s)` address and an optional
  /// title. The page is never read (no network in the app).
  Future<String> addLink(
    String projectId, {
    required String url,
    String title = '',
  }) async {
    final owner = await _writableProject(projectId);
    final address = Repository._webUrl(url);
    if ((await linksOf(projectId)).length >= maxLinksPerProject) {
      throw const Refused(Refusal.tooManyLinks);
    }
    final id = newId();
    await db.transaction(
      () => _put(
        'project_links',
        id,
        {
          'project_id': projectId,
          'url': address,
          'title': Repository._text(title, 200),
          'deleted_at': null,
        },
        homeId: owner.homeId,
        create: true,
      ),
    );
    return id;
  }

  Future<void> deleteLink(String id) async {
    final current =
        await (db.select(db.projectLinks)
              ..where((l) => l.id.equalsValue(id) & l.deletedAt.isNull()))
            .getSingleOrNull();
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableProject(current.projectId);
    await db.transaction(
      () => _put('project_links', id, {'deleted_at': _now()}),
    );
  }

  // ---------- tasks of a project ----------

  Future<List<ProjectTaskRow>> _projectTaskRows(String projectId) =>
      (db.select(db.projectTasks)..where(
            (l) => l.projectId.equalsValue(projectId) & l.deletedAt.isNull(),
          ))
          .get();

  /// The tasks of a project, oldest first, each with its open occurrence.
  Future<List<TaskEntry>> tasksOfProject(String projectId) async {
    final links = await _projectTaskRows(projectId);
    final entries = <TaskEntry>[];
    for (final link in links) {
      final found = await task(link.taskId);
      if (found == null) continue;
      final open = await openOccurrencesOf(found.id);
      entries.add(TaskEntry(found, open.isEmpty ? null : open.first));
    }
    entries.sort((a, b) => a.task.createdAt.compareTo(b.task.createdAt));
    return entries;
  }

  /// The project a task is in, if any.
  Future<ProjectRow?> projectOfTask(String taskId) async {
    final found = await task(taskId);
    if (found == null) return null;
    final link =
        await (db.select(db.projectTasks)..where(
              (l) =>
                  l.id.equalsValue(projectTaskId(found.homeId, taskId)) &
                  l.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return link == null ? null : project(link.projectId);
  }

  /// Tasks of the home in no project yet, by title (`attachable_tasks`).
  Future<List<TaskRow>> attachableTasks(String homeId) async {
    final taken = {
      for (final l
          in await (db.select(db.projectTasks)..where(
                (l) => l.homeId.equalsValue(homeId) & l.deletedAt.isNull(),
              ))
              .get())
        l.taskId,
    };
    final rows =
        await (db.select(db.tasks)
              ..where(
                (t) => t.homeId.equalsValue(homeId) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.title)]))
            .get();
    return [
      for (final t in rows)
        if (!taken.contains(t.id)) t,
    ];
  }

  /// Creates a task of the project (`add_task`).
  Future<String> addProjectTask(String projectId, TaskInput input) async {
    final owner = await _writableProject(projectId);
    return db.transaction(() async {
      final id = await createTask(owner.homeId, input);
      await _link(owner, id);
      return id;
    });
  }

  /// Puts an existing task in the project; a task is in one project at most
  /// (`attach_task`).
  Future<void> attachTask(String projectId, String taskId) async {
    final owner = await _writableProject(projectId);
    final found = await task(taskId);
    if (found == null || found.homeId != owner.homeId) {
      throw const Refused(Refusal.notInHome);
    }
    await db.transaction(() => _link(owner, taskId));
  }

  Future<void> _link(ProjectRow owner, String taskId) async {
    final id = projectTaskId(owner.homeId, taskId);
    final existing = await (db.select(
      db.projectTasks,
    )..where((l) => l.id.equalsValue(id))).getSingleOrNull();
    if (existing != null && existing.deletedAt == null) {
      throw const Refused(Refusal.taskInProject);
    }
    if (existing != null) {
      await _put('project_tasks', id, {
        'project_id': owner.id,
        'deleted_at': null,
      });
    } else {
      await _put(
        'project_tasks',
        id,
        {'project_id': owner.id, 'task_id': taskId, 'deleted_at': null},
        homeId: owner.homeId,
        create: true,
      );
    }
  }

  /// Takes the task out of the project; the task stays (`detach_task`).
  Future<void> detachTask(String projectId, String taskId) async {
    final owner = await _writableProject(projectId);
    final id = projectTaskId(owner.homeId, taskId);
    await db.transaction(
      () => _put('project_tasks', id, {'deleted_at': _now()}),
    );
  }

  // ---------- the budgets of a task, the real cost of an occurrence ----------

  /// Sets what one time of a task is planned to cost; empty text for none
  /// (`tasks/models.py` `material_budget`, `labour_budget`).
  Future<void> setTaskBudgets(
    String taskId, {
    required String material,
    required String labour,
  }) async {
    final current = await task(taskId);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableHome(current.homeId);
    final changes = _changes(current, {
      'material_budget': _optionalMoney(material),
      'labour_budget': _optionalMoney(labour),
    });
    if (changes.isEmpty) return;
    await db.transaction(() => _put('tasks', taskId, changes));
  }

  /// Sets what a done occurrence really cost; empty text for not known.
  /// Only a done occurrence has a real cost.
  Future<void> setActualCost(String occurrenceId, String cost) async {
    final current = await occurrence(occurrenceId);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableHome(current.homeId);
    if (current.status != 'done') throw const Refused(Refusal.notClosed);
    final value = _optionalMoney(cost);
    if (value == current.actualCost) return;
    await db.transaction(
      () => _put('occurrences', occurrenceId, {'actual_cost': value}),
    );
  }

  // ---------- the paint left of a room ----------

  /// The stock article of the paint left over of a room, or none
  /// (`rooms/models.py` `paint_article`): an article of the room's home.
  Future<void> setPaintArticle(String roomId, String? articleId) async {
    final current = await room(roomId);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableHome(current.homeId);
    if (articleId != null &&
        (await article(articleId))?.homeId != current.homeId) {
      throw const Refused(Refusal.notInHome);
    }
    if (current.paintArticleId == articleId) return;
    await db.transaction(
      () => _put('rooms', roomId, {'paint_article_id': articleId}),
    );
  }

  // ---------- annual envelopes ----------

  Future<Map<int, Decimal>> envelopesOf(String homeId) async => {
    for (final e in await (db.select(
      db.annualEnvelopes,
    )..where((e) => e.homeId.equalsValue(homeId) & e.deletedAt.isNull())).get())
      e.year: budget.readMoney(e.amount),
  };

  /// Sets the envelope of [year] (`set_envelope`); empty text removes it.
  Future<void> setEnvelope(String homeId, int year, String amount) async {
    await _writableHome(homeId);
    if (year < envelopeYears.$1 || year > envelopeYears.$2) {
      throw const Refused(Refusal.dateOutOfRange);
    }
    final value = _optionalMoney(amount);
    final id = envelopeId(homeId, year);
    final existing = await (db.select(
      db.annualEnvelopes,
    )..where((e) => e.id.equalsValue(id))).getSingleOrNull();
    await db.transaction(() async {
      if (existing == null) {
        if (value == null) return;
        await _put(
          'annual_envelopes',
          id,
          {'year': year, 'amount': value, 'deleted_at': null},
          homeId: homeId,
          create: true,
        );
      } else if (value == null) {
        if (existing.deletedAt == null) {
          await _put('annual_envelopes', id, {'deleted_at': _now()});
        }
      } else {
        await _put('annual_envelopes', id, {
          if (existing.amount != value) 'amount': value,
          if (existing.deletedAt != null) 'deleted_at': null,
        });
      }
    });
  }

  // ---------- the ledger of the budget ----------

  /// Everything the figures of [homeId] need (`budget/services.py` `load`),
  /// as of [today] (default: today on the phone).
  Future<budget.Ledger> ledger(String homeId, {Day? today}) async {
    final home = await this.home(homeId);
    if (home == null) throw const Refused(Refusal.notFound);
    final rooms = await this.rooms(homeId);
    final roomIds = {for (final r in rooms) r.id};
    final projectRows =
        await (db.select(db.projects)
              ..where(
                (p) => p.homeId.equalsValue(homeId) & p.deletedAt.isNull(),
              )
              ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
            .get();
    final roomLinks = await (db.select(
      db.projectRooms,
    )..where((l) => l.homeId.equalsValue(homeId) & l.deletedAt.isNull())).get();
    final alive = {for (final p in projectRows) p.id};
    final quotes = await _quotes(homeId: homeId);
    final taskRows =
        await (db.select(db.tasks)
              ..where(
                (t) => t.homeId.equalsValue(homeId) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final taskIds = {for (final t in taskRows) t.id};
    final links = await (db.select(
      db.projectTasks,
    )..where((l) => l.homeId.equalsValue(homeId) & l.deletedAt.isNull())).get();
    final occurrences =
        await (db.select(db.occurrences)..where(
              (o) =>
                  o.homeId.equalsValue(homeId) &
                  o.deletedAt.isNull() &
                  o.status.isIn(budget.budgetStatuses),
            ))
            .get();
    final byTask = <String, List<budget.OccurrenceFacts>>{};
    for (final o in occurrences) {
      (byTask[o.taskId] ??= []).add(
        budget.OccurrenceFacts(
          o.status,
          o.dueOn == null ? null : Day.parse(o.dueOn!),
          o.completedOn == null ? null : Day.parse(o.completedOn!),
          o.actualCost == null ? null : budget.readMoney(o.actualCost!),
        ),
      );
    }
    final articles = {
      for (final a
          in await (db.select(db.articles)..where(
                (a) => a.homeId.equalsValue(homeId) & a.deletedAt.isNull(),
              ))
              .get())
        a.id: a,
    };
    final stockOf = <String, List<(Decimal, Decimal?)>>{};
    for (final m
        in await (db.select(db.taskMaterials)..where(
              (m) => m.homeId.equalsValue(homeId) & m.deletedAt.isNull(),
            ))
            .get()) {
      final article = articles[m.articleId];
      if (article == null) continue;
      (stockOf[m.taskId] ??= []).add((
        stock.readQuantity(m.quantity),
        article.unitPrice == null
            ? null
            : stock.readQuantity(article.unitPrice!),
      ));
    }
    return budget.Ledger.of(
      currency: home.currency,
      today: today ?? this.today(),
      projects: [
        for (final p in projectRows)
          budget.ProjectFacts(
            id: p.id,
            title: p.title,
            status: p.status,
            createdYear: DateTime.fromMillisecondsSinceEpoch(p.createdAt).year,
            roomIds: [
              for (final l in roomLinks)
                if (l.projectId == p.id && roomIds.contains(l.roomId)) l.roomId,
            ],
          ),
      ],
      lines: [
        for (final l in await _lines(homeId: homeId))
          if (alive.contains(l.projectId))
            budget.LineFacts(
              id: l.id,
              projectId: l.projectId,
              nature: l.nature,
              planned: budget.readMoney(l.planned),
              paid: budget.readMoney(l.paid),
            ),
      ],
      acceptedQuotes: [
        for (final q in quotes)
          if (q.status == budget.accepted &&
              q.budgetLineId != null &&
              alive.contains(q.projectId))
            budget.QuoteFacts(
              lineId: q.budgetLineId!,
              projectId: q.projectId,
              amount: budget.readMoney(q.amount),
              issuedOn: q.issuedOn == null ? null : Day.parse(q.issuedOn!),
            ),
      ],
      projectOfTask: {
        for (final l in links)
          if (alive.contains(l.projectId) && taskIds.contains(l.taskId))
            l.taskId: l.projectId,
      },
      tasks: [
        for (final t in taskRows)
          budget.TaskFacts(
            id: t.id,
            title: t.title,
            roomId: t.roomId,
            materialBudget: t.materialBudget == null
                ? null
                : budget.readMoney(t.materialBudget!),
            labourBudget: t.labourBudget == null
                ? null
                : budget.readMoney(t.labourBudget!),
            rule: Repository._ruleOf(t),
            seriesStart: t.seriesStart == null
                ? null
                : Day.parse(t.seriesStart!),
            occurrences: byTask[t.id] ?? const [],
            stock: stockOf[t.id] ?? const [],
          ),
      ],
      envelopes: await envelopesOf(homeId),
      rooms: [for (final r in rooms) budget.RoomFacts(r.id, r.name)],
    );
  }

  // ---------- reports ----------

  Future<ReportRow?> report(String id) =>
      (db.select(db.reports)
            ..where((r) => r.id.equalsValue(id) & r.deletedAt.isNull()))
          .getSingleOrNull();

  /// The reports of a home, the latest first; [status] keeps one status,
  /// `closed` the two closed ones.
  Future<List<ReportEntry>> reportsOf(
    String homeId, {
    String status = '',
  }) async {
    final rows =
        await (db.select(db.reports)
              ..where(
                (r) => r.homeId.equalsValue(homeId) & r.deletedAt.isNull(),
              )
              ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
            .get();
    final kept = [
      for (final r in rows)
        if (status.isEmpty ||
            r.status == status ||
            (status == 'closed' && reportClosedStatuses.contains(r.status)))
          r,
    ];
    return [
      for (final r in kept)
        ReportEntry(r, task: r.taskId == null ? null : await task(r.taskId!)),
    ];
  }

  /// The reports that wait for the person in [homeId]: the line of Today and
  /// the count of Reports in More (`waiting_for` of `reports/services.py`).
  /// The open reports of the home for whoever writes there, and none for a
  /// read-only member of a server home, as on the web: the server sends a
  /// reader their own reports only (web ADR 0086), and the web shows a
  /// reader no count, not even of those.
  Future<int> reportsWaiting(String homeId) async {
    if (await serverRole(homeId) == 'read_only') return 0;
    return openReportCount([homeId]);
  }

  /// The open reports of [homeIds] (`open_count`).
  Future<int> openReportCount(Iterable<String> homeIds) async {
    final ids = homeIds.toList();
    if (ids.isEmpty) return 0;
    final count = db.reports.id.count();
    final query = db.selectOnly(db.reports)
      ..addColumns([count])
      ..where(
        db.reports.homeId.isInValues(ids) &
            db.reports.deletedAt.isNull() &
            db.reports.status.equals(reportOpen),
      );
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// The reports a task was made from, the latest first
  /// (`reports_of_task` of `reports/services.py`): the ones not deleted, of
  /// the home of the task, whatever their status. Same rule as the web: a
  /// read-only member sees only the reports they made (`visible_reports`),
  /// and the server sends a reader only those, so the phone holds nothing
  /// else and shows all it holds (the app does not hold the author). A task
  /// made from a report the reader may not see keeps its title and place and
  /// has no report of origin on the phone: this finds none, without an error.
  Future<List<ReportRow>> reportsOfTask(String taskId) async {
    final owner = await task(taskId);
    if (owner == null) return [];
    return (db.select(db.reports)
          ..where(
            (r) =>
                r.taskId.equalsValue(taskId) &
                r.homeId.equalsValue(owner.homeId) &
                r.deletedAt.isNull(),
          )
          ..orderBy([
            (r) => OrderingTerm.desc(r.createdAt),
            (r) => OrderingTerm.desc(r.id),
          ]))
        .get();
  }

  /// The tasks among [taskIds] that a report with a photo was made from
  /// (`mark_photo_reports` of `reports/services.py`), in one query for a
  /// whole page of a list: the same reports as [reportsOfTask] (not deleted,
  /// whatever their status).
  Future<Set<String>> tasksWithReportPhoto(Iterable<String> taskIds) async {
    final ids = taskIds.toSet().toList();
    if (ids.isEmpty) return {};
    final rows =
        await (db.select(db.reports)..where(
              (r) =>
                  r.taskId.isInValues(ids) &
                  r.deletedAt.isNull() &
                  r.photo.isNotNull() &
                  r.photo.equals('').not(),
            ))
            .get();
    // A report counts for the task of its own home only (the web reads the
    // reports of the home).
    final homes = {
      for (final t in await (db.select(
        db.tasks,
      )..where((t) => t.id.isInValues(ids))).get())
        t.id: t.homeId,
    };
    return {
      for (final r in rows)
        if (homes[r.taskId] == r.homeId) r.taskId!,
    };
  }

  /// The photo of a report, named by its id.
  File reportPhoto(ReportRow row) =>
      File('${homeDirectory(row.homeId).path}/${row.id}.jpg');

  /// Reports a problem: what is wrong, at most one place, a photo if there
  /// is one, already re-encoded (`create_report`). [place] is the text of the
  /// place as the phone writes it now ("Kitchen · Boiler").
  Future<String> createReport(
    String homeId, {
    required String title,
    String? roomId,
    String? itemId,
    String? articleId,
    String place = '',
    ProcessedPhoto? photo,
  }) async {
    await _writableHome(homeId);
    final clean = Repository._name(title, 200);
    if ([roomId, itemId, articleId].whereType<String>().length > 1) {
      throw const Refused(Refusal.onePlace);
    }
    final String? owner = roomId != null
        ? (await room(roomId))?.homeId
        : itemId != null
        ? (await item(itemId))?.homeId
        : articleId != null
        ? (await article(articleId))?.homeId
        : homeId;
    if (owner != homeId) throw const Refused(Refusal.notInHome);
    final id = newId();
    File? file;
    if (photo != null) {
      final directory = homeDirectory(homeId)..createSync(recursive: true);
      file = File('${directory.path}/$id.jpg')
        ..writeAsBytesSync(photo.image, flush: true);
    }
    try {
      await db.transaction(
        () => _put(
          'reports',
          id,
          {
            'title': clean,
            'status': reportOpen,
            'room_id': roomId,
            'item_id': itemId,
            'article_id': articleId,
            'place': Repository._text(place, 250),
            'task_id': null,
            'closed_at': null,
            // The reference of a server (an id of its own and the digest),
            // so that the photo goes to the server with the report (lot 4d).
            'photo': photo?.fileReference().encode(),
            'deleted_at': null,
          },
          homeId: homeId,
          create: true,
        ),
      );
    } catch (_) {
      if (file != null && file.existsSync()) file.deleteSync();
      rethrow;
    }
    return id;
  }

  Future<ReportRow> _writableReport(String id) async {
    final found = await report(id);
    if (found == null) throw const Refused(Refusal.notFound);
    await _writableHome(found.homeId);
    return found;
  }

  /// Makes an open report into a task with no date, keeping the link
  /// (`make_task`). The task is in the report's room or about its item.
  Future<String> makeTask(String reportId) async {
    final current = await _writableReport(reportId);
    if (current.status != reportOpen) {
      throw const Refused(Refusal.reportNotOpen);
    }
    String? roomId = current.roomId, itemId = current.itemId;
    if (roomId != null && await room(roomId) == null) roomId = null;
    if (itemId != null && await item(itemId) == null) itemId = null;
    return db.transaction(() async {
      final taskId = await createTask(
        current.homeId,
        TaskInput(title: current.title, roomId: roomId, itemId: itemId),
      );
      await _put('reports', reportId, {
        'status': reportTask,
        'task_id': taskId,
      });
      return taskId;
    });
  }

  /// Closes a report as resolved or as needing no action (`close_report`).
  Future<void> closeReport(String reportId, String resolution) async {
    final current = await _writableReport(reportId);
    if (!reportClosedStatuses.contains(resolution)) {
      throw const Refused(Refusal.choiceInvalid);
    }
    if (reportClosedStatuses.contains(current.status)) {
      throw const Refused(Refusal.alreadyClosed);
    }
    await db.transaction(
      () => _put('reports', reportId, {
        'status': resolution,
        'closed_at': _now(),
      }),
    );
  }

  /// Reopens a closed report; it goes back to its task if it still has one
  /// (`reopen_report`).
  Future<void> reopenReport(String reportId) async {
    final current = await _writableReport(reportId);
    if (!reportClosedStatuses.contains(current.status)) {
      throw const Refused(Refusal.reportNotClosed);
    }
    final back = current.taskId != null && await task(current.taskId!) != null
        ? reportTask
        : reportOpen;
    await db.transaction(
      () => _put('reports', reportId, {'status': back, 'closed_at': null}),
    );
  }
}
