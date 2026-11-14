# Sync and relay protocol, version 1

- Status: draft for review (lot 0). Nothing here is implemented yet.
- Decisions behind it: [ADR 0003](adr/0003-sync-protocol.md) (operations, clock, merge),
  [ADR 0004](adr/0004-encryption-and-family-keys.md) (keys), [ADR 0005](adr/0005-relay-server.md)
  (relay), [ADR 0006](adr/0006-subscription.md) (entitlement).
- Words: **space** = the encrypted copy of one home on a relay; **device** = one install of the
  app on one phone; **relay** = any server that implements section 3.

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
| Settings key | 32 bytes | `kdf(E[e], id=3, ctx="hcconf__")` |
| Blob key | 32 bytes | random, per blob, carried in the operation |
| Recovery seed | 32 bytes | random; signing and box keys = `kdf(seed, 1, "hcrecov_")`, `kdf(seed, 2, "hcrecov_")` used as seeds |

### 2.2 Operations

An operation is a JSON object:

```json
{"t": "tasks.task", "id": "8f0c…", "k": "put", "c": "0193a1b2c3d40001",
 "f": {"title": "Change the smoke alarm battery", "repeat_mode": "fixed", "room_id": "1c2d…"}}
```

- `t`: entity type, `<app>.<model>` of the web application in lower case (`homes.home`,
  `rooms.room`, `rooms.item`, `rooms.photo`, `tasks.contractor`, `tasks.task`,
  `tasks.taskmaterial`, `tasks.occurrence`, `tasks.materialdraw`, `stock.article`,
  `stock.supplier`, `stock.movement`, `projects.project`, `projects.budgetline`,
  `projects.quote`, `projects.projectfile`, `projects.projectlink`, `projects.projecttask`,
  `projects.annualenvelope`, `reports.report`), the link tables `projects.project_rooms`,
  `stock.article_rooms`, `stock.article_compatible_items`, and the types of the app
  `family.member` and `family.settings`.
- `id`: row id. Deterministic ids (ADR 0003) are `uuid5(home_id, name)`.
- `k`: `put` (set the fields in `f`), `delete` (sets `deleted_at`), `restore` (clears it).
- `c`: HLC of the operation; it is the clock of every field it sets.
- `f`: field names are those of the web model, foreign keys by their column name (`room_id`).
  Values: string, number, boolean, `null`; amounts and quantities as decimal strings (`"12.50"`);
  dates `"YYYY-MM-DD"`; instants as HLC strings. A photo or file field holds
  `{"blob": b64, "key": b64, "size": n, "type": "image/jpeg", "w": n, "h": n}`.
- A receiver MUST keep fields it does not know and MUST NOT drop the operation.

**Apply** (every phone, same result in any order): for each field of `f`, write the value if
`(c, device)` is greater than the stored clock of that field, and store the new clock. `delete`
and `restore` are the field `deleted_at`. Then run the repair rules of ADR 0003.

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
`plaintext` = `{"ops": [operation, …]}`. A batch holds at most 256 KiB after padding.

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
one per row: `{"t", "id", "f": {field: [value, hlc, device_b64]}}`, tombstones included, then
the space settings. Chunks of 64 KiB, last chunk tagged `FINAL`.

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
it is synced as any row.

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
| `PUT /v1/spaces/{s}/blobs/{id}` | octet-stream blob | 201; 409 if it exists with other bytes |
| `GET /v1/spaces/{s}/blobs/{id}` | | octet-stream |
| `DELETE /v1/spaces/{s}/blobs/{id}` | | 204 |

The relay checks on a batch: magic and `v`, `space` matches the route, `device` matches the
token and is not removed, `epoch` is the current one or the one before it (rotation in
progress), signature, size and quota. It never decrypts. `pos` grows by one per accepted batch
of a space and never repeats.

Retention: the relay keeps the two latest snapshots, and every batch with `pos` greater than the
`covers` of the older one; it MAY drop older batches 30 days after a newer snapshot arrives.

Blob format: `"HCF1"`, stream header (24 bytes), chunks of 64 KiB under the blob key, the
size padded with `pad` to a multiple of 64 KiB. Phones delete a blob 30 days after the row that
referenced it was deleted.

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
version, app version, date, home id, SHA-256 and size of each entry), `data/<app>.json` (rows
with every field and its clock, tombstones included) and `files/<blob id>`. Chunks of 64 KiB,
the last one tagged `FINAL`.
