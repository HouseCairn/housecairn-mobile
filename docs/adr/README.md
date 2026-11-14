# Architecture decision records

One file per decision: context, decision, consequences. A decision is changed by a new record
that says which one it amends. References `file:line` point to `src/housecairn/` of the web
repository at commit `a6953f3`; "web ADR nnnn" is a record of the web repository
(`docs/adr/` there).

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](0001-flutter-stack-and-packages.md) | Flutter stack and packages | proposed |
| [0002](0002-local-storage-and-migrations.md) | Local storage and migrations | proposed |
| [0003](0003-sync-protocol.md) | Sync protocol: operation log, clock, merge rules | proposed |
| [0004](0004-encryption-and-family-keys.md) | Encryption: device keys, family key, invitation, removal, recovery | proposed |
| [0005](0005-relay-server.md) | The relay: language, API, storage, authentication, quotas, push | proposed |
| [0006](0006-subscription.md) | Subscription: purchases checked by the relay | proposed |
| [0007](0007-license.md) | License: AGPL-3.0-only proposed | to confirm |
