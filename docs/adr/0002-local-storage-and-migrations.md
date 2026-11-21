# 0002. Local storage and migrations

- Status: proposed
- Date: 2026-11-14

## Context

The phone is the source of the household's data: no server holds a copy unless the family
subscribes, and even then the relay holds only ciphertext. A failed migration, a corrupt file
or an upgrade that loses a column loses data for good. The schema will grow over the lots,
and two phones of one family may run different versions of the app
([ADR 0003](0003-sync-protocol.md)).

## Decision

**One SQLite database per app, through drift**, opened by `drift_flutter` in a background
isolate. Tables mirror the web model: same names in English, UUID primary keys (stored as
16-byte blobs), `created_at`, `updated_at`, `deleted_at` (`core/models.py:28-38`), and
`home_id` on every business row (`homes/models.py:161-164`). Amounts are `TEXT` holding a
decimal string with two places, never `REAL` (as web ADR 0051 forbids floating point).
Dates of tasks are `TEXT` `YYYY-MM-DD`; instants are UTC milliseconds.

**Sync tables live in the same database**, written in the same transaction as the row they
describe:

- `field_clock(entity, row_id, field, hlc, device)`: the clock of the last write of each field,
  for the merge rule.
- `op_log(device, seq, hlc, body)`: the operations this phone wrote and has not yet seen
  acknowledged by the relay, and the last ones received (for undo of a merge, debugging).
- `extra(entity, row_id, json)`: fields this version does not know, kept and re-emitted.
- `pending(entity, body)`: operations on entity types this version does not know.

Without sync these tables stay empty except `field_clock`, so that turning sync on later
needs no rewrite.

**Migrations by drift's guided migrations.** `dart run drift_dev make-migrations` keeps a
schema file per version and generates step-by-step migration code and tests
(<https://drift.simonbinder.eu/migrations/>). Rules:

- A migration only adds: tables, nullable columns or columns with a default, indexes. A
  rename or a type change is a new column filled from the old one, the old one dropped one
  major version later.
- Before a migration the app copies the database file (`VACUUM INTO`) next to it and keeps
  the last copy; a migration that fails restores it and the app opens read-only with a message.
- CI runs the generated tests from every released schema version to the current one, with
  data (lot 1).
- `PRAGMA foreign_keys = ON`, `journal_mode = WAL`, `integrity_check` on start after an
  update.

**Encryption at rest**: v1 relies on the operating system: iOS Data Protection (file class
*complete until first user authentication*, so that background sync can open it) and
Android file-based encryption. Keys of sync are not in the database but in the Keychain or
Keystore (`flutter_secure_storage`). Database encryption with SQLite3MultipleCiphers stays
possible through the `sqlite3` hook option ([ADR 0001](0001-flutter-stack-and-packages.md))
without changing package; v1 does not use it (maintainer's decision), nor an app lock of its
own; an optional lock may come in lot 8.

**Photos and PDF** are files in the app's private directory, named by their UUID, never by
the name chosen by the person (as the web, `rooms/models.py:205-207`), re-encoded on import
as the web does (`rooms/images.py:75-101`): turned upright, every metadata but the colour
profile removed (location included), longest side at most 2560 px (`rooms/conf.py:17`), JPEG
quality 85; a thumbnail of 360 px (`rooms/conf.py:18`), made on each phone and never synced.
Each file belongs to the home of its row; deleting a home erases its files
([ADR 0008](0008-several-homes-one-family-space.md)).

**Backups by the OS**: the database and the files are excluded from iCloud and Google
backups. A backup by the system would be a copy outside the person's control, not encrypted
end to end; the encrypted export ([spec](../spec.md#export-and-import)) is the backup.
*Changed in lot 4b by the maintainer (2026-11-16)*: Android backups and transfers carry the
database and the files, and exclude only the secure store; a restored database takes a new
device id ([threat model](../threat-model.md), "Lost or stolen phone").

## Schema 2 (lot 2a)

Schema 2 (`lib/data/tables.dart`) holds `homes`, `rooms`, `items`, `photos`, `contractors`,
`tasks`, `occurrences`, `field_clock` and `local_settings`, created by the guided step from
schema 1 (`lib/data/database.steps.dart`). What lot 2a settled within the rules above:

- **No SQL foreign key** between tables of the model: references are UUID columns checked on
  read, as [ADR 0003](0003-sync-protocol.md) requires ("Invariants across rows"); sync may
  bring a row before the row it points to. Deleting a home therefore deletes, table by table,
  every row whose `home_id` is that home and their `field_clock` rows, then the home and the
  directory `homes/<home id>/` of its files.
- **`field_clock` is written by `lib/data/repository.dart`** for every field a change sets
  (and `created_at` and `deleted_at` on creation), with one clock per change, as one operation
  of [protocol.md](../protocol.md) section 2.2. The clock of lot 2a only sends: it never goes
  back, even when the phone's time does, and restarts from the last clock of this phone found
  in `field_clock`; receiving clocks of other phones comes with lot 4. `op_log`, `extra` and
  `pending` come with lot 4 too: without sync they stay empty.
- **Instants** (`created_at`, `updated_at`, `deleted_at`, `archived_at`) are UTC milliseconds
  in the database; the operations of lot 4 carry them as HLC strings.
- **`local_settings`** holds what belongs to this phone and is never synced: the device id
  (16 random bytes), the current home and whether Today shows all homes
  ([spec](../spec.md#homes)).
- **Amounts** (budgets, real cost) and the members (`assignee`, `completed_by`) are not in
  schema 2: they come with lots 3 and 5, as nullable columns.
- **Photos**: the table only; the file reference is the JSON of protocol section 2.9, and the
  re-encoding and thumbnails come with lot 2b.

## Schema 3 (lot 3a)

Schema 3 adds the stock (`lib/data/tables.dart`): `articles`, `article_rooms` and
`article_items` (the rooms and compatible items of an article, one row per link), `suppliers`,
`movements`, `task_materials` and `material_draws`, created by the guided step from schema 2,
which adds tables and indexes only. What lot 3a settled within the rules above:

- **Quantities and amounts** (`quantity`, `threshold`, `unit_price`, `last_price`, `wanted`,
  `drawn`) are `TEXT` with two decimals, read as `Decimal` (package `decimal`,
  [ADR 0001](0001-flutter-stack-and-packages.md)); `test/no_double_test.dart` fails when the
  code of the stock names `double`.
- **No stock level and no effect of a movement is stored.** A movement keeps what the person
  typed (for an inventory, the count); the effect of each line and the stock of an article are
  computed on read from its movements in the order of the clock that created them
  (`field_clock` of `created_at`, then device, then id), as
  [ADR 0003](0003-sync-protocol.md) says for the ledger ("Derived"). The web stores a `delta`
  worked out at writing time; for one phone the result is the same.
- **Deterministic ids** for the rows that must stay one per pair: a material line
  (`material:<task>:<article>`), a draw (`draw:<occurrence>:<article>`) and the links of an
  article (`stock.article_rooms:…`, `stock.article_compatible_items:…`), in the home's
  namespace ([ADR 0003](0003-sync-protocol.md)); removing one soft-deletes it, adding it again
  brings the same row back.
- **Done draws, undo gives back**: closing an occurrence as done writes, in the same
  transaction, an exit per material, never above what was wanted nor below zero, and a draw row;
  undo writes entries for what was taken and ends the draws. No line of the ledger is ever
  changed or erased (`stock/models.py:175`).


## Schema 4 (lot 3b)

Schema 4 adds the projects and the budget (`lib/data/tables.dart`): `projects`,
`project_rooms` (one row per room of a project), `budget_lines`, `quotes`, `project_files`,
`project_links`, `project_tasks`, `annual_envelopes` and `reports`, and four nullable columns:
`tasks.material_budget`, `tasks.labour_budget`, `occurrences.actual_cost` and
`rooms.paint_article_id`. The guided step from schema 3 adds those columns and tables and their
indexes; no row of schema 3 changes (`test/drift/housecairn/migration_test.dart`, from files of
schemas 2 and 3 with data). What lot 3b settled within the rules above:

- **Amounts** (`planned`, `paid`, `amount` of a quote and of an envelope, the budgets of a task,
  the real cost) are `TEXT` with two decimals below 10^10, read as `Decimal`
  (`projects/models.py` `money_field`); `test/no_double_test.dart` covers the budget's files.
- **Nothing derived is stored**: the committed amount of a line is the sum of its accepted
  quotes, and every figure of the budget is worked out on read by `lib/domain/budget.dart`, a port
  of the web's `budget/services.py` checked against the web's own figures for the same rows
  (`test/budget_web_test.dart`, `tool/budget_figures.py`, element `budget` of
  `tool/web_alignment.json`).
- **An accepted quote has a line of its project** (the web's `quote_accepted_has_line`); the
  repository refuses it otherwise, and any other status clears the line.
- **Deterministic ids**: a room of a project (`projects.project_rooms:<project>:<room>`), the
  project of a task (`projects.projecttask:<task>`: a task is in one project at most) and the
  envelope of a year (`projects.annualenvelope:<year>`, `envelope:<year>` in four digits since schema 6, as ADR 0003 and the web name it), in the home's namespace.
- **Files**: the file of a project's photo or of a quote is in the home's directory, named by
  the id of its row; its name as the person saw it is kept for the screens only. A link of
  inspiration is kept as typed: the app never reads the page (no network in `lib/`).

## Schema 6 (lot 4)

Schema 6 adds the tables of sync, new and empty; the guided step from schema 5 creates them and
no row of schema 5 changes (`test/drift/housecairn/migration_test.dart`, from a schema 5 file
with homes, tasks, an occurrence, clocks and local settings):

- `op_log(seq, device, hlc, home_id, body)`: each local change, as the operation of
  [protocol.md](../protocol.md) section 2.2 in JSON, written by `Repository._put` in the same
  transaction as the row and its `field_clock`; removed once the transport took it. `home_id`
  lets a purge drop what was not sent.
- `extra(entity, row_id, home_id, json)`: the fields this version does not know, one JSON object
  per row, their clocks in `field_clock`. The rows of `family.settings` and `family.member`,
  which have no table before lot 5, live there whole; `min_sv` is read from it.
- `pending(key, entity, home_id, body)`: operations on unknown entity types; `key` (type, home,
  row, clock, device) makes a duplicate one row.
- `purged_homes(home_id)`: the homes purged on this phone, kept for ever.
- `other_versions(entity, row_id, home_id, field, value, hlc, device, kept_until)`: the long
  texts that lost a merge, kept 30 days on this phone, never synced.

`updated_at` is the time of the newest clock of the row (`hlc >> 16`), on the phone that writes
and on those that merge, so that two phones with the same operations hold the same value. Deleting
a home without sync is the purge of lot 4 (`purgeHome`), so its id is kept in `purged_homes`.

## Schema 8 (lot 4c)

Schema 8 adds `file_sync(file_id, home_id, holder, row_id, direction, state, attempts, next_at,
code)`, new and empty (`test/drift/housecairn/migration_test.dart`): one row per file reference of
a row of a home of a server, with the way it goes, the tries and the last refusal. Never synced,
never exported, emptied when the phone leaves the server
([ADR 0012](0012-files-with-a-server.md)). A photo fetched from a server is stored whole under
the id of its row (`<id>.jpg`, its thumbnail `<id>.thumb.jpg`) as one made on the phone.

## Schema 13 (the real cost the server keeps)

Schema 13 adds three nullable amounts, read only (web ADR 0090, 0091, 0092):
`material_draws.unit_price`, the unit price of the article when it was taken, and
`occurrences.planned_labour` and `occurrences.planned_material`, the plan kept when the occurrence
was marked done. The server alone sets them; the phone keeps what the feed and the snapshot give,
writes them in no change and sends them in no operation (`serverOnlyFields` of
`lib/data/tables.dart`). The guided step from schema 12 adds the columns and moves the values a
phone of the third way kept in `extra` to them; their clocks were in `field_clock` already
(`test/real_cost_test.dart`). The real cost is worked out on read by `lib/domain/costs.dart`, a
port of the web's `tasks/costs.py`: the stock used plus the amount typed, else the plan kept.
An occurrence marked done on the phone that the server has not taken yet (its status or a draw
still in `op_log`) is estimated with the prices and the plan of now, as the web counts a closing,
and the screen says so; the next sync gives the server's values. Without a server nothing keeps
them, and the figures are those of now.

## Consequences

- Every write goes through one repository layer that updates the row, `field_clock` and
  `op_log` together; no screen writes SQL.
- A phone lost without sync and without export loses the data. The app says so after the
  first ten tasks and offers the export.
- Excluding OS backups was a choice against convenience; since lot 4b the maintainer keeps
  Android backups of the data, without the secure store, and the encrypted export stays the
  backup the app controls.
