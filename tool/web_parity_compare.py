# SPDX-License-Identifier: AGPL-3.0-only
"""Measure the comparison of projects of the web application on a phone, for
test/web_parity_compare_test.dart.

The list of projects with its button **Compare projects**, the same list in its mode of
comparison (the rows to tick, then **Compare the ticked projects** and **Cancel**) and the page
that sets the ticked projects side by side (`projects/project_list.html`,
`projects/compare.html`). The mode of comparison came with the web release v0.5.1, after the
pin of `web_parity` (v0.3.2): this measure names the release it was taken at, and the test
compares that with the release the app is aligned on for these screens.

Run in the environment of the web repository at that release (`uv sync --frozen --group docs`,
`playwright install chromium`), against a local instance filled by
`manage.py load_demo_data --owner demo@example.com --language fr` (an account made beforehand,
password `demo-password-for-local-captures`, its language set to French in its preferences),
the translations compiled; the demonstration has two projects, which is what the comparison
needs:

    uv run python tool/web_parity_compare.py <capture directory> [<base URL>]

Writes test/parity/web_compare_fr_390.json and a screenshot of each screen.
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright


def web_checkout() -> dict:
    """The release and commit of the web checkout this runs in, as tool/web_parity.py
    (`WEB_RELEASE` and `WEB_COMMIT` stand in for a checkout without git)."""
    def git(*args: str) -> str:
        return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout.strip()

    release = os.environ.get("WEB_RELEASE") or git("describe", "--tags", "--exact-match", "HEAD")
    commit = os.environ.get("WEB_COMMIT") or git("rev-parse", "HEAD")
    return {"release": release, "commit": commit}


out = Path(sys.argv[1])
base = sys.argv[2] if len(sys.argv) > 2 else "http://127.0.0.1:8000"
target = Path(__file__).resolve().parent.parent / "test" / "parity" / "web_compare_fr_390.json"
out.mkdir(parents=True, exist_ok=True)

MEASURE = """
() => {
  const q = (s) => document.querySelector(s);
  const all = (s) => [...document.querySelectorAll(s)];
  const text = (e) => e ? e.innerText.replace(/\\s+/g, ' ').trim() : null;
  const box = (e) => { if (!e) return null; const r = e.getBoundingClientRect();
    return {x: r.x, y: r.y + window.scrollY, w: r.width, h: r.height}; };
  const style = (e) => { if (!e) return null; const c = getComputedStyle(e);
    return {font: parseFloat(c.fontSize), weight: parseInt(c.fontWeight, 10),
            line: parseFloat(c.lineHeight)}; };
  const button = (e) => e ? {text: text(e), box: box(e), radius: parseFloat(getComputedStyle(e).borderTopLeftRadius),
    ...style(e), secondary: e.classList.contains('button-secondary')} : null;
  const card = q('main .card-list');
  const rows = all('main .card-list > li');
  const table = q('main .table-scroll table');
  return {
    h1: {text: text(q('main h1')), ...style(q('main h1'))},
    content_left: card ? box(card).x : (table ? box(q('main .table-scroll')).x : null),
    rows: rows.map((li) => ({
      title: text(li.querySelector('.row-title')),
      text: text(li.querySelector('.row-text')),
      height: li.getBoundingClientRect().height,
      // A box to tick in the mode of comparison: the row is its label, one target.
      tick: li.querySelector('input[type=checkbox]') ? box(li.querySelector('input[type=checkbox]')) : null,
      tick_is_row: !!li.querySelector('label.row input[type=checkbox]'),
    })),
    compare_link: button([...document.querySelectorAll('main a.button')]
      .find((a) => /compare=1/.test(a.getAttribute('href') || ''))),
    submit: button(q('main .button-row button[type=submit]')),
    cancel: button(q('main .button-row a.button')),
    button_row_gap: (() => { const s = q('main .button-row button[type=submit]');
      const c = q('main .button-row a.button'); if (!s || !c) return null;
      const a = s.getBoundingClientRect(), b = c.getBoundingClientRect();
      return Math.abs(a.top - b.top) < 1 ? b.left - a.right : b.top - a.bottom; })(),
    empty: text(q('main p.empty')),
    table: table ? {
      region: {role: q('main .table-scroll').getAttribute('role'),
               tabindex: q('main .table-scroll').getAttribute('tabindex'),
               label: text(document.getElementById(q('main .table-scroll').getAttribute('aria-labelledby'))),
               box: box(q('main .table-scroll'))},
      width: box(table).w,
      head: all('main .table-scroll thead th').map(text),
      head_style: style(q('main .table-scroll thead th')),
      cell_style: style(q('main .table-scroll tbody td')),
      row_head_style: style(q('main .table-scroll tbody th')),
      head_height: box(q('main .table-scroll thead tr')).h,
      rows: all('main .table-scroll tbody tr').map((tr) => ({
        cells: [...tr.children].map(text),
        height: tr.getBoundingClientRect().height,
        link: !!tr.querySelector('th a[href]'),
      })),
      columns: all('main .table-scroll thead th').map((th) => th.getBoundingClientRect().width),
    } : null,
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
    H = "/h/" + re.search(r"/h/([0-9a-f-]{36})/", page.url).group(1)

    def measure(name: str, path: str) -> None:
        page.goto(base + path)
        page.wait_for_load_state("networkidle")
        page.evaluate("document.fonts.ready")
        page.screenshot(path=str(out / f"{name}.png"), full_page=True)
        result[name] = page.evaluate(MEASURE)
        result[name]["url"] = re.sub(r"[0-9a-f-]{36}", "<id>", path)
        print(name, json.dumps(result[name], ensure_ascii=False))

    result: dict = {}
    measure("projects", f"{H}/projects/")
    measure("projects_compare", f"{H}/projects/?compare=1")
    # Tick every project of the list, then send the form, as a person does.
    for box in page.query_selector_all("main input[type=checkbox][name=p]"):
        box.check()
    page.click("main .button-row button[type=submit]")
    page.wait_for_load_state("networkidle")
    measure("project_compare", page.url.replace(base, ""))
    # Fewer than two projects: the page asks to tick more.
    one = page.url.replace(base, "").split("&")[0]
    measure("project_compare_one", one)
    b.close()

document = {
    "$comment": "Measures of the comparison of projects of the web application at 390 x 844 CSS px, "
                "factor 3, in French, with its demonstration data, written by "
                "tool/web_parity_compare.py; read by test/web_parity_compare_test.dart.",
    "web": {"repository": "HouseCairn/housecairn", **web_checkout()},
    "screens": result,
}
target.write_text(json.dumps(document, indent=1, ensure_ascii=False) + "\n")
