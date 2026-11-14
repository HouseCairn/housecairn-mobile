# 0004. Encryption: device keys, family key, invitation, removal, recovery

- Status: proposed
- Date: 2026-11-14

## Context

The relay stores and forwards the family's data and must not be able to read it, nor forge
it, nor let in a phone the family did not approve. There is no account: no e-mail, no
password a server could reset. Phones are lost, sold, and change hands within a family.
Whoever loses every key must be told plainly what is lost. The construction uses libsodium
only ([ADR 0001](0001-flutter-stack-and-packages.md)); the byte formats are in
[protocol.md](../protocol.md).

## Decision

**Keys of a phone (device keys)**, made on the phone when sync is turned on, never leave it:
an Ed25519 key pair to sign, an X25519 key pair to receive sealed keys. Private keys are in the
Keychain (iOS, *after first unlock, this device only*) or wrapped by the Android Keystore,
through `flutter_secure_storage`. The device id is 16 random bytes.

**Key of the family (space key)**: 32 random bytes per **epoch**, starting at epoch 1. Subkeys
are derived by `crypto_kdf` (BLAKE2b): one for batches, one for snapshots, one per photo
(a random key per blob, carried inside the operation that references it). Each epoch key is
sent to each phone as a **sealed box** (`crypto_box_seal`) for its X25519 public key, signed by
the phone that made it. The relay stores these envelopes; it cannot open them.

**Membership log**: an append-only list of records, each signed by an admin phone and holding
the hash of the previous one: genesis (space id, first phone), add phone, remove phone, new
epoch, new recovery key, admin granted or withdrawn. Every phone verifies the whole chain from
the genesis before trusting a public key or an envelope. The relay keeps the log and checks the
signatures too, to decide whom it lets in, but it cannot write a valid record.

**Invitation by QR code**, in person:

1. An admin phone shows a QR code: relay address, space id, invitation id, a one-time secret of
   32 bytes, the fingerprint of its own signing key. Valid 15 minutes, once. The relay only
   knows a hash of the secret.
2. The new phone scans it, makes its device keys, and posts to the relay its public keys and the
   member name, encrypted with a key derived from the secret. The relay cannot read or change
   this request without the secret.
3. Both screens show the same **6-digit code**, derived from both public keys and the secret.
   The person checks it and confirms on the admin phone.
4. The admin phone appends "add phone" to the log and seals the current epoch key for the new
   phone. The new phone downloads the log, its envelope, the latest snapshot and the batches
   after it.

A photo of the QR code is useless after 15 minutes or once used; within that window an attacker
who also controls the relay is stopped by the 6-digit code.

**Removing a phone or a member** (lost, stolen, sold, a person leaves the family): an admin
phone appends "remove phone", which makes the relay refuse that phone at once, then **rotates**:
a new epoch key sealed for every remaining phone and the recovery key, and a new snapshot under
it. The "remove phone" record names the last batch of that phone the admin had merged; every
phone rejects any later batch signed by it, even one a compromised relay would replay or
forge with an old date. What a removed phone already had (its local database and whatever it downloaded) **cannot
be taken back**; the app says so before confirming.

**Recovery key**: when the space is created the app shows a recovery code (32 random bytes,
written as 8 groups of base32, with a checksum), to write down or print. Ed25519 and X25519 key
pairs are derived from it, and registered in the log as a special member that receives every
epoch key. With the code alone and a new phone, a family that lost every phone gets everything
back. A new code can be made at any time by an admin phone; it removes the old one and rotates.

**What is lost, and when:**

| Lost | Consequence |
| --- | --- |
| One phone, others remain | Nothing: remove it, rotate. |
| Every phone, recovery code kept | Nothing: a new phone joins with the code. |
| Every phone and the recovery code | The data on the relay can never be read again, by anyone. The relay deletes the space at the end of the subscription. Only an encrypted export with its passphrase can restore it. |
| Recovery code only, phones remain | Nothing yet: make a new code at once. |
| Passphrase of an export | That file is unreadable. |

**Admin**: the phone that creates the space is admin; an admin can make another member admin.
At least one admin must remain; the recovery key acts as admin.

## Consequences

- The relay sees public keys, device ids, sizes and times, never a name, a title or an
  amount ([threat model](../threat-model.md)).
- No forward secrecy inside an epoch: a stolen epoch key reads every batch of that epoch.
  Epochs rotate on every removal and, by default, every 90 days.
- Each removal re-encrypts a snapshot of the home: with many photos this is the cost of a
  removal, not of every sync, because photos keep their own random keys and are re-sealed,
  not re-uploaded. A removed phone that kept a photo key can still read that photo if it gets
  the blob from the relay; the relay refuses it, which is the only protection there.
- Losing every key is final. The onboarding of sync makes writing down the recovery code a
  step that cannot be skipped without a second confirmation.
