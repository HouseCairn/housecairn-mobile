// SPDX-License-Identifier: AGPL-3.0-only

// The adapter on `image_picker`: what it hands on, what it deletes, and how it
// turns the errors of the system into the exceptions of the app.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/photo_source.dart';
import 'package:image_picker/image_picker.dart';

import 'support/fakes.dart';

/// A picker that gives a file, nothing, or an error of the system.
class _Picker extends Fake implements ImagePicker {
  _Picker({this.file, this.error});

  final File? file;
  final PlatformException? error;
  final asked = <ImageSource>[];

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    asked.add(source);
    final failure = error;
    if (failure != null) throw failure;
    final f = file;
    return f == null ? null : XFile(f.path);
  }
}

void main() {
  late Directory cache;

  setUp(() {
    cache = Directory.systemTemp.createTempSync('picker');
    addTearDown(() => cache.deleteSync(recursive: true));
  });

  File original(Uint8List bytes) =>
      File('${cache.path}/picked.jpg')..writeAsBytesSync(bytes);

  group(
    'the file of the picker keeps the location: it is deleted once read',
    () {
      test('the camera: the bytes are handed on, the file is gone', () async {
        final bytes = jpegWithGps();
        final file = original(bytes);
        final picker = _Picker(file: file);
        expect(await ImagePickerSource(picker).takePhoto(), bytes);
        expect(picker.asked, [ImageSource.camera]);
        expect(file.existsSync(), isFalse);
        expect(cache.listSync(), isEmpty);
      });

      test('the gallery: the same', () async {
        final bytes = jpegWithGps();
        final file = original(bytes);
        final picker = _Picker(file: file);
        expect(await ImagePickerSource(picker).pickPhoto(), bytes);
        expect(picker.asked, [ImageSource.gallery]);
        expect(file.existsSync(), isFalse);
      });

      test('cancelled: nothing is returned, nothing to delete', () async {
        expect(await ImagePickerSource(_Picker()).takePhoto(), isNull);
      });
    },
  );

  group('the errors of the system', () {
    Future<Object?> failure(String code, {bool camera = true}) async {
      final source = ImagePickerSource(
        _Picker(error: PlatformException(code: code)),
      );
      try {
        await (camera ? source.takePhoto() : source.pickPhoto());
      } on Object catch (e) {
        return e;
      }
      return null;
    }

    test('a refused camera is PhotoPermissionDenied', () async {
      expect(
        await failure('camera_access_denied'),
        isA<PhotoPermissionDenied>(),
      );
    });

    test('a refused gallery is PhotoPermissionDenied', () async {
      expect(
        await failure('photo_access_denied', camera: false),
        isA<PhotoPermissionDenied>(),
      );
    });

    test('no camera on the phone is PhotoCameraUnavailable', () async {
      expect(
        await failure('no_available_camera'),
        isA<PhotoCameraUnavailable>(),
      );
    });

    test('any other error goes up unchanged', () async {
      expect(await failure('something_else'), isA<PlatformException>());
    });
  });
}
