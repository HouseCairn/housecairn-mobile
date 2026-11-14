# Scope of v1

- Status: proposed (lot 0, framing)
- Source model: `HouseCairn/housecairn`, `main` at commit `a6953f3` (2026-11-12). Every
  reference `file:line` below is a path under `src/housecairn/` at that commit.

## Principles

1. **Same model, same words.** The app keeps the entities, fields, choices and rules of the
   web application, so that a household that moves between the two finds the same things, and
   so that a Housecairn instance can one day act as the relay without translation.
2. **One phone is enough.** Nothing in v1 needs a network. Sync is an addition.
3. **Only the title is required**, done is one tap with undo, as on the web
   (`tasks/models.py:162`, ADR 0033 of the web application).
4. **No outbound call that the person did not configure**: no telemetry, no link preview, no
   remote image. The only network peer is the relay the person chose.
5. **Derived figures are computed, never stored or synced**: stock levels, budget figures,
   committed amounts, visibility dates.

## Data model: taken, simplified, left out

Every table has a UUID key, `created_at`, `updated_at`, and soft deletion by `deleted_at`
(`core/models.py:28-38`); every business table belongs to one home (`homes/models.py:161-164`).
The app keeps both. In the app, a **home is the unit of sync**: one home, one encrypted space
on the relay ([ADR 0003](adr/0003-sync-protocol.md)).

### Taken as they are

| Entity | Source | Notes |
| --- | --- | --- |
| Home: name, currency (ISO 4217), hemisphere | `homes/models.py:31-52` | Hemisphere drives the predefined seasons. |
| Room, with its memory (paint, coverings, notes) | `rooms/models.py:67-91` | `kind` from `RoomKind` (`:52-64`). `paint_article` links to stock (`:81-88`). |
| Item (equipment or surface): brand, model, serial, installation, warranty, contract, links | `rooms/models.py:124-157` | Contract provider is a contractor (`:140-148`). Links: at most 10, `http(s)` only (`:15`, `:35-49`). |
| Photo of a room or an item, with category | `rooms/models.py:189-196`, `:210-245` | Exactly one of room or item (`:238-245`). Re-encoded on the phone, as on the server. |
| Contractor: name, trade (list plus Other), phone, email, address, note | `tasks/models.py:96-158` | Phone pattern `:112`, address max length `:113`. |
| Task: title, room, item, priority, duration, labour and material budgets, notes, procedure (Markdown), assignee, contractor, repetition, season, masking | `tasks/models.py:161-229` | Assignee becomes a **member of the family** (see below). |
| Occurrence: due date, status, postponement, completion, real cost, note, `follows` | `tasks/models.py:324-346` | One open occurrence per task (`:357-361`): kept, by a deterministic successor ([ADR 0003](adr/0003-sync-protocol.md)). |
| Task material (article and quantity) | `tasks/models.py:284-318` | One line per article and task (`:310-314`). |
| Material draw (what a done occurrence took from the stock) | `tasks/models.py:375-411` | `drawn` never above `wanted` (`:400-401`). |
| Stock article: name, references, dimensions, place, unit, threshold, unit price, compatible items, rooms, notes, label photo | `stock/models.py:68-122` | Unit list plus Other (`:24-33`). |
| Supplier of an article | `stock/models.py:148-157` | |
| Stock movement: entry, exit, inventory; never changed | `stock/models.py:168-197` | Stock is the sum of deltas (`:177-180`), computed. |
| Project: title, goal, status, priority, rooms, duration, preferred season | `projects/models.py:52-127` | Statuses `:52-57`. |
| Budget line: label, nature, planned, paid | `projects/models.py:71-77`, `:171-184` | Committed is derived from accepted quotes. |
| Quote: contractor, amount, dates, status, budget line | `projects/models.py:80-84`, `:205-235` | An accepted quote has a line (`:248-251`). |
| Project task link (a task in one project at most) | `projects/models.py:340-344` | |
| Annual envelope (one per year) | `projects/models.py:355-377` | |
| Report: what is wrong, where (room, item or article, at most one), photo, status, task made from it | `reports/models.py:26-30`, `:43-103` | |
| Task templates (bundled library, EN and FR, with sources) | `tasks/task_templates.yaml`, web ADR 0049 | Shipped with the app, read only. |

**Rules taken as they are** (ported to Dart, checked against the Python code by shared test
vectors, [ADR 0001](adr/0001-flutter-stack-and-packages.md)):

- Recurrence: modes once, fixed date, after the last time (`tasks/recurrence.py:17-20`);
  units and their bounds (`:22-26`); month ends on the 29th to 31st and 29 February
  (`:152-173`); next date after a closing (`:202-235`); dates to come in a range (`:278-338`).
- Seasons: predefined seasons as whole months, the southern hemisphere shifted by six months
  (`tasks/recurrence.py:37-53`); windows across the new year (`:123-129`); a date out of season
  moves to the first day of the next season (`:132-138`); the former `heating` season read as
  custom months (`:32-35`, `:56-63`).
- A due date is a calendar day, never an instant (web ADR 0032). In the app, "today" is the
  day in the **time zone of the phone**, not of an instance.
- Done in one tap, with undo; undo refused once the next occurrence was worked on
  (`tasks/services.py:563-643`, `:605-613`). Postpone keeps the original date
  (`tasks/services.py:588-602`). A completion date cannot be in the future (`:545-546`).
- Budget figures: planned, committed, paid, used, gap, still to pay; a project counted in the
  year it starts; upkeep is the tasks in no project; projection of repeating tasks over a
  year (web ADR 0051, `budget/services.py`; cost a year `:41`). Computed in decimal, never in
  floating point.
- Reminders: first reminder `days_before` (default 1) at `send_at` (default 08:00), quiet
  hours, daily summary (`notifications/models.py:61-91`); follow-ups every 1, 3 or 7 days by
  priority (`notifications/reminders.py:56`); the person reminded is the assignee, otherwise
  every member who may write (`notifications/reminders.py:4-7`).

### Simplified

| What | Web application | App v1 | Why |
| --- | --- | --- | --- |
| People | Accounts, memberships with roles owner, member, read only (`homes/models.py:17-23`, `:68-87`) | **Members** of the family: a display name and a colour, synced; each phone belongs to one member. One flag, *admin*, for who may add and remove phones. | No accounts by design. A read-only role needs every peer to reject writes; possible, but not needed for a family (see open questions). |
| Invitations | E-mailed link with a hashed secret (`homes/models.py:90-145`) | QR code shown on a phone of the family, confirmed by a short code ([ADR 0004](adr/0004-encryption-and-family-keys.md)) | No e-mail, no server-side identity. |
| Display preferences | Per person, server side (`tasks/models.py:414-451`) | Per phone, local, not synced | A setting of the screen, not of the home. |
| Reminder preferences | Per person, server side, sent by a worker | Per phone, local; scheduled by the phone ([Reminders](#reminders)) | No server sends anything. |
| Attachments | Any file type on tasks, projects, quotes (`tasks/models.py:463-494`, `projects/models.py:273-300`) | Photos and PDF only | What a phone produces; keeps the encrypted blobs small. |
| Project links | Address, title and picture read by a worker (`projects/models.py:303-337`, web ADR 0070) | Address and a title typed by the person; the page is never fetched | Principle 4. |
| Report limits | 20 open reports per reporter (`reports/models.py:21-23`) | No limit | It protects the home from a tenant with the read-only role, which the app does not have. |
| Stock draws | `drawn` limited to the stock held at closing (`tasks/models.py:378-381`) | Same on the phone that closes; after a merge of two phones the stock may show below zero, shown as a shortfall | Two offline phones can each take the last tin; no automatic correction is right. |
| Time zone | Of the instance (web ADR 0032) | Of the phone | Each phone has its own "today". |

### Left out of v1

| What | Source | Why |
| --- | --- | --- |
| Sign-in, passkeys, single sign-on, provider required by a home | `accounts/`, `homes/models.py:53-58` | No accounts. |
| API tokens, web API, instance settings, administrator, demonstration mode | `apitokens/`, `instance/`, `demo/` | No server in the app. |
| Audit log | `audit/models.py:19-34` | A family log of who did what is the history of occurrences; the relay must not keep one. |
| Events received from Home Assistant | `events/models.py:10-16` | Home Assistant is not in v1. |
| Notification channels (Apprise) and web push devices | `notifications/models.py:30-50`, `:153-192` | Replaced by local notifications. |
| Calendar feeds (secret ICS address) | `calendar/models.py:10-26` | Needs a server. A one-shot `.ics` export is possible later. |
| QR labels of rooms, items, articles | `labels/models.py:33-53` | Labels printed by the web point to web addresses; app links are a later lot. |
| Paperless-ngx fields of a quote | `projects/models.py:236-240` | Connectors are not in v1. Kept if they come from a later import (unknown fields are preserved, [ADR 0003](adr/0003-sync-protocol.md)). |
| CSV import and export, export jobs, archive of a home in format 3 | `homes/models.py:172-226`, web ADR 0048 | Replaced by the encrypted export below. Reading a web archive is an open question. |
| Several homes on one phone | `homes/models.py:68-87` | The model keeps `home_id` everywhere; the v1 screens show one home (open question). |

## Members and assignment

A **member** is a name and a colour; the member who creates the home is admin. A task's
assignee and an occurrence's `completed_by` point to a member (they point to a user on the web,
`tasks/models.py:187-194`, `:338-340`). Without sync there is one member, the owner of the
phone, and assignment is hidden.

## Screens of v1

Mobile first, one hand, 360 px wide and up, system font size respected.

1. **Today**: overdue, coming up within the horizon (1 week by default, `tasks/models.py:421-426`),
   in season, and open reports. Grouped by urgency or room (or person, with sync). Done is
   one tap, with an undo bar; skip and postpone from the same row.
2. **Task**: form with only the title required; repetition with a preview of the next five
   dates (`tasks/recurrence.py:341-351`); materials; history of occurrences; photos.
3. **Add from a template**: the bundled library, filtered by the equipment ticked.
4. **Rooms**: list in the household's order; a room shows its memory, items, photos, tasks.
5. **Item**: details, warranty state (`rooms/models.py:182-186`), contract, links, photos, tasks.
6. **Stock**: articles with low-stock flag (`stock/models.py:90-96`), an article with its
   movements and suppliers, add an entry, an exit or an inventory.
7. **Projects**: list by status (`projects/models.py:61-67`); a project with its budget lines,
   quotes, tasks, links and photos.
8. **Budget**: the year against its envelope, by room, by project, upkeep (read only).
9. **Report a problem**: title, place, photo; the list, make a task from a report, close it.
10. **Contractors**: list and card, call and e-mail from the card.
11. **Settings**: home (name, currency, hemisphere), language, reminders, export and import,
    family sync (subscribe, invite a phone, phones, recovery code, relay address), licences.

## Reminders

Local notifications only, scheduled by the phone from its own data
([ADR 0001](adr/0001-flutter-stack-and-packages.md)).

- Same defaults and follow-ups as the web (`notifications/models.py:70-91`,
  `notifications/reminders.py:56`), in the phone's time zone.
- With sync, each phone reminds only its own member when the task is assigned to them, else
  every member, as the web does for members who may write (`notifications/reminders.py:4-7`).
- iOS keeps 64 pending local notifications per app (documented by the plugin, see ADR 0001):
  the phone schedules the nearest 60 and a daily summary for the rest, and reschedules on
  every start, every sync and on a background refresh.
- Android 14 and later restrict exact alarms: reminders use inexact scheduling, which is
  enough for a day-level reminder; no exact-alarm permission is asked.

## Export and import

- **Export**: one file, `.hcbackup`, with every row (deleted ones included, so that an import
  cannot resurrect them) and every photo of the home, encrypted with a passphrase (Argon2id,
  then XChaCha20-Poly1305 secretstream; format in [protocol.md](protocol.md#backup-file)).
  The app proposes a generated passphrase of six words and says that a lost passphrase loses
  the file. Shared through the system share sheet; the app never uploads it.
- **Import**: into an empty app, or as a copy with new identifiers (the rule of web ADR 0069),
  never merged into a synced home.
- The inner layout follows the archive of the web (manifest, one document per table, files,
  web ADR 0048); reading it by the web application is a later lot, not a promise of v1.

## Languages

English is the source language; French ships in v1. No string in code: Flutter `gen-l10n`
with ARB files. Dates, numbers and amounts in the currency of the home are formatted by
`intl` in the language of the phone. The French terms follow the catalogue of the web
application, so that both say the same words.

## Not in v1

Home Assistant, Paperless-ngx, Sure, Apprise, calendar feeds, QR labels, widgets, a watch
app, a tablet layout, a web or desktop build, several homes in the screens, roles other than
admin.
