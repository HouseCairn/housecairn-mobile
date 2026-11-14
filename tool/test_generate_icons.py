# SPDX-License-Identifier: AGPL-3.0-only
"""Tests of the app icons: python3 tool/test_generate_icons.py (run in CI).

- no icon has the fingerprint of an icon of the Flutter project template;
- the 1024 px iOS icon, and every iOS icon, is RGB with no alpha channel and no tRNS chunk;
- every file named by Contents.json and by the adaptive icon exists;
- the generator reproduces the committed files (same pixels).
"""
import hashlib
import json
import re
import subprocess
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_icons as g  # noqa: E402

# SHA-256 of every icon of the Flutter project template (iOS AppIcon.appiconset and Android
# mipmap-*), frozen before the Housecairn icons replaced them.
FLUTTER_DEFAULT_ICONS = {
    "19be171481dc71a0b2803ebcd01dd8b0c5fd5778dee34c0a3cabc948c225f24e",
    "3c34e1f298d0c9ea3455d46db6b7759c8211a49e9ec6e44b635fc5c87dfb4180",
    "41c7d42f6e61f8fe7f30b1ffa2256aecbc9682be06d18c4a3062043e1a2e547c",
    "4209a49e44a92ec40a327d3455eb1b1c153ee83d75de1c2be0a12ab18b2ff9de",
    "4d470bf22d5c17d84edc5f82516d1ba8a1c09559cd761cefb792f86d9f52b540",
    "5d7e5bdf01b93802bc973345b3a78c038907147625035952a08a115a563b7f81",
    "5dee24dc104ac76dc162e42ae0beb163d426bf365562ee28ba7b3ad368559a60",
    "6a7c8f0d703e3682108f9662f813302236240d3f8f638bb391e32bfb96055fef",
    "7770183009e914112de7d8ef1d235a6a30c5834424858e0d2f8253f6b8d31926",
    "7c61c42fc7b657d9cf314d32a4ec458f0647c3aaf360be1b9377857266ec2499",
    "836c918cb613249eba0483a6b02fa3df3c1c0a89a315ee4d3b88509b83c7ab73",
    "a9b21eb6f4271385655a8771f76e29eef8c1107d7879cbcfc567e6619d1f716a",
    "b9ad02cf6576a04d1b6806ac02a2431481b448dd0c2e505ce25842d1f7c4730b",
    "c6e6d3b215ae744a9c391f4c4d44157eff5e739d6ad6c39f9bfa5df66dddd267",
    "c7c0c0189145e4e32a401c61c9bdc615754b0264e7afae24e834bb81049eaf81",
    "cab10a0d391ec5bc09ef50ce49e8ad401cee7ef03707ec0923a222c5c2b3d212",
    "e14aa40904929bf313fded22cf7e7ffcbf1d1aac4263b5ef1be8bfce650397aa",
    "e677d701ffe4af7bc2935098d6b3984cc9ab7ace573e6900955a5535b12410cf",
}


def icon_files():
    return sorted(g.IOS.glob("*.png")) + sorted(g.RES.glob("mipmap-*/*.png")) + sorted(
        g.RES.glob("drawable-*/ic_launcher_*.png")
    )


class IconTests(unittest.TestCase):
    def test_no_flutter_default_icon_is_left(self):
        files = icon_files()
        self.assertEqual(len(files), 30)
        for path in files:
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            self.assertNotIn(digest, FLUTTER_DEFAULT_ICONS, f"{path} is a Flutter default icon")

    def test_ios_icons_have_no_alpha(self):
        for path in g.IOS.glob("*.png"):
            data = path.read_bytes()
            width, height, ctype, _ = g.decode(data)
            self.assertEqual(ctype, 2, f"{path.name} must be RGB (colour type 2)")
            self.assertNotIn(b"tRNS", data, f"{path.name} has a transparency chunk")
        width, height, _, _ = g.decode((g.IOS / "Icon-App-1024x1024@1x.png").read_bytes())
        self.assertEqual((width, height), (1024, 1024))

    def test_contents_json_is_consistent(self):
        contents = json.loads((g.IOS / "Contents.json").read_text())
        names = {image["filename"] for image in contents["images"]}
        self.assertEqual(names, {p.name for p in g.IOS.glob("*.png")})
        for image in contents["images"]:
            side = round(float(image["size"].split("x")[0]) * int(image["scale"][:-1]))
            width, height, _, _ = g.decode((g.IOS / image["filename"]).read_bytes())
            self.assertEqual((width, height), (side, side), image["filename"])
        self.assertIn("ios-marketing", {image["idiom"] for image in contents["images"]})

    def test_android_adaptive_icon_is_complete(self):
        xml = (g.RES / "mipmap-anydpi-v26/ic_launcher.xml").read_text()
        for layer in ("background", "foreground", "monochrome"):
            self.assertIn(f"<{layer} ", xml)
        colour = (g.RES / "values/ic_launcher_background.xml").read_text()
        slate = json.loads(g.TOKENS.read_text())["color"]["slate"]
        self.assertRegex(colour, re.escape(slate))
        for density, factor in g.DENSITIES.items():
            side = round(g.CANVAS_DP * factor)
            for name in ("ic_launcher_foreground", "ic_launcher_monochrome"):
                w, h, ctype, _ = g.decode((g.RES / f"drawable-{density}/{name}.png").read_bytes())
                self.assertEqual((w, h, ctype), (side, side, 6))
        manifest = (g.ROOT / "android/app/src/main/AndroidManifest.xml").read_text()
        self.assertIn('android:icon="@mipmap/ic_launcher"', manifest)

    def test_generator_reproduces_the_committed_files(self):
        done = subprocess.run(
            [sys.executable, str(Path(g.__file__)), "--check"], capture_output=True, text=True
        )
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)


if __name__ == "__main__":
    unittest.main()
