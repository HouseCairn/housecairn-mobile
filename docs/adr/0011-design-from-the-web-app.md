# 0011. The look of the web application, adapted to the phone

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
  (`lib/design/icons.dart`); a `+` is added, in the same stroke.
- **The add buttons, where the web has them** (`HcAddButton`): "Add a task" a primary block
  button after the list of Today, "Add a contractor" the same after the contractors, "Add a
  home" and the "Add a task" of a room or an item secondary block buttons, "Add a room" a
  secondary button as wide as its label; each after its list, 12 px under it, scrolling with
  it. The app has no floating button: the maintainer found the app, on the same iPhone as the
  web, laid out differently because of it.

**Adapted to the phone, and why.**

| Web | App | Why |
| --- | --- | --- |
| Brand bar, then the page title as `h1` in the page | The title in the app bar, in the `h1` style; the selector of the current home at its end | The app bar is where a phone shows the title and the back button; the brand is the app icon |
| Back link at the top of the page | The back button of the app bar, the system back of Android, the back gesture of iOS (`MaterialPageRoute`) | What each platform's users expect; the gesture comes with the route |
| Targets of 44 px, Done of 48 px | 48 px for every target (`touch-target-lg`): buttons 48 high where the web's are 45.2 (44 and a border), fields 48 where the web's are 50 | The minimum of Android, and the size Material's own widgets keep |
| Hover colours | None (`hoverColor` transparent); a sand ripple on press | No hover on a touch screen |
| Undo banner above the bar | Floating snack bar above the bar, sage, border, action in the primary colour | The same place and look, with the platform's announcement to screen readers |
| Skip and Postpone on the task page | Also in the menu of each row of Today, behind the `…` icon of the web | Lot 2a already offered them there; one tap fewer |
| Number and unit side by side, the unit under the number when too narrow (`.field-pair`) | Side by side, stacked from a text size of 1.3 | The same rule, decided by the text size of the phone |
| Text sizes scale with the browser | Text sizes scale with the phone; the labels of the bar keep their size, and the Save action of the app bar grows up to 1.3 times | Five labels side by side at 360 px, as the tab bar of iOS does; a larger Save pushes the back button out of the bar |
| Safe area of the bar (`env(safe-area-inset-bottom)`) | `Scaffold` and `NavigationBar` keep the safe areas | The same rule, done by the framework |
| Room list: a search form, "Change the order" with up and down buttons, "Add a room" | The list and "Add a room" after it; no search, no reordering (rooms keep the household's order, then their creation) | Search and a reordering screen are not in the plan of lot 2b; the order is the web's, `position` then creation |
| Room page: photos filtered by category chips, the stock of the room, the label tools | Photos as one grid (the category is on each photo, and on its own screen); no stock, no labels | Stock is lot 3; labels are not in v1 |
| Photo: an upload form (file field) | A sheet with Take a photo and Choose from the gallery, permission asked at that moment; the photo is re-encoded before it is stored | A phone has a camera, and the location must not leave it |
| Contractor: a vCard download | Call and Write buttons on the card (`tel:`, `mailto:`) | What a phone does with a number; the spec asks for call and e-mail |
| Reminder preferences per member (days before, hour) | One switch in More, the web's defaults (1 day before, 08:00, follow-ups by priority) | The per-member settings come with sync; the permission is asked when the switch is turned on |

**Not taken.** No dark theme: the web has none. No page title and back link inside the page,
no breadcrumbs, no computer layout with a column on the left: the app is a phone app. The help
link of the web (to its documentation site) waits for a lot that decides the app's help.

**Same rendering as the web, measured** (`test/web_parity_test.dart`). Checking the tokens
and the CSS by reading the code was not enough: the maintainer, on an iPhone, found the app
smaller and laid out differently from the web opened on the same phone. The test opens each
screen at 390 x 844 logical pixels (an iPhone) in French, with the web's demonstration data,
and compares what it measures on the render tree with what `tool/web_parity.py` measured in a
headless browser on the web at 390 x 844 CSS pixels (`test/parity/web_fr_390.json`): the
drawn size and weight of the page title, section headings, row titles, row texts, pills,
labels and buttons, the line height of rows, the left margin, the height of the bar, of the
fields, of the buttons and of the rows, the place, width, height and gap of the add button and
that it scrolls with the list. On Today it also compares the words: each section's heading with
its count, and for each row its title, its place, its pills and its height. A CSS pixel and a
logical pixel are the same unit on a phone (a point on iOS, a dp on Android), and the app
applies no scale of its own: the text scaler is the phone's, untouched except in the bottom
bar and the Save action (above). The differences kept on purpose are listed in the test with
their reason (`adaptations`: a value the app has instead; `absences`: a measure one side lacks;
`menuWraps`: a row whose title takes a second line); every other measure must equal the web's,
within 0.01 px for a text size and 1.5 px for a box, and a measure taken on one side only fails.
The web's measures carry the release and commit they were taken at (`web` of the file), which
`tool/web_alignment.py check` compares with the pin `web_parity`: when a web release changes a
file that draws these screens, `update` moves the pin, and `check` fails until the measure is
taken again with `tool/web_parity.py`.

**Today, as the web's v0.3.2.** Sections *Overdue*, *Today*, *Coming up* (and *No date*), each
heading followed by its count in brackets; under each title the room, then the item
(`Room · Item`; on All homes the home first); the date as a pill in the web's format
(`21 nov. 2026`), not "Due ..."; the lines of the row at 1.3 (title) and 1.35 (place), as the
web's CSS. Kept apart from the web, with the reason:

| Web (v0.3.2) | App | Why |
| --- | --- | --- |
| Offer to receive the reminders on this device (`_device_banner.html`, Web Push) | None | The app's reminders are local notifications, asked by the switch in More; there is no Web Push subscription to offer |
| *Photo* pill on a task born from a report with a photo; "Report a problem" | None | Reports are a web feature that the app does not have; its tasks carry no report |
| Undated tasks only when in season, under *In season* | Undated tasks under *No date* | The app has no seasons on Today yet; showing them is the safer error |
| A postponed task shows its date | A postponed task shows an info pill "Postponed to ..." | The state is useful on a phone and a test pins it; a later lot may drop it |
| Order of one day: priority, then creation | Creation | Not measured by the demonstration data (every task is of normal priority but one, alone in its section) |
| A row has Done and nothing else | Done and a menu of skip and postpone (48 dp) | The app has no other place for them; a long title therefore wraps one line sooner (`menuWraps`, the height is the web's plus one line) |
| Rows of a room and of an item: the date as plain text under the title | The same | Was a pill until this change |

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
