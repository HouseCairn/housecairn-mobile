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

## Consequences

- Every write goes through one repository layer that updates the row, `field_clock` and
  `op_log` together; no screen writes SQL.
- A phone lost without sync and without export loses the data. The app says so after the
  first ten tasks and offers the export.
- Excluding OS backups is a choice against convenience, accepted by the maintainer: the
  encrypted export is the backup.
