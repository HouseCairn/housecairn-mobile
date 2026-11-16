// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'store.dart';

/// [Store] on the iOS Keychain and the Android Keystore
/// (docs/adr/0001-flutter-stack-and-packages.md, `flutter_secure_storage`).
/// Lot 4b keeps the credential of the access to a Housecairn server in it;
/// the keys of lot 5 will join it. Values are kept as base64 text, the form
/// the package stores.
class SecureStore implements Store {
  SecureStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Only on this phone, after its first unlock; never in a backup
            // restored on another device.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<Uint8List?> read(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? null : base64.decode(value);
  }

  @override
  Future<void> write(String key, Uint8List value) =>
      _storage.write(key: key, value: base64.encode(value));

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
