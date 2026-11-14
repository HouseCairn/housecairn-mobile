# 0010. The look of the web application, adapted to the phone

- Status: proposed. A design lot before lot 2b is the maintainer's decision of 2026-11-14; what
  is taken and what is adapted is the choice this record proposes.
- Date: 2026-11-14

## Context

Lot 2a shipped its screens with the colours of the web application only: the system font,
Material's own components and sizes. On a phone the app did not look like Housecairn. The web
application has one visual system ([web ADR 0017](https://github.com/HouseCairn/housecairn/blob/main/docs/adr/0017-visual-system-and-brand.md)):
its values are in `design/tokens.json`, its components in `static/css/components.css`,
`shell.css` and `tasks.css`, its icons in `templates/components/icon.html`, its font is
Manrope. It has no dark theme (`color-scheme: light`, `base.css`).

## Decision

**Taken from the web, value for value.**

- **Tokens.** `design/tokens.json` keeps every group of the web file unchanged (colours, font,
  space, radius, shadow, layout) and adds `component`, the few sizes the web components write in
  their own CSS (row height, pill padding, icon size, stroke, focus ring), and `$sources`, the web
  path of every value. `lib/design/tokens.dart` carries them in Dart; a test compares the two.
- **Font.** Manrope, in the four weights the web draws (400, 600, 700, 800), bundled
  (`assets/fonts/README.md`): the static files of the official repository, unmodified, of the
  same version as the web's subset (4.505), under the SIL Open Font License 1.1, which `NOTICE`
  names and the licence check accepts for fonts. The web serves a variable WOFF2 subset, which
  Flutter does not read.
- **Type scale and roles** (`HcText` in `lib/design/theme.dart`): page title (`h1`, 24 px,
  800), group heading (`h2`, 13 px, 700, capitals, tracking 0.08 em, muted, in the danger colour
  for what is overdue), row title (16 px, 600) and row text (13 px, muted), buttons (16 px, 700;
  14 px for the small ones), field labels above the field (14 px, 700, muted), pills (13 px,
  700).
- **Components** (`lib/design/widgets.dart`, and the theme for Material's own widgets): the
  card and the card list (white, a border, 14 px corners, a line between rows), the row with
  its chevron, the task row with its one-tap Done button and the danger background when overdue,
  the pill in its seven tones, the empty state in a dashed frame, the field with its label
  above, the primary, secondary and danger buttons (12 px corners), the bar with the five
  sections and the icons of the web, the home selector, the undo bar in sage.
- **Icons.** The outline icons of the web (24 px grid, 2 px stroke), drawn from the same shapes
  (`lib/design/icons.dart`); a `+` is added for the floating button, in the same stroke.

**Adapted to the phone, and why.**

| Web | App | Why |
| --- | --- | --- |
| Brand bar, then the page title as `h1` in the page | The title in the app bar, in the `h1` style; the selector of the current home at its end | The app bar is where a phone shows the title and the back button; the brand is the app icon |
| Back link at the top of the page | The back button of the app bar, the system back of Android, the back gesture of iOS (`MaterialPageRoute`) | What each platform's users expect; the gesture comes with the route |
| "Add a task", a block button after the list | A floating button, primary colour, 12 px corners | Reachable with the thumb whatever the length of the list |
| Targets of 44 px, Done of 48 px | 48 px for every target (`touch-target-lg`) | The minimum of Android, and the size Material's own widgets keep |
| Hover colours | None (`hoverColor` transparent); a sand ripple on press | No hover on a touch screen |
| Undo banner above the bar | Floating snack bar above the bar, sage, border, action in the primary colour | The same place and look, with the platform's announcement to screen readers |
| Skip and Postpone on the task page | Also in the menu of each row of Today, behind the `…` icon of the web | Lot 2a already offered them there; one tap fewer |
| Number and unit side by side, the unit under the number when too narrow (`.field-pair`) | Side by side, stacked from a text size of 1.3 | The same rule, decided by the text size of the phone |
| Text sizes scale with the browser | Text sizes scale with the phone; the labels of the bar keep their size, and the Save action of the app bar grows up to 1.3 times | Five labels side by side at 360 px, as the tab bar of iOS does; a larger Save pushes the back button out of the bar |
| Safe area of the bar (`env(safe-area-inset-bottom)`) | `Scaffold` and `NavigationBar` keep the safe areas | The same rule, done by the framework |

**Not taken.** No dark theme: the web has none. No page title and back link inside the page,
no breadcrumbs, no computer layout with a column on the left: the app is a phone app. The help
link of the web (to its documentation site) waits for a lot that decides the app's help.

**Rules for the next screens** (lot 2b on): a screen uses the components of `lib/design/` and
the themed Material widgets, and writes no colour, text style or size of its own;
`test/design_rules_test.dart` fails otherwise, and checks the contrast of every pair of text and
background the components draw against WCAG 2.2 AA (4.5:1). Golden files of each screen at
360 px, in English and French, at text scale 1 and 2 (`test/goldens/`), drawn with the bundled
font, make every change of look visible in review; they hold the data of the test fixture only.

## Consequences

- The app looks like the web application on a phone; the components of lot 2b exist before its
  screens.
- A change of a web token reaches the app through `design/tokens.json`; a change of a web
  component needs the matching change in `lib/design/`, which the golden files show.
- Four font files (about 580 kB) are bundled; their SHA-256 is checked in CI.
- Golden files are compared with a tolerance of 0.2 % of the pixels, so that anti-aliasing
  differences between two Linux machines do not fail CI; they are regenerated with
  `flutter test --update-goldens test/goldens_test.dart` and reviewed in the pull request.
