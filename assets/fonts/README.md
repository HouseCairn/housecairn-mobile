# Fonts (bundled)

Manrope, the font of the web application (`design/tokens.json`, `font.family-base`), under the
SIL Open Font License 1.1. The app bundles it so that the text looks the same on every phone;
nothing is downloaded at run time.

Only the four weights the app draws are bundled (`HcFont.weights` in
`lib/design/tokens.dart`): regular 400, semibold 600, bold 700, extrabold 800. They are the
static files of the official repository of the font, unmodified (the web application serves a
variable subset of the same version, 4.505, which Flutter does not read). Source:
[googlefonts/manrope](https://github.com/googlefonts/manrope) at commit
`468c0dbe38efa331b80bfe9448256abe27be44c3`, directory `fonts/ttf/`; the licence is `OFL.txt`
of the same commit. Each file was checked against the git blob of that commit when it was
added.

| File | Weight | SHA-256 | Licence |
| --- | --- | --- | --- |
| `manrope-regular.ttf` | 400 | `d23d6eedf51dd495138aa1a83588027d4a63549cdfcc2fa5e0d8e84e09cf4cb1` | `Manrope-OFL.txt` |
| `manrope-semibold.ttf` | 600 | `f43edb46a08e1538413ea2383ef01ed93cdab191a2c57d2489d9590985858cf7` | `Manrope-OFL.txt` |
| `manrope-bold.ttf` | 700 | `484d10f0683e9e9f588de978f70cd3ad17cb3522bc0ca6efc4491c83429d323c` | `Manrope-OFL.txt` |
| `manrope-extrabold.ttf` | 800 | `c5c0faa3c3a1b1a184f6bb2e405931bdbf51d21c72d8162309118e91304988e0` | `Manrope-OFL.txt` |

`dart run tool/check_licenses.dart` fails when a font file of this directory is not in this
table, when its SHA-256 differs, or when its licence file is missing or not allowed
(`tool/licenses/allowed-licenses.txt`). The About screen lists the licence with those of the
packages.
