# SPDX-License-Identifier: AGPL-3.0-only
"""Measure the figures of the web application on a phone, for test/web_parity_values_test.dart.

The lines "label at the left, value at the right" (`dl.facts`), the figures of a budget table
on a phone (`.table-stack td`), the quantity of a stock item (`.stock-quantity`) and the gauge
of the budget (`progress` and its `.small`), on the screens that show them: the budget, a
project and a stock item.

Run as tool/web_parity.py says (same environment, same instance and data):

    uv run python tool/web_parity_values.py [<base URL>]

Writes test/parity/web_values_fr_390.json, with the release and commit it measured ("web"),
which test/web_parity_values_test.dart compares with the pin of `web_parity` in
tool/web_alignment.json.
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


base = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
target = Path(__file__).resolve().parent.parent / "test" / "parity" / "web_values_fr_390.json"

MEASURE = """
() => {
  const q = (s) => document.querySelector(s);
  const style = (e, pseudo) => { if (!e) return null; const c = getComputedStyle(e, pseudo);
    return {font: parseFloat(c.fontSize), weight: parseInt(c.fontWeight, 10),
            line: parseFloat(c.lineHeight), color: c.color}; };
  const box = (e) => { if (!e) return null; const r = e.getBoundingClientRect();
    return {x: r.x, w: r.width, h: r.height}; };
  const facts = q('main dl.facts');
  const rows = facts ? [...facts.querySelectorAll(':scope > div')] : [];
  const first = rows[0];
  const td = q('main .table-stack td[data-label]');
  const qty = q('main .stock-quantity');
  const progress = q('main .envelope-gauge progress');
  return {
    facts: first ? {
      label: style(first.querySelector('dt')),
      value: style(first.querySelector('dd')),
      // The value ends at the right of its row; the label starts at its left.
      value_right_gap: box(first).x + box(first).w
        - box(first.querySelector('dd')).x - box(first.querySelector('dd')).w,
      label_left_gap: box(first.querySelector('dt')).x - box(first).x,
      heights: rows.map((r) => r.getBoundingClientRect().height),
      separator: getComputedStyle(rows[1] || first).borderTopWidth,
    } : null,
    dense: td ? {
      label: style(td, '::before'), value: style(td), height: box(td).h,
    } : null,
    figure: qty ? {
      figure: style(qty.querySelector('strong')),
      unit: style(qty),
      gap: (() => { const r = document.createRange();
        const unit = [...qty.childNodes].find((n) => n.nodeType === 3 && n.textContent.trim());
        if (!unit) return null;
        r.selectNodeContents(unit); const t = r.getClientRects()[0];
        return t.x - box(qty.querySelector('strong')).x - box(qty.querySelector('strong')).w; })(),
    } : null,
    progress: progress ? {
      height: box(progress).h, text: style(progress.nextElementSibling),
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

    def link(path, title, pattern):
        page.goto(base + path)
        for text, href in page.eval_on_selector_all(
                "main a[href]", "els => els.map(e => [e.innerText.trim(), e.getAttribute('href')])"):
            if title in (text or "") and re.search(pattern, href.split("?")[0]):
                return href.split("?")[0]
        raise SystemExit(f"no link {title!r} on {path}")

    screens = {
        "budget": f"{H}/budget/",
        "project": link(f"{H}/projects/", "Repeindre le salon", r"/projects/[0-9a-f-]{36}/$"),
        "article": link(f"{H}/stock/", "Filtre de VMC", r"/stock/[0-9a-f-]{36}/$"),
    }
    result = {}
    for name, path in screens.items():
        page.goto(base + path)
        page.wait_for_load_state("networkidle")
        page.evaluate("document.fonts.ready")
        result[name] = page.evaluate(MEASURE)
        result[name]["url"] = re.sub(r"[0-9a-f-]{36}", "<id>", path)
        print(name, json.dumps(result[name], ensure_ascii=False))
    b.close()

document = {
    "$comment": "Measures of the figures of the web application at 390 x 844 CSS px, factor 3, in "
                "French, with its demonstration data, written by tool/web_parity_values.py; read by "
                "test/web_parity_values_test.dart. Measure again when the pin of web_parity moves.",
    "web": {"repository": "HouseCairn/housecairn", **web_checkout()},
    "screens": result,
}
target.write_text(json.dumps(document, indent=1, ensure_ascii=False) + "\n")
