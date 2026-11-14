# 0003. Sync protocol: operation log, clock, merge rules

- Status: proposed
- Date: 2026-11-14

## Context

Two to six phones of one family edit the same homes (a family may have several,
[ADR 0008](0008-several-homes-one-family-space.md)), often offline (a cellar, a garden), and
meet again later through a relay that cannot read anything. There is no server to decide
who wins, so the merge must be decided by the phones, the same way on each, whatever order
the changes arrive in. The model has rules that a naive merge breaks: one open occurrence
per task (`tasks/models.py:357-361`), one material line per article and task (`:310-314`),
one envelope per year (`projects/models.py:369-373`), a stock that is the sum of an
immutable ledger (`stock/models.py:174-180`). Phones may run different versions of the app.
The full wire format is in [protocol.md](../protocol.md).

## Decision

**State-based on fields, carried by an operation log.** Each local write produces an
operation: entity type, home, row id, the fields set, a hybrid logical clock, the device. Phones
upload batches of operations and download those of the others; applying an operation is
idempotent and commutative, so every phone that has seen the same operations has the same
data. Periodic encrypted **snapshots** let a new phone start without the whole history and
let the relay drop old batches.

**Clock: hybrid logical clock (HLC)**, 64 bits: 48 bits of milliseconds since the Unix epoch,
16 bits of counter, ordered with the device id (16 bytes) as tie-break. It stays close to wall
time (readable "edited at"), never goes backwards when a phone's clock does, and orders a
change after every change its writer had seen. A received clock more than 24 hours ahead of
the phone's time is accepted but not adopted as the local clock, so a phone with a wrong date
cannot push every other phone into the future.

**Merge rule by kind of field:**

| Kind | Examples | Rule |
| --- | --- | --- |
| Scalar: text, number, amount, date, choice, reference | title, priority, `due_on`, `planned`, `room_id` | Last writer wins **per field** (HLC, then device). Two phones editing different fields of one task both keep their change. |
| Long text | notes, procedure, goal | Last writer wins per field; the losing text is kept 30 days in a local "other version" list on the task, shown with a notice. No text CRDT in v1. |
| Set of links | rooms of a project, compatible items and rooms of an article | Each element is a row of a link table with a deterministic id; add and remove are last writer wins on that row. |
| Append-only ledger | stock movements (`stock/models.py:175`: never changed, a mistake is corrected by a new line) | Insert only, union of all phones. Never edited. |
| Derived | stock level, budget figures, committed, `visible_from`, delta of an inventory | Never synced; recomputed on read. An inventory line stores the count; its delta is the count minus the sum before it in HLC order. |

**Every row belongs to one home**, as on the web (`homes/models.py:161-164`), and every
operation names it (`h`). A row never moves to another home; rows are keyed by home and id, so
two homes never collide, and a reference to a row of another home is read as empty. Members and
the settings of the space are family-wide and have no home.

**Deletion**: a soft delete sets `deleted_at` like any field (last writer wins), so an edit of
another field never brings a row back; only an explicit *restore* with a later clock does.
Children of a deleted row are hidden on read and come back with it. Tombstones are never
dropped from snapshots (a row id and a clock: a few dozen bytes), so a phone that was offline
for a year cannot resurrect what others deleted.

**Deleting a home is a purge**, final like the web's (`homes/services.py:239-252`), not a soft
delete: a record `purge` in the membership log, signed by an admin
([ADR 0004](0004-encryption-and-family-keys.md)). The log, not the batches, carries it because
the log has one verified order: whether the signer was admin is the same answer on every phone.
It wins over every clock: each phone erases the home's rows and files, keeps the home id in its
list of purged homes, and drops any later operation of that home, even one written offline
with a later clock. Because a purge erases whatever was applied before it and blocks whatever
comes after, the result is the same in any order. **Archiving** a home is not a deletion: a field `archived_at`, last writer
wins, that hides the home and stops its reminders; rows stay and keep syncing.

**Deterministic identifiers where the model has a uniqueness rule**, UUID version 5 in the
namespace of the home the row belongs to (`h`), so the same name in two homes gives two ids:

- successor of an occurrence: `uuid5(home, "next:" + occurrence_id)`. Two phones that close the
  same occurrence offline create **the same** next occurrence, whose fields then merge;
- material line: `uuid5(home, "material:" + task_id + ":" + article_id)`;
- material draw: `uuid5(home, "draw:" + occurrence_id + ":" + article_id)`;
- annual envelope: `uuid5(home, "envelope:" + year)`;
- link rows: `uuid5(home, "<table>:" + a + ":" + b)`.

**Invariants across rows are checked on read, repaired deterministically, never enforced by
refusing a merge.** After applying a batch the phone runs repair rules whose result depends
only on the merged data, so two phones that repair concurrently write the same thing:

- two open occurrences of one task (one phone postponed, the other closed): the occurrence that
  `follows` the other stays open; the earlier one is closed as *done* if a phone marked it done,
  else *skipped*;
- an accepted quote whose budget line was deleted: shown "needs a line", not changed;
- stock below zero after two phones drew the same article: shown as a shortfall, not changed;
- an undo whose successor was edited on another phone in the meantime: the edit wins, the undo
  is reverted on the phone that made it, with a notice (the web refuses the same case,
  `tasks/services.py:605-613`).

**Versions of the schema between phones.** Each operation carries the schema version `sv` of
its writer. Within one major version of the protocol, the schema only grows (new entity
types, new optional fields, new choice values), the rule of [ADR 0002](0002-local-storage-and-migrations.md):

- a field a phone does not know is stored in `extra` and re-emitted in its snapshots, so an
  older phone never erases what a newer one wrote;
- an unknown choice value is shown as "Other (update the app)" and kept as is; the web model
  already lives with this, when an old client sends the former `heating` season
  (`tasks/recurrence.py:32-35`);
- an operation on an unknown entity type is kept in `pending` and applied after the update;
- a change that is not additive raises `min_sv` in the space's encrypted settings: a phone
  below it **reads but does not write**, and asks for an update. A data migration that must run
  once is written as operations with deterministic ids, so two phones that migrate
  concurrently produce the same result.

## Consequences

- No central order, no lock, no conflict screen in the common case; the price is that two
  people changing the same field at the same time keep only the later one.
- Every model rule of the web application that involves two rows needs a line in this ADR
  before a lot implements it; a reviewer checks it.
- The merge is a pure function of a set of operations: lot 4 tests it by property tests
  (random histories of at least two homes, applied in random orders, give identical
  databases), purges of a home included.
- A purge cannot be undone, by anyone: the app asks for the exact name and offers an export
  first, as the web does.
- Any server that stores and returns batches in order can be the relay; it needs no knowledge
  of the model. A Housecairn instance can implement the relay API without understanding the
  ciphertext, and a later lot can let an instance join the space as a phone would.
