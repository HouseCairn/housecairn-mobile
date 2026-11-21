// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';

import 'budget.dart' show cents, zero;

/// The real cost of a done occurrence (web ADR 0090, 0091, 0092): the one
/// rule, ported from `tasks/costs.py` of the web, read by the task page, the
/// History and the Budget.
///
/// The real cost is the value of the stock the occurrence used plus the rest
/// (labour, purchases outside the stock). The value of the stock is, for each
/// live draw, the quantity taken times the unit price of the article when it
/// was taken (`unit_price`, kept by the server), added and rounded once to
/// the cent, half up. A draw whose article had no price counts for nothing and
/// is counted apart ([StockUsed.unpriced]).
///
/// The rest is the amount typed when there is one, zero included; with
/// nothing typed, the plan the server kept when the occurrence was marked
/// done ([Planned]). A done occurrence with nothing typed, no plan and no
/// stock of value is "done without a cost": no amount, which is not zero.
/// Everything is in [Decimal], never in floating point.

/// The stock a done occurrence used, at the prices of when it was taken.
class StockUsed {
  const StockUsed([Decimal? amount, this.unpriced = 0]) : _amount = amount;

  final Decimal? _amount;

  Decimal get amount => _amount ?? zero;

  /// The draws whose article had no unit price: counted for nothing.
  final int unpriced;

  /// Whether the occurrence took anything from the stock.
  bool get any => _amount != null;
}

const nothingUsed = StockUsed();

/// The stock used by the live draws [draws] of a done occurrence: each is
/// (quantity drawn, unit price or none). Rounded once, half up, to the cent.
StockUsed stockUsed(Iterable<(Decimal, Decimal?)> draws) {
  Decimal? total;
  var unpriced = 0;
  for (final (drawn, price) in draws) {
    total ??= zero;
    if (price == null) {
      unpriced++;
    } else {
      total += drawn * price;
    }
  }
  return total == null ? nothingUsed : StockUsed(cents(total), unpriced);
}

/// What the plan of a task said when an occurrence of it was marked done
/// (web ADR 0091): the labour planned, and the material budget typed only
/// when the stock does not work the materials out (ADR 0081). `null` is
/// "nothing planned", which is not a plan of zero.
class Planned {
  const Planned([this.labour, this.material]);

  final Decimal? labour;
  final Decimal? material;

  bool get known => labour != null || material != null;

  Decimal get amount => (labour ?? zero) + (material ?? zero);
}

const noPlan = Planned();

/// What the plan of a task says now, for an occurrence marked done on this
/// phone before the server kept its own (`plan_when_done` of the web): none
/// for a task of a project, whose money is in the lines of the project; the
/// material budget only when no stock item with a price works it out.
Planned planWhenDone({
  required bool inProject,
  required Decimal? labourBudget,
  required Decimal? materialBudget,
  required bool materialFromStock,
}) {
  if (inProject) return noPlan;
  return Planned(labourBudget, materialFromStock ? null : materialBudget);
}

/// What is not in the stock: the amount typed if any (0 is an amount), else
/// the plan.
Decimal? rest(Decimal? typed, [Planned planned = noPlan]) {
  if (typed != null) return typed;
  return planned.known ? planned.amount : null;
}

/// The real cost: the stock used plus the rest; `null` when nothing says
/// anything.
Decimal? realCost(Decimal? typed, Decimal stock, [Planned planned = noPlan]) {
  final other = rest(typed, planned);
  if (other == null && stock == zero) return null;
  return (other ?? zero) + stock;
}

/// The real cost of one occurrence, its parts apart. [estimated] is true for
/// an occurrence marked done on this phone that the server has not answered
/// yet: its prices and its plan are those of now, until the next sync brings
/// those the server kept.
class OccurrenceCost {
  const OccurrenceCost(
    this.typed, [
    this.stock = nothingUsed,
    this.planned = noPlan,
    this.estimated = false,
  ]);

  final Decimal? typed;
  final StockUsed stock;
  final Planned planned;
  final bool estimated;

  /// The plan counted as paid: the one kept, when nothing is typed.
  Planned get fromPlan => typed == null ? planned : noPlan;

  Decimal? get total => realCost(typed, stock.amount, planned);
}

/// The cost of an occurrence that is not done: none.
const noCost = OccurrenceCost(null);
