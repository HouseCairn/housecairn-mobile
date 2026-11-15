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
@DataClassName('HomeRow')
class Homes extends Table with ModelColumns {
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get hemisphere => text().withDefault(const Constant('north'))();
  IntColumn get archivedAt => integer().nullable()();
}

/// `rooms.room` (`rooms/models.py:67-91`). The paint left in stock
/// (`paint_article`) comes with the stock, in lot 3.
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
}

/// `rooms.item` (`rooms/models.py:124-157`): equipment or surface.
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
  BlobColumn get contractContractorId =>
      blob().map(const UuidConverter()).nullable()();
  TextColumn get contractNumber => text().withDefault(const Constant(''))();
  TextColumn get contractUrl => text().withDefault(const Constant(''))();

  /// JSON list of `{"url", "label"}` (label optional), at most 10, `http(s)` only
  /// (`rooms/models.py:15`, `:35-49`).
  TextColumn get links => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
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
/// labour and material budgets come with lot 3, the assignee with the members
/// of the family (lot 5).
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
}

/// `tasks.occurrence` (`tasks/models.py:324-346`). Dates are `YYYY-MM-DD`.
/// The real cost comes with lot 3, `completed_by` with the members (lot 5).
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

/// Settings of this phone, never synced: the device id, the current home,
/// the scope of Today (docs/spec.md, "Homes").
@DataClassName('LocalSettingRow')
class LocalSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
