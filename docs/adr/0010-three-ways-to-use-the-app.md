# 0010. Three ways to use the app: alone, family sync through the relay, a Housecairn server

- Status: proposed. The three ways and their order of arrival are the maintainer's decision of
  2026-11-14; what each guarantees, the moves between them and the architecture are the
  choices this record proposes.
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
     self-hosted web application) and a Housecairn **API token**. The data is **shared with
     the server**: what is typed on the phone appears in the web application and the other way
     round; the server reads the data, it is not an end-to-end encrypted relay;
- the screen and the architecture are **planned now**, and each way is plugged in when its lot
  arrives.

References `file:line` to the web application are to `src/housecairn/` of
`HouseCairn/housecairn` at commit `254f889` (`main` on 2026-11-14, release `v0.3.1` and 8
commits), not at the commit `a6953f3` of the other records: the API was read for this record.

## Decision

### The three ways, and what each guarantees

| | 1. Alone on this phone | 2. Family sync (relay) | 3. My Housecairn server |
| --- | --- | --- | --- |
| Where the data is | On this phone only; in the encrypted export files the person makes ([spec](../spec.md#export-and-import)) | On every phone of the family; on the relay as ciphertext (batches, snapshots, blobs) | On this phone and **on the server, in clear**: its database, its files and its backups |
| Who can read it | Whoever can unlock this phone | The phones of the family; **not** the relay, which sees only the metadata of the [threat model](../threat-model.md) | The phone; **the server**: whoever administers the instance or its host, every account that is a member of these homes on it, the integrations that hold a token of these homes, and anyone who gets a backup of the server |
| Who decides a conflict | No conflict | Each phone, by the same merge rules ([ADR 0003](0003-sync-protocol.md)) | The same field rules, applied by the server, which keeps the order ([Architecture](#architecture-one-sync-layer-two-transports)) |
| Offline | Everything works; no network call, ever | Everything works; changes are sent and merged when the relay is reachable | Everything works on the copy of the phone; changes wait in the log and are sent when the server is reachable; edits made on the web meanwhile arrive then |
| Network peers | None | The relay the person chose, and the push services | The server the person typed, and nothing else (no push in v1: the phone syncs when opened and in the background) |
| Account | None | None (device keys, [ADR 0004](0004-encryption-and-family-keys.md)) | The account of the server that issued the token |
| Cost | Free | Subscription for the hosted relay; free on a self-hosted relay ([ADR 0006](0006-subscription.md)) | No subscription is needed by design: the publisher's relay is not used ([question](../plan.md#open-questions)) |

**One way at a time per phone in v1.** A phone is alone, or in a family on a relay, or connected
to one server. Mixing them (a phone on a server that also joins a family on the relay, or
homes of one phone split between local and server) is not in v1, and is an open question for
the maintainer ([plan](../plan.md#open-questions)).

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

- **HTTPS only**, with the system's certificate checks; the app never offers to skip them
  (whether plain HTTP is accepted on a local network is an
  [open question](../plan.md#open-questions));
- the **token is kept in the Keychain or the Android Keystore** (`Store`,
  [ADR 0002](0002-local-storage-and-migrations.md)), never in the database, never in an
  export, never in a log;
- the app sends to the server nothing but the homes bound to the token, and calls no other
  address;
- disconnecting deletes the token from the phone at once.

### What the screen says

The first-start screen shows the three ways as three choices of equal weight, the first one
selected. A way whose lot is not merged yet is **shown, disabled, with "Coming later"**; it
opens nothing, asks nothing and calls no network. The texts below are the intent; the exact
strings go in the ARB files with the lot that builds the screen.

- **Alone on this phone**: "Your homes stay on this phone. Nothing is sent anywhere. You can
  turn on sharing later."
- **Family sync**: "Share your homes with the phones of your family. Everything is encrypted
  on your phones before it leaves them: our server cannot read it. Needs a subscription."
- **My Housecairn server**: "Use the homes of your own Housecairn, the web application or the
  Home Assistant add-on. **Your server stores your homes and can read them**, like its web
  pages do."

Choosing the third way leads to a second screen, address and token, then a confirmation
before anything is sent or received, which names the server and lists what it gets:

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
| Alone → my server, **send this phone's homes** | **Yes, into homes that are empty on the server** | The phone uploads every row and file of the homes it sends, with its own ids, then syncs. The server must accept ids made by the phone and, for a home it does not have yet, a way to create it ([what the web lacks](#what-the-web-api-lacks-for-the-third-way)). |
| Alone → my server, **take the server's homes** | **Yes** | The phone downloads the homes bound to the token. Its local homes are not merged: the app offers an encrypted export first, then removes them from the phone, after the person types "remove" (the same care as deleting a home, [spec](../spec.md#homes)). |
| Alone → my server, both sides not empty, **merge** | No, after v1 | Two histories of the same house, written without common ids, cannot be merged field by field; matching rooms and tasks by name is a guess. The app offers the two choices above, never a silent merge. |
| Family sync → alone | **Yes** | Leaving the family, or being removed: the phone keeps what it had, as a removed member does ([ADR 0004](0004-encryption-and-family-keys.md)); its keys of the space are deleted. |
| My server → alone | **Yes** | Disconnect: changes not yet sent are listed and sent first when the server is reachable, or dropped after a confirmation that names them; the token is deleted; the phone keeps a local copy of the homes as they were at the last sync, which no longer syncs. |
| Family sync ↔ my server, directly | No, after v1 | In v1 a phone goes through the first way: leave the family, then connect to the server and send its homes into empty homes there (or the reverse). A direct move would have to decide what the other members of the family get, which is the maintainer's call. |
| A phone in two ways at once | No in v1 | [Open question](../plan.md#open-questions). |

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
                      Housecairn server, with the token from Store
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
| `pull(after: cursor)` | batches after `pos`; "start again" on 410, from the snapshot | changes after the server's cursor; "start again" when the cursor is too old, from a full download of the homes |
| `putFile`, `getFile`, `deleteFile` | blobs, encrypted with their own key | the files of the server's photos and attachments, in clear |
| `homesGone()` | `purge` records of the membership log | homes deleted on the server, or no longer bound to the token |

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
same table; the token in `Store`. No migration.

**Files.** The file reference of protocol section 2.9 names a blob and its key. With a server it
names a file of the server; the exact form is decided by lot 4b with the web lot, since it
depends on how the server stores files. A photo is re-encoded on the phone before anything
else in every way ([spec](../spec.md#photos-and-files)); a server that re-encodes again keeps its
own copy, and the phone keeps its own.

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
8. **Token bound to homes, but none to make or receive a home.** A token is bound to existing
   homes of its user (`apitokens/models.py:17-37`, `homes/scoping.py:27-38`), which fits the
   third way. But a token may not create a home (`homes/api.py:169-171`) nor restore one
   (`homes/api.py:379-381`), so a phone cannot send a home the server does not have; tokens
   expire after 90 days by default (web ADR 0007) with no renewal by the token itself; scopes
   are only `read`, `write` and `events` (`apitokens/models.py:11-14`), so a token lent to the
   phone is the same as one lent to any integration. Needed: a way to bind a new home of the
   phone (a home made on the web for it, or creation by the phone), a token kind for a device,
   or the OAuth 2 flow with PKCE that web ADR 0007 planned for "the iOS app" (`/o/`). Token
   management by a person signed in stays as it is (`apitokens/permissions.py:74-80`).
9. **Fields the app has and the web does not.** A home has no `archived_at` on the web
   (`homes/models.py:31-58`; [protocol](../protocol.md#22-operations) section 2.2); assignee and
   `completed_by` are accounts (`tasks/models.py:187-194`), not members of a family. Needed:
   the field on the web, or the app hides archiving in the third way; the members of a home in
   the feed, for assignment.
10. **Files with the client's id.** Photos and attachments are uploaded as multipart with an id
    made by the server, then re-encoded (`rooms/api.py:474-500`, `rooms/images.py:75-101`,
    `tasks/api/attachments.py:153-160`); the same for the label of an article
    (`stock/models.py:119`), the photo of a report (`reports/models.py:72`) and project files
    (`projects/models.py:282`). Needed: upload with the id of the phone's row, repeatable
    without a duplicate, the size limit announced (`rooms/conf.py`, instance setting
    `file_max_bytes`), and the file and thumbnail readable by id as today
    (`rooms/api.py:520-531`).
11. **Versions and limits announced.** Needed: one route that says the server's version, the
    sync API version and its limits (batch size, file size, rate), so that the app refuses a
    server too old in words, and keeps the fields it does not know (`extra`) as with the
    relay.

## Consequences

- The spec's principle "the only network peer is the relay the person chose" becomes "the relay
  or the server the person chose"; the web API is no longer out of scope of the app, only
  token management is, which stays on the web ([spec](../spec.md)).
- The first way stays complete on its own: an app that never leaves it has no network code
  running and no server to trust.
- The third way depends on work on the web repository. It cannot be built against the API of
  today: [what the web API lacks](#what-the-web-api-lacks-for-the-third-way) is the list for a
  lot of the web application, which the maintainer decides and which comes before the lot of
  the app.
- A family that wants both, the web for some members and phones for others, uses the third
  way for every phone; the second way is for families with no server. The two never mix in v1.
- The threat model gains an adversary for the third way, the server, which can read and change
  everything in its homes; the lot that plugs the third way in adds that section.
