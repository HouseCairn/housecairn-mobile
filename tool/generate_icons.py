#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-only
"""Generates the app icons of iOS and Android from design/brand/housecairn-icone-app.svg.

  python3 tool/generate_icons.py             write the files
  python3 tool/generate_icons.py --check     fail if a committed file differs (pixels) from a fresh render
  python3 tool/generate_icons.py --preview out.png   write a contact sheet (iOS and Android, 3 sizes)

Python standard library only (no package to install, nothing downloaded). The SVG is the
single source: its three paths and its group transform are read from the file and
rasterised here (flattened Bezier curves, 4x4 supersampling, sRGB, 8 bits). Nothing is
redrawn. Three things a platform requires differ from the web icon, and only these:

- iOS wants a square without transparency and applies its own mask: the slate background
  is the SVG rectangle without its rounded corners; the 1024 px icon has no alpha channel.
- The Android adaptive icon is two layers on a 108 dp canvas, of which only the central
  66 dp are always visible: the background is the slate colour (design/tokens.json), the
  foreground is the cairn alone, at the scale of the SVG. The script fails if a point of
  the cairn leaves the 66 dp disc.
- The Android 13 themed icon is the silhouette of the cairn (alpha only), same geometry.

Legacy Android icons (before API 26) are the rounded square of the SVG, as is.
The icon of the bar (assets/brand/, three densities) is design/brand/housecairn-icon.svg, the
cairn of the web as is, on a transparent background.
Output is deterministic: files are compared by decoded pixels, not by bytes, so that the
zlib version does not matter.
"""
import json
import math
import re
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SVG = ROOT / "design/brand/housecairn-icone-app.svg"
BRAND_SVG = ROOT / "design/brand/housecairn-icon.svg"
BRAND_DIR = ROOT / "assets/brand"
LOGO_ICON_DP = 40  # layout.logo-icon of design/tokens.json (2.5rem)
TOKENS = ROOT / "design/tokens.json"
IOS = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
RES = ROOT / "android/app/src/main/res"

SS = 4  # supersampling per axis
SAFE_DIAMETER_DP = 66.0
CANVAS_DP = 108.0
DENSITIES = {"mdpi": 1.0, "hdpi": 1.5, "xhdpi": 2.0, "xxhdpi": 3.0, "xxxhdpi": 4.0}


# --- SVG ------------------------------------------------------------------------------


def hex_rgb(value):
    return tuple(int(value[i : i + 2], 16) for i in (1, 3, 5))


class Source:
    """Geometry and colours read from the SVG, in the 256 x 256 space of its viewBox."""

    def __init__(self, text):
        box = re.search(r'viewBox="0 0 (\d+) (\d+)"', text)
        self.size = float(box.group(1))
        rect = re.search(r'<rect[^>]*fill="(#[0-9A-Fa-f]{6})"', text)
        self.background = hex_rgb(rect.group(1))
        self.radius = float(re.search(r'<rect[^>]*rx="([\d.]+)"', text).group(1))
        t = re.search(
            r'transform="translate\(([-\d.]+),([-\d.]+)\) scale\(([-\d.]+)\) '
            r'translate\(([-\d.]+),([-\d.]+)\)"',
            text,
        )
        tx1, ty1, k, tx2, ty2 = (float(v) for v in t.groups())
        self.paths = []  # (rgb, [polygon of (x, y) in viewBox space])
        for m in re.finditer(r'<path fill="(#[0-9A-Fa-f]{6})" d="([^"]+)"', text):
            polygon = flatten(m.group(2))
            polygon = [((x + tx2) * k + tx1, (y + ty2) * k + ty1) for x, y in polygon]
            self.paths.append((hex_rgb(m.group(1)), polygon))
        if len(self.paths) != 3:
            raise SystemExit("unexpected SVG: expected the three stones of the cairn")


class BrandSource:
    """The three stones of the web icon (housecairn-icon.svg, no background), as drawn."""

    def __init__(self, text):
        self.size = float(re.search(r'viewBox="0 0 (\d+) (\d+)"', text).group(1))
        self.paths = [
            (hex_rgb(m.group(1)), flatten(m.group(2)))
            for m in re.finditer(r'<path fill="(#[0-9A-Fa-f]{6})" d="([^"]+)"', text)
        ]
        if len(self.paths) != 3:
            raise SystemExit("unexpected SVG: expected the three stones of the cairn")


def flatten(d):
    """Polygon of a path made of absolute M, C and Z commands."""
    tokens = re.findall(r"[MCZ]|-?\d+(?:\.\d+)?", d)
    points, i, current = [], 0, None
    while i < len(tokens):
        cmd = tokens[i]
        i += 1
        if cmd == "M":
            current = (float(tokens[i]), float(tokens[i + 1]))
            i += 2
            points.append(current)
        elif cmd == "C":
            while i < len(tokens) and tokens[i] not in "MCZ":
                c = [float(v) for v in tokens[i : i + 6]]
                i += 6
                p0, p1, p2, p3 = current, (c[0], c[1]), (c[2], c[3]), (c[4], c[5])
                for s in range(1, 33):
                    u = s / 32
                    a, b, cc, e = (1 - u) ** 3, 3 * (1 - u) ** 2 * u, 3 * (1 - u) * u**2, u**3
                    points.append(
                        (
                            a * p0[0] + b * p1[0] + cc * p2[0] + e * p3[0],
                            a * p0[1] + b * p1[1] + cc * p2[1] + e * p3[1],
                        )
                    )
                current = p3
        elif cmd == "Z":
            pass
        else:
            raise SystemExit(f"unsupported path command {cmd}")
    return points


# --- Rasteriser -----------------------------------------------------------------------


class Canvas:
    """RGBA float canvas; shapes are composited in order with their coverage."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[[0.0, 0.0, 0.0, 0.0] for _ in range(w)] for _ in range(h)]

    def fill(self, polygon, rgb, scale, ox, oy):
        """Fill `polygon` (viewBox space) mapped by x*scale+ox, y*scale+oy (non-zero rule is
        equal to even-odd for these simple closed shapes)."""
        pts = [(x * scale + ox, y * scale + oy) for x, y in polygon]
        self._coverage(pts, lambda y, x, cov: self._blend(y, x, rgb, cov))

    def fill_rounded_rect(self, rgb, size, radius, scale, ox, oy):
        pts = []
        r = radius
        corners = [(size - r, r, -90), (size - r, size - r, 0), (r, size - r, 90), (r, r, 180)]
        for cx, cy, start in corners:
            for s in range(0, 33):
                a = math.radians(start + 90 * s / 32)
                pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
        self.fill(pts, rgb, scale, ox, oy)

    def fill_all(self, rgb):
        for y in range(self.h):
            for x in range(self.w):
                self._blend(y, x, rgb, 1.0)

    def _blend(self, y, x, rgb, cov):
        p = self.px[y][x]
        a = cov
        out_a = a + p[3] * (1 - a)
        if out_a <= 0:
            return
        for c in range(3):
            p[c] = (rgb[c] * a + p[c] * p[3] * (1 - a)) / out_a
        p[3] = out_a

    def _coverage(self, pts, emit):
        n = len(pts)
        ys = [p[1] for p in pts]
        y0 = max(0, int(min(ys)))
        y1 = min(self.h - 1, int(max(ys)))
        edges = []
        for i in range(n):
            (xa, ya), (xb, yb) = pts[i], pts[(i + 1) % n]
            if ya != yb:
                edges.append((xa, ya, xb, yb) if ya < yb else (xb, yb, xa, ya))
        for y in range(y0, y1 + 1):
            row = [0.0] * self.w
            for sy in range(SS):
                sample = y + (sy + 0.5) / SS
                xs = sorted(
                    xa + (sample - ya) * (xb - xa) / (yb - ya)
                    for xa, ya, xb, yb in edges
                    if ya <= sample < yb
                )
                for j in range(0, len(xs) - 1, 2):
                    left, right = xs[j], xs[j + 1]
                    # horizontal coverage by sub-samples
                    xi0 = max(0, int(left))
                    xi1 = min(self.w - 1, int(right))
                    for x in range(xi0, xi1 + 1):
                        lo, hi = max(left, x), min(right, x + 1)
                        if hi > lo:
                            row[x] += (hi - lo) / SS
            for x in range(self.w):
                if row[x] > 0:
                    emit(y, x, min(1.0, row[x]))

    def rgba8(self):
        out = []
        for row in self.px:
            line = []
            for r, g, b, a in row:
                if a <= 0:
                    line.append((0, 0, 0, 0))
                else:
                    line.append((round(r), round(g), round(b), round(a * 255)))
            out.append(line)
        return out


# --- Icons ----------------------------------------------------------------------------


def render(src, pixels, kind):
    """kind: 'square' (iOS, opaque), 'rounded' (legacy Android), 'foreground', 'mono'."""
    c = Canvas(pixels, pixels)
    scale = pixels / src.size
    if kind == "square":
        c.fill_all(src.background)
    elif kind == "rounded":
        c.fill_rounded_rect(src.background, src.size, src.radius, scale, 0, 0)
    for rgb, polygon in src.paths if kind != "mono" else [((0, 0, 0), p) for _, p in src.paths]:
        c.fill(polygon, rgb, scale, 0, 0)
    return c.rgba8()


def render_brand(brand, pixels):
    """The web icon on a transparent background, for the bar of the app."""
    c = Canvas(pixels, pixels)
    for rgb, polygon in brand.paths:
        c.fill(polygon, rgb, pixels / brand.size, 0, 0)
    return c.rgba8()


def check_safe_zone(src):
    """The cairn, mapped on the 108 dp canvas as the SVG on its 256 box, stays in 66 dp."""
    k = CANVAS_DP / src.size
    worst = max(
        ((x - src.size / 2) ** 2 + (y - src.size / 2) ** 2) ** 0.5 * k
        for _, polygon in src.paths
        for x, y in polygon
    )
    if worst > SAFE_DIAMETER_DP / 2:
        raise SystemExit(
            f"the cairn leaves the Android safe zone: {worst:.1f} dp from the centre, "
            f"limit {SAFE_DIAMETER_DP / 2:.0f} dp"
        )
    return worst


def png(pixels, alpha):
    """Deterministic PNG: RGBA (color type 6) or RGB (color type 2, no alpha, no tRNS)."""
    h, w = len(pixels), len(pixels[0])
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for p in row:
            raw.extend(p if alpha else p[:3])

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    header = struct.pack(">IIBBBBB", w, h, 8, 6 if alpha else 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )


def decode(data):
    """(width, height, colour type, rows of pixel bytes) of a PNG made by png()."""
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, w = 8, b"", None
    while pos < len(data):
        n = struct.unpack(">I", data[pos : pos + 4])[0]
        tag, body = data[pos + 4 : pos + 8], data[pos + 8 : pos + 8 + n]
        if tag == b"IHDR":
            w, h, depth, ctype = struct.unpack(">IIBB", body[:10])
        elif tag == b"IDAT":
            idat += body
        pos += 12 + n
    raw = zlib.decompress(idat)
    bpp = 4 if ctype == 6 else 3
    stride = 1 + w * bpp
    rows = []
    for y in range(h):
        if raw[y * stride] != 0:
            raise SystemExit("PNG with a filter other than none: not made by this script")
        rows.append(raw[y * stride + 1 : (y + 1) * stride])
    return w, h, ctype, rows


def targets(src):
    """Every generated file: relative path -> (bytes of a fresh render)."""
    cache = {}

    def get(pixels, kind):
        key = (pixels, kind)
        if key not in cache:
            cache[key] = render(src, pixels, kind)
        return cache[key]

    out = {}
    contents = json.loads((IOS / "Contents.json").read_text())
    for image in contents["images"]:
        side = round(float(image["size"].split("x")[0]) * int(image["scale"][:-1]))
        out[IOS / image["filename"]] = png(get(side, "square"), alpha=False)
    for density, factor in DENSITIES.items():
        legacy = round(48 * factor)
        layer = round(CANVAS_DP * factor)
        out[RES / f"mipmap-{density}/ic_launcher.png"] = png(get(legacy, "rounded"), alpha=True)
        out[RES / f"drawable-{density}/ic_launcher_foreground.png"] = png(get(layer, "foreground"), True)
        out[RES / f"drawable-{density}/ic_launcher_monochrome.png"] = png(get(layer, "mono"), True)
    # The icon of the bar, flutter_svg not being a dependency (docs/adr/0001): the PNG at the
    # logical size of layout.logo-icon, then @2x and @3x in the folders Flutter resolves.
    brand = BrandSource(BRAND_SVG.read_text())
    for folder, factor in (("", 1), ("2.0x/", 2), ("3.0x/", 3)):
        out[BRAND_DIR / f"{folder}housecairn-icon.png"] = png(
            render_brand(brand, LOGO_ICON_DP * factor), alpha=True
        )
    return out


def text_files(src):
    colour = "#%02X%02X%02X" % src.background
    tokens = json.loads(TOKENS.read_text())["color"]["slate"].upper()
    if tokens != colour:
        raise SystemExit(f"SVG background {colour} differs from the slate token {tokens}")
    return {
        RES / "mipmap-anydpi-v26/ic_launcher.xml": (
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@drawable/ic_launcher_foreground"/>\n'
            '    <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>\n'
            "</adaptive-icon>\n"
        ).encode(),
        RES / "values/ic_launcher_background.xml": (
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            f'    <color name="ic_launcher_background">{colour}</color>\n'
            "</resources>\n"
        ).encode(),
    }


# --- Preview --------------------------------------------------------------------------


def preview(src, path):
    sizes = [120, 60, 32]
    pad = 16
    width = pad + sum(s + pad for s in sizes)
    rows = [("ios", "square"), ("android", "adaptive")]
    height = pad + len(rows) * (sizes[0] + pad)
    sheet = Canvas(width, height)
    sheet.fill_all((247, 245, 241))
    for r, (platform, _) in enumerate(rows):
        x = pad
        y = pad + r * (sizes[0] + pad)
        for s in sizes:
            if platform == "ios":
                tile = render(src, s, "square")
                radius = s * 0.2237
            else:
                big = round(s * 108 / 66)
                bg = Canvas(big, big)
                bg.fill_all(src.background)
                for rgb, poly in src.paths:
                    bg.fill(poly, rgb, big / src.size, 0, 0)
                tile = [row[(big - s) // 2 : (big - s) // 2 + s] for row in bg.rgba8()[(big - s) // 2 : (big - s) // 2 + s]]
                radius = s / 2
            for ty in range(s):
                for tx in range(s):
                    cx, cy = min(tx + 0.5, s - tx - 0.5), min(ty + 0.5, s - ty - 0.5)
                    inside = True
                    if cx < radius and cy < radius:
                        inside = math.hypot(radius - cx, radius - cy) <= radius
                    if inside:
                        p = tile[ty][tx]
                        sheet.px[y + ty][x + tx] = [float(p[0]), float(p[1]), float(p[2]), 1.0]
            x += s + pad
    Path(path).write_bytes(png(sheet.rgba8(), alpha=False))


# --- Main -----------------------------------------------------------------------------


def main(argv):
    src = Source(SVG.read_text())
    worst = check_safe_zone(src)
    if "--preview" in argv:
        preview(src, argv[argv.index("--preview") + 1])
        print("preview written")
        return 0
    files = targets(src)
    files.update(text_files(src))
    if "--check" in argv:
        bad = []
        for path, fresh in files.items():
            if not path.exists():
                bad.append(f"missing: {path.relative_to(ROOT)}")
            elif path.suffix == ".png":
                a, b = decode(path.read_bytes()), decode(fresh)
                if a[:3] != b[:3] or a[3] != b[3]:
                    bad.append(f"differs: {path.relative_to(ROOT)}")
            elif path.read_bytes() != fresh:
                bad.append(f"differs: {path.relative_to(ROOT)}")
        for line in bad:
            print(line)
        print(f"{len(files)} generated files checked, {len(bad)} problem(s)")
        return 1 if bad else 0
    for path, data in files.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    print(f"{len(files)} files written; cairn at most {worst:.1f} dp from the centre (limit 33)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
