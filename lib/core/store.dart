// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

/// Secrets at rest, behind an interface
/// (docs/adr/0001-flutter-stack-and-packages.md, "Consequences").
///
/// The keys of sync (device keys, epoch keys, recovery seed) are never in the
/// database but in the iOS Keychain or the Android Keystore
/// (docs/adr/0002-local-storage-and-migrations.md, "Encryption at rest").
/// `SecureStore` (`secure_store.dart`) implements it with
/// `flutter_secure_storage`, from lot 4b, which keeps the access to a
/// Housecairn server in it; lot 5 adds the keys of sync.
abstract interface class Store {
  /// The value under [key], or `null` when there is none.
  Future<Uint8List?> read(String key);

  /// Writes [value] under [key], replacing any value there.
  Future<void> write(String key, Uint8List value);

  /// Removes [key]; nothing happens when it does not exist.
  Future<void> delete(String key);
}
