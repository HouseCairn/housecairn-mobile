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

## Consequences

- Every write goes through one repository layer that updates the row, `field_clock` and
  `op_log` together; no screen writes SQL.
- A phone lost without sync and without export loses the data. The app says so after the
  first ten tasks and offers the export.
- Excluding OS backups is a choice against convenience, accepted by the maintainer: the
  encrypted export is the backup.
