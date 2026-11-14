# Security policy

## Supported versions

Housecairn mobile has no release yet. The builds of the continuous integration are
for testing only and receive no security fixes. When versions are published, only the
latest one will receive security fixes, in a new version.

| Version | Supported |
| ------- | --------- |
| none released | No |

## Reporting a vulnerability

Please report vulnerabilities **only** through GitHub Private Vulnerability
Reporting, with the private form at
<https://github.com/HouseCairn/housecairn-mobile/security/advisories/new> (or: the
repository's **Security** tab, then **Report a vulnerability**). If that form is not
available, use the one of the web application,
<https://github.com/HouseCairn/housecairn/security/advisories/new>, and say that the
report concerns the mobile app. You need a GitHub account; the report is visible only
to you and the maintainer.

Do **not** open a public issue, pull request or discussion about a
vulnerability.

You will receive an acknowledgement within 7 days. We will then work with you
on an assessment and a fix, and agree on a disclosure date. If you wish, you
will be credited in the published advisory.

What the app protects, from whom, and what it does not protect is written in the
[threat model](docs/threat-model.md); the sync protocol is in
[docs/protocol.md](docs/protocol.md).

## How the code is protected

- every pull request passes automatic checks before the maintainer reads it:
  formatting, static analysis, unit and widget tests, Android and iOS builds;
- the licence of every dependency, direct or transitive, is checked against an
  allowed list, and no analytics, crash reporting or advertising package may enter the
  dependency tree (`tool/check_licenses.dart`);
- the Flutter SDK is installed from its official archive, whose SHA-256 is pinned in
  the repository and checked on every run;
- zizmor checks the GitHub Actions workflows;
- GitHub Actions are pinned to full commit SHAs, workflow tokens are read-only
  unless a job needs more, and no workflow runs the code of a pull request with
  write access;
- Dependabot proposes dependency updates weekly, only once a release has been
  public for 7 days; security updates are not delayed.
