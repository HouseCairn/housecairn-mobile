# 0007. License: AGPL-3.0-only proposed, to confirm

- Status: proposed, decision of the maintainer due
- Date: 2026-11-14

## Context

The web application is `AGPL-3.0-only`, with a `NOTICE` giving the copyright to the pseudonym
of the maintainer and a short contributor licence agreement (CLA) that allows relicensing. The
mobile app and the relay must be open source: the hosted relay is sold, and anyone may run
their own. The app will be distributed through the App Store and Google Play.

## Decision

**Proposed: `AGPL-3.0-only` for the app and the relay**, with the same `NOTICE` and CLA as the
web application.

- **Relay**: the AGPL is the licence made for a network service: whoever runs a modified relay
  for others must offer its source. It also lets the relay app later move into a Housecairn
  instance under the same licence ([ADR 0005](0005-relay-server.md)).
- **App**: the same licence keeps one rule for the whole project, and lets code and the task
  template library (`tasks/task_templates.yaml`) move between the web and the app.
- **Dependencies** listed in ADR 0001 and ADR 0005 are MIT, BSD, ISC, Apache-2.0 or LGPL-3.0
  (psycopg, as an option); all may be combined with AGPL-3.0. Lot 1 checks it in CI.

**App stores**: the terms of the App Store add restrictions that are commonly held to conflict
with the GPL family when a third party publishes someone else's GPL code. Here the publisher is
the copyright holder, who may distribute under other terms, and the CLA gives the right to do
so for contributions. This is the reason to keep the CLA for this repository; it is not legal
advice, and the CLA is still a draft until a lawyer reads it.

Alternatives: `MPL-2.0` for the app (file-level copyleft, no store question, but code no longer
moves freely to the web application), `GPL-3.0-only` for the app and AGPL for the relay.

## Consequences

- No `LICENSE` file is published until the maintainer confirms.
- If confirmed, the README, `NOTICE` and CLA come in lot 1, copied from the web repository with
  the name of this repository.
