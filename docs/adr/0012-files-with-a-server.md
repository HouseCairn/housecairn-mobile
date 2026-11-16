# 0012. Photos and files with a Housecairn server

- Status: proposed
- Date: 2026-11-16

## Context

Lot 4b gave the third way its rows. Its files were left for this lot: with a server, `putFile`,
`getFile` and `deleteFile` of `ServerTransport` answered "Files need a server with the file
routes of web ADR 0077", so a photo made on the phone never reached the server, and a photo
added on the web never reached the phone. The server (0.5.0) has the routes: web ADR 0077
(need 10, "As built (lot M6)") and `docs/api/sync.md` of the web (section "Files") decide them.
This record says how the app uses them. It amends [ADR 0010](0010-three-ways-to-use-the-app.md),
need 10, where the upload was written as multipart: the server took an octet-stream.

## Decision

**The wire.** `PUT /api/v1/sync/homes/{h}/files/{file_id}` with the bytes as the body
(`Content-Type: application/octet-stream`) and the header `HC-Sha256` (the digest in lower-case
hexadecimal); `GET` of the same route gives the file the server keeps, which is its own
re-encoded copy: the bytes the phone gets back are not those it sent, and the phone does not
compare them with its digest. A file reference in an operation is an object on the wire
(`{"file", "sha256", "size", "type", "width", "height"}`) and JSON text in the column of the
phone (`photos.image`, `project_files.file`): `ServerTransport` converts both ways, so the engine
and the merge still see a text.

**One reference, one id of its own.** A new photo or file gets `file`, a UUID that is not the id
of its row, and the SHA-256 of its bytes, at the moment it is stored. The file on the phone stays
named by the id of its row (ADR 0002); `file` names it on the server. A photo made on the web
is named by the id of its row and has no digest. A row of the first builds, whose reference had
neither (`{"size", "type", ...}`), is completed from the file the phone holds: `file` is derived
from the id of the row, so every operation of the row names the same file, and the digest is
computed. The operations of the first builds still waiting in `op_log` are completed the same
way before they are sent, since the server refuses a reference without them (`400` `malformed`).

**The order, and what never blocks.** A round of sync is: the files to send, the push of the
rows, the pull, the files to fetch, the sweep. The file goes before the row that names it, as
web ADR 0077 asks; if it fails, the row goes all the same (the server applies it and the row
"waits for its file"), and the file waits for the next round. Only the server stopping the phone
(`ServerStopped`) ends a round; one file failing never does.

**What is kept: `file_sync` (schema 8).** One row per file reference of a row of a home of the
server: the id, the home, the row, the way (`up`: this phone made it; `down`: another did), a
state (`waiting`, `done`, `failed`), the number of tries, the earliest next try and the code of
the last refusal. Never synced, never exported, emptied when the phone leaves the server and
when a row or a home is purged. The list is made from the rows (a scan before each step): a file
the phone holds under a reference with a digest is to send; a reference with no file on the
phone is to fetch; a reference with no digest and a file is a server's, already done. It lives
in a table and not in `local_settings` because it has one entry per photo, read by state.

**Tries.** A file that could not go (the server busy, out of reach, `404`) waits 30 seconds, then
twice as long at each failure, six hours at most; the next round does not try it before. "Send
now" in Settings clears every wait and every refusal and syncs. A refusal for good, `400`
(a digest that is not the one of the bytes), `403`, `409`, `413` (`too_large`, `quota_exceeded`)
or `415`, is written down with its code, shown in Settings in plain words, and not tried again by
itself: no loop. A file larger than `file_max_bytes` of `info.limits`, or whose bytes are no longer
the ones its row names, is not sent at all. A round sends at most half the `pushes_per_minute` of
the server and reads half its `reads_per_minute`, so that its push and its pull keep theirs. A
`404` on a file to fetch is not an error: the server does not have it yet, as when another phone's
upload has not come; the row shows its tile and the phone asks again later.

**Fetching: in the round, not when a photo is opened.** The files of rows that came with the pull
are fetched after it, newest first, within the budget above, and the thumbnail of a photo is made
at once. The alternative, fetching a photo when its screen opens, would leave every grid of
thumbnails empty until each photo is opened one by one, and a photo opened without a connection
would show nothing. The price is data used on a mobile connection: a setting for Wi-Fi only, which
the [spec](../spec.md#photos-and-files) says for the relay, is not part of this lot. Until its file
has come, a photo is a plain tile, and its screen says "Photo not on this phone"; a file that was
fetched is never sent back.

**Deleting.** A deleted photo or file is a tombstone like any row and goes to the server as
`delete`. A server has no route to delete a file (web ADR 0077: a file no row refers to, live or
deleted within the retention, is removed after 7 days), so `deleteFile` of the server transport
does nothing. On the phone the file stays 30 days after the deletion, so that it can be restored
([spec](../spec.md#photos-and-files)), then the sweep of a round removes it, its thumbnail and
its entry, whichever phone deleted the row.

**Not in this lot.** The label photo of a stock article and the photo of a report, whose
reference the server keeps in `extra` until a lot of its own; the files attached to a task, which
the app does not show yet; a Wi-Fi only option; the space used on the server.

## Consequences

- A photo or a file made on a phone is on the server and on the other phones after a few rounds,
  with its digest on both sides; a photo added on the site comes to the phone.
- `SyncTransport.putFile` and `getFile` take the home, as the server routes do, and `putFile`
  the digest and type; `FileRefused` and `FileNotFound` say what the other side answered.
- The reference of a photo changes shape (`file` and `sha256` added): a phone of an earlier
  build completes its old photos by itself.
- The test of the whole round is `test/files_sync_test.dart`, against the scripted server of
  `test/support/files_server.dart`; the real server runs in the e2e job.
