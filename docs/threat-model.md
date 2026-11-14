# Threat model

- Status: proposed (lot 0)
- Scope: the app on a phone, the relay (hosted or self-hosted), the push services, the stores.
  Constructions: [ADR 0004](adr/0004-encryption-and-family-keys.md), [protocol.md](protocol.md).

## Assets

| Asset | Where | Why it matters |
| --- | --- | --- |
| Content of the home: rooms, items with serial numbers and warranties, tasks, notes, budget, contractors' phones and addresses, reports | phone database; ciphertext on the relay | Says what a home holds, what it is worth, when work is done; personal data of third parties (contractors). |
| Photos, including "behind the walls" (`rooms/models.py:193`, `:199-202`) | phone files; ciphertext on the relay | Shows the inside of a home and where its pipes and cables run. |
| Device private keys, epoch keys | Keychain or Keystore | Read or forge everything of the space. |
| Recovery code | paper, password manager | Same, without a phone. |
| Export file and its passphrase | wherever the person put it | A full copy of the home. |
| Membership of the space (which phones, which members) | log on the relay (public keys only), names inside ciphertext | Who lives together. |
| Subscription | relay (hash of transaction), store | Links a store account to a space, through the relay. |

## Adversaries and what they get

### Compromised or curious relay (the operator, an intruder, a court order)

**Protected**: every content field, every name of a member, every photo, the settings of the
space, the schema in use. The relay cannot forge an operation (signed by a device, encrypted
under a key it does not have), cannot add a phone (membership records are signed by an admin
and verified by every phone from the genesis), cannot take over an invitation (it only knows a
hash of the secret; the six-digit code stops a relay that also saw the QR code).

**Not protected**, in the clear for the relay:

- the number of spaces, the number of phones per space and their public keys, when phones are
  added or removed, when epochs rotate;
- sizes (padded to 1 KiB for batches, 64 KiB for photos) and times of every upload and
  download, hence the rhythm of activity of a household;
- IP addresses of the phones, and their push tokens;
- the store, product and expiry of the subscription of a space;
- the total volume, hence roughly how many photos a household has.

**Can still do harm**: refuse service, delete a space, withhold batches from some phones (two
phones then see different states until they meet another way), replay old batches (rejected:
`(device, seq)` is unique and applying twice changes nothing), serve an older log or snapshot
(a phone keeps the highest `n` and `covers` it has seen and refuses to go back). Detection of a
relay that shows different logs to different phones (a fork) is not in v1.

### Lost or stolen phone

- **Locked**: the database is protected by the OS file encryption, keys by the Keychain or
  Keystore. The app does not add its own lock in v1 (open question).
- **Unlocked, or its code known**: the thief reads the whole home, as the owner does. Remedy:
  another phone of the family removes it; the relay refuses it at once; the epoch rotates. What
  it already holds stays readable offline, forever. With no other phone, the recovery code on a
  new phone does the removal.
- Without sync, a lost phone is lost data unless an export exists.

### Removed member

Keeps the local copy and anything downloaded before removal, and the keys of past epochs.
Gets nothing written after the rotation: the relay refuses its token, and new batches are under
a key it does not have. If it kept a blob key and gets the blob by some other way than the
relay, it can read that photo. Batches it uploaded and that no admin had merged before the
removal are dropped by every phone (`last_seq`, [protocol](protocol.md#25-membership-log)).

### Store (Apple, Google) and push services

They know that a store account bought "Family sync" for this app, when, and its renewals.
They never receive the space id (no `appAccountToken`, no `obfuscatedAccountId`,
[ADR 0006](adr/0006-subscription.md)), nor any content. APNs and FCM see a push token, the
sender and the timing of wake-ups, never a payload. The OS vendor controls the phone itself:
an app cannot protect itself from it.

### A person on the network

TLS to the relay, and the content is encrypted end to end anyway. A self-hosted relay without
valid TLS is refused by the app; plain HTTP is accepted only for `localhost` in debug builds.

### A malicious invitation or file

A QR code from an unknown source points to an attacker's relay: the app shows the relay address
and the inviter's member name before joining, and joining moves no local data to the new space.
An imported backup is parsed with size limits per entry, checked against its manifest, and
restored as a copy; it never runs code.

### A member of the family

Members are trusted to write: every phone can change or delete everything of the home. An admin
can remove phones; a non-admin cannot. A read-only member is not in v1.

## What the project commits to

- No telemetry, no analytics, no crash reporting, no remote configuration.
- The app talks to the chosen relay, the store, and the push service of the platform; nothing
  else. No link preview, no remote image.
- Cryptography only through libsodium constructions; no home-made primitive.
- The protocol is public; a self-hosted relay gives the same guarantees.
- A security review of the crypto and sync code by someone outside the project before the
  public release (lot 9).

## Out of scope

The OS and the hardware of the phone; malware on the phone; a family member who shares the
recovery code; forward secrecy within an epoch; hiding from the relay that a household uses
the service at all.
