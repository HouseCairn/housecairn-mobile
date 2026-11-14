# 0007. License: AGPL-3.0-only, with the NOTICE and CLA of the project

- Status: accepted (maintainer's decision, 2026-11-14)
- Date: 2026-11-14

## Context

The web application is `AGPL-3.0-only`, with a `NOTICE` giving the copyright to the pseudonym
of the maintainer and a short contributor licence agreement (CLA) that allows relicensing. The
mobile app and the relay must be open source: the hosted relay is sold, and anyone may run
their own. The app will be distributed through the App Store and Google Play.

## Decision

**`AGPL-3.0-only` for the app and the relay**, with the same `NOTICE` (copyright of the
pseudonym, attribution "Housecairn, by Robvred" under section 7(b), no trademark grant under
section 7(e)) and the same CLA as the web application.

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

Alternatives rejected: `MPL-2.0` for the app (file-level copyleft, no store question, but code
no longer moves freely to the web application); `GPL-3.0-only` for the app and AGPL for the
relay (two rules for one project, for no gain).

## Consequences

- `LICENSE` is the text of the web repository, byte for byte; `NOTICE` is the web one with the
  name of this repository. The relay repository (lot 6) gets the same two files.
- `CONTRIBUTING.md` points to the CLA of the web repository, which covers every repository of
  the project. Its automatic check is not set up here yet: no external contribution is merged
  before it is, and before the CLA's legal review.
- The "About" screen of the app (lot 1) shows the attribution required by `NOTICE`.
