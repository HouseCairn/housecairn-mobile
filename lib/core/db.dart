// SPDX-License-Identifier: AGPL-3.0-only

/// The local database, behind an interface of the app
/// (docs/adr/0001-flutter-stack-and-packages.md, "Consequences").
///
/// Implemented by `AppDatabase` (drift, docs/adr/0002-local-storage-and-migrations.md).
/// Lot 1 defines the life cycle only; the repository layer that writes rows,
/// `field_clock` and `op_log` together comes with the tables, from lot 2.
abstract interface class Db {
  /// Version of the schema this build of the app writes.
  int get schemaVersion;

  /// Opens the database, creating it or running the migrations up to
  /// [schemaVersion]. Calling it again on an open database does nothing.
  Future<void> open();

  /// Result of `PRAGMA integrity_check`: `ok` for a sound database, else the
  /// problems SQLite found, one per line.
  Future<String> integrityCheck();

  /// Closes the database. It cannot be used afterwards.
  Future<void> close();
}
