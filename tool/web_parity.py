# SPDX-License-Identifier: AGPL-3.0-only
"""Measure the web application on a phone, for test/web_parity_test.dart.

Run in the environment of the web repository at the commit of
tool/web_alignment.json (`uv sync --frozen --group docs`, `playwright install
chromium`), against a local instance filled by `manage.py load_demo_data
--owner demo@example.com --language fr` (an account made beforehand, password
`demo-password-for-local-captures`, its language set to French in its preferences), the
translations compiled (`manage.py compilemessages`), with one item in the utility room and
one contractor added (the names of test/web_parity_test.dart), the tasks of
lot 3c (a task done two days ago with its cost and a note, a task skipped, a task in season
beyond the week, a task hidden until its date gets closer; `Demo.seed` of
test/web_parity_test.dart lists them), and three stock items
('Filtre de VMC', 'Pile 9 V', 'Peinture blanche') with a supplier ("Magasin d'exemple", for
the first) and movements (the first one left low), and one open report ('Le robinet de la
cuisine fuit', in the kitchen):

    uv run python tool/web_parity.py <capture directory> [<base URL>] [--only <screen> ...]

Opens every screen at 390 x 844 CSS px, device scale factor 3, in French,
saves a screenshot of each in the capture directory and writes the measures, the
release and commit it measured ("web", which `web_alignment.py check`
compares with the pin of `web_parity`) and the day it ran ("today": the dates of the
rows are relative to it) to test/parity/web_fr_390.json.

`--only` measures the screens named and nothing else (the screens of ONLY_SCREENS, which
need only the demonstration data, one item in the utility room and the French language),
for a screen a later release added: the other screens keep their measure, and the file
says so in "carried" (the release and commit they were measured at, and their names), so
that "web" names the release of the newest measure without passing the others off as
taken at it. A full run, without `--only`, measures every screen and removes "carried".
"""

import datetime
import json
import os
import re
import subprocess
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright


def web_checkout() -> dict:
    """The release and commit of the web checkout this runs in (`WEB_RELEASE` and `WEB_COMMIT`
    stand in for a checkout without git, such as an archive)."""
    def git(*args: str) -> str:
        return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout.strip()

    release = os.environ.get("WEB_RELEASE") or git("describe", "--tags", "--exact-match", "HEAD")
    commit = os.environ.get("WEB_COMMIT") or git("rev-parse", "HEAD")
    return {"release": release, "commit": commit}


args = sys.argv[1:]
only = [args[i + 1] for i, a in enumerate(args) if a == "--only" and i + 1 < len(args)]
args = [a for i, a in enumerate(args) if a != "--only" and (i == 0 or args[i - 1] != "--only")]
base = args[1] if len(args) > 1 else "http://127.0.0.1:8000"
out = Path(args[0])
# The screens `--only` can measure on their own: their path and the selector of their add button.
ONLY_SCREENS = {
    # The Equipment tab (web v0.4.0): every item of the home.
    "equipment": ("items/", "main a.button-block[href*='/items/new/']"),
}
unknown = sorted(set(only) - set(ONLY_SCREENS))
if unknown:
    raise SystemExit(f"--only: no such screen {unknown}; one of {sorted(ONLY_SCREENS)}")
target = Path(__file__).resolve().parent.parent / "test" / "parity" / "web_fr_390.json"
out.mkdir(parents=True, exist_ok=True)

MEASURE = """
(addSel) => {
  const q = (s) => document.querySelector(s);
  const cs = (e) => e ? getComputedStyle(e) : null;
  const box = (e) => { if (!e) return null; const r = e.getBoundingClientRect();
    return {x: r.x, y: r.y + window.scrollY, w: r.width, h: r.height}; };
  const fs = (s) => { const e = q(s); return e ? parseFloat(cs(e).fontSize) : null; };
  const fw = (s) => { const e = q(s); return e ? parseInt(cs(e).fontWeight, 10) : null; };
  const lh = (s) => { const e = q(s); return e ? parseFloat(cs(e).lineHeight) : null; };
  const text = (e) => e ? e.innerText.replace(/\\s+/g, ' ').trim() : null;
  // What the screen lists, section by section: the heading, its count, the rows
  // (title, place, pills, height). Empty on a screen without section headings.
  const sections = [...document.querySelectorAll('main section[aria-labelledby]')]
    .filter((s) => s.querySelector('.task-list'))
    .map((s) => ({
      heading: text(s.querySelector('h2')),
      rows: [...s.querySelectorAll('.task-list > li')].map((li) => ({
        title: text(li.querySelector('.row-title')),
        text: text(li.querySelector('.row-text')),
        pills: [...li.querySelectorAll('.pill')].map(text),
        height: li.getBoundingClientRect().height,
      })),
    }));
  // A list with no heading (the list of all tasks, the history): its rows as
  // one section without a title.
  const plain = [...document.querySelectorAll('main > .task-list > li')];
  if (!sections.length && plain.length) {
    sections.push({
      heading: '',
      rows: plain.map((li) => ({
        title: text(li.querySelector('.row-title')),
        text: text(li.querySelector('.row-text')),
        pills: [...li.querySelectorAll('.pill')].map(text),
        height: li.getBoundingClientRect().height,
      })),
    });
  }
  const add = addSel ? q(addSel) : null;
  const row = q('main .task-row') || q('main .list > li') || q('main ul.list li');
  const card = q('main .task-list') || q('main .list') || q('main .card-list') || q('main .card');
  const field = q('main input[type=text], main input:not([type]), main select');
  return {
    h1_font: fs('main h1'), h1_box: box(q('main h1')),
    h2_font: fs('main h2'), h2_weight: fw('main h2'),
    row_title_font: fs('main .row-title'), row_text_font: fs('main .row-text'),
    row_title_weight: fw('main .row-title'), row_text_weight: fw('main .row-text'),
    row_title_line: lh('main .row-title'), row_text_line: lh('main .row-text'),
    pill_font: fs('main .pill'), pill_weight: fw('main .pill'),
    sections: sections,
    body_font: parseFloat(cs(document.body).fontSize),
    row_height: row ? box(row).h : null,
    done_button: box(q('main .button-done')),
    add_button: box(add), add_radius: add ? parseFloat(cs(add).borderTopLeftRadius) : null,
    add_class: add ? add.className : null, add_font: add ? parseFloat(cs(add).fontSize) : null,
    add_text: add ? add.innerText.trim() : null,
    add_gap: (() => { if (!add) return null; let e = add;
      while (e && !e.previousElementSibling) e = e.parentElement;
      const prev = e.previousElementSibling; if (!prev) return null;
      return add.getBoundingClientRect().top - prev.getBoundingClientRect().bottom; })(),
    done_font: fs('main .button-done'),
    appbar_height: box(q('header.appbar')).h,
    nav_height: box(q('nav.nav')) ? box(q('nav.nav')).h : null,
    content_left: card ? box(card).x : null,
    field_height: field ? box(field).h : null,
    label_font: fs('main label'),
    doc_height: document.documentElement.scrollHeight,
  };
}
"""

def measure_and_write(page, screens: dict, *, partial: bool) -> None:
    """Measure `screens` and write test/parity/web_fr_390.json.

    `partial` (`--only`): the screens not measured keep their measure, named in "carried" with
    the release and commit they were taken at, and "today" stays the day they were taken on
    (the dates of their rows are relative to it); each screen measured has its own "day".
    """
    result = {}
    for name, (path, add) in screens.items():
        page.goto(base + path)
        page.wait_for_load_state("networkidle")
        page.evaluate("document.fonts.ready")
        page.screenshot(path=str(out / f"{name}.png"))
        page.screenshot(path=str(out / f"{name}_full.png"), full_page=True)
        m = page.evaluate(MEASURE, add)
        m["url"] = re.sub(r"[0-9a-f-]{36}", "<id>", path)
        if partial:
            m["day"] = datetime.date.today().isoformat()
        result[name] = m
        print(name, json.dumps(m))
    document = json.loads(target.read_text()) if target.exists() else {}
    measured = {"repository": "HouseCairn/housecairn", **web_checkout()}
    if partial:
        before = document.get("web", {})
        kept = sorted(n for n in document.get("screens", {}) if n not in result)
        carried = document.get("carried")
        if carried is None:
            # Every screen kept was measured at the release the file named.
            carried = {"release": before.get("release"), "commit": before.get("commit"), "screens": kept}
        else:
            # A second partial run: the screens of the last one were measured at "web".
            newer = [n for n in kept if n not in carried["screens"]]
            if newer and before.get("commit") != measured["commit"]:
                raise SystemExit(
                    f"{newer} were measured at {before.get('release')} and the others at "
                    f"{carried['release']}: one \"carried\" cannot say both; measure every screen"
                )
            carried["screens"] = [n for n in carried["screens"] if n in kept]
        if carried["screens"] and carried["commit"] != measured["commit"]:
            document["carried"] = carried
        else:
            document.pop("carried", None)
        document["screens"] = {**document.get("screens", {}), **result}
    else:
        document.pop("carried", None)
        document["today"] = datetime.date.today().isoformat()
        document["screens"] = result
    # What `tool/web_alignment.py check` compares with the pin of `web_parity`.
    document["web"] = measured
    target.write_text(json.dumps(document, indent=1, ensure_ascii=False) + "\n")


with sync_playwright() as p:
    b = p.chromium.launch()
    c = b.new_context(viewport={"width": 390, "height": 844}, device_scale_factor=3,
                      locale="fr-FR", is_mobile=True, has_touch=True)
    page = c.new_page()
    page.goto(base + "/accounts/login/")
    page.fill("input[name=login]", "demo@example.com")
    page.fill("input[name=password]", "demo-password-for-local-captures")
    page.click("form button[type=submit]")
    page.wait_for_load_state()
    page.goto(base + "/h/")
    home = re.search(r"/h/([0-9a-f-]{36})/", page.content()).group(1)
    H = f"/h/{home}"

    def first(path, pattern):
        page.goto(base + path)
        hrefs = page.eval_on_selector_all("main a[href]", "els => els.map(e => e.getAttribute('href'))")
        for h in hrefs:
            if re.search(pattern, h):
                return h.split("?")[0]
        raise SystemExit(f"no link {pattern} on {path}: {hrefs}")

    if only:
        screens = {name: (f"{H}/{ONLY_SCREENS[name][0]}", ONLY_SCREENS[name][1]) for name in only}
        measure_and_write(page, screens, partial=True)
        b.close()
        raise SystemExit(0)
    page.goto(base + f"{H}/rooms/")
    rooms = sorted({h.split("?")[0] for h in page.eval_on_selector_all(
        "main a[href]", "els => els.map(e => e.getAttribute('href'))")
        if re.search(r"/rooms/[0-9a-f-]{36}/(\?|$)", h)})
    room = item = None
    for candidate in rooms:
        try:
            item = first(candidate, r"/items/[0-9a-f-]{36}/")
            room = candidate
            break
        except SystemExit:
            continue
    task = first("/", r"/tasks/[0-9a-f-]{36}/")
    screens = {
        "today": ("/", "main a.button-block[href*='/tasks/new/']"),
        "task": (task, None),
        "task_form": (f"{H}/tasks/new/", None),
        "homes": ("/h/", "main a[href*='/h/new/']"),
        "rooms": (f"{H}/rooms/", "main a[href*='/rooms/new/']"),
        "room": (room, "main a[href*='/tasks/new/']"),
        "room_form": (f"{H}/rooms/new/", None),
        "item": (item, "main a[href*='/tasks/new/']"),
        "item_form": (room + "items/new/", None),
        "contractors": (f"{H}/contractors/", "main a[href*='contractors/new']"),
        "templates": (f"{H}/tasks/templates/", None),
        "more": ("/more/", None),
        "reminders": ("/me/notifications/", None),
    }
    try:
        contractor = first(f"{H}/contractors/", r"/contractors/[0-9a-f-]{36}/")
        screens["contractor"] = (contractor, None)
        screens["contractor_form"] = (f"{H}/contractors/new/", None)
    except SystemExit as e:
        print(e)
    # The detail of the stock item with a supplier and movements (the low one).
    page.goto(base + f"{H}/stock/")
    article = next(
        (href.split("?")[0] for title, href in page.eval_on_selector_all(
            "main a.row[href]",
            "els => els.map(e => [e.querySelector('.row-title')?.innerText.trim(),"
            " e.getAttribute('href')])")
         if title == "Filtre de VMC" and re.search(r"/stock/[0-9a-f-]{36}/(\?|$)", href)),
        None)
    if article is None:
        raise SystemExit(f"no stock item 'Filtre de VMC' on {H}/stock/")
    screens["stock"] = (f"{H}/stock/", "main a[href*='/stock/new/']")
    screens["article"] = (article, "main a[href*='/suppliers/new/']")
    screens["article_form"] = (f"{H}/stock/new/", None)
    screens["supplier_form"] = (article + "suppliers/new/", None)
    # Lot 3b: the projects of the demonstration, the budget and the reports.
    page.goto(base + f"{H}/projects/")
    project = next(
        (href.split("?")[0] for title, href in page.eval_on_selector_all(
            "main a[href]",
            "els => els.map(e => [e.innerText.trim(), e.getAttribute('href')])")
         if "Repeindre le salon" in (title or "")
         and re.search(r"/projects/[0-9a-f-]{36}/(\?|$)", href)),
        None)
    if project is None:
        raise SystemExit(f"no project 'Repeindre le salon' on {H}/projects/")
    screens["projects"] = (f"{H}/projects/", "main a[href*='/projects/new/']")
    screens["project"] = (project, None)
    screens["project_form"] = (f"{H}/projects/new/", None)
    screens["budget"] = (f"{H}/budget/", None)
    screens["reports"] = (f"{H}/reports/", "main a[href*='/reports/new/']")
    screens["report_form"] = (f"{H}/reports/new/", None)
    # Lot 3c: all the tasks, the history and the details of what was done.
    screens["tasks"] = (f"{H}/tasks/", "main a.button-block[href*='/tasks/new/']")
    screens["history"] = (f"{H}/tasks/?status=done", None)
    page.goto(base + f"{H}/tasks/?status=done")
    changed = next(
        (href.split("?")[0] for title, href in page.eval_on_selector_all(
            "main a.row[href]",
            "els => els.map(e => [e.querySelector('.row-title')?.innerText.trim(),"
            " e.getAttribute('href')])")
         if title == "Changer la pile du détecteur"),
        None)
    if changed is None:
        raise SystemExit(f"no done task 'Changer la pile du détecteur' on {H}/tasks/?status=done")
    page.goto(base + changed)
    edit = page.eval_on_selector_all(
        "main a[href]", "els => els.map(e => e.getAttribute('href'))")
    edit = next(h.split("?")[0] for h in edit if re.search(r"/occurrences/[0-9a-f-]{36}/edit/", h))
    screens["occurrence_form"] = (edit, None)
    measure_and_write(page, screens, partial=False)
    b.close()
