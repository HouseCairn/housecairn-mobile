# Brand files used by the app

| File | Use |
| --- | --- |
| `housecairn-icone-app.svg` | Application icon, copied unchanged from `design/brand/` of the [web repository](https://github.com/HouseCairn/housecairn) (its web ADR 0017 describes the identity). The single source of every app icon. |

Palette and tokens: `design/tokens.json` (slate `#1F3A3D` is the icon background).

The logo and the name are **not** covered by the AGPL-3.0 grant: see `NOTICE`.

## App icons

`tool/generate_icons.py` (Python standard library only) renders the iOS `AppIcon.appiconset`
and the Android icons from the SVG. Nothing is redrawn; three platform constraints apply:

- iOS: square, no rounded corners and no alpha channel (iOS draws its own mask; the App Store
  rejects a 1024 px icon with transparency).
- Android adaptive icon (API 26+): the slate colour as background layer, the cairn alone as
  foreground, at the scale of the SVG. Only the central 66 dp of the 108 dp canvas are always
  visible; the script fails if the cairn leaves them (it is at most 32.5 dp from the centre,
  limit 33 dp).
- Android themed icon (API 33+): the silhouette of the cairn, alpha only.
- Android before API 26: the rounded square of the SVG, as is.

```sh
python3 tool/generate_icons.py                      # write the 30 PNG and 2 XML files
python3 tool/generate_icons.py --check              # compare with the committed files
python3 tool/generate_icons.py --preview out.png    # contact sheet, 3 sizes, iOS and Android
python3 tool/test_generate_icons.py                 # tests run in CI
```
