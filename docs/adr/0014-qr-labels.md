# 0014. QR labels on the phone: the web's opaque code, a sheet made on the phone, a scanner of our own

- Status: proposed. That QR labels are in v1, in the app, and work offline is the maintainer's
  decision of 2026-11-15; the rest is proposed here.
- Date: 2026-11-18
- Amends: [ADR 0010](0010-three-ways-to-use-the-app.md) (in the third way, the labels stay on
  the phone until a server carries them, below) and [ADR 0001](0001-flutter-stack-and-packages.md)
  (packages).
- Related: web ADR 0047 (QR labels and reports), web ADR 0085 (the label *photo* of an article as
  a file of the sync API), at the web release `v0.5.1`.

## Context

The web application prints stickers for a room, an item or a stock article (web ADR 0047,
`labels/`): an opaque code, a PDF of an A4 sheet of 3 by 8 labels or of a 62 mm roll, and a page
that the code opens for the members of the home. The maintainer decided on 2026-11-15: **QR
labels are in v1, in the app, and work offline**. The spec had left them out, since the web's
stickers hold the address of the instance.

What the app had before this record, read in the code: no QR label at all. The "labels" that
already sync with a server (lot 4d, [ADR 0013](0013-more-files-with-a-server.md), web ADR 0085)
are the **label photo of a stock article**, the field `stock.article.label`: a picture of the
packaging, not a sticker. Nothing of it is reused or changed here.

What the web gives at `v0.5.1`, read there: `labels.label` is not one of the entity types of the
sync API (`sync/reading.py`, `ENTITIES`), and the access of the app is accepted on the sync API
only (`apitokens/permissions.py`, `CredentialFitsView`), so the phone can neither read the
labels of a server nor ask `GET /api/v1/labels/resolve/<code>/`.

## Decision

**The model and the code of the web.** A table `labels` (schema 11) with the fields of
`labels.label`: `kind` (`room`, `item`, `article`), one reference of that kind, `code`,
`revoked_at`, and the columns of every row. The code is the web's: 16 random bytes of the secure
random of the phone, in the URL-safe base 64 alphabet without padding, 22 characters
(`secrets.token_urlsafe(16)`); it names nothing. It is unique in the table, revoked rows
included. An object has at most one active label; Regenerate revokes the label and makes another
for the same object in one transaction; Revoke keeps the row, so a printed code never opens
anything again. The rules of who may write are the web's: a home that is written (not archived,
not read only on a server), never the example home of the guide (web ADR 0084).

**What the QR code holds: the code, and nothing else.** No address of an instance, no name, no
id of the home or of the object: the 22 characters alone, at the web's level of error correction
(Q) with the 4 modules of white the standard asks for. A sticker of the phone says nothing to
whoever photographs it, and does not stop working when an instance moves.

**How it joins the stickers of the web.** The two kinds of sticker share one code and one table
of the web's shape:

- the scanner reads both: the code alone (a sticker of the phone) and the address of a sticker of
  the web, `<address of the instance>/l/<code>/`, of which it keeps the code only. The host is
  never read nor called;
- a code opens what **this phone** knows: an active label of one of its homes whose object
  exists. A code it does not know (a sticker of another phone, of the web, of a home that is not
  here), a revoked one and one whose object was deleted are each told in words;
- the web reads the code of a phone's sticker as it reads its own: its route
  `/l/<code>/` and `GET /api/v1/labels/resolve/<code>/` take the 22 characters, so a person of the
  web who has the row can open it by the code typed after `/l/`.

**Kept on the phone, in every way, until a server carries them.** The rows of `labels` are
written without `field_clock` and without an operation in `op_log`, and are not in the types of
the sync layer (`entityOf`, `homeTables`): sent to a server of `v0.5.1`, an operation of
`labels.label` would be refused as `unknown_type`. They are erased with their home, as `step_ticks`
are. In the third way this is an exception to "everything is on the server" of
[ADR 0010](0010-three-ways-to-use-the-app.md): the labels of the server's homes stay on the phone
that made them, and the server's own labels are not on the phone. For a sticker to open on every
phone and on the web, **the web needs**, in a lot of its own:

1. `labels.label` among the entity types of the sync API, with its fields as they are, `code`
   included, and the rule that a code is unique in the whole table;
2. the stickers it prints made readable by the app without the address (the code alone, or the
   address as today, which the app already reads).

When a server announces that type, the phone sends its labels and takes the server's, with the
merge rules of [ADR 0003](0003-sync-protocol.md) (a later lot); until then nothing of them leaves
the phone. With the relay (lots 5 to 7) they sync as any row, from the lot that adds them to the
types.

**The sheet, made on the phone.** The layouts of the web, with its numbers: an A4 sheet of 3 by 8
labels of 63.5 by 33.9 mm (margins 7.2 and 15.1 mm, a gap of 2.5 mm, a QR code of 27 mm) and a
62 mm roll, one label of 40 mm per page. A label shows the QR code, the name of the object in
bold (three lines at most) and where it is (the room of an item, the storage place of an
article; two lines). The text is set in Helvetica, one of the standard fonts of PDF: nothing is
embedded, nothing is fetched, and a character it has no glyph for prints as `?` (Windows
Latin-1, `printable` of the web). At most 200 labels per sheet. The PDF is written to the private
directory of the app, handed to the share sheet of the phone (print, save, send) and removed
right after; nothing is kept. From the list, a person who writes gets a label made for each
object ticked that has none; otherwise only the labels that exist are printed.

**The scanner, written once.** `CodeScannerScreen` shows the camera and closes with the first code
of the kinds it was given (`CodeFormat`: `qr`, `ean8`, `ean13`, `upcA`). The labels ask for `qr`;
the scan of products that follows asks for the three others with the same screen and the same
reader, with no rule of products here. Frames are read on the phone, in an isolate, by a pure
Dart port of ZXing; the tests run the same reader on QR codes and bars they draw. The camera
permission is asked when the scanner opens, never at the start of the app; refused, the screen
says so and where to allow it.

**Packages** (read on pub.dev on 2026-11-18; all older than the seven days of ADR 0001, all
accepted by `tool/check_licenses.dart`):

| Need | Package | Version, date | Publisher | License |
| --- | --- | --- | --- | --- |
| The camera's frames | camera (camera_android_camerax 0.7.6+1, camera_avfoundation 0.11.1, camera_platform_interface 2.15.0, camera_web 0.3.6) | 0.12.2, 2026-10-27 | flutter.dev | BSD-3-Clause |
| Reading QR, EAN-8, EAN-13 and UPC-A | zxing_lib (with charset 2.0.1, Apache-2.0) | 1.1.4, 2025-06-18 | shirne.com | Apache-2.0 |
| The matrix of the QR code | qr | 3.0.3, 2026-10-29 | kevmoo.com | BSD-3-Clause |
| The sheet as a PDF | pdf (with barcode, bidi, path_parsing) | 3.13.1, 2026-09-19 | nfet.net | Apache-2.0 |

- **No service of anyone else.** The camera plugin of flutter.dev uses CameraX of AndroidX
  (Apache-2.0, with Guava) on Android and AVFoundation on iOS; the reader is Dart. The plugin
  declares the microphone and the old storage permission for its videos: the app removes both
  from its manifest and records no sound.
- **`mobile_scanner`**, planned by ADR 0001 for the invitation, is **rejected**: on Android it
  reads codes with Google's ML Kit (`com.google.mlkit:barcode-scanning`, or the version of Play
  services), a closed library under Google's terms, which "send metrics about the performance and
  utilization of the APIs in your app to Google" (<https://developers.google.com/ml-kit/terms>). The invitation QR code of lot 5 uses this scanner instead.
- **`zxing_lib` has had no release in twelve months**, the rule of ADR 0001 "unless noted": it
  is noted here. It is a port of ZXing, whose QR and EAN readers have not changed in years, it
  is pure Dart (nothing to build, nothing native), and it is covered by the tests of the app on
  both kinds of code. `zxing2` (BSD-3-Clause) reads QR codes only. `flutter_zxing` (MIT, zxing-cpp)
  builds C++ on each platform and cannot run in the tests. Should `zxing_lib` need a
  replacement, it is behind `readCode`, one function.
- **`qr` stays at 3.0.3**: `pdf` depends on `barcode`, which asks for `qr` 3.
- **`pdf`** rather than writing PDF by hand (rule 1 of the project): it writes the standard
  fonts of PDF without embedding them, as ReportLab does on the web.

## Consequences

- A sticker printed by a phone opens only on that phone until the web carries `labels.label`;
  the message of an unknown code says it may come from another phone or from the web.
- The spec's line "QR labels left out of v1" is replaced; the plan gains lot 3f.
- The invitation of lot 5 uses `CodeScannerScreen` and not `mobile_scanner`; ADR 0001 is amended.
- The camera permission now covers two uses, photos and labels; the iOS text of the permission
  says both.
