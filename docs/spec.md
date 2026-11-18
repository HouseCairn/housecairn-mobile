# Scope of v1

- Status: proposed (lot 0, framing), with the maintainer's decisions of 2026-11-14: several
  homes and synced photos in v1
- Source model: `HouseCairn/housecairn`, `main` at commit `a6953f3` (2026-11-12). Every
  reference `file:line` below is a path under `src/housecairn/` at that commit.

## Principles

1. **Same model, same words.** The app keeps the entities, fields, choices and rules of the
   web application, so that a household that moves between the two finds the same things, and
   so that the app can sync with a Housecairn server without translation
   ([ADR 0010](adr/0010-three-ways-to-use-the-app.md)).
2. **One phone is enough.** Nothing in v1 needs a network. Sync is an addition.
3. **Only the title is required**, done is one tap with undo, as on the web
   (`tasks/models.py:162`, ADR 0033 of the web application).
4. **No outbound call that the person did not configure**: no telemetry, no link preview, no
   remote image. The only network peer is the relay, or the Housecairn server, the person chose
   ([Ways to use the app](#ways-to-use-the-app)).
5. **Derived figures are computed, never stored or synced**: stock levels, budget figures,
   committed amounts, visibility dates.

## Data model: taken, simplified, left out

Every table has a UUID key, `created_at`, `updated_at`, and soft deletion by `deleted_at`
(`core/models.py:28-38`); every business table belongs to one home (`homes/models.py:161-164`).
The app keeps both, and **several homes** in v1 (a main home, a second home, a rented flat). The
**family is the unit of sync**: one encrypted space on the relay holds every home of the family,
and each operation names its home ([ADR 0008](adr/0008-several-homes-one-family-space.md),
[ADR 0003](adr/0003-sync-protocol.md)).

### Taken as they are

| Entity | Source | Notes |
| --- | --- | --- |
| Home: name, currency (ISO 4217), hemisphere | `homes/models.py:31-52` | Hemisphere drives the predefined seasons. Several homes per family. One app field more, `archived_at` ([Homes](#homes)); `required_provider` (`:53-58`) is left out with sign-in. |
| Room, with its memory (paint, coverings, notes) | `rooms/models.py:67-91` | `kind` from `RoomKind` (`:52-64`). `paint_article` links to stock (`:81-88`). |
| Item (equipment or surface): brand, model, serial, purchase, installation, manufacturer's warranty, contract, links | `rooms/models.py:124-157` | Contract provider is a contractor (`:140-148`). Links: at most 10, `http(s)` only (`:15`, `:35-49`). Warranty (schema 5, web ADR 0080): `warranty_duration` 1 to 99, `warranty_duration_unit` `month` or `year`, `warranty_provider` `manufacturer`, `shop` or empty, `warranty_provider_name`, `warranty_starts_on`, `purchased_on`; `warranty_ends_on` is worked out from them (the same date that many months or years later, the last day of a shorter month), typed only without a duration. |
| Photo of a room or an item, with category | `rooms/models.py:189-196`, `:210-245` | Exactly one of room or item (`:238-245`). Re-encoded on the phone, as on the server. |
| Contractor: name, trade (list plus Other), phone, email, address, note | `tasks/models.py:96-158` | Phone pattern `:112`, address max length `:113`. |
| Task: title, room, item, priority, duration, labour and material budgets, notes, procedure (Markdown), assignee, contractor, repetition, season, masking | `tasks/models.py:161-229` | Assignee becomes a **member of the family** (see below). |
| Occurrence: due date, status, postponement, completion, real cost, note, `follows` | `tasks/models.py:324-346` | One open occurrence per task (`:357-361`): kept, by a deterministic successor ([ADR 0003](adr/0003-sync-protocol.md)). |
| Task material (article and quantity) | `tasks/models.py:284-318` | One line per article and task (`:310-314`). |
| Material draw (what a done occurrence took from the stock) | `tasks/models.py:375-411` | `drawn` never above `wanted` (`:400-401`). |
| Stock article: name, references, dimensions, place, unit, threshold, unit price, compatible items, rooms, notes, label photo | `stock/models.py:68-122` | Unit list plus Other (`:24-33`), the millilitre (`millilitre`, shown mL) included, with no conversion between units. |
| Supplier of an article | `stock/models.py:148-157` | |
| Stock movement: entry, exit, inventory; never changed | `stock/models.py:168-197` | Stock is the sum of deltas (`:177-180`), computed. |
| Project: title, goal, status, priority, rooms, duration, preferred season | `projects/models.py:52-127` | Statuses `:52-57`. |
| Budget line: label, nature, planned, paid | `projects/models.py:71-77`, `:171-184` | Committed is derived from accepted quotes. |
| Quote: contractor, amount, dates, status, budget line | `projects/models.py:80-84`, `:205-235` | An accepted quote has a line (`:248-251`). |
| Project task link (a task in one project at most) | `projects/models.py:340-344` | |
| Annual envelope (one per year) | `projects/models.py:355-377` | |
| Report: what is wrong, where (room, item or article, at most one), photo, status, task made from it | `reports/models.py:26-30`, `:43-103` | |
| Task templates (bundled library, EN and FR, with sources) | `tasks/task_templates.yaml`, web ADR 0049 | Shipped with the app, read only: `assets/task_templates.yaml`, a copy at the web release pinned in `tool/web_alignment.json` ([plan](plan.md#alignment-with-the-web-application)). |

**Rules taken as they are** (ported to Dart, checked against the Python code by shared test
vectors, [ADR 0001](adr/0001-flutter-stack-and-packages.md)):

- Recurrence: modes once, fixed date, after the last time (`tasks/recurrence.py:17-20`);
  units and their bounds (`:22-26`); month ends on the 29th to 31st and 29 February
  (`:152-173`); next date after a closing (`:202-235`); dates to come in a range (`:278-338`).
- Seasons: predefined seasons as whole months, the southern hemisphere shifted by six months
  (`tasks/recurrence.py:37-53`); windows across the new year (`:123-129`); a date out of season
  moves to the first day of the next season (`:132-138`); the former `heating` season read as
  custom months (`:32-35`, `:56-63`).
- A due date is a calendar day, never an instant (web ADR 0032). In the app, "today" is the
  day in the **time zone of the phone**, not of an instance.
- Done in one tap, with undo; undo refused once the next occurrence was worked on
  (`tasks/services.py:563-643`, `:605-613`). Postpone keeps the original date
  (`tasks/services.py:588-602`). A completion date cannot be in the future (`:545-546`).
- Budget figures: planned, committed, paid, used, gap, still to pay; a project counted in the
  year it starts; upkeep is the tasks in no project; projection of repeating tasks over a
  year (web ADR 0051, `budget/services.py`; cost a year `:41`). Computed in decimal, never in
  floating point.
- Reminders: first reminder `days_before` (default 1) at `send_at` (default 08:00), quiet
  hours, daily summary (`notifications/models.py:61-91`); follow-ups every 1, 3 or 7 days by
  priority (`notifications/reminders.py:56`); the person reminded is the assignee, otherwise
  every member who may write (`notifications/reminders.py:4-7`).

### Simplified

| What | Web application | App v1 | Why |
| --- | --- | --- | --- |
| People | Accounts, memberships of one home with roles owner, member, read only (`homes/models.py:17-23`, `:68-87`) | **Members** of the family: a display name and a colour, synced; each phone belongs to one member; every member belongs to every home of the family. One flag, *admin*, family-wide, for who may add and remove phones and delete a home. | No accounts by design. A read-only role needs every peer to reject writes; not needed for a family (maintainer's decision: no read-only role in v1). |
| Invitations | E-mailed link with a hashed secret (`homes/models.py:90-145`) | QR code shown on a phone of the family, confirmed by a short code ([ADR 0004](adr/0004-encryption-and-family-keys.md)) | No e-mail, no server-side identity. |
| Display preferences | Per person, server side (`tasks/models.py:414-451`) | Per phone, local, not synced | A setting of the screen, not of the home. |
| Reminder preferences | Per person, server side, sent by a worker | Per phone, local; scheduled by the phone ([Reminders](#reminders)) | No server sends anything. |
| Attachments | Any file type on tasks, projects, quotes (`tasks/models.py:463-494`, `projects/models.py:273-300`) | Photos and PDF only, synced ([Photos and files](#photos-and-files)) | What a phone produces; keeps the encrypted blobs small. |
| Project links | Address, title and picture read by a worker (`projects/models.py:303-337`, web ADR 0070) | Address and a title typed by the person; the page is never fetched | Principle 4. |
| Report limits | 20 open reports per reporter (`reports/models.py:21-23`) | No limit | It protects the home from a tenant with the read-only role, which the app does not have. |
| Stock draws | `drawn` limited to the stock held at closing (`tasks/models.py:378-381`) | Same on the phone that closes; after a merge of two phones the stock may show below zero, shown as a shortfall | Two offline phones can each take the last tin; no automatic correction is right. |
| Time zone | Of the instance (web ADR 0032) | Of the phone | Each phone has its own "today". |
| Deleting a home | Definitive, by an owner who types the name (`homes/services.py:239-252`) | Same, by an admin; or **archive** it, which the web does not have | A family keeps the history of a sold home without seeing it every day. |

### Left out of v1

| What | Source | Why |
| --- | --- | --- |
| Sign-in, passkeys, single sign-on, provider required by a home | `accounts/`, `homes/models.py:53-58` | No accounts. |
| Managing API tokens, instance settings, administrator, demonstration mode | `apitokens/`, `instance/`, `demo/` | No server in the app. The third way signs in with OAuth 2 and PKCE ([ADR 0010](adr/0010-three-ways-to-use-the-app.md)); the accesses are listed and revoked on the web. |
| Audit log | `audit/models.py:19-34` | A family log of who did what is the history of occurrences; the relay must not keep one. |
| Events received from Home Assistant | `events/models.py:10-16` | Home Assistant is not in v1. |
| Notification channels (Apprise) and web push devices | `notifications/models.py:30-50`, `:153-192` | Replaced by local notifications. |
| Calendar feeds (secret ICS address) | `calendar/models.py:10-26` | Needs a server. A one-shot `.ics` export is possible later. |
| QR labels of rooms, items, articles | `labels/models.py:33-53` | Labels printed by the web point to web addresses; app links are a later lot. |
| Paperless-ngx fields of a quote | `projects/models.py:236-240` | Connectors are not in v1. Kept if they come from a later import (unknown fields are preserved, [ADR 0003](adr/0003-sync-protocol.md)). |
| CSV import and export, export jobs, archive of a home in format 3 | `homes/models.py:172-226`, web ADR 0048 | Replaced by the encrypted export below. Reading a web archive in the app comes after v1 (maintainer's decision). |
| Invitations to one home by e-mail, with a role | `homes/models.py:90-145` | A phone joins the family, hence every home ([ADR 0008](adr/0008-several-homes-one-family-space.md)); a home shared outside the family is after v1. |

## Ways to use the app

At the first start the app offers three ways, one at a time per phone
([ADR 0010](adr/0010-three-ways-to-use-the-app.md), maintainer's decision of 2026-11-14):
**alone on this phone** (the default, no network), **family sync** through the end-to-end
encrypted relay (with a subscription on the hosted relay), and **my Housecairn server** (an
instance and a sign-in to it by OAuth 2 with PKCE; the server stores and reads all the homes of
the phone, which then also appear in its web pages; unlocked by a single in-app purchase). A
way whose lot is not merged yet is shown, disabled. What each way guarantees, the moves between
them and what the screen says are in ADR 0010.

In the app of lot 2c only the first way exists. The first-start screen shows the logo and its
title centred, as the first page of the web, then the three, "Alone on this phone" selected,
the two others disabled with "Coming later", muted with their mark (a tap on them opens nothing);
the third says that the server stores the homes and can read them, that everything of the phone
is kept on it, and that a one-time purchase unlocks it, with no price. Choosing the first way
stores `sync_mode` = `alone` in `local_settings` (never synced; absent means alone), then the
first home is made. A phone that already has homes and no `sync_mode`, an install of a lot 2 build,
never sees the screen and is alone. More shows the way in use and the other two, disabled. The
transport of the later ways is the interface `SyncTransport` (`lib/sync/transport.dart`),
defined and not implemented; the app opens no network connection.

## Homes

Several homes from v1, as on the web, where most households have one home and some have two or
more (`homes/current.py:3-6`).

- **Create**: name, currency, hemisphere; the first home is made at the first start. Any member
  may create one; it is synced to every phone of the family.
- **Rename**, change currency or hemisphere: any member, from the home's settings. A change of
  hemisphere moves the predefined seasons of its tasks, as the web does
  (`homes/services.py:148-152`).
- **Archive**: any member. An archived home leaves the selector, Today and the reminders; it
  stays readable from the list of homes, read only, synced and counted in the quota.
  Unarchive brings it back as it was.
- **Delete**: an admin (without sync, the owner of the phone), after typing the exact name, as
  the web (`homes/services.py:239-252`); the app offers an export first. Final on every phone:
  rows and photos of that home are erased, and its photos are deleted from the relay
  ([ADR 0008](adr/0008-several-homes-one-family-space.md)).
- The form of an existing home is titled *Edit the home*, has the help of the web under the
  currency and the hemisphere, and ends with
  *Archive this home* (or *Bring this home back*) above *Delete this home*, each the width of
  the column, as the web's page of a home.
- **Delete, everywhere**: the button that deletes a record (room, item, line, quote, task,
  stock item, supplier, contractor, project, photo, home) is one component, `HcDeleteButton`,
  filled in the danger colour and the width of the column, at the end of the form or page, as
  the web's `.button-danger`. Not an outlined button.
- The last active home can be neither archived nor deleted: the app always has a home to open.
  The example home of the guide (below) is not counted.

**The example home of the guide** (web ADR 0084): a disposable home with the fictional values of
`design/guide.json`, made by the person at step 1 of the guide, filled scenario after scenario
("Add what the earlier scenarios make" adds the rows of the earlier scenarios that are missing,
never one of the scenario opened or a later one), and deleted in one gesture: one confirmation,
no name to type, no export offered. Its rows, its files and the ticks of its steps go; nothing
is kept of it.

- **One per phone**, marked `homes.is_example`. Only the guide sets the mark; no form and no
  sync operation writes it (a pushed or pulled `is_example` is ignored), so a real home never
  becomes an example and the other way round.
- **It never leaves the phone, in every way of the app** (alone, family sync through the relay,
  "My Housecairn server"): the repository writes its rows without `op_log` and without
  `field_clock`, so it is never an operation, never in the relay's snapshot, never in an export
  and never in the homes of the phone sent to a server; an operation that names it is not
  applied. A phone on a server keeps it beside the server's homes, as its one local home.
- **Left out of the counts**: not a home for the rule of the last active home, not in the
  selector, not in **All homes** of Today, no reminder; its own screens show it.
- **Recognisable on its screens**: these screens of the example home (its page, its Today, a
  room, an item, a task and its list, the reports and a report with its photo, a project, a
  budget line, a quote, the envelope, a stock item, a supplier, a contractor, a done
  occurrence, a photo, an attachment, and their forms) starts with the banner
  **Example home**, with **Back to the guide** and **Delete the example home**; **My homes**
  lists it after the real homes with the pill **Example**; its page has no **Archive** nor
  **Delete** at the bottom, the banner deletes it.
- **The ticks of the steps**: a step whose state (`done_when` of the file) is true is ticked,
  and stays ticked even if the state goes away afterwards; four steps are ticked by hand. The
  evaluator is the web's (`guide.states`), checked on the web's vectors
  (`test/fixtures/guide_states.json`). The ticks are a table of the phone, never synced.

**Current home**, as the web defines it (`homes/current.py:1-13`, `:106-118`): the home last
chosen in the selector, or of the last screen of a home opened, **kept on the phone, not
synced**. At start the app opens on it; if it was archived or deleted meanwhile, on the first
active home by name (`homes/current.py:73-79`). The selector appears in the app bar from two
active homes on (`homes/current.py:31-32`). Today also offers **All homes**, and shows it until a
home is chosen (`homes/current.py:81-82`); the other sections show one home at a time.
Switching home keeps the screen when it needs only a home (a section root), else opens the
section's root: a room of one home does not exist in the other.

## Members and assignment

A **member** is a name and a colour, and belongs to every home of the family; the member who
turns on sync is admin. A task's assignee and an occurrence's `completed_by` point to a member
(they point to a user on the web, `tasks/models.py:187-194`, `:338-340`). Without sync there is
one member, the owner of the phone, and assignment is hidden.

## Screens of v1

Mobile first, one hand, 360 px wide and up, system font size respected. From two active homes
on, the app bar shows the **home selector** ([Homes](#homes)); every screen below except Today,
Homes and Settings shows the current home.

1. **Today**: overdue, coming up within the horizon (1 week by default, `tasks/models.py:421-426`),
   in season, and open reports, of the current home or of **All homes**; with All homes each row
   names its home. Grouped by urgency, room or home (or person, with sync). Done is one tap,
   with an undo bar; skip and postpone from the same row. In season lists the tasks of a season
   that is on, due beyond the week or without a date (`tasks/agenda.py`, `today_sections`). On one
   home, a tab **All** opens the list of every task (the hidden ones on demand, 30 to a page)
   and, under Done, the history with its real cost (`tasks/task_list.html`). Both lists have the
   tabs **To do** and **Done**, a search field and a sheet **Filters (n)** (web `design/patterns.md`,
   Filters and search): the search follows the typing after a short pause and looks in the title,
   the room and the item (the history also in the note of what was done), without regard to case
   or accents; the sheet holds the room and, under Done, the item, the contractor, the outcome
   and the dates, n being the criteria that apply. What was chosen stays while a task is opened
   and closed again, and starts from nothing on coming back to the list from elsewhere. A list
   that a search or a filter emptied offers to clear the filters. A row of an open task made
   from a report with a photo carries the ghost pill **Photo** after its date, in Today and in
   All (`mark_photo_reports`, `tasks/_occurrence_row.html`); a page of rows reads the reports
   once, not once a row.
2. **Task**: opens on its page, to read, in the order of the web (`tasks/task_detail.html`;
   web `design/patterns.md`, Record page): the pills of state, priority and repetition, the
   title, the place (room and item as links), the row of actions (Done as the primary one,
   Postpone, Skip this time, or Undo, then Edit the task), then, when the task was made from a
   report, Reported problem (one card a report, the latest first: Reported on and the day, the
   title of the report, which opens it, and its photo, which opens full width, or the plain
   tile Photo not on this phone until its file has come; the reports are those of the task's
   home that are not deleted, whatever their status, as the web's `reports_of_task`; the web
   adds who reported it, which the app does not hold; as there, a read-only member sees only the
   reports they made (`visible_reports`): the server sends a reader only those, so the app,
   which does not hold the author, shows all it holds; a task made from a report the reader may
   not see keeps its title and place and has no report of origin on the phone, so the task page
   shows no Reported problem for it), then When (repetition, due date,
   first date of a postponed one, masking, the next three dates), How to do it, Details
   (duration, budgets, contractor, notes), Cost (estimate, part from the stock, a year, paid so
   far), materials, photos of the item or the room, Photos and files (lot 4d: the photos as a
   grid of tiles with their name, then the other files with an icon, their name and size, then
   Add photos or files: take a photo, choose from the gallery or choose a PDF or a photo; a
   photo opens full width, a file in another app through the share sheet, Delete is on its
   screen with a confirmation; in an archived home, No file yet. when there is none), history
   of occurrences, each done one
   opening its details (day, real cost, note). Edit the task opens the form, in the order and
   the folded sections of the web (`tasks/task_form.html`): title, room, item and due date, then
   Repeat (with a preview of the next five dates, `tasks/recurrence.py:341-351`), Who, Time and
   budget, Materials (one line per stock item and quantity, one empty line offered, up to 50,
   saved with the task; the stock items themselves are added in Rooms, Stock, not in the form),
   How to do it; only the title is required; a room, an item or a contractor can be
   added with the task; Save and Cancel end it, deletion is under them.
3. **Add from a template**: the bundled library, filtered by the equipment ticked. Each template
   says its interval in the words of the web ("every month · source") and links its source,
   which opens in the browser of the phone.
4. **Rooms**: list in the household's order; a room shows its type, then **Report a problem**
   (Where starts with the room), its memory (the short values as lines of label and value, with
   **Edit the memory**, its own form as on the web), its photos, its items and its tasks, in the
   order of the web (`rooms/room_detail.html`). **Edit** in the bar opens the type, the name and
   the notes, in that order, with the help of the web; choosing a type fills the name in with the
   label of the type while the name is empty or still that of the previous type.
   Its tab **Equipment** lists every item of the home, by room then name, with its next task
   and its warranty, filtered by a room and by words of the name, brand, model or serial number
   (`rooms/services.py` `item_rows`, `rooms/item_list.html`). An **Add an item** button follows
   the list (the room being filtered is the form's first choice, the form asks for the room;
   absent in an archived home or while the home has no room). Saved, the new item opens, and
   Back from it returns to the list, still filtered (web design guide, After a form: created
   from the list of its own section, the record opens; from the page of a room, the form
   returns to that page).
5. **Item**: details, the manufacturer's warranty (a duration in months or years, who gives it,
   its start, else the purchase date, and its end worked out; web ADR 0080), its state,
   contract, **Report a problem** (Where starts with the item), links, photos, tasks.

The sheets of an existing item, room, task and stock article save themselves as they are
changed (web ADR 0082): a choice, a date or a tick at once, a text 800 ms after the typing
stops, one write of the fields that changed, a discreet "Saved" said by the screen reader. A
creation and a deletion keep their button, as does a task that adds a room, an item or a
contractor with it.
6. **Stock**: articles with the **Low stock** flag (`stock/models.py:90-96`), under the tabs
   **All** and **Low stock**, with a search field (name, manufacturer reference, supplier name
   or reference; without regard to case or accents) that follows the typing; an article with its
   movements and suppliers, add an entry, an exit or an inventory. **Edit the stock item** and
   **Report a problem** (Where starts with the article) are the action row of its page. Saved,
   a new article opens, and Back from it returns to the list (web design guide, After a form).
7. **Projects**: list by status (`projects/models.py:61-67`), under the card of the envelope of
   the year, in groups by status with their heading (In progress, Planned, Idea, Finished,
   Abandoned, the order of the web); a project with its pills (state,
   priority, what is left of the budget), its goal, its rooms as links, then its tasks, its
   budget lines (Planned, Committed, Paid, Gap; a line opens its form), quotes, links and
   photos, in the order of the web (`projects/project_detail.html`). Its form is the web's:
   title, goal, status, priority and (new project) budget, then the folded section *Rooms,
   duration and season* (closed on a new project, open when one of its fields has a value):
   the rooms as chips, the estimated duration and the preferred season (months typed on the
   web for a custom season are kept, not edited). Saved, a new project opens, and Back from it
   returns to the list.
8. **Budget**: the year of the current home against its envelope, by room, by project, upkeep
   (read only). Each home has its own currency and envelopes (`homes/models.py:33-39`,
   `projects/models.py:355-377`), so homes are never added together. Each tab has the title and
   the note of its web page (Budget, Budget by room, Budget by project, Budget of the upkeep);
   the details of the year are a folded section, as in the forms.
9. **Report a problem**: title, place (a room, an item or a stock item), photo; the list, make a
   task from a report, close it. A report page is a record page: its state pill, its title, then
   Where (a link to the place), Reported on, Closed on and Task as lines of label and value, and
   the action row.
10. **Contractors**: list and card, call and e-mail from the card.
11. **Homes**: the list of homes, active then archived; create, rename, change currency or
    hemisphere, archive, unarchive, delete ([Homes](#homes)).
12. **Settings**: language, reminders, export and import, the way the app is used and the move
    to another ([Ways to use the app](#ways-to-use-the-app)), family sync (subscribe, invite a
    phone, phones, recovery code, relay address, space used against the quota), licences and
    the attribution of `NOTICE`. More counts the reports that wait, as the web ("Reports (1)"):
    the open reports of the home, none for a read-only member of a server home (the web's
    `waiting_for`; the server sends a reader their own reports only, web ADR 0086). About is
    the card of the web: the cairn, the name, the version, the attribution, the licence and the
    link to the source code, then the links of the project (site, documentation, code, Home
    Assistant app and integration, mobile application, Android coming soon) and the iPhone
    beta, which can be opened or copied.
13. **Guide** (web ADR 0084, the web's `docs/screens/guide.md` and `guide-scenario.md`), opened
    from **More**, **Help**, **Guide** and from the card **Guide** of an empty Today (under
    *Nothing to do for now.*, **Open the guide**; the card goes as soon as Today shows a task,
    and is not on the Today of the example home). It lists the five scenarios, each with its
    progress (**1 of 3**, then **Done**; an optional step does not count), then, once the
    example home exists, its card and **Delete the example home**. A scenario shows its steps,
    ticked by the evaluator of the example home: **Fill in for me** opens the form of the step
    with the values of `design/guide.json` in it (nothing saved until its button is pressed),
    **Open** the same form empty or the screen of the step (the page of the home, its Today, the
    report); a step on a row already there opens the form of that row, a budget line or a quote
    waits for its project. The first step opens **New home** filled in with the example and a
    sentence that says so; saving makes the example home. The four steps that leave no trace have
    **Mark as done**. A scenario after the first offers **Add what the earlier scenarios make**
    while an earlier step that ticks by itself is not ticked, or while there is no example home.
    Every sentence comes from `design/guide.json`, in the language of the phone (English when the
    file does not have it), the labels it cites from `design/glossary.json`, in bold; only the
    words around them are in the ARB files. The values of a form are taken only on the example
    home, each checked as the form checks what is typed (a choice of its list, a room of the
    home, a number); the fields are those the web fills (`prefill_fields`), and the room and the
    item a new task starts on, and the place of a report, as the web's `?room=` and `?item=`
    (step 3.1 opens the task on the kitchen and the machine, step 4.1 the report on the
    kitchen). **Delete the example
    home** asks once, in a dialog (**Delete** and **Cancel**), no name to type and no export,
    then goes back to the guide.

## Reminders

Local notifications only, scheduled by the phone from its own data
([ADR 0001](adr/0001-flutter-stack-and-packages.md)).

- Same defaults and follow-ups as the web (`notifications/models.py:70-91`,
  `notifications/reminders.py:56`), in the phone's time zone.
- With sync, each phone reminds only its own member when the task is assigned to them, else
  every member, as the web does for members who may write (`notifications/reminders.py:4-7`).
- Reminders cover every **active** home, not only the current one; none for an archived home.
  When the family has two active homes or more, each reminder **names its home** in its title
  ("Second home: change the smoke alarm battery") and the daily summary groups by home.
  Opening a reminder makes its home the current one, also when the tap starts the app (the
  app was not running). The Android channel is named in the language of the app, and the
  iOS permission texts (camera, photos) are in English and French (`InfoPlist.strings`).
- iOS keeps 64 pending local notifications per app (documented by the plugin, see ADR 0001):
  the phone schedules the nearest 60 and a daily summary for the rest, and reschedules on
  every start, every sync and on a background refresh.
- Android 14 and later restrict exact alarms: reminders use inexact scheduling, which is
  enough for a day-level reminder; no exact-alarm permission is asked.

## Photos and files

Photos are synced from v1 (maintainer's decision), with PDF, in a quota of **2 GiB per family**,
all homes together, counting photos, files and the sync data.

- **Where**: photos of a room or an item with their category (`rooms/models.py:210-245`), the
  label photo of a stock article (`stock/models.py:119`), the photo of a report
  (`reports/models.py:71-84`), and photos or PDF attached to a task, a
  project or a quote (`tasks/models.py:463-494`, `projects/models.py:273-300`).
- **The photo of a report that became a task** stays on the report and shows on the page of the
  task as well, in Reported problem, and the rows of the task carry the pill Photo; it is the
  same file, opened full width from either page.
- **Taken** with the camera or picked from the gallery; PDF from the Files app or the document
  picker. At most 20 MiB a file.
- **Re-encoded on the phone before anything is stored**, as the web does
  (`rooms/images.py:75-101`): turned upright, every metadata removed but the colour profile,
  location included; longest side at most 2560 px (`rooms/conf.py:17`), JPEG at quality 85; a
  thumbnail of 360 px (`rooms/conf.py:18`) made on each phone. A PDF is kept as it is. The
  file the camera or the gallery hands over keeps the location, so it is deleted as soon as
  it is read.
- **Synced** as an encrypted blob with its own key, uploaded before the change that shows it
  ([protocol](protocol.md#29-files-photos-and-pdf)). Other phones download photos in the
  background on Wi-Fi, and at once when one is opened; until then they show a placeholder.
- **Quota full**: the photo stays on the phone that took it, marked "not synced", and the others
  show "photo on another phone"; Settings shows the space used and what takes it, by home.
- **Deleted**: a deleted photo can be restored for 30 days, then its blob is deleted from the
  relay; deleting a home deletes its photos from the relay at once.
- **With a Housecairn server** (the third way, [ADR 0012](adr/0012-files-with-a-server.md)):
  the file is sent to the server with the id of the phone and its SHA-256 before the row that
  shows it, and never holds the rows back. A photo or a file another phone or the site added is
  fetched after the pull, newest first, with a plain tile until it comes; a file the server does
  not have yet is asked for again later, without an error. A file that cannot go waits longer at
  each try (30 seconds, doubled, six hours at most) and survives closing the app; one the server
  refuses for good (too large, no room left, a kind it does not take, a digest that does not
  match) stays on the phone, is not sent again by itself, and Settings says why in plain words.
  Settings shows how many files wait and "Send now". A deleted photo's file leaves the phone 30
  days after the deletion; the server removes the files no row refers to by itself. Nothing is
  sent when the phone is alone. Lot 4d ([ADR 0013](adr/0013-more-files-with-a-server.md)) adds
  the files attached to a task, the photo of a report and the label photo of a stock article,
  under the same rules; a report and an article show the plain tile of a photo until their file
  has come. A photo, a file or a label an earlier build received without being able to keep its
  reference comes back with the next sync, with no action from the person.

## Export and import

- **Export**: one file, `.hcbackup`, with every row (deleted ones included, so that an import
  cannot resurrect them), every photo and file of **every home** of the phone, archived ones
  included (never the example home of the guide), and the members, encrypted with a
  passphrase (Argon2id, then XChaCha20-Poly1305 secretstream; format in [protocol.md](protocol.md#5-backup-file)).
  The app proposes a generated passphrase of six words and says that a lost passphrase loses
  the file. Shared through the system share sheet; the app never uploads it.
- **Import**: into an empty app (everything back as it was), or **as a copy** of the homes
  chosen in the file, with new identifiers (the rule of web ADR 0069), never merged into an
  existing home. A copy is how a home moves from one family to another.
- The inner layout follows the archive of the web (manifest, one document per table, files,
  web ADR 0048); reading it by the web application is a later lot, not a promise of v1.

## Languages

English is the source language; French ships in v1. No string in code: Flutter `gen-l10n`
with ARB files. Dates, numbers and amounts in the currency of the home are formatted by
`intl` in the language of the phone. The French terms follow the catalogue of the web
application, so that both say the same words.

## Not in v1

Home Assistant, Paperless-ngx, Sure, Apprise, calendar feeds, QR labels, widgets, a watch
app, a tablet layout, a web or desktop build, roles other than admin, a home shared with
someone outside the family, reading a web archive, a build without Google services (after
1.0).
