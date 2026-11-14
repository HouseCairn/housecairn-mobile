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
