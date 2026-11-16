# Sync and relay protocol, version 1

- Status: draft for review (lot 0). Nothing here is implemented yet.
- Decisions behind it: [ADR 0003](adr/0003-sync-protocol.md) (operations, clock, merge),
  [ADR 0004](adr/0004-encryption-and-family-keys.md) (keys), [ADR 0005](adr/0005-relay-server.md)
  (relay), [ADR 0006](adr/0006-subscription.md) (entitlement).
- Words: **space** = the encrypted copy of one family's data on a relay, every home of the
  family included ([ADR 0008](adr/0008-several-homes-one-family-space.md)); **home** = a row
  `homes.home` inside the space; **device** = one install of the app on one phone; **relay** =
  any server that implements section 3; **server mode** = the third way of
  [ADR 0010](adr/0010-three-ways-to-use-the-app.md), the same operations in clear to the sync
  API of a Housecairn server (section 2.10).

The key words MUST, MUST NOT, SHOULD and MAY are used as in RFC 2119.

## 1. Conventions

- JSON is UTF-8. Binary values inside JSON are base64url **without padding** (`b64`).
- `space_id`, `device_id`, `invite_id`, `blob_id`: 16 random bytes, in `b64` (22 characters).
- Row ids of the model are UUIDs in their canonical text form.
- **HLC**: a 64-bit unsigned integer, `(milliseconds since 1970-01-01 UTC << 16) | counter`,
  written as **16 lowercase hexadecimal digits**, so that string order is numeric order. Ties
  are broken by `device_id` bytes. Update rules are those of Kulkarni et al., *Logical
  Physical Clocks* (2014); a received HLC more than 24 h ahead of local time is stored but not
  adopted.
- Integers in binary headers are big-endian.
- Cryptography is libsodium: `aead` = `crypto_aead_xchacha20poly1305_ietf`, `seal` =
  `crypto_box_seal`, `sign` = `crypto_sign_detached` (Ed25519), `kdf` =
  `crypto_kdf_derive_from_key` (BLAKE2b), `hash` = `crypto_generichash` (BLAKE2b),
  `stream` = `crypto_secretstream_xchacha20poly1305`, `pwhash` = `crypto_pwhash` with
  Argon2id 1.3, `pad` = `sodium_pad`.

## 2. What the phones exchange

### 2.1 Keys

| Key | Size | Origin |
| --- | --- | --- |
| Device signing key | Ed25519 | random, per device |
| Device box key | X25519 | random, per device |
| Epoch key `E[e]` | 32 bytes | random, per epoch `e` ≥ 1 |
| Batch key | 32 bytes | `kdf(E[e], id=1, ctx="hcbatch_")` |
| Snapshot key | 32 bytes | `kdf(E[e], id=2, ctx="hcsnap__")` |
| Blob key | 32 bytes | random, per blob, carried in the operation |
| Recovery seed | 32 bytes | random; signing and box keys = `kdf(seed, 1, "hcrecov_")`, `kdf(seed, 2, "hcrecov_")` used as seeds |

### 2.2 Operations

An operation is a JSON object:

```json
{"t": "tasks.task", "h": "5b7e…", "id": "8f0c…", "k": "put", "c": "0193a1b2c3d40001",
 "f": {"title": "Change the smoke alarm battery", "repeat_mode": "fixed", "room_id": "1c2d…"}}
```

- `t`: entity type, `<app>.<model>` of the web application in lower case (`homes.home`,
  `rooms.room`, `rooms.item`, `rooms.photo`, `tasks.contractor`, `tasks.task`,
  `tasks.taskmaterial`, `tasks.occurrence`, `tasks.materialdraw`, `stock.article`,
  `stock.supplier`, `stock.movement`, `projects.project`, `projects.budgetline`,
  `projects.quote`, `projects.projectfile`, `projects.projectlink`, `projects.projecttask`,
  `projects.annualenvelope`, `reports.report`, `tasks.attachment`), the link tables
  `projects.project_rooms`,
  `stock.article_rooms`, `stock.article_compatible_items`, and the types of the app
  `family.member` and `family.settings`.
- `h`: id of the home the row belongs to. REQUIRED for every type except `family.*`, where it
  is absent; for `homes.home`, `h` equals `id`. A row never changes home. Rows are keyed by
  `(t, h, id)`: the same `id` in two homes is two rows. A foreign key to a row of another home is
  invalid: receivers keep it and read it as empty. **In the server mode** the server keys rows
  by `id` alone: a phone MUST NOT give one `id` to two rows, in two homes or in two types (a
  random UUID version 4, or `uuid5` in the namespace of the home, never collides), and a `put`
  that would create such a row is rejected with `id_taken` (section 2.10).
- `id`: row id: random UUID version 4, or deterministic (ADR 0003): `uuid5(h, name)`, so that
  deterministic ids never collide across homes.
- `k`: `put` (set the fields in `f`), `delete` (sets `deleted_at`), `restore` (clears it).
- `c`: HLC of the operation; it is the clock of every field it sets.
- `f`: field names are those of the web model, foreign keys by their column name (`room_id`).
  Values: string, number, boolean, `null`; amounts and quantities as decimal strings (`"12.50"`);
  dates `"YYYY-MM-DD"`; instants as HLC strings. A photo or file field holds a **file
  reference** `{"blob": b64, "key": b64, "size": n, "type": "image/jpeg", "width": n,
  "height": n}` (section 2.9); `width` and `height` only for images. In the server mode the
  reference has another form, given in section 2.10.
- A receiver MUST keep fields it does not know and MUST NOT drop the operation. A Housecairn
  server does too: it keeps them in `extra` and gives them to the other phones (web ADR 0077).

**Apply** (every phone, same result in any order): for each field of `f`, write the value if
`(c, device)` is greater than the stored clock of that field, and store the new clock. `delete`
and `restore` are the field `deleted_at`. Then run the repair rules of ADR 0003.

**Purge of a home**: deleting a home is not an operation but a record `purge` of the
membership log (section 2.5), so that who may purge is decided by the verified order of the log
and not by when a phone happens to apply a batch. It is **final and wins over every clock**:
a phone that reads a valid `purge` of home `H` erases every row with `h = H` and the local files
they reference, keeps `H` in its list of purged homes forever, and drops every operation with
`h = H` it receives afterwards, whatever its clock. An operation applied before the purge was
read is erased with the rest, so the result does not depend on the order. There is no
`restore` of a purged home.

`homes.home` has one field of the app that the web model does not have: `archived_at` (HLC
string or `null`), last writer wins. **In the server mode only an owner of the home may set
it**, as on the web: the app offers archiving to owners only, and an operation that sets it,
pushed by the phone of a member who is not an owner, is rejected with `forbidden`, the whole
operation. The server stores the time of the HLC for its pages and gives back the HLC string
exactly as it was sent.

### 2.3 Batch

A batch is the unit a device uploads: its operations since its previous batch.

```
"HCB1"                         4 bytes, magic and wire version
header_len                     u16
header                         JSON, header_len bytes
nonce                          24 bytes
ciphertext                     aead(batch key of header.epoch, nonce, ad = magic||header_len||header, pad(plaintext, 1024))
signature                      64 bytes, sign(device signing key, everything above)
```

`header` = `{"v": 1, "space": b64, "epoch": e, "device": b64, "seq": n, "sv": n}`; `seq`
starts at 1 and grows by one per batch of that device; `sv` is the writer's schema version.
`plaintext` = `{"ops": [operation, …]}`. A batch holds at most 256 KiB after padding, and may
mix operations of several homes; its header names no home.

A receiver MUST verify the signature against the device key in the membership log, MUST
reject a batch of a removed device whose `seq` is above the `last_seq` of its `remove` record
(clocks are chosen by the writer and cannot be trusted for this), and MUST process batches of
one device in `seq` order.

### 2.4 Snapshot

The merged state of the space, so that a new phone need not replay every batch.

```
"HCS1" | header_len u16 | header JSON | stream header 24 bytes | stream chunks | signature 64
```

`header` = `{"v": 1, "space", "epoch", "device", "covers": pos, "vv": {device_b64: seq}, "sv"}`:
`covers` is the last relay position merged; `vv` the last `seq` merged per device. Stream key =
snapshot key; additional data of the first chunk = the bytes before it. Plaintext is JSON lines,
one per row: `{"t", "h", "id", "f": {field: [value, hlc, device_b64]}}`, tombstones included,
then the space settings. Rows of a purged home are not written; the purged homes are those of
the membership log. Chunks of 64 KiB, last chunk tagged `FINAL`.

### 2.5 Membership log

Records are JSON bytes signed as they are, so that no canonical form is needed:

```json
{"payload": b64(record JSON bytes), "sig": b64(sign(signer key, payload bytes))}
```

record = `{"v": 1, "space", "n": index, "prev": b64(hash(previous payload, 32)), "type", "by": device_b64, "c": hlc, …}`:

| `type` | Extra fields | Who may sign |
| --- | --- | --- |
| `genesis` (n = 0, no `prev`) | `device`: {id, sign_pk, box_pk}, `recovery`: {id, sign_pk, box_pk} | the first device |
| `add` | `device`: {id, sign_pk, box_pk}, `member`: row id | an admin |
| `remove` | `device`: id, `last_seq`: the highest `seq` of that device the signer has merged | an admin, or the device itself |
| `epoch` | `epoch`: e | an admin |
| `recovery` | `recovery`: {id, sign_pk, box_pk} (replaces the previous one) | an admin |
| `admin` | `device`: id, `admin`: bool | an admin |
| `purge` | `home`: the home's UUID | an admin |

The genesis device and the recovery key are admins. A record is valid if its signer is an
admin according to the records before it, `n` follows, and `prev` matches. Phones verify the
chain from `n = 0`; the relay does too before storing a record.

### 2.6 Key envelope

`{"epoch": e, "device": b64, "sealed": b64(seal(E[e], device box_pk)), "by": b64, "sig": b64}`,
`sig` over `"hckey1" || space || u32(epoch) || device || sealed` by an admin device. One per
device and per epoch, the recovery key included.

### 2.7 Invitation

QR code text: `hcinvite:1:` followed by `b64` of the JSON
`{"r": "https://relay.example.com", "s": space, "i": invite_id, "k": secret(32), "p": inviter sign_pk}`.

- The inviter registers `proof = hash(32, key = secret, "hcclaim" || invite_id)` with the relay.
- The joiner sends `proof` and `box = aead(kdf(secret, 1, "hcinvite"), nonce, ad = invite_id, {"sign_pk", "box_pk", "device", "name"})`.
- Short code shown on both phones: the first 4 bytes of
  `hash(32, key = secret, inviter_sign_pk || joiner_sign_pk || joiner_box_pk)`, as an unsigned
  integer modulo 1 000 000, six digits with leading zeros.
- After confirmation the inviter posts an `add` record and an envelope for the new device.

### 2.8 Settings of the space

A row `family.settings` holds, among others, `min_sv` (ADR 0003) and the epoch rotation period;
it is synced as any row. Settings and members (`family.member`) are family-wide: they have no
`h`.

### 2.9 Files: photos and PDF

A file (photo or PDF) is a **blob** on the relay, encrypted under its own random key, and a
file reference in the operation of the row that holds it (`rooms.photo`, `stock.article`
label photo, `reports.report`, `projects.projectfile`, `tasks.attachment`).

- **Before upload**: a photo is re-encoded on the phone, as the
  [spec](spec.md#photos-and-files) says; a PDF is sent as it is. At most 20 MiB of plaintext.
- **Blob id**: 16 random bytes. **Blob key**: 32 random bytes, made for that blob only; a new
  version of a photo is a new blob with a new key.
- **Format**:

  ```
  "HCF1"                4 bytes, magic and wire version
  stream header         24 bytes, crypto_secretstream_xchacha20poly1305 under the blob key
  chunks                encrypted chunks of 64 KiB of plaintext (+ 17 bytes each)
  ```

  Plaintext = `pad(file bytes, 65536)`; the true size is `size` in the file reference.
  Additional data of the first chunk = `"HCF1" || space || blob_id`, of the others empty; the
  last chunk is tagged `FINAL`. A receiver MUST reject a blob whose last chunk is not `FINAL`,
  whose decrypted length is not `size` after unpadding, or whose first chunk fails with that
  additional data (a relay that swaps two blobs is caught).
- **Order**: the blob is uploaded (`PUT …/blobs/{id}`) **before** the batch whose operation
  references it. A receiver that finds a reference to a blob it cannot fetch yet shows a
  placeholder and retries; it never drops the field. A phone that sends a batch more than
  7 days after uploading the blobs it references uploads them again first (the same bytes:
  the relay answers as for a repeated upload), so the orphan rule below cannot remove them.
- **Download**: lazily. Phones fetch blobs in the background on an unmetered network, and on
  demand when a photo is opened. The thumbnail is made by each phone from the photo; it is not
  synced.
- **Quota**: blobs count in the space's quota with batches and snapshots (`usage` in
  `GET …/head`). When an upload answers 413, the file stays on the phone, marked "not
  synced", and the operation is still sent: other phones show "photo on another phone"
  until the upload succeeds.
- **Deletion**: when a row holding a file reference is deleted, or the field is changed to
  another file, the previous blob is kept 30 days (a `restore` brings it back), then any phone
  that has merged that deletion sends `DELETE …/blobs/{id}`; 404 counts as done. The device
  that purges a home deletes every blob of that home at once.
- **Orphans**: a blob uploaded but never referenced (the phone died between the upload and the
  batch) is found by `GET …/blobs`; a phone whose state covers the latest snapshot deletes
  blobs older than 7 days that no row of any home references, live or deleted less than 30
  days ago. A purged home has no row left, so its blobs are orphans too: a phone that finds
  some (the purging phone died before deleting them) deletes them at once.

### 2.10 With a Housecairn server

The server mode ([ADR 0010](adr/0010-three-ways-to-use-the-app.md)) sends the operations of
section 2.2, in clear, to the sync API of a Housecairn server: web ADR 0077 for the API and its
merge, web ADR 0078 for the sign-in, both in
[HouseCairn/housecairn#140](https://github.com/HouseCairn/housecairn/pull/140). Everything of
sections 1 and 2.2 holds; the differences are these.

- **The server's device id.** The server writes the edits made on the web as one device: 16
  random bytes, made once per instance, given by its `GET /api/v1/sync/info` as
  `server_device` in `b64`. Ties of HLC are broken by device id bytes (section 1), the server's
  included, the same on both sides.
- **Three numbers.** `seq` (section 2.3) numbers the batches of a device on a relay and is not
  used with a server. The server's position in the change feed of a home is `pos`, the phone's
  cursor, as `pos` is on a relay (section 3.3). The phone numbers each push to the server with
  `push`, per connection, so that a push sent twice runs once.
- **Ids** are unique on the server (section 2.2, `id_taken`). The deterministic ids are those
  of [ADR 0003](adr/0003-sync-protocol.md), with the exact names of its table, and the web
  computes the same ones.
- **File reference**: `{"file": uuid, "sha256": hex, "size": n, "type": "image/jpeg",
  "width": n, "height": n}`. `file` is a UUID made by the phone (instead of the 16 bytes of
  `blob`), there is no `key` since the server stores the file in clear, and `sha256` in
  lower-case hexadecimal names the bytes so that an upload sent twice is recognised. The file
  is uploaded before the push that references it, as with the relay. A phone keeps the form of
  the way it is in.
  **The upload** (lot 4c, [ADR 0012](adr/0012-files-with-a-server.md)): `PUT` of
  `/api/v1/sync/homes/{h}/files/{file}` with the bytes as the body (`application/octet-stream`)
  and the digest in the header `HC-Sha256`; `201` or `200` when taken, `400` `malformed` (digest
  missing or not the body's), `403` `forbidden`, `409` `file_conflict`, `413` `too_large` or
  `quota_exceeded`, `415` `unsupported_type`. `GET` of the same route gives the file the server
  keeps (its own re-encoded copy), `404` when it has none. There is no route to delete a file.
  A refusal is final for the file; `408`, `429` and `5xx` are tried again after a wait that
  doubles, six hours at most. The reference is an object on the wire and JSON text in the
  phone's column.
- **`archived_at`**: owners only (section 2.2).
- **Tombstones are kept 400 days**, not forever as on the relay ([ADR 0003](adr/0003-sync-protocol.md)),
  and the changes of the feed as long. A cursor older than that gets 410 `cursor_expired`,
  and the phone starts again from the server's snapshot by the rule below.
- **An erased home** answers 410 `home_gone` on every route of that home: the phone erases it as
  a purge (section 2.2) and drops every operation of it.

**The operation on the wire** (lot 4b, `ServerTransport.wire`). The phone keeps `deleted_at` as
a field of its `put`s; the server takes a deletion only as `k: delete` or `k: restore`, so the
transport sends a `put` that sets `deleted_at` as a `delete` with the same clock (and the other
fields as a `put`), one that clears it alone as a `restore`, and drops `deleted_at: null` next
to other fields. The columns the server keeps for itself, `updated_at` and `created_at` (but on
`stock.article`, `stock.supplier`, `stock.movement` and `reports.report`, whose `created_at` it
takes), are not sent, nor the derived `visible_from` of `tasks.occurrence` (web
`SYNC_DERIVED`, recomputed on each side, ADR 0003 "Derived"): one of them makes the whole
operation `rejected` with `forbidden`. The
device of the operations is the push's `device`, and their `sv` the push's.

**A push refused** (lot 4b, `ServerTransport.push`). A push holds at most 200 operations of the
phone, 500 on the wire and 1 MiB of body (the server's `ops_per_push` and `push_bytes`); one
operation larger than that alone is kept aside as `too_large` without being sent. A push whose
answer never came, or that got `429` or a `5xx`, is sent again with the same number and the
same bytes, and nothing else. Any other refusal is final, and the server wrote nothing: `400`
(`malformed`, `too_large`; `sync_version` stops the phone instead), `409` (`push_conflict`,
`wrong_device`), `403` `sso_required`. The rule is the maintainer's (decision A, 2026-11-16):
"Envoi refusé définitivement par le serveur : découper l'envoi pour isoler la ou les opérations
fautives, envoyer le reste, mettre les fautives de côté avec un message ; rien n'est perdu en
silence." So the phone forgets the push it would have sent again, then:

- with `malformed` and the `index` of an operation, that operation is kept aside and the others
  are pushed again (another one may be at fault);
- otherwise the push is cut in two halves, each pushed under its own number, and so on until
  each refused push holds one operation, which is kept aside with the code;
- `push_conflict` is first sent once more under the next number, since it is about the number
  and not the operations; `wrong_device` and `sso_required` are about the push's device or the
  home's sign-in, so every half would be refused the same: all its operations are kept aside at
  once, the result the halving would reach.

An operation `rejected` in a push the server took is kept aside the same way, with its code.
What is kept aside leaves `op_log` for a list of this phone only (`local_settings`, never
synced): the app shows each change on its line, with the name of its row and the reason in
words, to be sent again (back to `op_log`, as it was made) or no longer sent. A change no longer
sent gives the row back the server's value at once (maintainer's decision, 2026-11-16): the
fields it wrote lose their clock while it is still the change's, and the phone reads the row
again in the server's snapshot of the home (the sync API has no route that reads one row, and
the phone does not keep the server's earlier values) and merges it by the field rules, which the
server's clocks then win; a row the server does not have goes from the phone as by rule 2 below.
Out of reach, the read waits for the next sync (`server_reread` in `local_settings`); a change
made since on the same field keeps its own clock and stays. The list goes when the phone leaves
the server.

`setAside` and the removal from `op_log` run in one transaction. A push stopped part way by `429`
or a `5xx` still keeps aside what was refused for good before the stop, and applies the fields
that lost; the rest waits in `op_log`.

**A phone restored from a backup** finds no copy of its device id in its secure store, which no
backup carries: it takes a new device id, the waiting changes go under it, and the push whose
answer never came is forgotten, since its bytes name the old id; the server answers a device id
of another connection still in use with `wrong_device`. The access to the server is not in the
backup either: the phone signs in again before it sends anything.

**Starting again after 410.** The phone keeps, per row and outside the row's fields (in its sync
tables, never synced), a mark **seen by the server**. It sets the mark when the row arrives in
the feed or in a snapshot, and when the result of a push for an operation of that row is
`applied`, `ignored` or `repaired`; a `rejected` result, or a push whose answer never came,
does not set it (sending the same push again with the same number gets the first answer, and
sets it then). After 410 the phone reads the snapshot, then for every row of the home it holds:

1. a row in the snapshot is merged field by field, as any incoming change, and gets the mark;
2. a row absent from the snapshot that has the mark was deleted, then purged, on the server: the
   phone deletes it and its local files, and drops the operations of it still waiting to be
   sent, a `restore` included; a long text so dropped goes to the "other version" list, and the
   app lists what it dropped. Its children are not deleted with it: each follows its own rule.
   A child the server had seen is gone from the snapshot too, and goes by this rule; a child
   made on the phone and never sent goes by rule 3, and the server refuses it
   (`invalid_reference`, its parent being gone), so the phone keeps it aside with that reason,
   as any change the server refuses (below). Nothing the server never had is deleted in
   silence;
3. a row absent from the snapshot without the mark was made on the phone and never reached the
   server: the phone keeps it and sends it again as a `put` of every field with its clock;
4. operations still waiting for the rows of rules 1 and 3 are pushed as usual, and the server
   decides each field;
5. rows of the snapshot the phone did not have are added, tombstones included, and the cursor
   becomes the snapshot's `covers`.

So a phone back after more than 400 days cannot bring back what others deleted, and loses
nothing it made that the server never had. The one case the rule gets wrong: a push the server
applied whose answer was lost, never sent again within the 30 days the server keeps a push
number, and whose row someone else deleted and the purge then removed, comes back once by rule
3, and the person deletes it again.

**Plain HTTP between local addresses.** The rule is written once, in web ADR 0078 (section
"HTTPS, and plain HTTP between local addresses"), and this app applies the part it can see
before it sends anything: `http://` is allowed only when the address the person typed is an IP
literal that is not a public address by the rule of the web's `core.netguard.is_public`
(loopback, private networks, unique local IPv6, link-local, the shared space 100.64.0.0/10, the
documentation ranges; an IPv6 address that carries an IPv4 one judged by the IPv4 address).
A name, `.local` and `.home.arpa` included, needs `https://`: a name says nothing of where the
request goes, and a `.local` answer can be forged by anyone on the network. The server checks
the rest (the peer's address, through trusted proxies only). Every plain HTTP connection is
shown with the warning of ADR 0010.

## 3. Relay HTTP API

Base path `/v1`. Requests and answers are JSON unless stated `octet-stream`. Every answer
carries `HC-Protocol: 1`. All routes except `info`, space creation, auth and the store
callbacks need `Authorization: Bearer <token>`; the token names one device of one space.

### 3.1 Discovery and authentication

| Method and path | Body | Answer |
| --- | --- | --- |
| `GET /v1/info` | | `{"protocols": [1], "features": […], "entitlement_required": bool, "push": {"apns": bool, "fcm": bool}, "limits": {…}}` |
| `POST /v1/spaces` | `{"space", "genesis": record, "envelopes": [envelope], "push": optional}` | 201 `{"space"}`; 409 if the id exists |
| `POST /v1/auth/challenge` | `{"space", "device"}` | `{"nonce": b64(32), "expires": unix}` |
| `POST /v1/auth/token` | `{"space", "device", "nonce", "sig": sign("hcauth1" || space || device || nonce)}` | `{"token", "expires_in": 3600}`; 401 if removed or unknown |

### 3.2 Space

| Method and path | Body | Answer |
| --- | --- | --- |
| `GET /v1/spaces/{s}/head` | | `{"pos", "log": n, "epoch", "snapshot_covers", "oldest_pos", "usage": {…}, "entitlement": {…}}` |
| `GET /v1/spaces/{s}/log?after=n` | | `{"records": [...]}` |
| `POST /v1/spaces/{s}/log` | record | 201; 409 if `n` is not next; 403 if the signer may not |
| `POST /v1/spaces/{s}/keys` | `{"envelopes": [...]}` | 201 |
| `GET /v1/spaces/{s}/keys` | | envelopes for the calling device, every epoch |
| `DELETE /v1/spaces/{s}` | | 204; admin only; erases everything at once |

### 3.3 Data

| Method and path | Body | Answer |
| --- | --- | --- |
| `POST /v1/spaces/{s}/batches` | octet-stream batch | 201 `{"pos"}`; 200 with the same `pos` if the same `(device, seq)` and bytes exist; 409 if `(device, seq)` exists with other bytes |
| `GET /v1/spaces/{s}/batches?after=pos&limit=n` | | `{"batches": [{"pos", "data": b64}], "more": bool}`; 410 if `after < oldest_pos`: load the snapshot |
| `PUT /v1/spaces/{s}/snapshot` | octet-stream snapshot | 201 |
| `GET /v1/spaces/{s}/snapshot` | | octet-stream, the latest |
| `PUT /v1/spaces/{s}/blobs/{id}` | octet-stream blob | 201; 200 if the same bytes exist; 409 if it exists with other bytes; 413 over the quota |
| `GET /v1/spaces/{s}/blobs/{id}` | | octet-stream |
| `GET /v1/spaces/{s}/blobs?after=id&limit=n` | | `{"blobs": [{"id", "size", "created": unix}], "more": bool}`, in id order |
| `DELETE /v1/spaces/{s}/blobs/{id}` | | 204; 404 if unknown |

The relay checks on a batch: magic and `v`, `space` matches the route, `device` matches the
token and is not removed, `epoch` is the current one or the one before it (rotation in
progress), signature, size and quota. It never decrypts. `pos` grows by one per accepted batch
of a space and never repeats.

Retention: the relay keeps the two latest snapshots, and every batch with `pos` greater than the
`covers` of the older one; it MAY drop older batches 30 days after a newer snapshot arrives.

Blob format, upload order and deletion: section 2.9. The relay checks the magic and the size of
a blob, never its content. `usage` in `GET …/head` is `{"bytes": n, "limit": n}`, the sum of
the stored batches, snapshots and blobs of the space; the default limit is 2 GiB per space,
that is per family, all homes together ([ADR 0005](adr/0005-relay-server.md)).

### 3.4 Invitations

| Method and path | Body | Answer |
| --- | --- | --- |
| `POST /v1/invites` (inviter's token) | `{"invite", "proof", "expires"}` (at most 15 min) | 201 |
| `POST /v1/invites/{i}/claim` (no token) | `{"proof", "nonce", "box"}` | 202; 404 if unknown, used or expired; one claim only |
| `GET /v1/invites/{i}` (inviter's token) | | `{"state": "waiting" or "claimed", "nonce", "box"}` |
| `DELETE /v1/invites/{i}` | | 204 |

### 3.5 Push and entitlement

| Method and path | Body | Answer |
| --- | --- | --- |
| `PUT /v1/spaces/{s}/push` | `{"platform": "apns" or "fcm", "token", "sandbox": bool}` | 204 |
| `DELETE /v1/spaces/{s}/push` | | 204 |
| `POST /v1/spaces/{s}/entitlement` | `{"store": "apple", "jws"}` or `{"store": "google", "product", "token"}` | `{"state", "expires"}` |
| `POST /v1/stores/apple` | App Store Server Notification V2 | 200 |
| `POST /v1/stores/google` | Pub/Sub push of a Real-time developer notification | 200 |

Wake-up payloads carry nothing: APNs `{"aps": {"content-available": 1}}`, FCM a data message
with no key. A relay without push credentials MAY forward to a push gateway with
`POST <gateway>/v1/wake {"platform", "token", "sandbox"}`.

When `entitlement_required` is true and the space has no active entitlement, uploads answer
402; downloads stay open 30 days after expiry, then the space is deleted.

### 3.6 Errors and limits

Errors: `{"error": code, "detail": text}`, with `limit` and `retry_after` when they apply.
Codes: `bad_request` 400, `unauthorized` 401, `payment_required` 402, `forbidden` 403,
`not_found` 404, `conflict` 409, `gone` 410, `too_large` 413, `rate_limited` 429. Limits are
announced in `GET /v1/info` and are the relay's choice; defaults in ADR 0005.

## 4. Versions

- **Wire**: the magic (`HCB1`, `HCS1`, `HCF1`) and the `v` of headers and records. A new
  construction is a new magic; phones read both during one major version of the app.
- **API**: the path `/v1`. Additions within v1 are new routes, new optional keys and new
  `features`; clients and relays MUST ignore keys they do not know. A change that breaks a
  client is `/v2`, served next to `/v1` for at least a year.
- **Schema**: `sv` in batches and snapshots and `min_sv` in the settings (ADR 0003). The relay
  never looks at `sv` beyond storing it.

## 5. Backup file

Not sent to the relay; defined here to be readable by other tools.

```
"HCBK" | u8 version = 1 | salt 16 bytes | u64 opslimit | u64 memlimit | stream header 24 bytes | chunks
```

Key = `pwhash(32, passphrase, salt, opslimit, memlimit, Argon2id13)`; defaults are libsodium's
`MODERATE` limits. Plaintext: a ZIP with `manifest.json` (format `housecairn-mobile-backup`,
version, app version, date, the list of homes with their id, name and archived state, SHA-256
and size of each entry), `data/<app>.json` (rows with `h`, every field and its clock,
tombstones included; `family.member` and `family.settings` without `h`) and
`files/<blob id>` (plaintext of each file). Chunks of 64 KiB, the last one tagged `FINAL`.
