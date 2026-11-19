# 0015. Barcode lookup: the code alone to the open databases, asked first when the phone is alone

- Status: proposed. That scanning the barcode of a stock item or an item fills it from open
  databases, alone too, is the maintainer's decision of 2026-11-15; the rest is proposed here.
- Date: 2026-11-19
- Amends: [ADR 0010](0010-three-ways-to-use-the-app.md) (the first way's "no network call,
  ever", below) and the rule "no network in `lib/`" of the [plan](../plan.md).
- Related: web ADR 0083 (barcode lookup), at the web release `v0.5.1`;
  [ADR 0014](0014-qr-labels.md) (the scanner).

## Context

The web application (web ADR 0083, `v0.5.1`) gives a stock item and an item a field `ean`: empty,
or 8, 12, 13 or 14 digits with a valid GS1 check digit, stored as typed once spaces and dashes are
taken out, compared as a GTIN-14. A scan asks Open Products Facts, then Open Food Facts, what the
code is; only the code leaves the server; the answer fills the **empty** fields of the form once
the person chooses *Use these values*; a photo found is re-encoded without EXIF and kept, only
where there is none, with its credit (`source`, `source_url`, `license`, `license_url`,
`author`), shown under it, since the photos are under CC BY-SA 3.0.

The maintainer decided on 2026-11-15 that the phone does the same, **alone too**. Until now the
first way had no network code at all ([ADR 0010](0010-three-ways-to-use-the-app.md), "Offline:
everything works; no network call, ever"; the plan: "nothing in `lib/` opens a socket or an HTTP
client"). This is the first network call of the phone alone.

What the app had before this record, read in the code: no `ean` on an item or an article. The web
already sends `ean` of `rooms.item` and `stock.article`, `attribution` of `rooms.photo` and
`label_attribution` of `stock.article` in its sync API (every concrete column of these models,
`sync/rows.py`), and a phone of the third way kept them **in `extra`** as fields it does not know.

What the web gives at `v0.5.1` for a phone of the third way, read there: the lookup has its API,
`POST /api/v1/homes/<home>/barcodes/lookup/`, `GET .../barcodes/<code>/` and
`GET .../barcodes/<code>/photo/` (`barcodes/api.py`), but those views do not set
`sync_api = True`, so the access of the app is refused there with `403`
`connection_outside_sync` (`apitokens/authentication.py`, `check_view`).

## Decision

### The field, as on the web

- `ean` on `items` and `articles`, `attribution` on `photos`, `label_attribution` on `articles`:
  schema 12, columns with a default (`''`, `{}`). The step `from11To12` moves the values a server
  sent before into their columns, out of `extra`; their clocks were kept when they came.
- The check is the web's (`lib/domain/gtin.dart`, from `barcodes/gtin.py`): the form refuses a
  wrong code with the web's sentence, the repository refuses it too (`Refusal.eanInvalid`).
- The credit is an object on the wire and JSON text on the phone, as a file reference is
  (`ServerTransport.objectFields`).
- The search of the stock and of Equipment finds a code by its digits, or by another form of the
  same product (a UPC-A and its EAN-13), as `_ean_match` of the web.

### The scan

- A *Scan* button under the field, on the form of an item and of a stock item, opens the scanner
  of [ADR 0014](0014-qr-labels.md) with EAN-8, EAN-13 and UPC-A. Typing the code by hand always
  works, and a typed code is **never** looked up: only a scan asks.
- What was found shows under the field (name, brand, model, category, photo with its credit),
  and only *Use these values* writes, in the empty fields only; a field that has a value keeps
  it. The category goes in the notes, as on the web. A photo is offered only when the record has
  none, and kept when the form is saved, re-encoded as any photo (upright, no metadata,
  `processPhoto`), with its credit.

### Alone: the code to the open databases, after a question

- **At the first scan**, before anything leaves the phone, a screen says what leaves (the code,
  nothing else; no name, no home, no account), to whom (Open Products Facts, then Open Food Facts;
  like any site, they see the address of the connection), and under which licences (the data
  under the ODbL, the photos under CC BY-SA 3.0, credited under the photo). *Allow the lookup* or
  *Keep only the code*; going back asks again at the next scan. Refused, nothing leaves and the
  scan fills only the code. The choice is kept in `local_settings` (`barcode_lookup`) and changed
  in More, Settings ("Online lookup of barcodes", the web's words).
- **One module** opens a connection: `lib/core/open_facts_http_io.dart`. `GET` only, `https`
  only, to `world.openproductsfacts.org`, `world.openfoodfacts.org` and the hosts of their photos
  (`images.openproductsfacts.org`, `images.openfoodfacts.org`); any other host or port is
  refused before the connection, and a redirect is not followed; no proxy, no cookie; 1 MB for
  an answer, 5 MB for a photo, 6 seconds a call. The address holds the code and the fields asked
  (the web's `fields`), nothing else. `test/ways_test.dart` tolerates this file and no other
  besides the server transport.
- **The headers sent are these five, and no other** (`test/open_facts_http_io_test.dart` reads
  them as they leave, on a local socket):
  - `user-agent: HouseCairnMobile (+https://github.com/HouseCairn/housecairn-mobile)`: the name
    of the app and where its code is, as the Open Food Facts project asks of every application;
    no version, no system, no device;
  - `accept`: `application/json` for an answer, `image/jpeg,image/png,image/webp` for a photo;
  - `accept-encoding: gzip` and `host`, set by `dart:io`'s client;
  - `connection: close`: one connection a call, none kept open.

  Nothing in them identifies the phone or the person.
- No connection: a calm sentence, the code is filled. Not found, or not read: the web's
  sentences.

### With a server: the server asks, never the phone

- The lookup goes through the server's own API (`ServerTransport.barcodeLookup`, the address
  typed, the access of the phone): the phone asks again every two seconds, twelve times at most,
  as the web's screen, then reads the photo the server kept. The phone never calls the open
  databases in the third way, whatever was chosen alone.
- A server that refuses the app there, as `v0.5.1` does (`connection_outside_sync`), is said
  plainly ("This server does not look codes up for the app yet"), and the code is kept. **Need of
  the web**: `sync_api = True` (or an equivalent opening for a connection with the scope `sync`)
  on the three views of `barcodes/api.py`; nothing changes on the phone then.
- The lookup off on the server: the web's sentence.

### Permissions

- **Android**: `android.permission.INTERNET` in the main manifest. Only the debug and profile
  manifests declared it before (read in the badging of the release build of CI), so a release
  build could reach neither a server nor the open databases. It is a normal permission, granted
  at install, with no prompt.
- **iOS**: nothing to declare for the network: the calls are HTTPS, which App Transport
  Security allows; no local network is asked. The camera was declared already, for the photos
  and the QR labels ([ADR 0014](0014-qr-labels.md)); its reason (`NSCameraUsageDescription`, in
  `Info.plist` and in `InfoPlist.strings`, English and French) now names the barcode of a
  product too: "Housecairn uses the camera to photograph a room or an item, and to read the QR
  code of a label or the barcode of a product. The photo stays on this phone."
- **Android**: the camera is the scanner's of ADR 0014, unchanged.

### What the first way says

The sentence of the first way, at the first start and in More ("Nothing is sent anywhere",
[ADR 0010](0010-three-ways-to-use-the-app.md)), is made exact, on the maintainer's decision:
"Your homes stay on this phone. Nothing leaves the phone, except a product's barcode to open
product databases when you allow it. You can turn on sharing later." In French: "Vos logements
restent sur ce téléphone. Rien ne quitte le téléphone, sauf le code-barres d'un produit vers des
bases de produits libres, si vous l'autorisez. Vous pourrez activer le partage plus tard."

## Options set aside

- **Looking a code up from the phone in the third way** when the server refuses: set aside by the
  maintainer's rule that with a server the lookup goes through it.
- **Looking up a code typed by hand**: not done, so that the network is only called at a scan,
  as decided; the web does the same at a scan.
- **An HTTP package** (`http`, `dio`): `dart:io`'s client is enough for one `GET`, and the test of
  the imports stays as it is.

## Consequences

- A phone alone that never scans, or refuses, still calls nobody.
- The release build of Android may now reach the network, for the third way as well.
- Once the web opens its lookup to a connection, the third way works without a new build.
