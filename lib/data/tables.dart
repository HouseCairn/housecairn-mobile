// SPDX-License-Identifier: AGPL-3.0-only

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// A UUID of the model, held as 16 bytes (docs/adr/0002-local-storage-and-migrations.md)
/// and read as its canonical text form (docs/protocol.md, section 1).
class UuidConverter extends TypeConverter<String, Uint8List> {
  const UuidConverter();

  @override
  String fromSql(Uint8List fromDb) => Uuid.unparse(fromDb);

  @override
  Uint8List toSql(String value) => Uint8List.fromList(Uuid.parse(value));
}

/// The bytes of the UUID [id], for SQL written by the repository.
Uint8List uuidBytes(String id) => const UuidConverter().toSql(id);

/// The id of the annual envelope of [year] in [home]:
/// `uuid5(home, "envelope:" + year)`, the year in four decimal digits
/// (docs/adr/0003-sync-protocol.md, "Deterministic identifiers").
String envelopeIdOf(String home, int year) {
  if (year < 0 || year > 9999) {
    throw ArgumentError.value(year, 'year', 'four decimal digits');
  }
  return const Uuid().v5(home, 'envelope:${year.toString().padLeft(4, '0')}');
}

/// Columns of every table of the model (`core/models.py:28-38` of the web):
/// the UUID key, the instants of creation, change and soft deletion, in UTC
/// milliseconds.
mixin ModelColumns on Table {
  BlobColumn get id => blob().map(const UuidConverter())();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Columns of a business table: the home it belongs to
/// (`homes/models.py:161-164`). A row never changes home. No foreign key is
/// declared: a reference is checked on read, as sync requires
/// (docs/adr/0003-sync-protocol.md, "Invariants across rows").
mixin HomeOwned on Table {
  BlobColumn get homeId => blob().map(const UuidConverter())();
}

/// `homes.home` (`homes/models.py:31-52`), with the app field `archived_at`
/// (docs/adr/0008-several-homes-one-family-space.md). Its home is itself.
///
/// [isExample] marks the example home of the interactive guide (schema 10,
/// web ADR 0084): set only by `createExampleHome`, never by a form nor by a
/// sync operation, and never synced. A row of an example home writes no
/// `op_log` and no `field_clock`, in every way of the app.
@DataClassName('HomeRow')
class Homes extends Table with ModelColumns {
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get hemisphere => text().withDefault(const Constant('north'))();
  IntColumn get archivedAt => integer().nullable()();
  BoolColumn get isExample => boolean().withDefault(const Constant(false))();
}

/// `rooms.room` (`rooms/models.py:67-91`). [paintArticleId] is the stock
/// article of the paint left over (schema 4, lot 3b).
@DataClassName('RoomRow')
@TableIndex(name: 'room_home_position', columns: {#homeId, #position})
class Rooms extends Table with ModelColumns, HomeOwned {
  TextColumn get name => text()();
  TextColumn get kind => text().withDefault(const Constant('other'))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get paintColour => text().withDefault(const Constant(''))();
  TextColumn get paintBrand => text().withDefault(const Constant(''))();
  TextColumn get paintReference => text().withDefault(const Constant(''))();
  TextColumn get paintBatch => text().withDefault(const Constant(''))();
  TextColumn get floorCovering => text().withDefault(const Constant(''))();
  TextColumn get wallCovering => text().withDefault(const Constant(''))();
  TextColumn get memoryNotes => text().withDefault(const Constant(''))();
  BlobColumn get paintArticleId =>
      blob().map(const UuidConverter()).nullable()();
}

/// `rooms.item` (`rooms/models.py:124-157`): equipment or surface. The
/// manufacturer's warranty (schema 5, web ADR 0080): a duration in months or
/// years, who gives it and their name, its start (else the purchase date);
/// [warrantyEndsOn] is worked out from them, or typed without a duration.
@DataClassName('ItemRow')
class Items extends Table with ModelColumns, HomeOwned {
  BlobColumn get roomId => blob().map(const UuidConverter())();
  TextColumn get name => text()();
  TextColumn get kind => text().withDefault(const Constant('equipment'))();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get model => text().withDefault(const Constant(''))();
  TextColumn get serialNumber => text().withDefault(const Constant(''))();
  TextColumn get installedOn => text().nullable()();
  TextColumn get warrantyEndsOn => text().nullable()();
  TextColumn get purchasedOn => text().nullable()();
  IntColumn get warrantyDuration => integer().nullable()();
  TextColumn get warrantyDurationUnit =>
      text().withDefault(const Constant('year'))();
  TextColumn get warrantyProvider => text().withDefault(const Constant(''))();
  TextColumn get warrantyProviderName =>
      text().withDefault(const Constant(''))();
  TextColumn get warrantyStartsOn => text().nullable()();
  BlobColumn get contractContractorId =>
      blob().map(const UuidConverter()).nullable()();
  TextColumn get contractNumber => text().withDefault(const Constant(''))();
  TextColumn get contractUrl => text().withDefault(const Constant(''))();

  /// JSON list of `{"url", "label"}` (label optional), at most 10, `http(s)` only
  /// (`rooms/models.py:15`, `:35-49`).
  TextColumn get links => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// The barcode (schema 12, web ADR 0083): empty, or 8, 12, 13 or 14
  /// digits with a valid check digit (lib/domain/gtin.dart).
  TextColumn get ean => text().withDefault(const Constant(''))();
}

/// `rooms.photo` (`rooms/models.py:189-196`, `:210-245`): exactly one of room
/// or item. [image] is the file reference of docs/protocol.md, section 2.9,
/// as JSON; the file itself is in the home's directory of the app, named by
/// the photo's id. Re-encoding and thumbnails come with lot 2b.
@DataClassName('PhotoRow')
class Photos extends Table with ModelColumns, HomeOwned {
  BlobColumn get roomId => blob().map(const UuidConverter()).nullable()();
  BlobColumn get itemId => blob().map(const UuidConverter()).nullable()();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get caption => text().withDefault(const Constant(''))();
  TextColumn get image => text().nullable()();

  /// The credit of a photo from an open database (schema 12, web ADR 0083),
  /// JSON text of `source`, `source_url`, `license`, `license_url` and
  /// `author`, shown under it; `{}` for a photo taken by a member.
  TextColumn get attribution => text().withDefault(const Constant('{}'))();
}

/// `tasks.contractor` (`tasks/models.py:116-158`).
@DataClassName('ContractorRow')
class Contractors extends Table with ModelColumns, HomeOwned {
  TextColumn get name => text()();
  TextColumn get trade => text().withDefault(const Constant(''))();
  TextColumn get tradeOther => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// `tasks.task` (`tasks/models.py:161-229`). Only the title is required. The
/// labour and material budgets (schema 4) are decimal strings, null for none;
/// the assignee comes with the members of the family (lot 5).
@DataClassName('TaskRow')
@TableIndex(name: 'task_home_created', columns: {#homeId, #createdAt})
class Tasks extends Table with ModelColumns, HomeOwned {
  TextColumn get title => text()();
  BlobColumn get roomId => blob().map(const UuidConverter()).nullable()();
  BlobColumn get itemId => blob().map(const UuidConverter()).nullable()();
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  IntColumn get estimatedMinutes => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get procedure => text().withDefault(const Constant(''))();
  BlobColumn get contractorId => blob().map(const UuidConverter()).nullable()();
  TextColumn get repeatMode => text().withDefault(const Constant('once'))();
  TextColumn get repeatUnit => text().withDefault(const Constant('month'))();
  IntColumn get repeatInterval => integer().withDefault(const Constant(1))();
  TextColumn get season => text().withDefault(const Constant(''))();
  IntColumn get seasonStartMonth => integer().nullable()();
  IntColumn get seasonEndMonth => integer().nullable()();
  IntColumn get hideDaysBefore => integer().withDefault(const Constant(0))();

  /// First due date of a fixed series: it carries the day of the month.
  TextColumn get seriesStart => text().nullable()();

  /// What one time of the task is planned to cost, in materials and in
  /// labour (`tasks/models.py` `material_budget`, `labour_budget`).
  TextColumn get materialBudget => text().nullable()();
  TextColumn get labourBudget => text().nullable()();
}

/// `tasks.occurrence` (`tasks/models.py:324-346`). Dates are `YYYY-MM-DD`.
/// [actualCost] is what a done occurrence really cost (schema 4);
/// `completed_by` comes with the members (lot 5).
@DataClassName('OccurrenceRow')
@TableIndex(name: 'occ_home_status_due', columns: {#homeId, #status, #dueOn})
@TableIndex(name: 'occ_task_status', columns: {#taskId, #status})
class Occurrences extends Table with ModelColumns, HomeOwned {
  BlobColumn get taskId => blob().map(const UuidConverter())();
  TextColumn get dueOn => text().nullable()();
  TextColumn get visibleFrom => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  TextColumn get statusBefore => text().withDefault(const Constant(''))();
  TextColumn get postponedFrom => text().nullable()();
  TextColumn get completedOn => text().nullable()();
  TextColumn get completionNote => text().withDefault(const Constant(''))();

  /// The occurrence whose closing created this one.
  BlobColumn get follows => blob().map(const UuidConverter()).nullable()();
  TextColumn get actualCost => text().nullable()();
}

/// `stock.article` (`stock/models.py:68-122`): something kept in stock. Its
/// stock is the sum of its movements, computed, never stored. Quantities and
/// amounts are decimal strings with two places, never `REAL`
/// (docs/adr/0002-local-storage-and-migrations.md). [label] is the file
/// reference of the photo of its label (docs/protocol.md, section 2.9).
@DataClassName('ArticleRow')
@TableIndex(name: 'article_home_name', columns: {#homeId, #name})
class Articles extends Table with ModelColumns, HomeOwned {
  TextColumn get name => text()();
  TextColumn get manufacturerReference =>
      text().withDefault(const Constant(''))();
  TextColumn get dimensions => text().withDefault(const Constant(''))();
  TextColumn get storageLocation => text().withDefault(const Constant(''))();
  TextColumn get unit => text().withDefault(const Constant(''))();
  TextColumn get unitOther => text().withDefault(const Constant(''))();
  TextColumn get threshold => text().nullable()();
  TextColumn get unitPrice => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get label => text().nullable()();

  /// The barcode, and the credit of a label photo from an open database
  /// (schema 12, web ADR 0083), as on an item and a photo.
  TextColumn get ean => text().withDefault(const Constant(''))();
  TextColumn get labelAttribution => text().withDefault(const Constant('{}'))();
}

/// `stock.article_rooms`: a room where an article is used. The id is
/// deterministic (docs/adr/0003-sync-protocol.md, "Deterministic ids").
@DataClassName('ArticleRoomRow')
class ArticleRooms extends Table with ModelColumns, HomeOwned {
  BlobColumn get articleId => blob().map(const UuidConverter())();
  BlobColumn get roomId => blob().map(const UuidConverter())();
}

/// `stock.article_compatible_items`: an item an article fits.
@DataClassName('ArticleItemRow')
class ArticleItems extends Table with ModelColumns, HomeOwned {
  BlobColumn get articleId => blob().map(const UuidConverter())();
  BlobColumn get itemId => blob().map(const UuidConverter())();
}

/// `stock.supplier` (`stock/models.py:148-157`).
@DataClassName('SupplierRow')
class Suppliers extends Table with ModelColumns, HomeOwned {
  BlobColumn get articleId => blob().map(const UuidConverter())();
  TextColumn get name => text()();
  TextColumn get reference => text().withDefault(const Constant(''))();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get lastPrice => text().nullable()();
}

/// `stock.movement` (`stock/models.py:168-197`): a line of the ledger, never
/// changed. [quantity] is what the person typed (for an inventory, the
/// count); its effect on the stock is derived from the lines before it, in
/// the order of their clocks, and never stored
/// (docs/adr/0003-sync-protocol.md, "Derived").
@DataClassName('MovementRow')
@TableIndex(name: 'movement_article', columns: {#articleId})
class Movements extends Table with ModelColumns, HomeOwned {
  BlobColumn get articleId => blob().map(const UuidConverter())();
  TextColumn get kind => text()();
  TextColumn get quantity => text()();
  TextColumn get occurredOn => text()();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// The occurrence whose closing, or its undoing, wrote this line.
  BlobColumn get occurrenceId => blob().map(const UuidConverter()).nullable()();
}

/// `tasks.taskmaterial` (`tasks/models.py:284-318`): an article a task needs,
/// one line per article and task, by a deterministic id.
@DataClassName('TaskMaterialRow')
@TableIndex(name: 'material_task', columns: {#taskId})
class TaskMaterials extends Table with ModelColumns, HomeOwned {
  BlobColumn get taskId => blob().map(const UuidConverter())();
  BlobColumn get articleId => blob().map(const UuidConverter())();
  TextColumn get quantity => text()();
}

/// `tasks.materialdraw` (`tasks/models.py:375-411`): what a done occurrence
/// took of an article. [drawn] is never above [wanted].
@DataClassName('MaterialDrawRow')
@TableIndex(name: 'draw_occurrence', columns: {#occurrenceId})
class MaterialDraws extends Table with ModelColumns, HomeOwned {
  BlobColumn get occurrenceId => blob().map(const UuidConverter())();
  BlobColumn get articleId => blob().map(const UuidConverter())();
  TextColumn get wanted => text()();
  TextColumn get drawn => text()();
}

/// `projects.project` (`projects/models.py:98-168`): a piece of work with an
/// end. Only the title is required.
@DataClassName('ProjectRow')
@TableIndex(name: 'project_home_status', columns: {#homeId, #status})
class Projects extends Table with ModelColumns, HomeOwned {
  TextColumn get title => text()();
  TextColumn get goal => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('idea'))();
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  IntColumn get estimatedMinutes => integer().nullable()();
  TextColumn get season => text().withDefault(const Constant(''))();
  IntColumn get seasonStartMonth => integer().nullable()();
  IntColumn get seasonEndMonth => integer().nullable()();
}

/// `projects.project_rooms`: a room a project concerns, by a deterministic id.
@DataClassName('ProjectRoomRow')
class ProjectRooms extends Table with ModelColumns, HomeOwned {
  BlobColumn get projectId => blob().map(const UuidConverter())();
  BlobColumn get roomId => blob().map(const UuidConverter())();
}

/// `projects.budgetline` (`projects/models.py:171-197`): planned and paid
/// are typed; committed is the sum of the accepted quotes, never stored.
@DataClassName('BudgetLineRow')
@TableIndex(name: 'line_project', columns: {#projectId})
class BudgetLines extends Table with ModelColumns, HomeOwned {
  BlobColumn get projectId => blob().map(const UuidConverter())();
  TextColumn get label => text()();
  TextColumn get nature => text().withDefault(const Constant('other'))();
  TextColumn get planned => text().withDefault(const Constant('0.00'))();
  TextColumn get paid => text().withDefault(const Constant('0.00'))();
}

/// `projects.quote` (`projects/models.py:205-270`). An accepted quote has a
/// budget line of its project; any other has none.
@DataClassName('QuoteRow')
@TableIndex(name: 'quote_project', columns: {#projectId})
class Quotes extends Table with ModelColumns, HomeOwned {
  BlobColumn get projectId => blob().map(const UuidConverter())();
  BlobColumn get contractorId => blob().map(const UuidConverter()).nullable()();
  TextColumn get amount => text().withDefault(const Constant('0.00'))();
  TextColumn get issuedOn => text().nullable()();
  TextColumn get validUntil => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('requested'))();
  BlobColumn get budgetLineId => blob().map(const UuidConverter()).nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// `projects.projectfile` (`projects/models.py:273-300`): a photo of a
/// project or a file of one of its quotes. [file] is the file reference of
/// docs/protocol.md, section 2.9; the file is in the home's directory, named
/// by the row's id.
@DataClassName('ProjectFileRow')
class ProjectFiles extends Table with ModelColumns, HomeOwned {
  BlobColumn get projectId => blob().map(const UuidConverter())();
  BlobColumn get quoteId => blob().map(const UuidConverter()).nullable()();
  TextColumn get name => text()();
  TextColumn get file => text().nullable()();
  TextColumn get contentType => text().withDefault(const Constant(''))();
  BoolColumn get isImage => boolean().withDefault(const Constant(false))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
}

/// `tasks.attachment` (`tasks/models.py:466-497`, web ADR 0034): a photo or a
/// file attached to a task, or to one of its occurrences (schema 9, lot 4d).
/// [file] is the file reference of docs/protocol.md, section 2.10; the file
/// is in the home's directory, named by the row's id. [contentType] and
/// [sizeBytes] are what the phone stored; a server sends them in the
/// reference only.
@DataClassName('TaskAttachmentRow')
@TableIndex(name: 'attachment_task', columns: {#taskId})
class TaskAttachments extends Table with ModelColumns, HomeOwned {
  BlobColumn get taskId => blob().map(const UuidConverter())();
  BlobColumn get occurrenceId => blob().map(const UuidConverter()).nullable()();
  TextColumn get name => text()();
  TextColumn get file => text().nullable()();
  TextColumn get contentType => text().withDefault(const Constant(''))();
  BoolColumn get isImage => boolean().withDefault(const Constant(false))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
}

/// `projects.projectlink` (`projects/models.py:303-337`): a link of
/// inspiration. The app never reads the page: no title nor picture is
/// fetched, the link opens in the browser of the phone.
@DataClassName('ProjectLinkRow')
class ProjectLinks extends Table with ModelColumns, HomeOwned {
  BlobColumn get projectId => blob().map(const UuidConverter())();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
}

/// `projects.projecttask` (`projects/models.py:340-352`): a task in a
/// project, one project at most, by a deterministic id from the task.
@DataClassName('ProjectTaskRow')
class ProjectTasks extends Table with ModelColumns, HomeOwned {
  BlobColumn get projectId => blob().map(const UuidConverter())();
  BlobColumn get taskId => blob().map(const UuidConverter())();
}

/// `projects.annualenvelope` (`projects/models.py:355-380`): what the
/// household wants to spend on work in a year, one per year and home, by a
/// deterministic id from the year.
@DataClassName('EnvelopeRow')
class AnnualEnvelopes extends Table with ModelColumns, HomeOwned {
  IntColumn get year => integer()();
  TextColumn get amount => text()();
}

/// `reports.report` (`reports/models.py`): a problem reported, at most one
/// place, a photo (file reference) if there is one. [place] is written when
/// the report is made, so that it still reads right after a rename.
@DataClassName('ReportRow')
@TableIndex(name: 'report_home_status', columns: {#homeId, #status})
class Reports extends Table with ModelColumns, HomeOwned {
  TextColumn get title => text()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  BlobColumn get roomId => blob().map(const UuidConverter()).nullable()();
  BlobColumn get itemId => blob().map(const UuidConverter()).nullable()();
  BlobColumn get articleId => blob().map(const UuidConverter()).nullable()();
  TextColumn get place => text().withDefault(const Constant(''))();
  BlobColumn get taskId => blob().map(const UuidConverter()).nullable()();
  IntColumn get closedAt => integer().nullable()();
  TextColumn get photo => text().nullable()();
}

/// `labels.label` of the web (`labels/models.py:33-53`, web ADR 0047; schema
/// 11, docs/adr/0014-qr-labels.md): the QR label of a room, an item or a
/// stock article, by [kind] and the one reference of that kind. [code] is the
/// web's opaque code (`lib/domain/labels.dart`), unique in the table, revoked
/// rows included, so that a printed code never opens anything else. A label
/// is revoked, never deleted; an object has at most one active label (the
/// repository keeps it so).
///
/// Kept on this phone, never synced, in every way of the app: the sync API of
/// the web (v0.5.1) does not carry this type, and the relay comes later. No
/// `field_clock`, no `op_log`; erased with its home.
@DataClassName('LabelRow')
@TableIndex(name: 'label_code', columns: {#code}, unique: true)
@TableIndex(name: 'label_home_kind', columns: {#homeId, #kind})
class Labels extends Table with ModelColumns, HomeOwned {
  TextColumn get kind => text()();
  BlobColumn get roomId => blob().map(const UuidConverter()).nullable()();
  BlobColumn get itemId => blob().map(const UuidConverter()).nullable()();
  BlobColumn get articleId => blob().map(const UuidConverter()).nullable()();
  TextColumn get code => text()();
  IntColumn get revokedAt => integer().nullable()();
}

/// The clock of the last write of each field
/// (docs/adr/0002-local-storage-and-migrations.md): written in the same
/// transaction as the row, by the repository, so that turning sync on later
/// needs no rewrite. [hlc] is 16 lowercase hexadecimal digits
/// (docs/protocol.md, section 1).
@DataClassName('FieldClockRow')
class FieldClock extends Table {
  TextColumn get entity => text()();
  BlobColumn get rowId => blob().map(const UuidConverter())();
  TextColumn get field => text()();
  TextColumn get hlc => text()();
  BlobColumn get device => blob()();

  @override
  String get tableName => 'field_clock';

  @override
  Set<Column<Object>> get primaryKey => {entity, rowId, field};
}

/// A step of the interactive guide that is done, on the example home
/// (`guide.StepTick` of the web, ADR 0084; schema 10): stored as soon as its
/// state is true, or by hand for a step marked `manual`, and it stays. Never
/// synced, never in an export; erased with its home. [stepId] is the id of a
/// step of `design/guide.json` (`create-home.1`); [tickedAt] is in UTC
/// milliseconds.
@DataClassName('StepTickRow')
class StepTicks extends Table {
  BlobColumn get homeId => blob().map(const UuidConverter())();
  TextColumn get stepId => text()();
  IntColumn get tickedAt => integer()();

  @override
  String get tableName => 'step_ticks';

  @override
  Set<Column<Object>> get primaryKey => {homeId, stepId};
}

/// Settings of this phone, never synced: the device id, the current home,
/// the scope of Today (docs/spec.md, "Homes").
@DataClassName('LocalSettingRow')
class LocalSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// The operations this phone wrote and the engine has not yet seen taken by
/// the other side (docs/adr/0002-local-storage-and-migrations.md, schema 6):
/// [seq] orders them on this phone, [body] is the operation of
/// docs/protocol.md section 2.2 as JSON. Written by the repository in the
/// transaction of the change; removed once the transport took them.
@DataClassName('OpLogRow')
class OpLog extends Table {
  IntColumn get seq => integer().autoIncrement()();
  BlobColumn get device => blob()();
  TextColumn get hlc => text()();
  BlobColumn get homeId => blob().map(const UuidConverter()).nullable()();
  TextColumn get body => text()();

  @override
  String get tableName => 'op_log';
}

/// The fields of a row that this version of the app does not know, kept and
/// sent again (docs/adr/0003-sync-protocol.md, "Versions of the schema"):
/// [json] maps each field to its value; their clocks are in `field_clock`.
/// Rows of `family.*` types, which have no table yet, live here entirely.
@DataClassName('ExtraRow')
class Extra extends Table {
  TextColumn get entity => text()();
  BlobColumn get rowId => blob().map(const UuidConverter())();
  BlobColumn get homeId => blob().map(const UuidConverter()).nullable()();
  TextColumn get json => text()();

  @override
  String get tableName => 'extra';

  @override
  Set<Column<Object>> get primaryKey => {entity, rowId};
}

/// Operations on entity types this version does not know, kept as they came
/// and applied after an update (docs/adr/0003-sync-protocol.md). [key] is the
/// operation's type, home, row, clock and device, so that a duplicate is one
/// row.
@DataClassName('PendingRow')
class Pending extends Table {
  TextColumn get key => text()();
  TextColumn get entity => text()();
  BlobColumn get homeId => blob().map(const UuidConverter()).nullable()();
  TextColumn get body => text()();

  @override
  String get tableName => 'pending';

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// The homes purged on this phone, kept for ever: every later operation of
/// one of them is dropped (docs/protocol.md section 2.2, "Purge of a home").
@DataClassName('PurgedHomeRow')
class PurgedHomes extends Table {
  BlobColumn get homeId => blob().map(const UuidConverter())();

  @override
  String get tableName => 'purged_homes';

  @override
  Set<Column<Object>> get primaryKey => {homeId};
}

/// The rows a Housecairn server has seen (docs/protocol.md section 2.10,
/// "Starting again after 410"): a row of the feed or of a snapshot, or of a
/// push the server applied, ignored or repaired. Never synced, never in an
/// export; emptied when the phone leaves the server.
@DataClassName('ServerSeenRow')
class ServerSeen extends Table {
  TextColumn get entity => text()();
  BlobColumn get rowId => blob().map(const UuidConverter())();
  BlobColumn get homeId => blob().map(const UuidConverter())();

  @override
  String get tableName => 'server_seen';

  @override
  Set<Column<Object>> get primaryKey => {entity, rowId};
}

/// A long text that lost the merge, kept 30 days on this phone and never
/// synced (docs/adr/0003-sync-protocol.md, "Long text"). [keptUntil] is in
/// UTC milliseconds.
@DataClassName('OtherVersionRow')
class OtherVersions extends Table {
  TextColumn get entity => text()();
  BlobColumn get rowId => blob().map(const UuidConverter())();
  BlobColumn get homeId => blob().map(const UuidConverter()).nullable()();
  TextColumn get field => text()();
  TextColumn get value => text()();
  TextColumn get hlc => text()();
  BlobColumn get device => blob()();
  IntColumn get keptUntil => integer()();

  @override
  String get tableName => 'other_versions';

  @override
  Set<Column<Object>> get primaryKey => {entity, rowId, field, hlc, device};
}

/// The files of the rows that hold one (`fileHolders`: photos, project
/// files, task attachments, the photo of a report, the label of an article),
/// as this phone sends and fetches them with a Housecairn server
/// (docs/adr/0012-files-with-a-server.md): one row per file reference, named
/// by `file` of the reference. Never synced, never in an export; emptied when
/// the phone leaves the server.
///
/// [direction] is `up` for a file this phone made and has to send, `down`
/// for one it has to fetch. [state] is `waiting` (to try, not before
/// [nextAt]), `done` (on both sides) or `failed` (the server refused it for
/// good: only the person's "Try again" tries it again). [code] is the code of
/// the last refusal (`malformed`, `too_large`, `quota_exceeded`, ...).
/// [nextAt] is in UTC milliseconds.
@DataClassName('FileSyncRow')
class FileSync extends Table {
  TextColumn get fileId => text()();
  BlobColumn get homeId => blob().map(const UuidConverter())();

  /// The table of the row that holds the file, a key of `fileHolders`.
  TextColumn get holder => text()();
  BlobColumn get rowId => blob().map(const UuidConverter())();
  TextColumn get direction => text()();
  TextColumn get state => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAt => integer().withDefault(const Constant(0))();
  TextColumn get code => text().nullable()();

  @override
  String get tableName => 'file_sync';

  @override
  Set<Column<Object>> get primaryKey => {fileId};
}
