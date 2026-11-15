// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';

import 'day.dart';
import 'recurrence.dart' as recurrence;

/// The budget of a home, by year, room, project and maintenance task: the
/// rules of the web (`budget/services.py`, `projects/services.py` `Amounts`,
/// web ADR 0050, 0051, 0062, 0073), ported line by line. Nothing here is
/// stored: every figure is worked out when read, in [Decimal], from the budget
/// lines and accepted quotes of projects and from the estimates and real costs
/// of tasks. No figure ever passes through floating point
/// (`test/no_double_test.dart`), and the figures of two homes are never added:
/// a [Ledger] is one home, in its currency.
///
/// `test/budget_web_test.dart` loads the fixture `test/fixtures/budget_fixture.json`
/// and compares every figure with what the web computes from the same rows
/// (`test/fixtures/budget_web_figures.json`, written by `tool/budget_figures.py`
/// at the web release pinned in `tool/web_alignment.json`).

final Decimal zero = Decimal.zero;
final Decimal _hundred = Decimal.fromInt(100);

/// Project statuses (`projects/models.py` `ProjectStatus`), and the order the
/// list shows them in: what is going on, what is coming, what is over.
const projectStatuses = ['in_progress', 'planned', 'idea', 'done', 'abandoned'];
const abandoned = 'abandoned';

/// What a budget line pays for (`BudgetNature`).
const material = 'material';
const labour = 'labour';
const rental = 'rental';
const other = 'other';
const natures = [material, labour, rental, other];

/// Quote statuses (`QuoteStatus`).
const quoteStatuses = ['requested', 'received', 'accepted', 'rejected'];
const accepted = 'accepted';

/// Occurrence statuses the budget reads (`_OPEN` and done); the others are
/// left out by the loader.
const budgetStatuses = ['planned', 'postponed', 'done'];
const _done = 'done';

/// A year is 12 months, 52 weeks or 365 days (web ADR 0051).
const perYear = {
  recurrence.monthUnit: 12,
  recurrence.weekUnit: 52,
  recurrence.dayUnit: 365,
  recurrence.yearUnit: 1,
};

/// An amount of money of the model: `max_digits=12, decimal_places=2`
/// (`projects/models.py` `money_field`), so at most two decimals, zero or
/// more, below 10^10. `null` when [text] is not one; a comma is read as the
/// decimal point, as the French keyboard types it (`projects/services.py`
/// `_money`).
Decimal? parseMoney(String text) {
  final clean = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(clean)) return null;
  return Decimal.parse(clean);
}

/// The text an amount is stored as: two decimals (docs/protocol.md, 2.2).
String storedMoney(Decimal value) => value.toStringAsFixed(2);

/// The stored text read back.
Decimal readMoney(String text) => Decimal.parse(text);

/// [value] / [by], rounded once, half up (away from zero), to the cent: the
/// division is exact (a rational), so no digit is lost before the rounding.
Decimal cents(Decimal value, [int by = 1]) {
  final exact = (value * _hundred) / Decimal.fromInt(by);
  return Decimal.fromBigInt(exact.round()).shift(-2);
}

/// [value] / [by] (positive) rounded to a whole number, half to even:
/// Python's `Decimal.quantize(Decimal(1))` in the default context.
BigInt _halfEven(Decimal value, Decimal by) {
  final floor = value ~/ by; // both positive: truncation is the floor
  final twice = (value - Decimal.fromBigInt(floor) * by) * Decimal.fromInt(2);
  if (twice > by) return floor + BigInt.one;
  if (twice < by) return floor;
  return floor.isEven ? floor : floor + BigInt.one;
}

Decimal _max(Decimal a, Decimal b) => a >= b ? a : b;

/// The three amounts of a line or a project, and what they say together
/// (`projects/services.py` `Amounts`). A line is spent ([engaged]) for the
/// more of what is committed and what is paid; the gap is the planned amount
/// less that. Sums add [engaged] and [toPay] line by line, never from the
/// totals: an overrun on one line is not hidden by the room left on another.
class Amounts {
  Amounts(this.planned, this.committed, this.paid, this.engaged, this.toPay);

  /// One line: [engaged] and [toPay] worked out from its three amounts.
  factory Amounts.line([Decimal? planned, Decimal? committed, Decimal? paid]) {
    final p = planned ?? zero, c = committed ?? zero, d = paid ?? zero;
    return Amounts(p, c, d, _max(c, d), _max(c - d, zero));
  }

  static final none = Amounts.line();

  final Decimal planned;
  final Decimal committed;
  final Decimal paid;
  final Decimal engaged;
  final Decimal toPay;

  Amounts operator +(Amounts other) => Amounts(
    planned + other.planned,
    committed + other.committed,
    paid + other.paid,
    engaged + other.engaged,
    toPay + other.toPay,
  );

  /// Negative: over budget.
  Decimal get gap => planned - engaged;

  /// `over`, `under` or `on`: said in words on the screens, never by colour.
  String get state => gap < zero
      ? 'over'
      : gap > zero
      ? 'under'
      : 'on';

  Decimal get overBy => -gap;

  Map<String, String> toJson() => {
    'planned': planned.toStringAsFixed(2),
    'committed': committed.toStringAsFixed(2),
    'paid': paid.toStringAsFixed(2),
    'engaged': engaged.toStringAsFixed(2),
    'to_pay': toPay.toStringAsFixed(2),
    'gap': gap.toStringAsFixed(2),
  };
}

Amounts sumOf(Iterable<Amounts> items) =>
    items.fold(Amounts.none, (total, item) => total + item);

/// Cents shared out evenly; the odd cents go to the first parts, so that the
/// sum is exact (`_split`).
List<Decimal> _split(Decimal amount, int parts) {
  final total = (amount * _hundred).toBigInt(); // truncated, as `int()`
  final p = BigInt.from(parts);
  // Python's divmod: floor division, remainder of the divisor's sign.
  var base = total ~/ p;
  var odd = total.remainder(p);
  if (odd < BigInt.zero) {
    odd += p;
    base -= BigInt.one;
  }
  return [
    for (var i = 0; i < parts; i++)
      Decimal.fromBigInt(
        base + (BigInt.from(i) < odd ? BigInt.one : BigInt.zero),
      ).shift(-2),
  ];
}

/// [amounts] shared between [parts] rooms, column by column (`share`).
List<Amounts> share(Amounts amounts, int parts) {
  final columns = [
    _split(amounts.planned, parts),
    _split(amounts.committed, parts),
    _split(amounts.paid, parts),
    _split(amounts.engaged, parts),
    _split(amounts.toPay, parts),
  ];
  return [
    for (var i = 0; i < parts; i++)
      Amounts(
        columns[0][i],
        columns[1][i],
        columns[2][i],
        columns[3][i],
        columns[4][i],
      ),
  ];
}

// ---------- what is loaded ----------

/// A project as the ledger reads it.
class ProjectFacts {
  const ProjectFacts({
    required this.id,
    required this.title,
    required this.status,
    required this.createdYear,
    this.roomIds = const [],
  });

  final String id;
  final String title;
  final String status;

  /// The year of its creation, in the time zone of the phone.
  final int createdYear;
  final List<String> roomIds;
}

class LineFacts {
  const LineFacts({
    required this.id,
    required this.projectId,
    required this.nature,
    required this.planned,
    required this.paid,
  });

  final String id;
  final String projectId;
  final String nature;
  final Decimal planned;
  final Decimal paid;
}

/// An accepted quote: its line, its project, its amount, its date.
class QuoteFacts {
  const QuoteFacts({
    required this.lineId,
    required this.projectId,
    required this.amount,
    this.issuedOn,
  });

  final String lineId;
  final String projectId;
  final Decimal amount;
  final Day? issuedOn;
}

/// An occurrence as the budget reads it: done, or open (planned, postponed).
class OccurrenceFacts {
  const OccurrenceFacts(this.status, this.due, [this.completed, this.cost]);

  final String status;
  final Day? due;
  final Day? completed;
  final Decimal? cost;
}

class TaskFacts {
  const TaskFacts({
    required this.id,
    required this.title,
    this.roomId,
    this.materialBudget,
    this.labourBudget,
    this.rule = const recurrence.Rule(),
    this.seriesStart,
    this.occurrences = const [],
    this.stock = const [],
  });

  final String id;
  final String title;
  final String? roomId;
  final Decimal? materialBudget;
  final Decimal? labourBudget;
  final recurrence.Rule rule;
  final Day? seriesStart;
  final List<OccurrenceFacts> occurrences;

  /// The stock articles of the task: (quantity, unit price or none).
  final List<(Decimal, Decimal?)> stock;
}

class RoomFacts {
  const RoomFacts(this.id, this.name);

  final String id;
  final String name;
}

/// What the stock articles of a task are planned to cost (web ADR 0062):
/// quantity times unit price, added and rounded once; an article without a
/// price counts for nothing and is counted in [unpriced].
class StockPlan {
  const StockPlan(this.amount, this.priced, this.unpriced);

  final Decimal amount;
  final int priced;
  final int unpriced;
}

StockPlan stockPlan(Iterable<(Decimal, Decimal?)> lines) {
  var total = zero;
  var priced = 0, unpriced = 0;
  for (final (quantity, price) in lines) {
    if (price == null) {
      unpriced++;
    } else {
      priced++;
      total += quantity * price;
    }
  }
  return StockPlan(cents(total), priced, unpriced);
}

/// A project as the budget counts it (`ProjectRow`). An abandoned project
/// plans nothing any more.
class ProjectBudget {
  const ProjectBudget(
    this.project,
    this.amounts,
    this.year,
    this.roomIds,
    this.byNature,
    this.tasksPlanned,
  );

  final ProjectFacts project;
  final Amounts amounts;
  final int year;
  final List<String> roomIds;
  final Map<String, Amounts> byNature;
  final Decimal tasksPlanned;
}

/// The natures a task plans in (`TASK_NATURES`).
const taskNatures = [material, labour];

/// The lines of a project with what its tasks plan beyond them, nature by
/// nature, never counted twice (`project_plan`, web ADR 0073).
Map<String, Amounts> projectPlan(
  Map<String, Amounts> byNature,
  Map<String, Decimal> fromTasks,
) {
  final result = {...byNature};
  for (final nature in taskNatures) {
    final lines = result[nature] ?? Amounts.none;
    final beyond = _max((fromTasks[nature] ?? zero) - lines.planned, zero);
    if (beyond != zero) result[nature] = lines + Amounts.line(beyond);
  }
  return result;
}

/// What a maintenance task plans and costs over a period (`TaskFigures`).
class TaskFigures {
  const TaskFigures(
    this.count,
    this.material,
    this.labour,
    this.paid,
    this.missing,
    this.projected,
  );

  final int count;
  final Decimal material;
  final Decimal labour;
  final Decimal paid;

  /// Done with no cost typed: counted in the plan, paid as zero.
  final int missing;

  /// Of [count]: the times the repetition will still bring.
  final int projected;

  Amounts get amounts => Amounts.line(material + labour, zero, paid);
}

typedef Window = bool Function(Day? day);

/// A task in no project, its estimate per time and its occurrences
/// (`TaskRow`).
class TaskBudget {
  TaskBudget(this.task, this.today, this.stock)
    : done = [
        for (final o in task.occurrences)
          if (o.status == _done) (o.completed ?? o.due, o.cost),
      ],
      open = [
        for (final o in task.occurrences)
          if (o.status != _done) o.due,
      ];

  final TaskFacts task;
  final Day today;
  final StockPlan stock;
  final List<(Day?, Decimal?)> done;
  final List<Day?> open;
  final Map<int, int> _memo = {};

  Decimal get materialTyped => task.materialBudget ?? zero;
  Decimal get labour => task.labourBudget ?? zero;

  bool get hasEstimate =>
      task.materialBudget != null ||
      task.labourBudget != null ||
      stock.priced > 0;

  /// The materials of one time: the amount typed and the stock at its prices.
  Decimal get materialPlanned => materialTyped + stock.amount;

  Decimal get estimate => materialPlanned + labour;

  /// An open occurrence late from a year already over is counted on 1
  /// January of this year.
  Day? countedOn(Day? day) {
    final first = Day(today.year, 1, 1);
    return day != null && day < first ? first : day;
  }

  bool _openIn(Day? day, Window window, int? year) {
    if (year == null) return window(day);
    if (day == null) return year == today.year;
    return window(countedOn(day));
  }

  /// How many times the repetition will still bring the task in [year].
  int projected(int year) => _memo.putIfAbsent(year, () {
    final dates = [for (final day in open.map(countedOn)) ?day];
    if (year < today.year || !task.rule.repeats || dates.isEmpty) return 0;
    return recurrence
        .coming(
          task.rule,
          anchor: task.seriesStart,
          after: dates.reduce((a, b) => a > b ? a : b),
          since: Day(year, 1, 1),
          end: Day(year, 12, 31),
        )
        .length;
  });

  TaskFigures figures(Window window, {bool openToo = true, int? year}) {
    final inDone = [
      for (final entry in done)
        if (window(entry.$1)) entry,
    ];
    final coming = openToo
        ? [
            for (final day in open)
              if (_openIn(day, window, year)) day,
          ]
        : const <Day?>[];
    final more = year != null && openToo ? projected(year) : 0;
    final count = inDone.length + coming.length + more;
    final times = Decimal.fromInt(count);
    return TaskFigures(
      count,
      materialPlanned * times,
      labour * times,
      inDone.fold(zero, (sum, e) => e.$2 == null ? sum : sum + e.$2!),
      inDone.where((e) => e.$2 == null).length,
      more,
    );
  }

  /// Whether the task is on the calendar: it repeats by a known unit.
  bool get onCalendar =>
      task.rule.repeats && perYear.containsKey(task.rule.unit);

  /// The estimate times the times a year, rounded once to the cent; the
  /// multiplication comes before the division (0.24 every 48 years is 0.005
  /// a year, which rounds to 0.01).
  Decimal? get annualCost {
    if (!onCalendar || !hasEstimate) return null;
    return cents(
      estimate * Decimal.fromInt(perYear[task.rule.unit]!),
      task.rule.interval,
    );
  }
}

/// Everything the figures of one home need (`Ledger`).
class Ledger {
  Ledger._(
    this.currency,
    this.today,
    this.projects,
    this.tasks,
    this.envelopes,
    this.rooms,
  );

  /// The ledger of one home from its rows (`load`).
  factory Ledger.of({
    required String currency,
    required Day today,
    required List<ProjectFacts> projects,
    required List<LineFacts> lines,
    required List<QuoteFacts> acceptedQuotes,
    required Map<String, String> projectOfTask,
    required List<TaskFacts> tasks,
    required Map<int, Decimal> envelopes,
    required List<RoomFacts> rooms,
  }) {
    final committed = <String, Decimal>{};
    final quoteDays = <String, List<Day>>{};
    for (final q in acceptedQuotes) {
      committed[q.lineId] = (committed[q.lineId] ?? zero) + q.amount;
      if (q.issuedOn != null) {
        (quoteDays[q.projectId] ??= []).add(q.issuedOn!);
      }
    }
    final taskOf = {for (final t in tasks) t.id: t};
    final taskDays = <String, List<Day>>{};
    final fromTasks = <String, Map<String, Decimal>>{};
    for (final MapEntry(key: taskId, value: projectId)
        in projectOfTask.entries) {
      final task = taskOf[taskId];
      if (task == null) continue;
      for (final o in task.occurrences) {
        final day = o.status == _done ? (o.completed ?? o.due) : o.due;
        if (day != null) (taskDays[projectId] ??= []).add(day);
      }
      final times = Decimal.fromInt(task.occurrences.length);
      final stock = stockPlan(task.stock).amount;
      final wanted = fromTasks[projectId] ??= {};
      for (final (nature, each) in [
        (material, (task.materialBudget ?? zero) + stock),
        (labour, task.labourBudget ?? zero),
      ]) {
        wanted[nature] = (wanted[nature] ?? zero) + each * times;
      }
    }
    final linesOf = <String, List<LineFacts>>{};
    for (final line in lines) {
      (linesOf[line.projectId] ??= []).add(line);
    }
    final roomOrder = {for (final (i, r) in rooms.indexed) r.id: i};
    final budgets = <ProjectBudget>[];
    for (final project in projects) {
      final isAbandoned = project.status == abandoned;
      var byNature = <String, Amounts>{};
      for (final line in linesOf[project.id] ?? const <LineFacts>[]) {
        final amounts = Amounts.line(
          isAbandoned ? zero : line.planned,
          committed[line.id] ?? zero,
          line.paid,
        );
        byNature[line.nature] =
            (byNature[line.nature] ?? Amounts.none) + amounts;
      }
      final plan = isAbandoned
          ? const <String, Decimal>{}
          : fromTasks[project.id] ?? const <String, Decimal>{};
      byNature = projectPlan(byNature, plan);
      final days = [...?quoteDays[project.id], ...?taskDays[project.id]];
      final year = days.isEmpty
          ? project.createdYear
          : days.reduce((a, b) => a < b ? a : b).year;
      final ids = [
        for (final id in project.roomIds)
          if (roomOrder.containsKey(id)) id,
      ]..sort((a, b) => roomOrder[a]!.compareTo(roomOrder[b]!));
      budgets.add(
        ProjectBudget(
          project,
          sumOf(byNature.values),
          year,
          ids,
          byNature,
          plan.values.fold(zero, (a, b) => a + b),
        ),
      );
    }
    final maintenance = [
      for (final task in tasks)
        if (!projectOfTask.containsKey(task.id))
          TaskBudget(task, today, stockPlan(task.stock)),
    ];
    return Ledger._(currency, today, budgets, maintenance, envelopes, rooms);
  }

  final String currency;
  final Day today;
  final List<ProjectBudget> projects;
  final List<TaskBudget> tasks;
  final Map<int, Decimal> envelopes;
  final List<RoomFacts> rooms;

  /// Every year with a figure, the latest first.
  List<int> years() {
    final found = {
      today.year,
      ...envelopes.keys,
      for (final p in projects) p.year,
    };
    for (final row in tasks) {
      for (final (day, _) in row.done) {
        if (day != null) found.add(day.year);
      }
      for (final day in row.open.map(row.countedOn)) {
        if (day != null) found.add(day.year);
      }
    }
    return found.toList()..sort((a, b) => b.compareTo(a));
  }

  List<ProjectBudget> projectsIn(int? year) => [
    for (final p in projects)
      if (year == null || p.year == year) p,
  ];

  /// The upkeep of a year: done, open and still to come by the repetition.
  Amounts maintenance(int year) {
    final window = inYear(year);
    return sumOf(tasks.map((t) => t.figures(window, year: year).amounts));
  }
}

// ---------- windows of time ----------

Window inYear(int year) =>
    (day) => day != null && day.year == year;

/// First day of the 12 months ending [today].
Day rollingStart(Day today) {
  // `today - relativedelta(years=1) + 1 day`: 29 February goes to 28.
  final year = today.year - 1;
  final last = Day.daysInMonth(year, today.month);
  return Day(year, today.month, today.day > last ? last : today.day).addDays(1);
}

Window inRolling(Day today) {
  final start = rollingStart(today);
  return (day) => day != null && day >= start && day <= today;
}

bool anytime(Day? _) => true;

// ---------- reports ----------

/// One row of a report: a room, a project, a task, a nature or a year.
class Line {
  const Line(this.id, this.label, this.amounts, [this.extra = const {}]);

  final String? id;
  final String label;
  final Amounts amounts;
  final Map<String, Object?> extra;
}

class Report {
  const Report(
    this.year,
    this.currency,
    this.lines,
    this.total,
    this.years, [
    this.note = const {},
  ]);

  final int year;
  final String currency;
  final List<Line> lines;
  final Amounts total;
  final List<int> years;
  final Map<String, int> note;
}

/// Projects (shared evenly between their rooms) and upkeep, by room.
Report byRoom(Ledger ledger, int year) {
  final projects = <String?, Amounts>{};
  final upkeep = <String?, Amounts>{};
  for (final row in ledger.projectsIn(year)) {
    if (row.roomIds.isNotEmpty) {
      final parts = share(row.amounts, row.roomIds.length);
      for (final (i, room) in row.roomIds.indexed) {
        projects[room] = (projects[room] ?? Amounts.none) + parts[i];
      }
    } else {
      projects[null] = (projects[null] ?? Amounts.none) + row.amounts;
    }
  }
  final window = inYear(year);
  for (final task in ledger.tasks) {
    final room = ledger.rooms.any((r) => r.id == task.task.roomId)
        ? task.task.roomId
        : null;
    upkeep[room] =
        (upkeep[room] ?? Amounts.none) +
        task.figures(window, year: year).amounts;
  }
  final lines = <Line>[];
  for (final candidate in [...ledger.rooms, null]) {
    final key = candidate?.id;
    if (!projects.containsKey(key) && !upkeep.containsKey(key)) continue;
    final p = projects[key] ?? Amounts.none, u = upkeep[key] ?? Amounts.none;
    lines.add(
      Line(key, candidate?.name ?? '', p + u, {'projects': p, 'upkeep': u}),
    );
  }
  return Report(
    year,
    ledger.currency,
    lines,
    sumOf(lines.map((l) => l.amounts)),
    ledger.years(),
  );
}

/// The figures of one room in [byRoom], line by line (`room_budget`).
({Amounts total, List<Line> projects, List<Line> tasks}) roomBudget(
  Ledger ledger,
  int year,
  String roomId,
) {
  final projects = <Line>[];
  for (final row in ledger.projectsIn(year)) {
    final at = row.roomIds.indexOf(roomId);
    if (at >= 0) {
      final part = share(row.amounts, row.roomIds.length)[at];
      projects.add(Line(row.project.id, row.project.title, part));
    }
  }
  final window = inYear(year);
  final tasks = <Line>[];
  for (final task in ledger.tasks) {
    if (task.task.roomId != roomId) continue;
    final amounts = task.figures(window, year: year).amounts;
    if (amounts.planned != zero ||
        amounts.paid != zero ||
        amounts.committed != zero) {
      tasks.add(Line(task.task.id, task.task.title, amounts));
    }
  }
  return (
    total: sumOf([...projects, ...tasks].map((l) => l.amounts)),
    projects: projects,
    tasks: tasks,
  );
}

Report byProject(Ledger ledger) {
  final lines = [
    for (final row in ledger.projects)
      Line(row.project.id, row.project.title, row.amounts, {
        'year': row.year,
        'status': row.project.status,
        'tasks_planned': row.tasksPlanned,
      }),
  ];
  return Report(
    ledger.today.year,
    ledger.currency,
    lines,
    sumOf(lines.map((l) => l.amounts)),
    ledger.years(),
  );
}

/// Maintenance tasks with an estimate or a cost (`by_task`).
Report byTask(Ledger ledger, int year) {
  final window = inYear(year);
  final lines = <Line>[];
  var unlisted = 0;
  for (final row in ledger.tasks) {
    final total = row.figures(anytime);
    if (!row.hasEstimate && total.paid == zero) {
      unlisted++;
      continue;
    }
    final thisYear = row.figures(window, year: year);
    lines.add(
      Line(row.task.id, row.task.title, thisYear.amounts, {
        'estimate': row.hasEstimate ? row.estimate : null,
        'annual_cost': row.annualCost,
        'stock_estimate': row.stock.amount,
        'unpriced_materials': row.stock.unpriced,
        'total_paid': total.paid,
        'missing_costs': thisYear.missing,
        'projected': thisYear.projected,
      }),
    );
  }
  return Report(
    year,
    ledger.currency,
    lines,
    sumOf(lines.map((l) => l.amounts)),
    ledger.years(),
    {'unlisted': unlisted},
  );
}

/// What was paid on a task, shared between materials and labour as its
/// estimate is (`real_cost_split`).
(Decimal, Decimal) realCostSplit(
  TaskFigures figures,
  Decimal materialEstimate,
  Decimal labourEstimate,
) {
  final estimate = materialEstimate + labourEstimate;
  if (estimate <= zero) return (zero, zero);
  final exact = (figures.paid * materialEstimate * _hundred) / estimate;
  final inMaterials = Decimal.fromBigInt(exact.round()).shift(-2);
  return (inMaterials, figures.paid - inMaterials);
}

/// Materials, labour, rental, other (`by_nature`).
List<Line> byNature(Ledger ledger, int year) {
  final found = {for (final n in natures) n: Amounts.none};
  for (final row in ledger.projectsIn(year)) {
    for (final MapEntry(:key, :value) in row.byNature.entries) {
      found[key] = found[key]! + value;
    }
  }
  final window = inYear(year);
  for (final task in ledger.tasks) {
    final figures = task.figures(window, year: year);
    final (inMaterials, inLabour) = realCostSplit(
      figures,
      task.materialPlanned,
      task.labour,
    );
    found[material] =
        found[material]! + Amounts.line(figures.material, zero, inMaterials);
    found[labour] =
        found[labour]! + Amounts.line(figures.labour, zero, inLabour);
    found[other] =
        found[other]! +
        Amounts.line(zero, zero, figures.paid - inMaterials - inLabour);
  }
  return [for (final n in natures) Line(null, n, found[n]!)];
}

class YearLine {
  const YearLine(this.year, this.envelope, this.projects, this.upkeep);

  final int year;
  final Decimal? envelope;
  final Amounts projects;
  final Amounts upkeep;

  Amounts get total => projects + upkeep;
}

List<YearLine> byYear(Ledger ledger) => [
  for (final year in ledger.years())
    YearLine(
      year,
      ledger.envelopes[year],
      sumOf(ledger.projectsIn(year).map((p) => p.amounts)),
      ledger.maintenance(year),
    ),
];

/// The envelope of a year against what is planned, engaged and paid
/// (`EnvelopeReport`).
class EnvelopeReport {
  const EnvelopeReport(this.year, this.envelope, this.projects, this.upkeep);

  final int year;
  final Decimal? envelope;
  final Amounts projects;
  final Amounts upkeep;

  Amounts get total => projects + upkeep;

  Decimal? get leftToPlan =>
      envelope == null ? null : envelope! - total.planned;

  Decimal? get leftToSpend =>
      envelope == null ? null : envelope! - total.engaged;

  /// What is set aside: the envelope when there is one, else the plans.
  Decimal get setAside => envelope ?? total.planned;

  Decimal get spent => total.engaged;

  Decimal get left => setAside - spent;

  /// How far the spending is past what is set aside; zero when it is not.
  Decimal get leftOver => _max(-left, zero);

  /// Spent against what is set aside, whole percent, half to even; none when
  /// nothing is set aside.
  int? get percent {
    if (setAside <= zero) return null;
    return _halfEven(spent * _hundred, setAside).toInt();
  }

  int get gaugeValue {
    final value = percent ?? 0;
    return value > 100 ? 100 : value;
  }
}

EnvelopeReport envelope(Ledger ledger, int year) => EnvelopeReport(
  year,
  ledger.envelopes[year],
  sumOf(ledger.projectsIn(year).map((p) => p.amounts)),
  ledger.maintenance(year),
);

/// The last 12 months of upkeep; payments on projects carry no date.
({Day since, Day until, Amounts upkeep, int missing}) rolling(Ledger ledger) {
  final window = inRolling(ledger.today);
  final figures = [
    for (final row in ledger.tasks) row.figures(window, openToo: false),
  ];
  return (
    since: rollingStart(ledger.today),
    until: ledger.today,
    upkeep: sumOf(figures.map((f) => f.amounts)),
    missing: figures.fold(0, (sum, f) => sum + f.missing),
  );
}
