#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-only
"""Writes test/fixtures/budget_web_figures.json: the budget the web computes from the fixture.

The budget of the app (lib/domain/budget.dart) must give the same figures as the web
application's (`housecairn.budget.services`) for the same rows (docs/plan.md, lot 3). This
script loads test/fixtures/budget_fixture.json (two neutral homes, in EUR and CHF) into an
empty database of the web application, computes every figure of every year with the web's own
functions (by year, envelope, by room, by project, by task, by nature, the last 12 months, the
projected times of each task) and writes them; test/budget_web_test.dart loads the same fixture
through the repository of the app and compares, figure by figure.

Run it in an environment where the web application is installed, from a checkout of
HouseCairn/housecairn, for example:

    git clone https://github.com/HouseCairn/housecairn web && cd web
    uv sync --frozen --no-dev
    uv run python -I ../housecairn-mobile/tool/budget_figures.py \\
        --source-commit "$(git rev-parse HEAD)" \\
        ../housecairn-mobile/test/fixtures/budget_fixture.json \\
        ../housecairn-mobile/test/fixtures/budget_web_figures.json

The database is a temporary SQLite file, removed at the end; nothing is sent anywhere. The same
web code gives the same file, byte for byte: `tool/web_alignment.py check` regenerates it at
the pinned commit and compares (element `budget`).
"""

import argparse
import datetime
import importlib.metadata
import json
import os
import sys
import tempfile
from decimal import Decimal
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("fixture", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    fixture = json.loads(args.fixture.read_text(encoding="utf-8"))
    with tempfile.TemporaryDirectory(prefix="budget-figures-") as data:
        os.environ.update(
            {
                "DJANGO_SETTINGS_MODULE": "housecairn.settings",
                "HOUSECAIRN_DATA_DIR": data,
                "SECRET_KEY": "budget-figures-only-0123456789abcdef0123456789abcdef",
                "ALLOWED_HOSTS": "localhost",
                "SECURE_SSL_REDIRECT": "false",
                "TIME_ZONE": "UTC",
            }
        )
        os.environ.pop("DATABASE_URL", None)
        import django

        django.setup()
        from django.core.management import call_command

        call_command("migrate", verbosity=0, interactive=False)
        figures = compute(fixture)
    source = {
        "repository": "HouseCairn/housecairn",
        "commit": args.source_commit,
        "housecairn": importlib.metadata.version("housecairn"),
        "fixture": "test/fixtures/budget_fixture.json",
    }
    rest = json.dumps({"today": fixture["today"], "homes": figures}, indent=1, ensure_ascii=False)
    # The source on one line, first: tool/web_alignment.py tells a change of the header alone
    # (another commit, the same figures) from a change of the figures.
    text = "{\n \"source\": " + json.dumps(source, ensure_ascii=False) + ",\n" + rest[2:] + "\n"
    args.output.write_text(text, encoding="utf-8")
    return 0


def money(value: Decimal | None) -> str | None:
    return None if value is None else str(Decimal(value).quantize(Decimal("0.01")))


def day(text: str | None) -> datetime.date | None:
    return None if text is None else datetime.date.fromisoformat(text)


def amounts(a) -> dict:
    return {
        "planned": money(a.planned),
        "committed": money(a.committed),
        "paid": money(a.paid),
        "engaged": money(a.engaged),
        "to_pay": money(a.to_pay),
        "gap": money(a.gap),
    }


def compute(fixture: dict) -> dict:
    from django.utils import timezone

    from housecairn.budget import services as budget
    from housecairn.homes.models import Home
    from housecairn.projects.models import (
        AnnualEnvelope,
        BudgetLine,
        Project,
        ProjectTask,
        Quote,
    )
    from housecairn.rooms.models import Room
    from housecairn.stock.models import Article
    from housecairn.tasks.models import Occurrence, Task, TaskMaterial

    today = day(fixture["today"])
    result = {}
    for spec in fixture["homes"]:
        home = Home.objects.create(name=spec["name"], currency=spec["currency"])
        keys: dict = {}
        rooms = {}
        for position, r in enumerate(spec["rooms"]):
            rooms[r["key"]] = Room.objects.create(home=home, name=r["name"], position=position)
            keys[rooms[r["key"]].id] = r["key"]
        articles = {
            a["key"]: Article.objects.create(
                home=home, name=a["name"], unit="piece",
                unit_price=None if a["unit_price"] is None else Decimal(a["unit_price"]),
            )
            for a in spec["articles"]
        }
        projects = {}
        for created, p in enumerate(spec["projects"]):
            project = Project.objects.create(home=home, title=p["title"], status=p["status"])
            # The order of creation, at noon UTC of the day given: its year is that day's.
            stamp = datetime.datetime.fromisoformat(p["created"] + "T12:00:00+00:00")
            stamp += datetime.timedelta(seconds=created)
            Project.objects.filter(pk=project.pk).update(created_at=stamp)
            project.rooms.set([rooms[k] for k in p["rooms"]])
            projects[p["key"]] = project
            keys[project.id] = p["key"]
            lines = {}
            for line in p["lines"]:
                lines[line["key"]] = BudgetLine.objects.create(
                    home=home, project=project, label=line["label"], nature=line["nature"],
                    planned=Decimal(line["planned"]), paid=Decimal(line["paid"]),
                )
            for q in p["quotes"]:
                Quote.objects.create(
                    home=home, project=project, amount=Decimal(q["amount"]), status=q["status"],
                    issued_on=day(q["issued_on"]),
                    budget_line=lines[q["line"]] if q["line"] else None,
                )
        for created, t in enumerate(spec["tasks"]):
            repeat = t["repeat"]
            task = Task.objects.create(
                home=home, title=t["title"],
                room=rooms[t["room"]] if t["room"] else None,
                material_budget=None if t["material_budget"] is None else Decimal(t["material_budget"]),
                labour_budget=None if t["labour_budget"] is None else Decimal(t["labour_budget"]),
                repeat_mode=repeat["mode"], repeat_unit=repeat["unit"],
                repeat_interval=repeat["interval"], series_start=day(t["series_start"]),
            )
            Task.objects.filter(pk=task.pk).update(
                created_at=timezone.now() + datetime.timedelta(seconds=created)
            )
            keys[task.id] = t["key"]
            for status, due, completed, cost in t["occurrences"]:
                Occurrence.objects.create(
                    home=home, task=task, status=status, due_on=day(due),
                    completed_on=day(completed),
                    actual_cost=None if cost is None else Decimal(cost),
                )
            for article, quantity in t["materials"]:
                TaskMaterial.objects.create(
                    home=home, task=task, article=articles[article], quantity=Decimal(quantity)
                )
            if t.get("project"):
                ProjectTask.objects.create(home=home, project=projects[t["project"]], task=task)
        for year, amount in spec["envelopes"].items():
            AnnualEnvelope.objects.create(home=home, year=int(year), amount=Decimal(amount))

        ledger = budget.load(home, today)
        years = ledger.years()
        figures: dict = {"currency": ledger.currency, "years": years}
        figures["by_year"] = [
            {
                "year": line.year,
                "envelope": money(line.envelope),
                "projects": amounts(line.projects),
                "upkeep": amounts(line.upkeep),
                "total": amounts(line.total),
            }
            for line in budget.by_year(ledger)
        ]
        figures["envelope"] = {}
        figures["by_room"] = {}
        figures["by_task"] = {}
        figures["by_nature"] = {}
        for year in years:
            e = budget.envelope(ledger, year)
            figures["envelope"][str(year)] = {
                "envelope": money(e.envelope),
                "total": amounts(e.total),
                "set_aside": money(e.set_aside),
                "spent": money(e.spent),
                "left": money(e.left),
                "left_over": money(e.left_over),
                "percent": e.percent,
                "left_to_plan": money(e.left_to_plan),
                "left_to_spend": money(e.left_to_spend),
            }
            figures["by_room"][str(year)] = [
                {
                    "room": keys.get(line.id),
                    "amounts": amounts(line.amounts),
                    "projects": amounts(line.extra["projects"]),
                    "upkeep": amounts(line.extra["upkeep"]),
                }
                for line in budget.by_room(ledger, year).lines
            ]
            report = budget.by_task(ledger, year)
            projected = {row.task.id: row.projected(year) for row in ledger.tasks}
            figures["by_task"][str(year)] = {
                "unlisted": report.note["unlisted"],
                "total": amounts(report.total),
                "lines": [
                    {
                        "task": keys[line.id],
                        "amounts": amounts(line.amounts),
                        "estimate": money(line.extra["estimate"]),
                        "annual_cost": money(line.extra["annual_cost"]),
                        "stock_estimate": money(line.extra["stock_estimate"]),
                        "unpriced_materials": line.extra["unpriced_materials"],
                        "total_paid": money(line.extra["total_paid"]),
                        "missing_costs": line.extra["missing_costs"],
                        "projected": projected[line.id],
                    }
                    for line in report.lines
                ],
            }
            figures["by_nature"][str(year)] = [
                {"nature": line.label, "amounts": amounts(line.amounts)}
                for line in budget.by_nature(ledger, year)
            ]
        report = budget.by_project(ledger)
        figures["by_project"] = {
            "total": amounts(report.total),
            "lines": [
                {
                    "project": keys[line.id],
                    "amounts": amounts(line.amounts),
                    "year": line.extra["year"],
                    "status": str(line.extra["status"]),
                    "tasks_planned": money(line.extra["tasks_planned"]),
                }
                for line in report.lines
            ],
        }
        rolling = budget.rolling(ledger)
        figures["rolling"] = {
            "since": rolling.since.isoformat(),
            "until": rolling.until.isoformat(),
            "upkeep": amounts(rolling.upkeep),
            "missing": rolling.missing,
        }
        result[spec["key"]] = figures
    return result


if __name__ == "__main__":
    sys.exit(main())
