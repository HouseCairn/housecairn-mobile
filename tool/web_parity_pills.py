# SPDX-License-Identifier: AGPL-3.0-only
"""Measure the pills of state of the web application, for test/web_parity_test.dart.

The colour of the text, of the fill and of the border of the pill that tells the state of a report
and of a project, on their pages (`reports/report_detail.html`, `projects/project_detail.html`),
one page for each state.

Run as tool/web_parity.py says (same environment, same instance and data), with one report in each
state and one project in each state added to the demonstration data:

    uv run python tool/web_parity_pills.py [<base URL>]

Writes test/parity/web_pills_fr_390.json, with the release and commit it measured ("web").
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

REPORT_STATES = {"Robinet qui fuit": "open", "Porte qui grince": "task",
                 "Ampoule": "resolved", "Bruit": "no_action"}
PROJECT_STATES = {"Refaire la salle de bain": "idea", "Repeindre le salon": "planned", "P in_progress": "in_progress",
                  "P done": "done", "P abandoned": "abandoned"}


def web_checkout() -> dict:
    """The release and commit of the web checkout this runs in (`WEB_RELEASE` and `WEB_COMMIT`
    stand in for a checkout without git)."""
    def git(*args: str) -> str:
        return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout.strip()

    release = os.environ.get("WEB_RELEASE") or git("describe", "--tags", "--exact-match", "HEAD")
    commit = os.environ.get("WEB_COMMIT") or git("rev-parse", "HEAD")
    return {"release": release, "commit": commit}


base = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
target = Path(__file__).resolve().parent.parent / "test" / "parity" / "web_pills_fr_390.json"

MEASURE = """
() => {
  const pill = document.querySelector('main .task-pills .pill');
  if (!pill) return null;
  const c = getComputedStyle(pill);
  return {text: pill.innerText.trim(), color: c.color, background: c.backgroundColor,
          border_width: c.borderTopWidth, border_color: c.borderTopColor};
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

    def links(path, pattern):
        page.goto(base + path)
        return {text.split("\n")[0].strip(): href.split("?")[0] for text, href in page.eval_on_selector_all(
            "main a[href]", "els => els.map(e => [e.innerText.trim(), e.getAttribute('href')])")
            if re.search(pattern, href.split("?")[0])}

    result = {}
    for kind, path, pattern, states in [
        ("reports", f"{H}/reports/?show=all", r"/reports/[0-9a-f-]{36}/$", REPORT_STATES),
        ("projects", f"{H}/projects/", r"/projects/[0-9a-f-]{36}/$", PROJECT_STATES),
    ]:
        for title, state in states.items():
            # The projects are listed by tab: going on, ideas, finished (docs/adr/0017 of the web).
            view = {"idea": "ideas", "done": "finished", "abandoned": "finished"}.get(state, "")
            found = links(path + (f"?view={view}" if kind == "projects" else ""), pattern)
            href = next((h for t, h in found.items() if title in t), None)
            if href is None:
                raise SystemExit(f"no link {title!r} on {path}")
            page.goto(base + href)
            page.wait_for_load_state("networkidle")
            result[f"{kind}.{state}"] = page.evaluate(MEASURE)
            print(kind, state, json.dumps(result[f"{kind}.{state}"], ensure_ascii=False))
    b.close()

document = {
    "$comment": "Colours of the pills of state of the web application, in French, with its "
                "demonstration data, written by tool/web_parity_pills.py; read by "
                "test/web_parity_test.dart. Measure again when the pin of web_parity moves.",
    "web": {"repository": "HouseCairn/housecairn", **web_checkout()},
    "pills": result,
}
target.write_text(json.dumps(document, indent=1, ensure_ascii=False) + "\n")
