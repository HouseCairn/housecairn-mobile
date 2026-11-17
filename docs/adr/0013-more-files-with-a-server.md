# 0013. Attachments of tasks, photos of reports and labels with a server

- Status: proposed
- Date: 2026-11-17

## Context

[ADR 0012](0012-files-with-a-server.md) synced the files of two tables, the photos of rooms and
items and the files of projects. It left three for later: the files attached to a task
(`tasks.attachment`), which the app had no table for, and the photo of a report and the label
photo of a stock article, whose reference the server kept in `extra`. People saw the photos of
the site missing in the app. The server serves the files of `tasks.attachment` already (web
`sync/files.py`, `HOLDERS`); the maintainer's contract for the two others, built on the server
at the same time, is the one of `rooms.photo`: `reports.report` field `photo` and
`stock.article` field `label`, images only, the same routes `GET` and `PUT`
`/api/v1/sync/homes/{h}/files/{file}`, the same headers, refusals and limits. The reference of a
row that exists keeps its form (named by the id of the row, without a digest for an image of the
site); a row pushed by a phone carries a full reference whose file goes by `PUT` before the row.

## Decision

**Five holders.** `fileHolders` (`lib/data/file_repository.dart`) lists `photos.image`,
`project_files.file`, `task_attachments.file`, `reports.photo` and `articles.label`. Every rule
of ADR 0012 holds for each: the list `file_sync`, the order of a round (files to send, push,
pull, files to fetch, sweep), the waits, the refusals, "Send now", the 30 days a deleted file
stays, the sweep in the homes of the server only, the counts of Settings. A photo of a report or
a label is `<id>.jpg` in the directory of its home, an attachment is `<id>`, as a file of a
project.

**The attachments of a task: schema 9.** A table `task_attachments` (`task_id`, `occurrence_id`,
`name`, `file`, `content_type`, `is_image`, `size_bytes`, index on the task), synced as
`tasks.attachment`. The operations of attachments a server sent to an earlier build wait in
`pending` and are applied at the next sync. As for a file of a project, `content_type` and
`size_bytes` are not sent: the server reads them in the reference. On the phone an attachment is
a photo (re-encoded) or a PDF, at most 30 on a task (`MAX_ATTACHMENTS_PER_TASK`); a file of
another type made on the site comes and is shown by its name. Deleting a task deletes its
attachments with it.

**The page of a task** shows them under Photos and files, after the photos of its place and
before its History, as the site does: the photos as a grid of tiles with their name, then the
other files with an icon, their name and their size, then Add photos or files (take a photo,
choose from the gallery, choose a file). A photo opens full width; a file opens in another app
through the share sheet of the system (`share_plus`, already in [ADR 0001](0001-flutter-stack-and-packages.md)):
neither system opens a file of the app's own directory otherwise. Deleting is on the screen of
the attachment, with the Delete button of the forms and a confirmation.

**A report and an article** show their photo under their facts; until its file has come, the
plain tile of a photo, said with "Photo not on this phone". A report made on the phone writes
the full reference (an id of its own and the digest), so its photo goes to the server; a report
of an earlier build, whose reference had neither, is completed as in ADR 0012.

**A reference with no size.** The site gives the label of an article with no size (its model
keeps none). A reference with a `file` is read with size 0 and an empty type when they are
missing, so that the file is fetched all the same.

**Not in this lot.** The app makes no label photo itself (no screen asks for one). The export of
a home does not exist in the app yet (docs/spec.md, "Export and import"); the erasure of a home
removes its directory, the three new kinds of files with it.

## Consequences

- The photos of reports, the labels and the attachments made on the site come to the phone, and
  those made on the phone go to the server.
- The e2e job runs against the server 0.5.0, which does not serve the photo of a report nor the
  label of an article yet: it keeps their reference in `extra` and no row claims the file sent,
  which its nightly purge removes after 7 days. The e2e job checks neither.
- The tests of these three kinds are `test/files_more_sync_test.dart`, against the scripted
  server.
