# Housecairn mobile

![status: foundations](https://img.shields.io/badge/status-foundations-lightgrey.svg)
![stage: alpha](https://img.shields.io/badge/stage-alpha-orange.svg)

A phone app for iOS and Android that answers the question
[Housecairn](https://github.com/HouseCairn/housecairn) answers on the web: **what to do in the
home, where, when, with what and for how much**. Recurring upkeep (the battery of a smoke
alarm, the filter of the ventilation) and one-off work (repaint the living room) in one place,
with a planned budget, a stock of materials and a history.

## What it is

- **Standalone.** The data lives on the phone, in SQLite. The app works fully with no
  network, no account and no server. It does not need a Housecairn instance.
- **Free.** Every feature that runs on one phone is free.
- **Several homes.** A main home, a second home, a rented flat: one app, one switch.
- **Family sync, paid by subscription.** Phones of one household share all their homes, photos
  included, through a relay that stores and forwards **end-to-end encrypted** data it cannot
  read. The hosted relay will run in the European Union.
- **Open.** App and relay are open source. The hosted relay is sold; anyone can run their
  own relay, and point the app at it, at no cost.
- **One code base**, Flutter, for both platforms.
- **Documented protocol.** The sync protocol is versioned and written down so that another
  server, a Housecairn instance later, can play the relay.

Not in the first version: the Home Assistant integration, the connectors of the web
application (Paperless-ngx, Sure, Apprise), calendar feeds.

## Status

**Early.** Lot 2b adds the rooms, items, contractors, task templates, photos and local reminders to the foundations. The documents below frame the app; the code has its foundations (lot 1 of
the [plan](docs/plan.md)): the Flutter project for Android and iOS, the app shell with its
five sections and an About screen, English and French, the empty database, and the
continuous integration (checks, tests, licences of every dependency, an Android APK and an
unsigned iOS build on every pull request). No feature yet, and nothing is released; the
first builds will be alpha. How to build and test: [CONTRIBUTING.md](CONTRIBUTING.md).

| Document | What it settles |
| --- | --- |
| [docs/spec.md](docs/spec.md) | Scope of v1: what is taken from the Housecairn model, simplified or left out; screens; reminders; encrypted export |
| [docs/adr/](docs/adr/) | Decisions: stack and packages, local storage, sync, encryption, relay, subscription, license, several homes in one family space |
| [docs/protocol.md](docs/protocol.md) | Sync and relay protocol, precise enough for another server to implement |
| [docs/threat-model.md](docs/threat-model.md) | What is protected, from whom, and what is not |
| [docs/plan.md](docs/plan.md) | Lots 1 to 9, with acceptance criteria, and the questions still open |

## Related

- [HouseCairn/housecairn](https://github.com/HouseCairn/housecairn): the self-hosted web
  application, whose data model this app follows.
- `HouseCairn/housecairn-relay`: the relay, in its own repository from lot 6 of the plan.
- Documentation of the web application: <https://docs.housecairn.app>.

## How it is made

Housecairn is developed with an AI coding agent, under human review. Each pull request is
reviewed by a second AI model, then read and merged by the human maintainer, who is
responsible for what enters the repository. Every pull request states which AI tool and model
were used.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md): the CLA of the project and a `Signed-off-by` on every
commit.

## License

Housecairn mobile is free software under the GNU Affero General Public License, version 3 only
(`AGPL-3.0-only`), as the web application: see [LICENSE](LICENSE), and [NOTICE](NOTICE) for the
copyright and the additional terms (author attribution, trademark) under section 7
([ADR 0007](docs/adr/0007-license.md)).
