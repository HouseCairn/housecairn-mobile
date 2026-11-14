# 0008. Several homes in v1: one encrypted space per family, shared by all its homes

- Status: proposed. Several homes in v1 is the maintainer's decision of 2026-11-14; one space
  per family is the choice this record proposes.
- Date: 2026-11-14
- Amends: [ADR 0003](0003-sync-protocol.md) (operations carry their home),
  [ADR 0004](0004-encryption-and-family-keys.md) (the space is the family's),
  [ADR 0006](0006-subscription.md) (one subscription per family).

## Context

The maintainer decided that v1 handles **several homes** (a main home, a second home, a rented
flat), where the lot 0 draft showed one. The web model already has them:

- every business table belongs to exactly one home (`homes/models.py:161-164`, web ADR 0006);
- a home has a name, a currency and a hemisphere (`homes/models.py:31-52`);
- people belong to a home through a membership with a role `owner`, `member` or `read_only`
  (`homes/models.py:17-23`, `:68-87`), one active membership per home and person
  (`:78-84`); the creator of a home is its owner (`homes/services.py:123-132`);
- the web remembers a **current home**, a preference never a permission; a home left or
  deleted falls back to the first home by name (`homes/current.py:1-13`, `:73-79`); the
  selector appears from two homes on (`homes/current.py:31-32`); Today can show all homes
  (`homes/current.py:81-82`);
- deleting a home is definitive, by an owner who types its name, without grace period
  (`homes/services.py:239-252`); there is no archived state on the web `Home`
  (`homes/models.py:31-58`).

References are to `src/housecairn/` of `HouseCairn/housecairn`, `main` at `a6953f3`.

The question this record settles: **does a family share one encrypted space for all its
homes, or does each home get its own space and its own key?**

## Decision

**One space per family. Every home of the family lives in it, under the same epoch keys, the
same membership log and the same recovery code.** Each operation names its home (`h`,
[protocol](../protocol.md#22-operations)); a home is a row `homes.home` like any other.

Why:

1. **The family is the unit of trust in v1.** Every member writes everything and there is no
   read-only role (maintainer's decision). A key per home would protect nothing between
   members who all hold every key.
2. **The family is the unit of the decisions already taken**: the photo quota is 2 GiB **per
   family**, and the subscription pays for the family's sync. One space makes quota and
   entitlement one counter each.
3. **The relay learns less.** With one space per home the relay would see how many homes a
   family has, the size and the rhythm of each, and which phones hold which home. With one
   space it sees one total: the number of homes, their names and their sizes stay inside the
   ciphertext.
4. **One ceremony instead of N**: one QR invitation brings a phone into every home; one removal
   and one rotation cut it from all of them; one recovery code restores everything.

Rejected: **a space per home** (clear separation, but N invitations, N logs, N rotations, N
recovery codes, and the number of homes in the clear for the relay); **one space with a
subkey per home** (the same metadata as one space, the complexity of N keys, and no protection
while every member holds every subkey).

**How the web model maps.** Every member of the family is a member of every home of the space;
the *admin* flag is family-wide ([spec](../spec.md#members-and-assignment)). If a family later
exports to a Housecairn instance, each member becomes a membership of each home, `owner` for an
admin, `member` otherwise.

**Lifecycle of a home in the app:**

| Action | Who | Effect |
| --- | --- | --- |
| Create | any member | a row `homes.home` with a random UUID; its deterministic ids use it as namespace. |
| Rename, change currency or hemisphere | any member | field writes, last writer wins (web: `homes/services.py:135-153`; a change of hemisphere moves the predefined seasons, as `:148-152`). |
| Archive, unarchive | any member | field `archived_at` (an app field, not in the web model). An archived home is out of the selector, of Today and of reminders, read only, still synced and still counted in the quota. |
| Delete | an admin, after typing the name, as the web (`homes/services.py:239-252`) | a record `purge` of the home in the membership log: final, no restore ([ADR 0003](0003-sync-protocol.md)); every phone erases the rows and files of that home; the phone that purges deletes its blobs on the relay, which frees the quota. |

The last active home cannot be archived or deleted while the family has no other one: the
app always opens on a home, as the web falls back to the next one (`homes/current.py:73-79`).

## Consequences

- Every operation carries its home, and rows are keyed by `(home, id)`: two homes can never
  collide, and a reference from one home to a row of another is invalid and shown empty.
- A home cannot be shared with someone outside the family (a sibling who uses the second
  home, a tenant) without giving them every home. That needs a second space, which the
  protocol allows (a device authenticates per space); joining several spaces on one phone is
  after v1. Moving a home out of a family is an export of that home and an import as a copy.
- A removed member loses every home at once, and keeps what was on their phone, as before.
- The relay still sees the total size, the times, and bursts that betray a large change; it
  also sees that a home was deleted, and when: the `purge` record names a random home id, and
  is followed by a burst of blob deletions ([threat model](../threat-model.md)). It never sees
  how many homes remain.
- Reminders and Today name the home whenever the family has two active homes or more.
