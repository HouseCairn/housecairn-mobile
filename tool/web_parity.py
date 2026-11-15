# SPDX-License-Identifier: AGPL-3.0-only
"""Measure the web application on a phone, for test/web_parity_test.dart.

Run in the environment of the web repository at the commit of
tool/web_alignment.json (`uv sync --frozen --group docs`, `playwright install
chromium`), against a local instance filled by `manage.py load_demo_data
--owner demo@example.com --language fr` (an account made beforehand, password
`demo-password-for-local-captures`), with one item in the utility room and
one contractor added (the names of test/web_parity_test.dart):

    uv run python tool/web_parity.py <capture directory> [<base URL>]

Opens every screen at 390 x 844 CSS px, device scale factor 3, in French,
saves a screenshot of each in the capture directory and writes the measures
to test/parity/web_fr_390.json.
"""

import json
import re
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

base = sys.argv[2] if len(sys.argv) > 2 else "http://127.0.0.1:8000"
out = Path(sys.argv[1])
target = Path(__file__).resolve().parent.parent / "test" / "parity" / "web_fr_390.json"
out.mkdir(parents=True, exist_ok=True)

MEASURE = """
(addSel) => {
  const q = (s) => document.querySelector(s);
  const cs = (e) => e ? getComputedStyle(e) : null;
  const box = (e) => { if (!e) return null; const r = e.getBoundingClientRect();
    return {x: r.x, y: r.y + window.scrollY, w: r.width, h: r.height}; };
  const fs = (s) => { const e = q(s); return e ? parseFloat(cs(e).fontSize) : null; };
  const add = addSel ? q(addSel) : null;
  const row = q('main .task-row') || q('main .list > li') || q('main ul.list li');
  const card = q('main .task-list') || q('main .list') || q('main .card');
  const field = q('main input[type=text], main input:not([type]), main select');
  return {
    h1_font: fs('main h1'), h1_box: box(q('main h1')),
    h2_font: fs('main h2'),
    row_title_font: fs('main .row-title'), row_text_font: fs('main .row-text'),
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
    result = {}
    for name, (path, add) in screens.items():
        page.goto(base + path)
        page.wait_for_load_state("networkidle")
        page.evaluate("document.fonts.ready")
        page.screenshot(path=str(out / f"{name}.png"))
        page.screenshot(path=str(out / f"{name}_full.png"), full_page=True)
        m = page.evaluate(MEASURE, add)
        m["url"] = re.sub(r"[0-9a-f-]{36}", "<id>", path)
        result[name] = m
        print(name, json.dumps(m))
    document = json.loads(target.read_text()) if target.exists() else {}
    document["screens"] = result
    target.write_text(json.dumps(document, indent=1, ensure_ascii=False) + "\n")
    b.close()
