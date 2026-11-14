# Architecture decision records

One file per decision: context, decision, consequences. A decision is changed by a new record
that says which one it amends. References `file:line` point to `src/housecairn/` of the web
repository at commit `a6953f3` (`main` on 2026-11-14); "web ADR nnnn" is a record of the web
repository (`docs/adr/` there).

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](0001-flutter-stack-and-packages.md) | Flutter stack and packages | proposed |
| [0002](0002-local-storage-and-migrations.md) | Local storage and migrations | proposed |
| [0003](0003-sync-protocol.md) | Sync protocol: operation log, clock, merge rules | proposed, amended by 0008 |
| [0004](0004-encryption-and-family-keys.md) | Encryption: device keys, family key, invitation, removal, recovery | proposed, amended by 0008 |
| [0005](0005-relay-server.md) | The relay: language, API, storage, authentication, quotas, push | proposed |
| [0006](0006-subscription.md) | Subscription: purchases checked by the relay | proposed, amended by 0008 |
| [0007](0007-license.md) | License: AGPL-3.0-only, with the NOTICE and CLA of the project | accepted |
| [0008](0008-several-homes-one-family-space.md) | Several homes in v1: one encrypted space per family | proposed |
| [0009](0009-early-testflight-builds.md) | TestFlight builds from `main`, from lot 1b on | proposed |
| [0010](0010-design-from-the-web-app.md) | The look of the web application, adapted to the phone | proposed |
