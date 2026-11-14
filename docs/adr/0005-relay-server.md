# 0005. The relay: language, API, storage, device authentication, quotas, push

- Status: proposed
- Date: 2026-11-14

## Context

The relay is a mailbox for ciphertext: it accepts batches, snapshots and photos from the
phones of a space, gives them back in order, and wakes the other phones. It is sold as a hosted
service and must also run, free, on a household's own server. Later, a Housecairn instance may
play the same role ([ADR 0003](0003-sync-protocol.md)). The protocol is in
[protocol.md](../protocol.md).

## Decision

**A separate public repository, `HouseCairn/housecairn-relay`, from lot 6** (maintainer's
decision); until then the relay exists only as this record and [protocol.md](../protocol.md).

**Python 3.13 and Django 5.2 LTS, with Django REST framework**, the stack of the web
application (its `pyproject.toml` pins `django>=5.2.8,<5.3` and `djangorestframework>=3.16`).
Django 5.2 LTS has extended support until April 2028
(<https://www.djangoproject.com/download/>). The relay is written as a **reusable Django app**
(`housecairn_relay`) inside a small standalone project: the same app can later be installed in
a Housecairn instance, which then is a relay without a second implementation. The same tools
as the web repository: uv, ruff, mypy, pytest, the same CI and supply-chain rules.
Alternative rejected: Go, for a single static binary; it would add a second server language
for one maintainer and a second implementation for the instance.

Server-side packages, read on PyPI on 2026-11-14:

| Need | Package | Version, date | License | Page |
| --- | --- | --- | --- | --- |
| Verify Ed25519 signatures | PyNaCl | 1.6.2, 2026-01-01 | Apache-2.0 | <https://pypi.org/project/PyNaCl/> |
| Verify App Store transactions | app-store-server-library (Apple) | 3.1.2, 2026-06-01 | MIT | <https://pypi.org/project/app-store-server-library/> |
| Google Play Developer API | google-api-python-client, google-auth | 2.202.0, 2026-11-10; 2.62.2, 2026-11-10 | Apache-2.0 | <https://pypi.org/project/google-api-python-client/> |
| APNs over HTTP/2 | httpx with h2 | 0.28.1, 2024-12-06; 4.4.1, 2026-08-03 | BSD-3-Clause; MIT | <https://pypi.org/project/httpx/>, <https://pypi.org/project/h2/> |

httpx has had no release for almost two years; it is widely used and small enough to replace
behind the push sender if needed.

**API**: HTTPS and JSON under `/v1/`, binary bodies as `application/octet-stream`. Resources:
info, spaces, membership log, key envelopes, batches with a cursor, snapshots, blobs,
invitations, push tokens, entitlement, store notifications. No WebSocket: phones pull on
opening, in the background, and when woken.

**Storage**: SQLite by default, PostgreSQL as an option (as the web application). Blobs and
snapshots as files in a directory, named by random ids; an S3-compatible store later if the
hosted service needs it. The database holds ids, public keys, sizes, cursors, signed records,
quotas and entitlements; never a clear text of the family.

**Authentication of phones without an account**: a phone proves it holds the signing key of a
device registered and not removed in the space's membership log. `POST /v1/auth/challenge`
gives a random nonce; the phone signs it with the space and device ids; the relay answers with
a bearer token valid one hour, stored hashed. No e-mail, no password, no name. A space is
created by its first phone with its public keys and the genesis record.

**Quotas** (defaults of the hosted relay, all settings of a self-hosted one): 12 phones per
space, **2 GiB per space, that is per family and all its homes together** (batches, snapshots,
photos and PDF; maintainer's decision), 256 KiB per batch, 20 MiB per file,
50 MiB per snapshot, 600 requests an hour per phone, 10 invitations a day per space. Over a
quota the relay answers 413 or 429 with the limit in the body; the app shows it in words.

**Push wake-up, with no content**: when a batch arrives, the relay wakes the other phones of
the space, at most once every 20 minutes per phone. iOS: an APNs background notification
(`content-available`, `apns-push-type: background`, priority 5); Apple asks not to send more
than two or three an hour and may not deliver them
(<https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app>).
Android: an FCM data message with no field. The payload never holds a space id, a count or a
title. Push credentials (APNs key, FCM service account) belong to the publisher of the app: a
**self-hosted relay** either runs without push (the phones sync on opening and in the
background), or forwards wake-ups to the publisher's **push gateway**, which receives only a
push token and returns nothing. The gateway is **open to self-hosted relays at no cost, with a
rate limit** per relay and per push token (maintainer's decision); the limits are announced
by the gateway, as a relay announces its own.

**Hosting of the paid relay**: in the European Union (maintainer's decision), with its data,
its backups and the push gateway.

**Docker image** for self-hosting: one container, amd64 and arm64, a non-root user, the
database and the files in one volume, configuration by environment variables
(`RELAY_REQUIRE_ENTITLEMENT=false` by default for a self-hosted relay), published on GHCR by
digest with provenance and SBOM, as the web image (web ADR 0015).

## Consequences

- The relay needs no knowledge of the model: a new version of the app does not need a new
  relay unless the protocol's major version changes.
- A compromised relay can withhold, delay or delete data, and read the metadata; it cannot read
  or forge content, nor add a phone ([threat model](../threat-model.md)).
- The publisher's push gateway is a shared service with a cost, open to self-hosted relays:
  its rate limit is what keeps that cost bounded, and it must be abuse-proof without knowing
  who runs a relay.
- A conformance test suite, in the relay repository, drives the HTTP API from the outside; a
  Housecairn instance that wants to be a relay passes the same suite.
