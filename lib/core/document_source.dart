// SPDX-License-Identifier: AGPL-3.0-only

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// A document the person picked: its name as the system shows it, its bytes
/// and its type, read from the extension.
class PickedDocument {
  const PickedDocument(this.name, this.bytes, this.contentType);

  final String name;
  final Uint8List bytes;
  final String contentType;
}

/// Where the file of a quote comes from: the Files app on iOS, the document
/// picker of the system on Android. Behind an interface so that tests give
/// one. No permission is asked: the system picker gives only the file chosen.
abstract interface class DocumentSource {
  /// A PDF or a photo; `null` when the person cancelled.
  Future<PickedDocument?> pickDocument();
}

/// The type of a file the app accepts for a quote, from its name; `null`
/// for any other.
String? documentType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.png')) return 'image/png';
  return null;
}

/// [DocumentSource] on `file_picker` (UIDocumentPickerViewController on iOS,
/// the Storage Access Framework on Android). The copy the picker makes in the
/// cache of the app is removed once read.
class FilePickerSource implements DocumentSource {
  const FilePickerSource();

  @override
  Future<PickedDocument?> pickDocument() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked == null) return null;
    try {
      final type = documentType(picked.name);
      if (type == null) return null;
      return PickedDocument(picked.name, await picked.readAsBytes(), type);
    } finally {
      await FilePicker.clearTemporaryFiles();
    }
  }
}
