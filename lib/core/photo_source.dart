// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Where a photo comes from, behind an interface so that tests give one.
/// The system asks for its permission at the moment of use (the camera when
/// the person takes a photo; the gallery picker needs none on recent
/// systems), never at start.
abstract interface class PhotoSource {
  /// A photo taken with the camera; `null` when the person cancelled.
  /// Throws [PhotoPermissionDenied] when they refused the camera.
  Future<Uint8List?> takePhoto();

  /// A photo picked from the gallery; `null` when the person cancelled.
  /// Throws [PhotoPermissionDenied] when they refused access.
  Future<Uint8List?> pickPhoto();
}

/// The person refused the camera or the gallery. The screen says so and
/// points to the system settings; nothing else changes.
class PhotoPermissionDenied implements Exception {
  const PhotoPermissionDenied();

  @override
  String toString() => 'PhotoPermissionDenied';
}

/// [PhotoSource] on `image_picker`. The picker returns the file as the
/// camera or the gallery made it, location included: it is read as bytes and
/// handed to `processPhoto`, which drops every metadata before anything is
/// stored.
class ImagePickerSource implements PhotoSource {
  ImagePickerSource([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<Uint8List?> _from(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      return await file?.readAsBytes();
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        throw const PhotoPermissionDenied();
      }
      rethrow;
    }
  }

  @override
  Future<Uint8List?> takePhoto() => _from(ImageSource.camera);

  @override
  Future<Uint8List?> pickPhoto() => _from(ImageSource.gallery);
}
