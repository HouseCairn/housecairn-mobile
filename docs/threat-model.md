# Threat model

- Status: proposed (lot 0)
- Scope: the app on a phone, the relay (hosted or self-hosted), the push services, the stores.
  Constructions: [ADR 0004](adr/0004-encryption-and-family-keys.md), [protocol.md](protocol.md).

## Assets

| Asset | Where | Why it matters |
| --- | --- | --- |
| Content of the homes: rooms, items with serial numbers and warranties, tasks, notes, budget, contractors' phones and addresses, reports | phone database; ciphertext on the relay | Says what a home holds, what it is worth, when work is done; personal data of third parties (contractors). |
| The list of a family's homes: how many, their names, which is archived | phone database; inside the ciphertext of the space | Says where a family owns or rents, and when a home is sold. |
| Photos, including "behind the walls" (`rooms/models.py:193`, `:199-202`) | phone files; ciphertext on the relay | Shows the inside of a home and where its pipes and cables run. |
| Device private keys, epoch keys | Keychain or Keystore | Read or forge everything of the space. |
| Recovery code | paper, password manager | Same, without a phone. |
| Export file and its passphrase | wherever the person put it | A full copy of every home of the phone. |
| Membership of the space (which phones, which members) | log on the relay (public keys only), names inside ciphertext | Who lives together. |
| Subscription | relay (hash of transaction), store | Links a store account to a space, through the relay. |

## Adversaries and what they get

### Compromised or curious relay (the operator, an intruder, a court order)

**Protected**: every content field, every name of a member, every photo, the settings of the
space, the schema in use, and **the homes**: their number, their names and which data belongs
to which home, since one space holds every home of the family under the same keys
([ADR 0008](adr/0008-several-homes-one-family-space.md)). A batch mixes homes and its header
names none. The relay cannot forge an operation (signed by a device, encrypted
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
- the total volume, hence roughly how many photos a household has, and the number and padded
  sizes of its blobs;
- that a home was deleted, and when: the `purge` record of the membership log names the home
  by its random id, followed by a burst of blob deletions; it never says how many homes remain;
- bursts: a new home filled from an import shows as many uploads at once; the relay can guess
  that something large changed, not what nor in which home.

**Can still do harm**: refuse service, delete a space, withhold batches from some phones (two
phones then see different states until they meet another way), replay old batches (rejected:
`(device, seq)` is unique and applying twice changes nothing), serve an older log or snapshot
(a phone keeps the highest `n` and `covers` it has seen and refuses to go back). Detection of a
relay that shows different logs to different phones (a fork) is not in v1.

### Lost or stolen phone

- **Locked**: the database is protected by the OS file encryption, keys by the Keychain or
  Keystore. The app adds neither its own lock nor its own database encryption in v1
  (maintainer's decision); an optional app lock may come in lot 8. OS backups (iCloud,
  Google) exclude the app's data, so no copy leaves the phone outside the person's control.
- **Unlocked, or its code known**: the thief reads the whole home, as the owner does. Remedy:
  another phone of the family removes it; the relay refuses it at once; the epoch rotates. What
  it already holds stays readable offline, forever. With no other phone, the recovery code on a
  new phone does the removal.
- Without sync, a lost phone is lost data unless an export exists.

### Removed member

Keeps the local copy of **every home** and anything downloaded before removal, and the keys of
past epochs: there is no removal from one home only.
Gets nothing written after the rotation: the relay refuses its token, and new batches are under
a key it does not have. If it kept a blob key and gets the blob by some other way than the
relay, it can read that photo. Batches it uploaded and that no admin had merged before the
removal are dropped by every phone (`last_seq`, [protocol](protocol.md#25-membership-log)).

### A photo

A photo can show more than its subject: the location where it was taken, the phone that took
it. The app re-encodes every photo before storing it and keeps no metadata but the colour
profile ([spec](spec.md#photos-and-files)); lot 2 tests it on a fixture with GPS data. A blob is
encrypted under its own key, bound to its id and its space: a relay that swaps two blobs is
caught. The photos of a deleted home are erased on every phone and deleted from the relay;
what a removed member downloaded before stays readable to them.

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

Members are trusted to write: every phone can change or delete everything of every home, and
archive a home. Only an admin can remove phones and delete a home, a purge that every phone
applies only if the log says its signer is admin; a non-admin cannot. A read-only member is not
in v1 (maintainer's decision).

### A Housecairn server (the third way)

In the third way ([ADR 0010](adr/0010-three-ways-to-use-the-app.md)) the phone's homes are on
a Housecairn server **in clear**: whoever runs the server or its host, every account that is a
member of these homes on it, the integrations that hold a token of them, and anyone who gets a
backup of the server can read and change everything in them. The app says so on its confirmation
screen, before anything is sent or received. What the app still holds to:

- it talks only to the address typed: every request goes to that origin, no redirect is
  followed, no proxy of the environment is used, and an endpoint that `info` gives on another
  host is refused (`lib/sync/server_address.dart`, `server_http_io.dart`);
- HTTPS with the system's certificate checks, which cannot be skipped; `http://` only to an IP
  literal that is not public (protocol section 2.10), never a name, `.local` included, and after
  a warning that anyone on that network can read what the phone sends;
- the sign-in is OAuth 2 with PKCE `S256` in the system browser, `state` checked; no token is
  typed or pasted. The access and refresh tokens are in the Keychain or the Android Keystore
  (`Store`), never in the database, an export or a log;
- the server cannot make the phone write outside the homes the access covers, and a home it
  stops listing is removed from the phone as a purge;
- disconnecting deletes the credential at once, and the access can be revoked on the server,
  per phone; a revoked access stops the phone at its next call, and the phone says so.

A server can still feed the phone false data in its homes, as any member could; it cannot
reach the relay, the other ways, or another server.

## What the project commits to

- No telemetry, no analytics, no crash reporting, no remote configuration.
- The app talks to the chosen relay or Housecairn server, the store, and the push service of
  the platform; nothing else. No link preview, no remote image.
- Cryptography only through libsodium constructions; no home-made primitive.
- The protocol is public; a self-hosted relay gives the same guarantees.
- A security review of the crypto and sync code by someone outside the project before the
  public release (lot 9).

## Out of scope

The OS and the hardware of the phone; malware on the phone; a family member who shares the
recovery code; forward secrecy within an epoch; hiding from the relay that a household uses
the service at all.
