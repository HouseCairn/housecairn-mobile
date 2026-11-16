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
| Brand bar, then the page title as `h1` in the page | A compact app bar (back, one action at most; on a section root the brand and the help button), then the title as the `h1` at the top of the content, where it wraps (`HcScaffold`, lot D4). The selector of the current home, from two homes on, is the compact line under the `h1` of a section root, as on the web, and is not on any other page. On iOS the `h1` folds into the bar once the content is scrolled | The title in the bar was cut by its action ("Report a pro…"); the large title of iOS is the same rule, the title in the content (design/patterns.md of the web, Header) |
| Back link at the top of the page (`‹ Rooms`) | The back button of the app bar, the system back of Android, the back gesture of iOS (`hcRoute`); on iOS the button is the chevron and the title of the previous page, as the web's link names its target (`HcBackButton`, `HcBackTitles`, at most two fifths of the bar). On iOS a form opens as a modal sheet, Cancel on the left of its bar and the web's label of its save on the right (the form of a task keeps Save and Cancel at its end, as on the web); on Android it stays a page. The sheet of a row that exists also saves itself as it is changed, "Saved" shown in its bar; a creation waits for its save | What each platform's users expect; the gesture comes with the route (platform adaptations 5 and 7 of design/patterns.md) |
| Targets of 44 px, Done of 48 px | 48 px for every target (`touch-target-lg`): buttons 48 high where the web's are 45.2 (44 and a border), fields 48 where the web's are 50 | The minimum of Android, and the size Material's own widgets keep |
| Hover colours | None (`hoverColor` transparent); a sand ripple on press | No hover on a touch screen |
| Undo banner above the bar | Floating snack bar above the bar, sage, border, action in the primary colour | The same place and look, with the platform's announcement to screen readers |
| Skip and Postpone on the task page | Also in the menu of each row of Today, behind the `…` icon of the web | Lot 2a already offered them there; one tap fewer |
| Number and unit side by side, the unit under the number when too narrow (`.field-pair`) | Side by side, stacked from a text size of 1.3 | The same rule, decided by the text size of the phone |
| Text sizes scale with the browser | Text sizes scale with the phone; the labels of the bar keep their size, and the Save action of the app bar grows up to 1.3 times | Five labels side by side at 360 px, as the tab bar of iOS does; a larger Save pushes the back button out of the bar |
| Safe area of the bar (`env(safe-area-inset-bottom)`) | `Scaffold` and `NavigationBar` keep the safe areas | The same rule, done by the framework |
| Room list: a search form, "Change the order" with up and down buttons, "Add a room" | The list and "Add a room" after it; no search, no reordering (rooms keep the household's order, then their creation) | Search and a reordering screen are not in the plan of lot 2b; the order is the web's, `position` then creation |
| Room page: photos filtered by category chips, the stock of the room, the label tools | Photos as one grid (the category is on each photo, and on its own screen); no stock, no labels | The stock has its own tab since lot 3a, the stock of a room on its page is not in it; labels are not in v1 |
| Stock item page: the photo of its label, the label tools; the movement form sent by one of three buttons | No label photo yet (the column exists, `label`), no labels; the same form and buttons | The label photo is not in lot 3a; labels are not in v1 |
| Photo: an upload form (file field) | A sheet with Take a photo and Choose from the gallery, permission asked at that moment; the photo is re-encoded before it is stored | A phone has a camera, and the location must not leave it |
| Contractor: a vCard download | Call and Write buttons on the card (`tel:`, `mailto:`) | What a phone does with a number; the spec asks for call and e-mail |
| Reminder preferences per member (days before, hour) | One switch on the Notifications screen (More, Me), the web's defaults (1 day before, 08:00, follow-ups by priority) | The per-member settings come with sync; the permission is asked when the switch is turned on |

**Not taken.** No dark theme: the web has none. No page title and back link inside the page,
no breadcrumbs, no computer layout with a column on the left: the app is a phone app. The help
button of the web (the circled question mark, to its documentation site) is in the bar of every page that has no other action, and on the five section roots; it opens the page of the documentation site that describes the screen in the browser of the phone, and the app has no help screen of its own.

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

**Figures as the web, measured** (`test/web_parity_values_test.dart`, design lot D3). A value
of a card is a line, the label at the left and the value at the right (`HcValueRow` in an
`HcValueList`, the web's `dl.facts`): label 14/400 muted, value 16/600, 12 above and under a
row, a line between two rows; the figures of a budget card are the same line, smaller (13/400
and 14/400, 4 above and under, no line, the web's `.table-stack td` on a phone). The quantity
of a stock item is a figure 32/700 with its unit after it and the pill of its state
(`HcFigure`, `.stock-quantity`); a gauge is `HcProgress`, with its text at the right. Long
texts (notes, goal, address, links) stay under their label (`HcFact`). The test opens the
budget, a project and a stock item as `test/web_parity_test.dart` does, and compares the size,
weight, line height and colour of each text, the place of the value at the right edge, the
height of the rows and the gap of the unit with what `tool/web_parity_values.py` measured
(`test/parity/web_values_fr_390.json`); that file carries the release and commit it measured,
which the test compares with the pin `web_parity`.

**Tones of the pills of state, measured** (`test/web_parity_test.dart`, group "pills of state"). The
tone of the pill of a report (`reportStatusTone`: open `warning`, made a task `info`, closed
`ghost`) and of a project (`projectStatusTone`: `info`) is the web's. The test draws a pill of each
tone, and the pill of the open report and of the planned project on their screens, and compares
the colour of the text, of the fill and of the border with what `tool/web_parity_pills.py`
measured (`test/parity/web_pills_fr_390.json`, the same pin `web_parity`).

**Amounts in the fields.** A field of money shows its value as the web does, in the language
of the phone (`1 200,00` in French, `1,200.00` in English; `hcAmount`, `moneyFieldText`) and reads
what is typed in that language (`amountInput`: spaces ignored, a comma or a point as the
decimal in French; in English a comma is read only as the grouping of thousands, as in `1,200.50`,
and any other comma such as `12,5` or `1,20` is refused with the web's message, "Enter a number
with a point as the decimal mark, for example 12.5."). What is stored does not change: two
decimals, as text (`docs/protocol.md`, 2.2).

| Web | App | Why |
| --- | --- | --- |
| The value keeps up to 60 % of the line and wraps there, the label wraps in what is left | The same; the value goes under its label, at the left, only when the line cannot hold it (the value wider than 60 %, or the longest word of the label beside it), which happens at large text sizes | The value is never cut and never wraps beside its label; at the normal size the line is the web's |
| The browser's own `progress` (16 high and 10 em wide in Chromium) | A gauge 8 high, rounded, primary on the muted surface, warning beyond 100 %, across the card, its text at the right | The design's gauge, the same on iOS and Android; Safari and Chromium draw `progress` differently |
| Engaged, then its gauge and "40 % used" in the same cell | Engaged on its line, the gauge and its text on the next | The same order; a cell of the web holds three things side by side, too narrow at 390 |

**Today, as the web's v0.3.2.** Sections *Overdue*, *Today*, *Coming up* (and *No date*), each
heading followed by its count in brackets; under each title the room, then the item
(`Room · Item`; on All homes the home first); the date as a pill in the web's format
(`21 nov. 2026`), not "Due ..."; the lines of the row at 1.3 (title) and 1.35 (place), as the
web's CSS. Kept apart from the web, with the reason:

| Web (v0.3.2) | App | Why |
| --- | --- | --- |
| Offer to receive the reminders on this device (`_device_banner.html`, Web Push) | None | The app's reminders are local notifications, asked by the switch of Notifications (More, Me); there is no Web Push subscription to offer |
| *Photo* pill on a task born from a report with a photo | None | Not drawn by the row of Today yet; the photo is seen from the report |
| Open reports line: *N problems reported* and *See the reports* in a sage-soft banner, the button at the right (`reports/_today.html`) | The same banner, the same place, under the `h1` and the home selector; the button keeps the 48 px of the app | The 48 px are the adaptation of the targets, above |
| Undated tasks only when in season, under *In season* | *In season* as the web, and the other undated tasks under *No date* | A task with no date and no season is not lost to the list *All*; showing it on Today is the safer error |
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

**Screen patterns, shared with the web** (change of 2026-11-15). This record aligns the atoms
(tokens, font, type, components); the anatomy of a screen (the record page that opens to read,
with Done, Postpone and Skip at its top and its form behind Edit; label-value rows and figures;
the header; forms in sections; filters; empty, loading and error states; the groups of More), the
glossary of the shared terms and the list of the iOS adaptations are in
[`design/patterns.md` of the web](https://github.com/HouseCairn/housecairn/blob/main/design/patterns.md),
the reference for both. On an iPhone the app uses the controls of iOS that the list allows, one by
one; on Android it keeps Material. A screen of the app follows that document; where this record
and that document disagree on a screen, that document is right. `design/glossary.json` is a copy
of the web's glossary, and `test/glossary_test.dart` checks that the ARB keys that show a term say
it in English and French, with the keys known to differ listed with their lot.

**The controls of iOS on an iPhone** (design lot D5, rows 1 to 4 of the adaptations of
`design/patterns.md`). The screens call one API, `lib/design/adaptive.dart`, which draws the
control of the platform of the theme (the phone's, or `debugDefaultTargetPlatformOverride` in
tests); on Android every control is the one of Material it was before. The colours, Manrope and
the sizes stay those of the tokens on both: `housecairnCupertinoTheme` gives the widgets of iOS
the primary colour and the font, and every text of those controls is drawn in an `HcText` style.

| Control | iPhone | Android | Component |
| --- | --- | --- | --- |
| Choice in a list | a field with a chevron, which opens the wheel of iOS in a sheet, Cancel at the left of its bar and Done (French: OK) at the right | the menu of Material | `HcSelect`, `hcChoice` |
| Date | the field below, which opens the date wheel of iOS in the same sheet | the calendar of Material | `HcDateField`, `hcPickDate`, `pickDay` |
| Confirmation, alert, short form | the alert of iOS: Cancel in bold, the destroying action in the danger colour, a message centred | the dialog of Material, the danger button for what destroys | `HcDialog`, `showHcDialog` |
| A choice among actions (attach a task) | the action sheet of iOS, Cancel apart | a simple dialog | `showHcChoices` |
| Switch | the switch of iOS, the primary colour when on | the switch of Material | `HcSwitch` |

A date is a field on both platforms (T8 of the design audit): the date in the phone's language,
or "No date" muted, a calendar icon at its end, a button that removes the date when it may be
removed, and the picker of the platform on a tap; it was a text and two text buttons. The menus
of a row (`…`), the photo sheet and the other rows of the adaptations are later lots.
`test/adaptive_test.dart` runs each control on both platforms and keeps golden files of iOS in
English and French (`test/goldens/ios_*`).

## Consequences

- The app looks like the web application on a phone; the components of lot 2b exist before its
  screens.
- A change of a web token reaches the app through `design/tokens.json`; a change of a web
  component needs the matching change in `lib/design/`, which the golden files show.
- Four font files (about 580 kB) are bundled; their SHA-256 is checked in CI.
- Golden files are compared with a tolerance of 0.2 % of the pixels, so that anti-aliasing
  differences between two Linux machines do not fail CI; they are regenerated with
  `flutter test --update-goldens test/goldens_test.dart` and reviewed in the pull request.
