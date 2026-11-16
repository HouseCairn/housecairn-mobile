// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// The file reference of docs/protocol.md section 2.9 in the form of a
/// Housecairn server (web ADR 0077, need 10): `{"file", "sha256", "size",
/// "type", "width", "height"}`. It is the value of the column `photos.image`
/// and `project_files.file`, as JSON text.
///
/// `file` is a UUID made by the phone that is not the id of the row; the
/// file on the phone is named by the id of the row, the file on the server by
/// this one. `sha256` (lower-case hexadecimal) names the bytes the phone
/// sends, so that the phone and the server never disagree silently about
/// them. A photo or a file made on the web is named by the id of its row and
/// has no `sha256`.
class FileReference {
  const FileReference({
    required this.file,
    this.sha256,
    required this.size,
    required this.type,
    this.width,
    this.height,
  });

  final String file;
  final String? sha256;
  final int size;
  final String type;
  final int? width;
  final int? height;

  /// A reference to a new file: its id is made now.
  factory FileReference.fresh(
    Uint8List bytes, {
    required String type,
    int? width,
    int? height,
  }) => FileReference(
    file: const Uuid().v4(),
    sha256: sha256Hex(bytes),
    size: bytes.length,
    type: type,
    width: width,
    height: height,
  );

  Map<String, Object?> toJson() => {
    'file': file,
    'sha256': ?sha256,
    'size': size,
    'type': type,
    'width': ?width,
    'height': ?height,
  };

  String encode() => jsonEncode(toJson());

  /// The reference written in [text], or `null` when it is none (a photo
  /// without a file, a text that is not JSON). A reference of the first
  /// builds of the app, which had no `file` (`{"size", "type", "width",
  /// "height"}`, or `{"id", "size", "content_type"}` for a file of a
  /// project), is read with the id [legacyFile] gives for the row
  /// [rowId]: the same id every time, so that the phone and the server name
  /// the file alike.
  static FileReference? parse(String? text, {required String rowId}) {
    if (text == null || text.isEmpty) return null;
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      return null;
    }
    if (json is! Map) return null;
    return fromJson(json.cast<String, Object?>(), rowId: rowId);
  }

  static FileReference? fromJson(
    Map<String, Object?> json, {
    required String rowId,
  }) {
    final file = json['file'];
    final digest = json['sha256'];
    final type = json['type'] ?? json['content_type'];
    final size = json['size'];
    if (type is! String || size is! int) return null;
    return FileReference(
      file: file is String && file.isNotEmpty ? file : legacyFile(rowId),
      sha256: digest is String && _digest.hasMatch(digest) ? digest : null,
      size: size,
      type: type,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  static final _digest = RegExp(r'^[0-9a-f]{64}$');

  /// The id a file of the first builds takes: derived from the id of its
  /// row, so that every operation of the row names the same file.
  static String legacyFile(String rowId) =>
      const Uuid().v5(Namespace.url.value, 'housecairn-file:$rowId');

  /// Whether [text] is a reference of the first builds of the app, which
  /// had no `file`: the phone completes it from the file it holds. A
  /// reference without `sha256` but with a `file` is a server's (a photo made
  /// on the web), left as it is.
  static bool isLegacy(String? text) {
    if (text == null || text.isEmpty) return false;
    try {
      final json = jsonDecode(text);
      return json is Map && json['file'] is! String;
    } on FormatException {
      return false;
    }
  }
}

/// The SHA-256 of [bytes], in lower-case hexadecimal.
String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();
