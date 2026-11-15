// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Where a photo comes from, behind an interface so that tests give one.
/// The system asks for its permission at the moment of use (the camera when
/// the person takes a photo; the gallery picker needs none on recent
/// systems), never at start.
abstract interface class PhotoSource {
  /// A photo taken with the camera; `null` when the person cancelled.
  /// Throws [PhotoPermissionDenied] when they refused the camera, and
  /// [PhotoCameraUnavailable] when the phone has none.
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

/// There is no camera to use (a tablet without one, an emulator). The screen
/// says so; nothing else changes.
class PhotoCameraUnavailable implements Exception {
  const PhotoCameraUnavailable();

  @override
  String toString() => 'PhotoCameraUnavailable';
}

/// [PhotoSource] on `image_picker`. The picker returns the file as the
/// camera or the gallery made it, location included: it is read as bytes and
/// handed to `processPhoto`, which drops every metadata before anything is
/// stored. The file the picker made keeps the location, so it is deleted as
/// soon as it is read: no copy with the position stays in the cache of the
/// app.
class ImagePickerSource implements PhotoSource {
  ImagePickerSource([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<Uint8List?> _from(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return null;
      try {
        return await picked.readAsBytes();
      } finally {
        await _forget(picked.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        throw const PhotoPermissionDenied();
      }
      if (e.code == 'no_available_camera') {
        throw const PhotoCameraUnavailable();
      }
      rethrow;
    }
  }

  /// Deletes the file of the picker. A failure is not an error of the photo:
  /// the system empties its cache on its own in the end.
  Future<void> _forget(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // Left to the system.
    }
  }

  @override
  Future<Uint8List?> takePhoto() => _from(ImageSource.camera);

  @override
  Future<Uint8List?> pickPhoto() => _from(ImageSource.gallery);
}
