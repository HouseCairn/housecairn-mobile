#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-only
"""Writes test/fixtures/recurrence_vectors.json from the recurrence module of the web app.

The Dart port of `housecairn.tasks.recurrence` (lib/domain/recurrence.dart) must give
the same dates as the Python module (docs/plan.md, lot 2). This script runs the Python
functions on a fixed set of rules and dates (month ends, 29 February, seasons in both
hemispheres, `after_last`, fixed series begun decades ago, dates near the end of the
calendar) and writes every call with its result; test/recurrence_test.dart replays them.

Run it in an environment where the web application is installed, from a checkout of
HouseCairn/housecairn, for example:

    git clone https://github.com/HouseCairn/housecairn web && cd web
    uv sync --frozen --no-dev
    uv run python ../housecairn-mobile/tool/recurrence_vectors.py \\
        --source-commit "$(git rev-parse HEAD)" ../housecairn-mobile/test/fixtures/recurrence_vectors.json

The cases are fixed or drawn from a seeded generator: the same module gives the same
file, byte for byte.
"""

import argparse
import datetime
import importlib.metadata
import json
import random
import sys

from housecairn.tasks import recurrence as r

SEED = 20261114
D = datetime.date


def iso(day: datetime.date | None) -> str | None:
    return None if day is None else day.isoformat()


def rule_json(rule: r.Rule) -> dict[str, object]:
    return {
        "mode": rule.mode,
        "unit": rule.unit,
        "interval": rule.interval,
        "season_start": rule.season_start,
        "season_end": rule.season_end,
    }


# Days that make the month-end and leap-year rules work: the 28th to the 31st, 29
# February of leap years (2000 and 2024; 2100 is not one), the turn of the year.
SPECIAL_DAYS = [
    D(2024, 1, 28), D(2024, 1, 29), D(2024, 1, 30), D(2024, 1, 31),
    D(2024, 2, 28), D(2024, 2, 29), D(2023, 2, 28), D(2025, 2, 28),
    D(2024, 3, 31), D(2024, 4, 30), D(2024, 5, 31), D(2024, 8, 31),
    D(2024, 10, 31), D(2024, 11, 30), D(2024, 12, 31), D(2025, 1, 1),
    D(2000, 2, 29), D(2100, 2, 28), D(2099, 12, 31), D(2026, 6, 15),
    D(2026, 11, 14), D(2027, 3, 1),
]
# Fixed series begun decades ago, done today: the walk must not be a century long.
OLD_ANCHORS = [D(1926, 1, 31), D(1950, 2, 28), D(1976, 2, 29), D(1990, 7, 31), D(2001, 9, 30)]
# The end of the calendar: Python stops at 9999-12-31, so must the port.
LATE_DAYS = [D(9999, 1, 31), D(9999, 11, 30), D(9999, 12, 25), D(9999, 12, 31)]

SEASONS: list[tuple[int, int] | None] = [None]
for hemisphere in (r.NORTH, r.SOUTH):
    for season in r.PREDEFINED_SEASONS:
        SEASONS.append(r.season_window(season, hemisphere))
    for season in r.LEGACY_SEASONS:
        SEASONS.append(r.legacy_season(season, hemisphere))
SEASONS += [(11, 3), (5, 5), (1, 12), (12, 12)]

INTERVALS = {
    r.DAY: [1, 2, 3, 10, 30, 45, 365, 18_250],
    r.WEEK: [1, 2, 3, 4, 52, 2_600],
    r.MONTH: [1, 2, 3, 6, 11, 12, 13, 18, 24, 600],
    r.YEAR: [1, 2, 4, 5, 10, 50],
}


def rules(rng: random.Random) -> list[r.Rule]:
    found = [r.Rule()]
    for mode in (r.FIXED, r.AFTER_LAST):
        for unit, intervals in INTERVALS.items():
            for interval in intervals:
                for season in SEASONS:
                    # Every rule without a season and with a season of each kind for the
                    # small intervals; a sample of the others, to keep the file small.
                    if season is not None and interval > 13 and rng.random() < 0.7:
                        continue
                    start, end = season if season else (None, None)
                    found.append(r.Rule(mode, unit, interval, start, end))
    return found


def some_day(rng: random.Random, low: int = 1990, high: int = 2060) -> datetime.date:
    year = rng.randint(low, high)
    month = rng.randint(1, 12)
    last = (D(year + (month == 12), month % 12 + 1, 1) - datetime.timedelta(days=1)).day
    # One day in three at a month end, where the rules differ.
    day = rng.randint(max(1, last - 3), last) if rng.random() < 0.34 else rng.randint(1, last)
    return D(year, month, day)


def pick_day(rng: random.Random) -> datetime.date:
    roll = rng.random()
    if roll < 0.45:
        return rng.choice(SPECIAL_DAYS)
    return some_day(rng)


def next_due_vectors(rng: random.Random, all_rules: list[r.Rule]) -> list[dict[str, object]]:
    out = []

    def add(rule: r.Rule, anchor, due_on, done_on) -> None:
        out.append(
            {
                "rule": rule_json(rule),
                "anchor": iso(anchor),
                "due_on": iso(due_on),
                "done_on": iso(done_on),
                "expected": iso(r.next_due(rule, anchor=anchor, due_on=due_on, done_on=done_on)),
            }
        )

    for rule in all_rules:
        for _ in range(4):
            due_on = pick_day(rng)
            roll = rng.random()
            if roll < 0.3:
                done_on = due_on
            elif roll < 0.65:
                done_on = due_on + datetime.timedelta(days=rng.randint(1, 400))
            else:
                done_on = due_on - datetime.timedelta(days=rng.randint(1, 60))
            anchor_roll = rng.random()
            if anchor_roll < 0.15:
                anchor = None
            elif anchor_roll < 0.6:
                anchor = due_on
            elif anchor_roll < 0.85:
                anchor = due_on - datetime.timedelta(days=rng.randint(1, 3000))
            else:
                anchor = due_on + datetime.timedelta(days=rng.randint(1, 90))
            if rng.random() < 0.08:
                due_on = None
            add(rule, anchor, due_on, done_on)
    # Every special day as the anchor and the due date of the plain monthly and yearly
    # rules, closed on time, late and early.
    for unit in (r.MONTH, r.YEAR):
        for interval in (1, 2, 12):
            rule = r.Rule(r.FIXED, unit, interval)
            for day in SPECIAL_DAYS:
                for done in (day, day + datetime.timedelta(days=45), day - datetime.timedelta(days=3)):
                    add(rule, day, day, done)
    # Old series: anchor decades ago, the open occurrence far behind, done today.
    today = D(2026, 11, 14)
    for anchor in OLD_ANCHORS:
        for unit, intervals in INTERVALS.items():
            for interval in intervals[:4]:
                for season in (None, (3, 5), (11, 3)):
                    start, end = season if season else (None, None)
                    rule = r.Rule(r.FIXED, unit, interval, start, end)
                    add(rule, anchor, anchor, today)
                    add(rule, anchor, today - datetime.timedelta(days=10), today)
    # The end of the calendar: no date after 9999-12-31.
    for day in LATE_DAYS:
        for unit in r.UNITS:
            for mode in (r.FIXED, r.AFTER_LAST):
                for season in (None, (3, 5)):
                    start, end = season if season else (None, None)
                    rule = r.Rule(mode, unit, 1, start, end)
                    add(rule, day, day, day)
    return out


def coming_vectors(rng: random.Random, all_rules: list[r.Rule]) -> list[dict[str, object]]:
    out = []

    def add(rule: r.Rule, anchor, after, since, end) -> None:
        out.append(
            {
                "rule": rule_json(rule),
                "anchor": iso(anchor),
                "after": iso(after),
                "since": iso(since),
                "end": iso(end),
                "expected": [
                    d.isoformat()
                    for d in r.coming(rule, anchor=anchor, after=after, since=since, end=end)
                ],
            }
        )

    for rule in rng.sample(all_rules, k=min(len(all_rules), 260)):
        for _ in range(2):
            after = pick_day(rng)
            roll = rng.random()
            if roll < 0.4:
                since = after + datetime.timedelta(days=1)
            elif roll < 0.8:
                since = after + datetime.timedelta(days=rng.randint(30, 4000))
            else:
                since = after - datetime.timedelta(days=rng.randint(1, 40))
            end = since + datetime.timedelta(days=rng.choice([31, 92, 365, 366]))
            anchor_roll = rng.random()
            if anchor_roll < 0.2:
                anchor = None
            elif anchor_roll < 0.7:
                anchor = after - datetime.timedelta(days=rng.randint(0, 2000))
            else:
                anchor = after + datetime.timedelta(days=rng.randint(1, 200))
            add(rule, anchor, after, since, end)
    # A year of calendar for an old series, and the end of the calendar.
    for anchor in OLD_ANCHORS:
        for unit in r.UNITS:
            for season in (None, (12, 2)):
                start, end = season if season else (None, None)
                rule = r.Rule(r.FIXED, unit, 1 if unit != r.DAY else 7, start, end)
                add(rule, anchor, anchor, D(2027, 1, 1), D(2027, 12, 31))
    for unit in r.UNITS:
        rule = r.Rule(r.FIXED, unit, 1)
        add(rule, D(9999, 10, 31), D(9999, 10, 31), D(9999, 11, 1), D(9999, 12, 31))
        rule = r.Rule(r.AFTER_LAST, unit, 1)
        add(rule, None, D(9999, 10, 31), D(9999, 11, 1), D(9999, 12, 31))
    return out


def preview_vectors(rng: random.Random, all_rules: list[r.Rule]) -> list[dict[str, object]]:
    out = []
    for rule in rng.sample(all_rules, k=min(len(all_rules), 200)):
        due_on = pick_day(rng)
        anchor = rng.choice([None, due_on, due_on - datetime.timedelta(days=rng.randint(1, 900))])
        out.append(
            {
                "rule": rule_json(rule),
                "anchor": iso(anchor),
                "due_on": iso(due_on),
                "count": 5,
                "expected": [
                    d.isoformat() for d in r.preview(rule, anchor=anchor, due_on=due_on, count=5)
                ],
            }
        )
    return out


def problems_vectors() -> list[dict[str, object]]:
    candidates = [
        r.Rule(),
        r.Rule("weekly"),
        r.Rule(r.ONCE, "fortnight", 0),
        r.Rule(r.FIXED, "fortnight"),
        r.Rule(r.FIXED, r.DAY, 0),
        r.Rule(r.AFTER_LAST, r.DAY, 18_250),
        r.Rule(r.AFTER_LAST, r.DAY, 18_251),
        r.Rule(r.FIXED, r.WEEK, 2_600),
        r.Rule(r.FIXED, r.WEEK, 2_601),
        r.Rule(r.FIXED, r.MONTH, 600),
        r.Rule(r.FIXED, r.MONTH, 601),
        r.Rule(r.FIXED, r.YEAR, 50),
        r.Rule(r.FIXED, r.YEAR, 51),
        r.Rule(r.FIXED, r.YEAR, -1),
        r.Rule(r.FIXED, r.MONTH, 1, 3, None),
        r.Rule(r.FIXED, r.MONTH, 1, None, 5),
        r.Rule(r.FIXED, r.MONTH, 1, 0, 5),
        r.Rule(r.FIXED, r.MONTH, 1, 3, 13),
        r.Rule(r.FIXED, r.MONTH, 1, 12, 1),
        r.Rule("weekly", r.MONTH, 1, 3, None),
        r.Rule(r.FIXED, r.MONTH, 0, 13, 1),
    ]
    return [{"rule": rule_json(rule), "expected": r.problems(rule)} for rule in candidates]


def season_vectors() -> dict[str, list[dict[str, object]]]:
    names = [*r.PREDEFINED_SEASONS, *r.LEGACY_SEASONS, r.CUSTOM, "", "monsoon"]
    hemispheres = [r.NORTH, r.SOUTH, "equator"]
    window = [
        {"season": s, "hemisphere": h, "expected": r.season_window(s, h)}
        for s in names
        for h in hemispheres
    ]
    legacy = [
        {"season": s, "hemisphere": h, "expected": r.legacy_season(s, h)}
        for s in names
        for h in hemispheres
    ]
    named = [
        {"start": a, "end": b, "expected": r.season_named(a, b)}
        for a in [None, *range(1, 13)]
        for b in [None, *range(1, 13)]
    ]
    in_season = [
        {
            "rule": rule_json(r.Rule(r.FIXED, r.MONTH, 1, *season) if season else r.Rule()),
            "day": iso(D(2026, month, 15)),
            "expected": r.in_season(
                r.Rule(r.FIXED, r.MONTH, 1, *season) if season else r.Rule(), D(2026, month, 15)
            ),
        }
        for season in SEASONS
        for month in range(1, 13)
    ]
    return {"season_window": window, "legacy_season": legacy, "season_named": named, "in_season": in_season}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--source-commit", required=True, help="commit of HouseCairn/housecairn")
    parser.add_argument("output")
    args = parser.parse_args()
    rng = random.Random(SEED)
    all_rules = rules(rng)
    document = {
        "generated_by": "tool/recurrence_vectors.py",
        "source": {
            "repository": "HouseCairn/housecairn",
            "commit": args.source_commit,
            "module": "housecairn.tasks.recurrence",
            "python": "%d.%d.%d" % sys.version_info[:3],
            "python-dateutil": importlib.metadata.version("python-dateutil"),
        },
        "seed": SEED,
        "next_due": next_due_vectors(rng, all_rules),
        "coming": coming_vectors(rng, all_rules),
        "preview": preview_vectors(rng, all_rules),
        "problems": problems_vectors(),
        **season_vectors(),
    }
    with open(args.output, "w", encoding="utf-8", newline="\n") as f:
        f.write("{\n")
        keys = list(document)
        for i, key in enumerate(keys):
            value = document[key]
            comma = "," if i < len(keys) - 1 else ""
            if isinstance(value, list):
                # One vector per line: a change of the module shows as a readable diff.
                f.write(f"  {json.dumps(key)}: [\n")
                for j, item in enumerate(value):
                    sep = "," if j < len(value) - 1 else ""
                    f.write(f"    {json.dumps(item, sort_keys=True)}{sep}\n")
                f.write(f"  ]{comma}\n")
            else:
                f.write(f"  {json.dumps(key)}: {json.dumps(value, sort_keys=True)}{comma}\n")
        f.write("}\n")
    counts = {k: len(v) for k, v in document.items() if isinstance(v, list)}
    print(json.dumps(counts))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
