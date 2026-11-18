# SPDX-License-Identifier: AGPL-3.0-only
"""Tests of tool/web_alignment.py: python3 tool/test_web_alignment.py (run in CI).

They run on a throwaway copy of the app files and a throwaway git repository standing for the
web application, with the vector generator replaced by a stub (no uv, no network):

- a web release that changes nothing the app carries: changed=false, nothing written, pin kept;
- a real gap (template, token, vectors): changed=true, files and pin moved;
- `check`: a token missing or modified, a vector edited by hand, a pin that is not the tag;
- a missing or malformed pin file;
- the copies of the guide, the glossary and the guide's vectors: one byte changed or a missing
  file fails `check`; `update --only` adds an element to the pin and moves no other;
- a patch that touches a file outside those the update may change is refused.
"""
import contextlib
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import web_alignment as wa  # noqa: E402

TEMPLATES = "src/housecairn/tasks/task_templates.yaml"
RECURRENCE = "src/housecairn/tasks/recurrence.py"
TOKENS = "design/tokens.json"
CSS = "src/housecairn/static/css/components.css"
PARITY = "test/parity/web_fr_390.json"
BUDGET = "test/fixtures/budget_web_figures.json"
BUDGET_WEB = "src/housecairn/budget/services.py"
# The copies of web ADR 0084: element, web file, file of the app, first content.
GUIDE_COPIES = (
    ("guide", "design/guide.json", "design/guide.json", '{\n  "version": 1,\n  "title": {"en": "Guide", "fr": "Guide"}\n}\n'),
    ("glossary", "design/glossary.json", "design/glossary.json", '{\n  "terms": [{"id": "save", "en": "Save", "fr": "Enregistrer"}]\n}\n'),
    ("guide_states", "tests/fixtures/guide_states.json", "test/fixtures/guide_states.json", '{\n  "cases": []\n}\n'),
)
GIT_ENV = {
    "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@example.com",
    "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@example.com",
}


def run(*command: str, cwd: Path) -> str:
    env = {**os.environ, **GIT_ENV}
    return subprocess.run(command, cwd=cwd, env=env, check=True, capture_output=True, text=True).stdout.strip()


def vectors(commit: str, body: str = "v1") -> bytes:
    """What the stub generator returns: a header naming the commit, then the vectors."""
    return (f'{{\n  "source": {{"commit": "{commit}"}},\n  "next_due": [\n    "{body}"\n  ]\n}}\n').encode()


class Case(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="web-alignment-test-"))
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.web = self.tmp / "web"
        self.app = self.tmp / "app"
        self.web.mkdir()
        self.app.mkdir()
        run("git", "init", "--quiet", cwd=self.web)
        self.body = "v1"  # what the stub generator says the vectors are, per release
        self.bodies: dict[str, str] = {}

        # Web release v0.1.0.
        self.web_write(TEMPLATES, "templates: one\n")
        self.web_write(RECURRENCE, "# recurrence\n")
        self.web_write(TOKENS, json.dumps({"color": {"slate": "#1F3A3D"}}, indent=2) + "\n")
        self.web_write("README.md", "web\n")
        self.web_write(CSS, ".row { }\n")
        for _, web_path, _, text in GUIDE_COPIES:
            self.web_write(web_path, text)
        self.first = self.web_release("v0.1.0")

        # The app, aligned on v0.1.0.
        (self.app / "tool").mkdir()
        (self.app / "docs").mkdir()
        (self.app / "docs" / "spec.md").write_text("Nothing cited.\n")
        self.app_write("assets/task_templates.yaml", "templates: one\n")
        self.app_write("test/fixtures/recurrence_vectors.json", vectors(self.first).decode())
        self.app_write(BUDGET, vectors(self.first).decode())
        self.app_write(TOKENS, json.dumps({"color": {"slate": "#1F3A3D", "app-only": "#000000"}}, indent=2) + "\n")
        self.app_write(
            PARITY, json.dumps({"web": {"repository": wa.WEB_REPOSITORY, "release": "v0.1.0", "commit": self.first}}) + "\n"
        )
        for _, _, app_path, text in GUIDE_COPIES:
            self.app_write(app_path, text)
        pin = {"release": "v0.1.0", "commit": self.first}
        element = lambda web, mobile, **extra: {**pin, "web": [web], "mobile": [mobile], **extra}  # noqa: E731
        self.reference = {
            "repository": wa.WEB_REPOSITORY,
            "elements": {
                "recurrence": element(RECURRENCE, "test/fixtures/recurrence_vectors.json", python="3.13.0"),
                "task_templates": element(TEMPLATES, "assets/task_templates.yaml"),
                "design_tokens": element(TOKENS, TOKENS),
                "web_parity": element("src/housecairn/static/css", PARITY),
                "budget": element(BUDGET_WEB, BUDGET, python="3.13.0"),
                **{name: element(web_path, app_path) for name, web_path, app_path, _ in GUIDE_COPIES},
            },
        }
        self.write_reference()

        saved = (wa.ROOT, wa.REFERENCE, wa.SPEC, wa.recurrence_vectors, wa.budget_figures)
        wa.ROOT, wa.REFERENCE, wa.SPEC = self.app, self.app / "tool" / "web_alignment.json", self.app / "docs" / "spec.md"
        wa.recurrence_vectors = lambda web, commit, python: vectors(commit, self.bodies.get(commit, "v1"))
        # The budget figures do not change with the stub releases (the vectors are the signal).
        wa.budget_figures = lambda web, commit, python: vectors(commit)
        self.addCleanup(lambda: (setattr(wa, "ROOT", saved[0]), setattr(wa, "REFERENCE", saved[1]),
                                 setattr(wa, "SPEC", saved[2]), setattr(wa, "recurrence_vectors", saved[3]),
                                 setattr(wa, "budget_figures", saved[4])))
        self.snapshot_before = self.snapshot()

    # Helpers.

    def web_write(self, path: str, text: str) -> None:
        file = self.web / path
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(text)

    def web_release(self, tag: str) -> str:
        run("git", "add", "--all", cwd=self.web)
        run("git", "commit", "--quiet", "-m", tag, cwd=self.web)
        run("git", "tag", tag, cwd=self.web)
        return run("git", "rev-parse", "HEAD", cwd=self.web)

    def app_write(self, path: str, text: str) -> None:
        file = self.app / path
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(text)

    def write_reference(self) -> None:
        (self.app / "tool" / "web_alignment.json").write_text(json.dumps(self.reference, indent=2) + "\n")

    def snapshot(self) -> dict[str, bytes]:
        return {str(p.relative_to(self.app)): p.read_bytes() for p in sorted(self.app.rglob("*")) if p.is_file()}

    def cli(self, *argv: str) -> tuple[int, str, str]:
        out, err = io.StringIO(), io.StringIO()
        saved = sys.argv
        sys.argv = ["web_alignment.py", *argv]
        try:
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                code = wa.main()
        finally:
            sys.argv = saved
        return code, out.getvalue(), err.getvalue()

    def update(self, release: str) -> tuple[str, str]:
        report = self.tmp / "report.md"
        code, out, err = self.cli("update", "--web", str(self.web), "--release", release, "--report", str(report))
        self.assertEqual(code, 0, err)
        return out, report.read_text()


class Update(Case):
    def test_release_without_effect_changes_nothing(self):
        # A new release: another web file, a refactoring of the recurrence module (same vectors).
        self.web_write("README.md", "web, second\n")
        self.web_write(RECURRENCE, "# recurrence, refactored\n")
        self.web_release("v0.2.0")
        out, report = self.update("v0.2.0")
        self.assertIn("changed=false", out)
        self.assertNotIn("changed=true", out)
        self.assertEqual(self.snapshot(), self.snapshot_before, "no file written, the pin included")
        self.assertIn("v0.2.0", report)
        self.assertIn("checked, nothing to port", report)
        self.assertIn("The pin stays at v0.1.0", report)
        self.assertIn(f"web file changed: `{RECURRENCE}`", report)
        # The app stays consistent with its own pin.
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 0, out + err)

    def test_real_gap_changes_files_and_pin(self):
        self.web_write(TEMPLATES, "templates: one\ntemplates: two\n")
        second = self.web_release("v0.2.0")
        out, report = self.update("v0.2.0")
        self.assertIn("changed=true", out)
        self.assertEqual((self.app / "assets/task_templates.yaml").read_text(), "templates: one\ntemplates: two\n")
        reference = json.loads((self.app / "tool" / "web_alignment.json").read_text())
        for name, element in reference["elements"].items():
            # The measure of the rendering keeps its pin: no file that draws the screens changed.
            expected = ("v0.1.0", self.first) if name == "web_parity" else ("v0.2.0", second)
            self.assertEqual((element["release"], element["commit"]), expected)
        # The vectors follow the pin: only their header changed.
        self.assertIn(second, (self.app / "test/fixtures/recurrence_vectors.json").read_text())
        self.assertIn("regenerated, changed", report)
        self.assertNotIn("nothing to port", report)
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 0, out + err)

    def test_real_gap_in_the_vectors(self):
        self.web_write(RECURRENCE, "# recurrence, new rule\n")
        second = self.web_release("v0.2.0")
        self.bodies[second] = "v2"
        out, report = self.update("v0.2.0")
        self.assertIn("changed=true", out)
        self.assertIn('"v2"', (self.app / "test/fixtures/recurrence_vectors.json").read_text())
        self.assertIn("1 vector lines changed", report)

    def test_real_gap_in_a_token(self):
        self.web_write(TOKENS, json.dumps({"color": {"slate": "#222222"}}, indent=2) + "\n")
        self.web_release("v0.2.0")
        out, _ = self.update("v0.2.0")
        self.assertIn("changed=true", out)
        tokens = json.loads((self.app / TOKENS).read_text())
        self.assertEqual(tokens["color"], {"slate": "#222222", "app-only": "#000000"})

    def test_a_change_of_the_drawing_files_moves_the_pin_and_leaves_the_measure_stale(self):
        self.web_write(CSS, ".row { padding: 1px }\n")
        self.web_release("v0.2.0")
        out, report = self.update("v0.2.0")
        self.assertIn("changed=true", out)
        self.assertIn("stale until it is measured again", report)
        self.assertIn(f"web file changed: `{CSS}`", report)
        # Not regenerated: the measure still says v0.1.0, and `check` fails on it.
        self.assertEqual(json.loads((self.app / PARITY).read_text())["web"]["release"], "v0.1.0")
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("web_parity", out)
        self.assertIn("measure again", out)

    def test_a_measure_taken_again_passes(self):
        self.web_write(CSS, ".row { padding: 1px }\n")
        second = self.web_release("v0.2.0")
        self.update("v0.2.0")
        self.app_write(PARITY, json.dumps({"web": {"repository": wa.WEB_REPOSITORY, "release": "v0.2.0", "commit": second}}) + "\n")
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 0, out)

    def test_a_measure_of_another_commit_fails(self):
        self.app_write(PARITY, json.dumps({"web": {"repository": wa.WEB_REPOSITORY, "release": "v0.1.0", "commit": "0" * 40}}) + "\n")
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("web_parity: test/parity/web_fr_390.json was measured at v0.1.0", out)

    def test_unknown_release_fails(self):
        code, _, err = self.cli("update", "--web", str(self.web), "--release", "v9.9.9")
        self.assertEqual(code, 2)
        self.assertIn("web_alignment:", err)


class Check(Case):
    def test_aligned_app_passes(self):
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 0, out + err)

    def test_token_missing_fails(self):
        self.app_write(TOKENS, json.dumps({"color": {"app-only": "#000000"}}, indent=2) + "\n")
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("color.slate: missing in the app", out)

    def test_token_modified_fails(self):
        self.app_write(TOKENS, json.dumps({"color": {"slate": "#999999"}}, indent=2) + "\n")
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("color.slate: #999999 in the app, #1F3A3D on the web", out)

    def test_vector_edited_by_hand_fails(self):
        self.app_write("test/fixtures/recurrence_vectors.json", vectors(self.first, "edited").decode())
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("1 vector lines differ", out)

    def test_pin_that_is_not_the_tag_fails(self):
        self.reference["elements"]["task_templates"]["commit"] = "0" * 40
        self.write_reference()
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("the pin says", out)

    def test_missing_parity_measure_fails_cleanly(self):
        (self.app / PARITY).unlink()
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1, err)
        self.assertIn(f"web_parity: {PARITY} is missing", out)

    def test_parity_measure_of_another_repository_fails(self):
        self.app_write(
            PARITY, json.dumps({"web": {"repository": "example.com/other", "release": "v0.1.0", "commit": self.first}}) + "\n"
        )
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("(" + self.first[:7] + ") of example.com/other, the pin says", out)


class GuideCopies(Case):
    """The guide, the glossary and the guide's vectors are the web's bytes (web ADR 0084)."""

    def test_one_byte_changed_in_a_copy_fails(self):
        for name, web_path, app_path, text in GUIDE_COPIES:
            with self.subTest(name):
                file = self.app / app_path
                data = bytearray(file.read_bytes())
                data[len(data) // 2] ^= 0x01  # one bit of one byte, the size unchanged
                file.write_bytes(bytes(data))
                code, out, _ = self.cli("check", "--web", str(self.web))
                self.assertEqual(code, 1, out)
                self.assertIn(f"{name}: {app_path} is not {web_path} of v0.1.0 byte for byte", out)
                self.assertIn(f"{name}: v0.1.0 ({self.first[:7]}): DIFFERENT", out)
                file.write_text(text)
                code, out, _ = self.cli("check", "--web", str(self.web))
                self.assertEqual(code, 0, out)

    def test_a_copy_reformatted_but_equal_as_json_fails(self):
        # Byte for byte, not value by value: the app reads the same bytes as the web.
        file = self.app / "design/guide.json"
        file.write_text(json.dumps(json.loads(file.read_text())) + "\n")
        code, out, _ = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1)
        self.assertIn("guide: design/guide.json is not", out)

    def test_a_missing_copy_fails(self):
        (self.app / "test/fixtures/guide_states.json").unlink()
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 1, err)
        self.assertIn("guide_states: test/fixtures/guide_states.json is not tests/fixtures/guide_states.json", out)

    def test_a_change_of_the_guide_on_the_web_is_a_real_gap(self):
        self.web_write("design/guide.json", '{\n  "version": 2\n}\n')
        second = self.web_release("v0.2.0")
        out, report = self.update("v0.2.0")
        self.assertIn("changed=true", out)
        self.assertEqual((self.app / "design/guide.json").read_text(), '{\n  "version": 2\n}\n')
        self.assertIn("- **guide** (v0.1.0 → v0.2.0): `design/guide.json` regenerated, changed.", report)
        reference = json.loads((self.app / "tool" / "web_alignment.json").read_text())
        self.assertEqual(reference["elements"]["guide"]["commit"], second)
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 0, out + err)


class Only(Case):
    """`update --only`: the elements named, and no other; how a new element enters the pin."""

    def without(self, *names: str) -> None:
        for name in names:
            del self.reference["elements"][name]
        self.write_reference()

    def test_an_element_missing_from_the_pin_is_refused_by_check_and_update(self):
        self.without("guide")
        code, _, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 2)
        self.assertIn("no pin for guide", err)
        code, _, err = self.cli("update", "--web", str(self.web), "--release", "v0.1.0")
        self.assertEqual(code, 2)
        self.assertIn("no pin for guide", err)
        code, _, err = self.cli("update", "--web", str(self.web), "--release", "v0.1.0", "--only", "glossary")
        self.assertEqual(code, 2, "an element missing and not named stays an error")

    def test_only_adds_the_new_elements_and_moves_no_other(self):
        # The web moves on: a template changes, and the drawing files too.
        self.web_write(TEMPLATES, "templates: one\ntemplates: two\n")
        self.web_write(CSS, ".row { padding: 1px }\n")
        self.web_write("design/guide.json", '{\n  "version": 2\n}\n')
        second = self.web_release("v0.2.0")
        self.without("guide", "guide_states")
        (self.app / "design/guide.json").unlink()
        (self.app / "test/fixtures/guide_states.json").unlink()
        before = self.snapshot()

        out, report = self.update_only("v0.2.0", "guide", "glossary", "guide_states")
        self.assertIn("changed=true", out)
        self.assertEqual((self.app / "design/guide.json").read_bytes(), b'{\n  "version": 2\n}\n')
        self.assertEqual((self.app / "test/fixtures/guide_states.json").read_text(), GUIDE_COPIES[2][3])
        self.assertIn("- **guide** (new, v0.2.0): `design/guide.json` copied.", report)
        self.assertIn("- **glossary** (v0.1.0 → v0.2.0): `design/glossary.json` regenerated, identical.", report)
        self.assertIn("- **task_templates** (pinned v0.1.0): not examined (`--only`).", report)

        reference = json.loads((self.app / "tool" / "web_alignment.json").read_text())
        self.assertEqual(list(reference["elements"]), list(wa.ELEMENTS), "the elements in their order")
        for name, element in reference["elements"].items():
            expected = ("v0.2.0", second) if name in ("guide", "glossary", "guide_states") else ("v0.1.0", self.first)
            self.assertEqual((element["release"], element["commit"]), expected, name)
        self.assertEqual(reference["elements"]["guide_states"]["web"], ["tests/fixtures/guide_states.json"])
        self.assertEqual(reference["elements"]["guide_states"]["mobile"], ["test/fixtures/guide_states.json"])
        after = self.snapshot()
        touched = {p for p in set(before) | set(after) if before.get(p) != after.get(p)}
        self.assertEqual(touched, {"design/guide.json", "test/fixtures/guide_states.json", "tool/web_alignment.json"})
        # The templates and the measure keep their pin, so the app stays consistent.
        code, out, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 0, out + err)

    def test_only_without_a_gap_changes_nothing(self):
        self.web_write(TEMPLATES, "templates: one\ntemplates: two\n")
        self.web_release("v0.2.0")
        out, report = self.update_only("v0.2.0", "guide")
        self.assertIn("changed=false", out)
        self.assertEqual(self.snapshot(), self.snapshot_before)
        self.assertIn("checked, nothing to port", report)

    def test_only_refuses_an_unknown_element(self):
        with self.assertRaises(SystemExit):
            with contextlib.redirect_stderr(io.StringIO()):
                self.cli("update", "--web", str(self.web), "--release", "v0.1.0", "--only", "nothing")

    def update_only(self, release: str, *names: str) -> tuple[str, str]:
        report = self.tmp / "report.md"
        argv = ["update", "--web", str(self.web), "--release", release, "--report", str(report)]
        for name in names:
            argv += ["--only", name]
        code, out, err = self.cli(*argv)
        self.assertEqual(code, 0, err)
        return out, report.read_text()


class Reference(Case):
    def test_missing_reference_fails(self):
        (self.app / "tool" / "web_alignment.json").unlink()
        for argv in (["check", "--web", str(self.web)], ["update", "--web", str(self.web), "--release", "v0.1.0"]):
            code, out, err = self.cli(*argv)
            self.assertEqual(code, 2)
            self.assertIn("web_alignment.json is missing", err)
            self.assertNotIn("changed=", out)

    def test_element_without_pin_fails(self):
        del self.reference["elements"]["design_tokens"]
        self.write_reference()
        code, _, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 2)
        self.assertIn("no pin for design_tokens", err)

    def test_other_repository_fails(self):
        self.reference["repository"] = "example.com/other"
        self.write_reference()
        code, _, err = self.cli("check", "--web", str(self.web))
        self.assertEqual(code, 2)
        self.assertIn("repository must be", err)


class Patch(Case):
    """The patch the workflow applies with the token of the App: the four files, nothing else."""

    def setUp(self):
        super().setUp()
        run("git", "init", "--quiet", cwd=self.app)
        run("git", "add", "--all", cwd=self.app)
        run("git", "commit", "--quiet", "-m", "app", cwd=self.app)

    def patch(self) -> Path:
        run("git", "add", "--all", cwd=self.app)
        file = self.tmp / "alignment.patch"
        file.write_bytes(subprocess.run(["git", "diff", "--cached", "--binary"], cwd=self.app, check=True,
                                        capture_output=True).stdout)
        return file

    def test_the_four_files_pass(self):
        for path in wa.ALLOWED_PATHS:
            self.app_write(path, (self.app / path).read_text() + "\n")
        code, out, err = self.cli("verify-patch", str(self.patch()))
        self.assertEqual(code, 0, out + err)

    def test_the_allowed_paths_are_the_files_of_the_pin(self):
        # The measure of the rendering is taken in a browser: `update` never writes it.
        carried = {
            m for n, e in self.reference["elements"].items() if n != "web_parity" for m in e["mobile"]
        } | {"tool/web_alignment.json"}
        self.assertEqual(set(wa.ALLOWED_PATHS), carried)
        code, out, _ = self.cli("allowed-paths")
        self.assertEqual(out.split(), list(wa.ALLOWED_PATHS))

    def test_other_files_are_refused_and_listed(self):
        self.app_write("assets/task_templates.yaml", "x\n")
        self.app_write(".github/workflows/ci.yml", "name: hijacked\n")
        self.app_write("lib/main.dart", "void main() {}\n")
        code, out, err = self.cli("verify-patch", str(self.patch()))
        self.assertEqual(code, 1)
        self.assertIn(".github/workflows/ci.yml", out)
        self.assertIn("lib/main.dart", out)
        self.assertNotIn("FAIL assets/task_templates.yaml", out)
        self.assertIn("may change", err)

    def test_a_deleted_or_renamed_allowed_file_is_refused(self):
        (self.app / "design/tokens.json").rename(self.app / "design/tokens-moved.json")
        code, out, _ = self.cli("verify-patch", str(self.patch()))
        self.assertEqual(code, 1)
        self.assertIn("tokens-moved.json", out)

    def test_an_allowed_file_turned_into_a_symlink_is_refused(self):
        target = self.app / "assets/task_templates.yaml"
        target.unlink()
        target.symlink_to("../.github/workflows/ci.yml")
        code, out, _ = self.cli("verify-patch", str(self.patch()))
        self.assertEqual(code, 1)

    def test_an_empty_or_broken_patch(self):
        file = self.tmp / "broken.patch"
        file.write_text("not a patch\n")
        code, _, _ = self.cli("verify-patch", str(file))
        self.assertEqual(code, 1)


if __name__ == "__main__":
    unittest.main()
