# 0010. Three ways to use the app: alone, family sync through the relay, a Housecairn server

- Status: accepted. The three ways and their order of arrival are the maintainer's decision of
  2026-11-14, and so are the answers to the questions this record raised (questions 4 to 14,
  same day), written in [Decisions of the maintainer](#decisions-of-the-maintainer-2026-11-14).
  What each way guarantees, the moves between them and the architecture were proposed here and
  are accepted with them. The rules of the third way that the web decided with the maintainer
  on 2026-11-14 (web ADR 0077 to 0079,
  [HouseCairn/housecairn#140](https://github.com/HouseCairn/housecairn/pull/140)) are in
  [The third way, as the web decided it](#the-third-way-as-the-web-decided-it) and in
  [protocol section 2.10](../protocol.md#210-with-a-housecairn-server).
- Date: 2026-11-14
- Amends: [ADR 0003](0003-sync-protocol.md) and [ADR 0005](0005-relay-server.md), which left
  "a Housecairn instance acting as the relay" for after v1. That idea is replaced by the third
  way below, which means something else: the server reads the data.

## Context

Until now the app had one way to work, alone on the phone, and one way to share, the family
space on an end-to-end encrypted relay (lots 4 to 7). People who already run Housecairn, as the
self-hosted web application or as the Home Assistant add-on, want the phone and the web to show
the same homes: what is typed on the phone appears on the web, and the other way round. The
relay cannot do that by design: it never sees a clear text, and the web application can only
work on clear text (pages, reminders, calendar feeds, budget, search, Home Assistant).

The maintainer decided on 2026-11-14:

- at the first start, the app offers **three ways to use it**:
  1. **Alone on this phone**: the default, local data, what the app does today;
  2. **Family sync through the hosted relay**, with a subscription (lots 4 to 7 of the
     [plan](../plan.md));
  3. **My Housecairn server**: the address of an instance (the Home Assistant add-on or the
     self-hosted web application) and a sign-in to it (OAuth 2 with PKCE, decided below; the
     first wording of the decision said an API token). The data is **shared with
     the server**: what is typed on the phone appears in the web application and the other way
     round; the server reads the data, it is not an end-to-end encrypted relay;
- the screen and the architecture are **planned now**, and each way is plugged in when its lot
  arrives.

References `file:line` to the web application are to `src/housecairn/` of
`HouseCairn/housecairn` at commit `254f889` (`main` on 2026-11-14, release `v0.3.1` and 8
commits), not at the commit `a6953f3` of the other records: the API was read for this record.

## Decision

### Decisions of the maintainer (2026-11-14)

The maintainer answered the open questions of this record the same day. The sections below
are written with these answers; this list is the short form, and wins over any older wording.

- **One way at a time, and everything on the server (questions 4 and 11).** A phone is in
  one way at a time: alone, on the relay, or on a server. In the third way **everything is on
  the server**: no mix of homes kept on the phone and homes on the server, and no relay in
  addition. In v1, going to the third way while both the phone and the server hold data
  forces an explicit choice: **keep the phone's homes or keep the server's**. Merging the two
  comes after v1.
- **The access and the homes (questions 5 and 7).** The access covers **the homes chosen at
  the sign-in**. The phone **may create new homes** on the server, under a right of the access
  made for that (see [the web needs](#what-the-web-api-lacks-for-the-third-way), need 8).
- **Sign-in (question 6).** **OAuth 2 with PKCE in the browser**, as web ADR 0007 planned for
  the mobile app. The access is **revocable per device**. There is **no API token to copy**
  and paste.
- **Network (question 8).** HTTPS everywhere. `http://` only towards a local address, with a
  clear warning. "Local" is the rule of web ADR 0078, written once and applied by both sides
  ([protocol section 2.10](../protocol.md#210-with-a-housecairn-server)): an IP literal that
  is not a public address; **a name, `.local` included, needs HTTPS**, since a `.local` answer
  can be forged by anyone on the network. The Home Assistant add-on will **open a port of its
  own** for the app, since its Ingress needs a Home Assistant sign-in, with HTTPS on it as an
  option (the certificate Home Assistant keeps in `/ssl`); that change is made in the add-on,
  not here.
- **Business model (question 9).** The app is free, with the first way complete. The hosted
  relay is a subscription. **The third way is unlocked by a single in-app purchase.** This is
  the principle only: no price here, and nothing about store accounts. The AGPL licence
  ([ADR 0007](0007-license.md)) lets anyone build the app without that lock; the maintainer
  accepts it.
- **Order (question 10).** The third way (lot 4b) is **required before the public beta
  (lot 8)**.
- **Archiving (question 12).** Archiving a home will be **added to the web** (`archived_at`),
  so the third way does not hide it. On a server, **only the owners** of a home archive it, as
  on the web; the app offers it to owners only in the third way, and the server refuses it
  from anyone else (`forbidden`).
- **Members (question 13).** The phone always stands for **the signed-in account**. Its
  reminders cover **its tasks and those with no assignee**.
- **The web lot (question 14).** The lot of the web application for the sync API **starts
  now**, in parallel with the mobile lots, as a card of its own in the web repository. Lot 4b
  depends on it.

### The three ways, and what each guarantees

| | 1. Alone on this phone | 2. Family sync (relay) | 3. My Housecairn server |
| --- | --- | --- | --- |
| Where the data is | On this phone only; in the encrypted export files the person makes ([spec](../spec.md#export-and-import)) | On every phone of the family; on the relay as ciphertext (batches, snapshots, blobs) | On this phone and **on the server, in clear**: its database, its files and its backups |
| Who can read it | Whoever can unlock this phone | The phones of the family; **not** the relay, which sees only the metadata of the [threat model](../threat-model.md) | The phone; **the server**: whoever administers the instance or its host, every account that is a member of these homes on it, the integrations that hold a token of these homes, and anyone who gets a backup of the server |
| Who decides a conflict | No conflict | Each phone, by the same merge rules ([ADR 0003](0003-sync-protocol.md)) | The same field rules, applied by the server, which keeps the order ([Architecture](#architecture-one-sync-layer-two-transports)) |
| Offline | Everything works; no network call, ever (*amended by [ADR 0015](0015-barcode-lookup.md)*: a scanned barcode, once the person allowed it) | Everything works; changes are sent and merged when the relay is reachable | Everything works on the copy of the phone; changes wait in the log and are sent when the server is reachable; edits made on the web meanwhile arrive then |
| Network peers | None; with [ADR 0015](0015-barcode-lookup.md), Open Products Facts and Open Food Facts at a scan the person allowed | The relay the person chose, and the push services | The server the person typed, and nothing else (no push in v1: the phone syncs when opened and in the background) |
| Account | None | None (device keys, [ADR 0004](0004-encryption-and-family-keys.md)) | The account of the server that the person signed in with |
| Cost | Free | Subscription for the hosted relay; free on a self-hosted relay ([ADR 0006](0006-subscription.md)) | No subscription, since the publisher's relay is not used; a **single in-app purchase unlocks** the way ([business model](#business-model)) |

**One way at a time per phone.** A phone is alone, or in a family on a relay, or connected to
one server, and in the third way **all its homes are on the server**. Mixing them (a phone on
a server that also joins a family on the relay, or homes of one phone split between local and
server) is not offered: the maintainer decided it so, not only for v1.

*Amended by [ADR 0015](0015-barcode-lookup.md), on the maintainer's decision of 2026-11-15:*
scanning the barcode of a stock item or an item fills it from open databases, alone too. This is
the first network call of the first way, and a narrow one: one module
(`lib/core/open_facts_http_io.dart`) sends the scanned code, and nothing else, to Open Products
Facts then Open Food Facts, only at a scan, and only once the person allowed it at their first
scan (changed in Settings); refused or offline, the scan fills only the code. With a server, the
lookup goes through the server, never from the phone.

*Amended by [ADR 0014](0014-qr-labels.md):* the QR labels of the homes of a server stay on the
phone that made them, since the sync API of the web (`v0.5.1`) does not carry `labels.label`;
they join the server once it does. Nothing else of a home of a server is kept on the phone
alone.

### Business model

The principle, decided on 2026-11-14; it sets no price and says nothing of store accounts.

- The app is **free**, and the first way is **complete** in it.
- The hosted relay (second way) is a **subscription** ([ADR 0006](0006-subscription.md)).
- The third way is **unlocked by a single in-app purchase**.
- The licence is AGPL ([ADR 0007](0007-license.md)): anyone may build the app from the source
  without that lock. The maintainer accepts this; the purchase pays for convenience and for
  the maintenance, it does not stop anyone.

### Why the third way is not end-to-end encrypted

The point of the third way is that the web application shows and works on the phone's data:
pages, the today list, reminders by Apprise and web push, calendar feeds, budget figures,
search, the Home Assistant blueprints and, later, Paperless-ngx and Sure. Each of these reads
clear text on the server. Encrypting end to end would leave the web with ciphertext it cannot
show, so it would be the relay again, under another name. The trust therefore moves: in the
second way the person trusts no server; in the third, the person trusts **the operator of the
server** with everything, as they already do when they use its web pages. On a server the
household runs itself, that operator is the household.

What the app still guarantees in the third way:

- **HTTPS**, with the system's certificate checks; the app never offers to skip them. The one
  exception is `http://` towards a **local address** (an IP literal that is not public, by the
  rule of [protocol section 2.10](../protocol.md#210-with-a-housecairn-server); never a name,
  not even `.local`), shown with a clear warning that the traffic can be read on that network;
- the **credential of the sign-in is kept in the Keychain or the Android Keystore** (`Store`,
  [ADR 0002](0002-local-storage-and-migrations.md)), never in the database, never in an
  export, never in a log;
- the app sends to the server nothing but the homes the access covers, and calls no other
  address;
- disconnecting deletes the credential from the phone at once, and the access can be revoked
  on the server, per device.

### What the screen says

The first-start screen shows the three ways as three choices of equal weight, the first one
selected. A way whose lot is not merged yet is **shown, disabled, with "Coming later"**; it
opens nothing, asks nothing and calls no network. The texts below are the intent; the exact
strings go in the ARB files with the lot that builds the screen.

- **Alone on this phone**: "Your homes stay on this phone. Nothing is sent anywhere. You can
  turn on sharing later." Since [ADR 0015](0015-barcode-lookup.md): "Your homes stay on this
  phone. Nothing leaves the phone, except a product's barcode to open product databases when
  you allow it. You can turn on sharing later."
- **Family sync**: "Share your homes with the phones of your family. Everything is encrypted
  on your phones before it leaves them: our server cannot read it. Needs a subscription."
- **My Housecairn server**: "Use the homes of your own Housecairn, the web application or the
  Home Assistant add-on. **Your server stores your homes and can read them**, like its web
  pages do. Everything of this phone is kept on the server; a one-time purchase unlocks it."

Choosing the third way leads to a second screen, the server's address, then the sign-in in the
browser (OAuth 2 with PKCE) where the person picks the homes the access covers, then a
confirmation before anything is sent or received, which names the server and lists what it
gets:

> **This server will see everything in these homes**: tasks, rooms, notes, amounts and
> photos. So can the people who run it, the people who are members of these homes on it, and
> its backups. Continue only with a server you trust.

The same sentence is shown in Settings for as long as the phone is connected, next to the
server's address. A phone that was started before the screen existed (TestFlight builds of
lot 2) is in the first way, and never sees the first-start screen; Settings offers the same
choices.

### Moving from one way to another

| From → to | v1 | How |
| --- | --- | --- |
| Alone → family sync | **Yes** | Turning sync on creates the space; every home of the phone becomes its first snapshot ([ADR 0004](0004-encryption-and-family-keys.md), lot 5). Nothing to choose: the space is new and empty. |
| Alone → my server, **keep this phone's homes** | **Yes, into homes that are empty on the server** | The phone uploads every row and file of the homes it sends, with its own ids, then syncs. The phone creates the homes the server does not have yet, under the right of its access ([what the web lacks](#what-the-web-api-lacks-for-the-third-way)). |
| Alone → my server, **keep the server's homes** | **Yes** | The phone downloads the homes the access covers. Its local homes are not merged: the app offers an encrypted export first, then removes them from the phone, after the person types "remove" (the same care as deleting a home, [spec](../spec.md#homes)). |
| Alone → my server, data on both sides | **Yes, with an explicit choice** | The app makes the person **choose** between keeping the phone's homes and keeping the server's (the two rows above), never a silent merge. |
| Alone → my server, both sides not empty, **merge** | No, after v1 | Two histories of the same house, written without common ids, cannot be merged field by field; matching rooms and tasks by name is a guess. The merge comes after v1. |
| Family sync → alone | **Yes** | Leaving the family, or being removed: the phone keeps what it had, as a removed member does ([ADR 0004](0004-encryption-and-family-keys.md)); its keys of the space are deleted. |
| My server → alone | **Yes** | Disconnect: changes not yet sent are listed and sent first when the server is reachable, or dropped after a confirmation that names them; the credential is deleted; the phone keeps a local copy of the homes as they were at the last sync, which no longer syncs. |
| Family sync ↔ my server, directly | No, after v1 (maintainer's decision) | In v1 a phone goes through the first way: leave the family, then connect to the server and send its homes into empty homes there (or the reverse). A direct move would have to decide what the other members of the family get, which is the maintainer's call. |
| A phone in two ways at once | No | Decided by the maintainer: one way at a time, no relay next to a server, no local homes next to server homes. |

Whatever the move, nothing is erased from the phone without a confirmation, and an export is
offered before any removal.

## Architecture: one sync layer, two transports

```
screens
  │
Repository            lib/data/repository.dart: rows, field_clock, ids made on the phone,
  │                   op_log (lot 4); the same for the three ways
SyncEngine            lot 4: outgoing operations from op_log, incoming ones applied by the
  │                   field rules of ADR 0003, repair rules, purge of a home, sv / extra / pending
SyncTransport         lot 2c: the interface below, nothing else knows the network
  ├── RelayTransport  lots 5 and 6: sealed batches, snapshots, blobs, membership log,
  │                   device keys
  └── ServerTransport lot 4b: the same operations in clear, over HTTPS, to the sync API of a
                      Housecairn server, with the access from Store
```

**What is shared by the second and third ways**, and written once: the operation of
[protocol.md](../protocol.md#22-operations) section 2.2 (`t`, `h`, `id`, `k`, `c`, `f`, field
names of the web model), the hybrid logical clock, the merge rule per kind of field, the
deterministic ids (`uuid5(home, "next:" + occurrence)` and the others of ADR 0003), the repair
rules, the rules of schema versions, the "not synced" state of a file. The local database is the
one of lot 2a: `field_clock` is already written on every change and every id is made on the
phone, so neither way needs a migration of the data to start.

**`SyncTransport`**, the only seam (Dart, `lib/sync/transport.dart`):

| Member | Relay | Server |
| --- | --- | --- |
| `capabilities()` | `GET /v1/info` | the server's version and sync capabilities |
| `push(operations)` | one sealed batch | one request applied as a whole; the answer gives, for each field that lost, the value that won |
| `pull(after: cursor)` | batches after `pos`; "start again" on 410, from the snapshot | changes after the server's `pos`; on 410, the server's snapshot and the reconciliation rule of [protocol section 2.10](../protocol.md#210-with-a-housecairn-server), by the mark "seen by the server" |
| `putFile`, `getFile`, `deleteFile` | blobs, encrypted with their own key | the files of the server's photos and attachments, in clear: `PUT` and `GET` of `/files/{id}` of a home, with the digest in `HC-Sha256`; no route to delete ([ADR 0012](0012-files-with-a-server.md)) |
| `homesGone()` | `purge` records of the membership log | homes deleted on the server, or no longer covered by the access |

Members, invitations, epochs and the recovery code exist only with the relay: they stay outside
the interface (lot 5). With a server, the members are the server's accounts of each home, read
only on the phone.

**Who orders the changes.** With the relay, the phones: the merge is a pure function of the
operations, the same on each. With a server, the server applies the same field rule as it
receives the operations, keeps the result, and gives it back in its own order, with its cursor;
the phone applies what it pulls with the same code as a batch of the relay. An edit made on the
web gets a clock from the server, with a device id of the server, so that it is compared as any
other.

**The way of the phone** is a row of `local_settings` (schema 2, key and value, never synced):
`sync_mode` = `alone`, `relay` or `server`, absent meaning `alone`; the server's address in the
same table; the credential of the access in `Store`. No migration.

**Files.** The file reference of protocol section 2.9 names a blob and its key. With a server it
names a file of the server, in the form web ADR 0077 decided and
[protocol section 2.10](../protocol.md#210-with-a-housecairn-server) states: a UUID made by the
phone, the SHA-256 of the bytes, no key. A photo is re-encoded on the phone before anything
else in every way ([spec](../spec.md#photos-and-files)); a server that re-encodes again keeps its
own copy, and the phone keeps its own.

### The third way, as the web decided it

Web ADR 0077 to 0079 ([HouseCairn/housecairn#140](https://github.com/HouseCairn/housecairn/pull/140))
answer the needs listed below, with decisions of the maintainer of 2026-11-14 that change what
the app does in the third way. They are written in
[protocol section 2.10](../protocol.md#210-with-a-housecairn-server); in short:

- **Deletions are kept 400 days** on the server, not forever as on the relay. A phone away
  longer starts again from the server's snapshot and reconciles each row by a mark "seen by
  the server" that it keeps per row: a row the server saw and the snapshot lacks is deleted,
  a row the server never saw is sent again, waiting changes are pushed and decided field by
  field. The promise of [ADR 0003](0003-sync-protocol.md) that nobody resurrects what others
  deleted holds with that rule.
- **The server keeps the fields it does not know** and gives them to the other phones, as every
  receiver of the protocol must.
- **The server writes as a device** with an id of 16 bytes, given by `info` as `server_device`,
  so ties of clocks are broken the same way on both sides.
- **Row ids are unique on the server**: a phone never gives one id to two rows, in two homes
  or two types (`id_taken` otherwise).
- **Only owners archive** a home (above).
- **`http://` only to a local IP literal**, by the web's rule (above).
- The words of the transport: `pos` is the server's cursor, `push` numbers a push to the
  server, `seq` stays the relay's number of a device's batches.

## What the web API lacks for the third way

Read in `src/housecairn/` at `254f889`. The web planned for it: "an offline client needs to know
what changed and what was deleted since its last sync" (web ADR 0005), "an iOS app installed
months ago must keep working against a newer server" (web ADR 0004, `/api/v1/` only gets
additive changes). These are needs, not a design of the web: the web lot decides how.

1. **Ids made by the client.** `BaseModel.id` is a random UUID with `editable=False`
   (`core/models.py:35`), and the serializers make `id` read only (`rooms/api.py:142`, `:280`,
   `tasks/api/tasks.py:151`, `tasks/api/contractors.py:55`, `tasks/api/materials.py:63`,
   `homes/api.py:86`). Needed: creating a row with the id the phone gave it, and a repeated
   request with the same id and content answering as the first one (a phone retries after a cut
   connection).
2. **The same deterministic ids on the server.** The server makes the next occurrence with a
   random id (`tasks/services.py:503-516`, `_spawn_next`), the phone with
   `uuid5(home, "next:" + occurrence)` (ADR 0003). When the web and a phone close the same
   occurrence, two successors appear. The same holds for material lines and draws, the annual
   envelope and the link rows of ADR 0003.
3. **Changes since a cursor.** Lists page by a cursor on `-created_at`, `-id`
   (`core/pagination.py:4-9`, web ADR 0004): new rows, not changed ones. `updated_at` is set by
   the server's clock (`core/models.py:36-37`) and is not a safe cursor: two transactions can
   commit out of the order of their times, and a phone that read up to an instant misses the
   earlier one. Needed: a change sequence given by the server, per home, and one feed of every
   entity type of a home in that order.
4. **Deletions visible.** The default manager hides deleted rows (`core/models.py:21-25`).
   `soft_delete()` on a queryset writes `deleted_at` without `updated_at`
   (`core/models.py:17-18`), as deleting a task does for its occurrences and attachments
   (`tasks/services.py:476-484`) and deleting a project for its lines, quotes and files
   (`projects/services.py:417-425`). Some deletions leave nothing: the successor removed by an
   undo (`tasks/services.py:634`), a task detached from a project (`projects/services.py:422`,
   `:507`), a home erased with everything in it (`homes/services.py:220-233`). Needed: every
   deletion in the feed as a tombstone, a home's erasure as one event (the phone erases it as a
   purge), and no purge of old deleted rows without a rule for how long tombstones stay (web
   ADR 0005 leaves that purge undecided).
5. **Conflicts decided per field, not per request.** A `PATCH` writes what it receives, without
   `If-Match` or a version (`ETag` exists only on the calendar feeds,
   `calendar/views.py:329-335`); a row keeps one `updated_at` for all its fields. A phone
   offline for a day would overwrite the web's edits of the same row, field by field or not.
   Needed: a clock per field (the `field_clock` of the phone), or at least the version each
   change was based on, so that the server applies the rule of ADR 0003 and tells the phone
   which value won; the losing long text returned, so that the phone keeps it as "other version".
6. **Rules across rows repaired, not refused.** The database refuses a second open occurrence of
   a task (`tasks/models.py:357-361`), a second material line per article (`:310-314`), a
   second draw per article and occurrence (`:394-398`); undo is refused once the successor was
   changed (`tasks/services.py:617-634`). A phone that closed the occurrence offline while the
   web postponed it sends a state the database refuses. Needed: the repair rules of ADR 0003
   applied by the server, the same as on the phones.
7. **Writes as data, besides actions.** Done, skip, postpone and undo are actions with effects on
   the server (`tasks/api/occurrences.py:370-425`: successor, stock draws), while the phone has
   already computed and written those effects as fields. Needed: either the sync API accepts the
   resulting fields and the server checks them, or it replays the action exactly once for an
   operation id.
8. **An access bound to homes, with the right to create a home.** A token is bound to existing
   homes of its user (`apitokens/models.py:17-37`, `homes/scoping.py:27-38`), which fits the
   third way. But a token may not create a home (`homes/api.py:169-171`) nor restore one
   (`homes/api.py:379-381`), so a phone cannot send a home the server does not have; tokens
   expire after 90 days by default (web ADR 0007) with no renewal by the token itself; scopes
   are only `read`, `write` and `events` (`apitokens/models.py:11-14`), so a token lent to the
   phone is the same as one lent to any integration. Decided: the sign-in is the OAuth 2 flow
   with PKCE that web ADR 0007 planned for "the iOS app" (`/o/`); the access is revocable per
   device, covers the homes chosen at the sign-in, and carries a **right to create homes**
   that the web must add. Token management by a person signed in stays as it is
   (`apitokens/permissions.py:74-80`).
9. **Fields the app has and the web does not.** A home has no `archived_at` on the web
   (`homes/models.py:31-58`; [protocol](../protocol.md#22-operations) section 2.2); assignee and
   `completed_by` are accounts (`tasks/models.py:187-194`), not members of a family. Needed:
   the field on the web (decided: archiving is added to the web); the members of a home in the
   feed, for assignment, the phone standing for the signed-in account.
10. **Files with the client's id.** Photos and attachments are uploaded as multipart with an id
    made by the server, then re-encoded (`rooms/api.py:474-500`, `rooms/images.py:75-101`,
    `tasks/api/attachments.py:153-160`); the same for the label of an article
    (`stock/models.py:119`), the photo of a report (`reports/models.py:72`) and project files
    (`projects/models.py:282`). Needed: upload with the id of the phone's row, repeatable
    without a duplicate, the size limit announced (`rooms/conf.py`, instance setting
    `file_max_bytes`), and the file and thumbnail readable by id as today
    (`rooms/api.py:520-531`).
    *As decided (web ADR 0077, built in lot 4c, [ADR 0012](0012-files-with-a-server.md)).* The
    upload is not multipart: it is the bytes as an octet-stream under the id of the phone, with
    the digest in the header `HC-Sha256`; the server answers `201` or `200` for the same bytes,
    and refuses with `400` `malformed`, `403`, `409` `file_conflict`, `413` `too_large` or
    `quota_exceeded`, `415`. A file no row refers to is removed by the server itself, so there is
    no route to delete one.
11. **Versions and limits announced.** Needed: one route that says the server's version, the
    sync API version and its limits (batch size, file size, rate), so that the app refuses a
    server too old in words, and keeps the fields it does not know (`extra`) as with the
    relay.

## Consequences

- The spec's principle "the only network peer is the relay the person chose" becomes "the relay
  or the server the person chose"; the web API is no longer out of scope of the app, only the
  management of accesses is, which stays on the web ([spec](../spec.md)).
- The first way stays complete on its own: an app that never leaves it has no network code
  running and no server to trust.
- The third way depends on work on the web repository. It cannot be built against the API of
  today: [what the web API lacks](#what-the-web-api-lacks-for-the-third-way) is the list for a
  lot of the web application, which the maintainer decides and which comes before the lot of
  the app.
- A family that wants both, the web for some members and phones for others, uses the third
  way for every phone; the second way is for families with no server. The two never mix.
- The app needs a purchase flow before the third way can be turned on ([business
  model](#business-model)), and the web needs the OAuth flow, the right to create homes and
  `archived_at`, in the lot that starts now.
- The Home Assistant add-on opens a port of its own for the app; that is a change in the
  add-on's repository, tracked there.
- The threat model gains an adversary for the third way, the server, which can read and change
  everything in its homes; the lot that plugs the third way in adds that section.
