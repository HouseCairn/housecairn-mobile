// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

/// Cryptography of the app, behind an interface
/// (docs/adr/0001-flutter-stack-and-packages.md, "Consequences").
///
/// Each method is one primitive of docs/protocol.md, section 1, under the same
/// name; lot 5 implements them with libsodium (`sodium`) and checks them
/// against the committed test vectors. Lot 1 defines the interface only: no
/// implementation exists yet, and nothing in the app encrypts.
abstract interface class Crypto {
  /// `randombytes_buf`: [length] bytes from the system's secure generator.
  Uint8List randomBytes(int length);

  /// `aead`: XChaCha20-Poly1305 (IETF) encryption of [message] with [key]
  /// (32 bytes) and [nonce] (24 bytes), authenticating [additionalData].
  Uint8List aeadEncrypt({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List message,
    Uint8List? additionalData,
  });

  /// Inverse of [aeadEncrypt]; throws [CryptoException] when the ciphertext,
  /// the nonce, the key or [additionalData] do not match.
  Uint8List aeadDecrypt({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List ciphertext,
    Uint8List? additionalData,
  });

  /// `seal`: anonymous sealed box of [message] for the X25519 [publicKey].
  Uint8List seal({required Uint8List publicKey, required Uint8List message});

  /// Inverse of [seal] with the recipient's key pair; throws [CryptoException]
  /// when the box is not for these keys or was changed.
  Uint8List openSealed({
    required Uint8List publicKey,
    required Uint8List secretKey,
    required Uint8List box,
  });

  /// `sign`: detached Ed25519 signature of [message].
  Uint8List sign({required Uint8List secretKey, required Uint8List message});

  /// Checks a detached Ed25519 [signature] of [message].
  bool verify({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  });

  /// `kdf`: subkey [id] of [key] in [context] (8 ASCII characters), of
  /// [length] bytes (BLAKE2b, `crypto_kdf_derive_from_key`).
  Uint8List kdf({
    required Uint8List key,
    required int id,
    required String context,
    int length = 32,
  });

  /// `hash`: BLAKE2b of [message], of [length] bytes (`crypto_generichash`).
  Uint8List hash(Uint8List message, {int length = 32});
}

/// A failed check: wrong key, changed ciphertext or signature.
class CryptoException implements Exception {
  const CryptoException(this.message);

  final String message;

  @override
  String toString() => 'CryptoException: $message';
}
