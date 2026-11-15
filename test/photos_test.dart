// SPDX-License-Identifier: AGPL-3.0-only

// Photos re-encoded on the phone (docs/spec.md, "Photos and files"): no
// metadata, upright, at most 2560 px, a thumbnail of 360 px, and the file
// reference of docs/protocol.md section 2.9.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:image/image.dart' as img;

import 'support/fakes.dart';

void main() {
  group('the fixture is what a camera makes', () {
    test('it holds an EXIF block with a GPS position, and a comment', () {
      final photo = jpegWithGps();
      expect(jpegMetadata(photo), containsAll(['Exif', 'COM']));
      final exif = img.decodeJpgExif(photo)!;
      expect(exif.gpsIfd.gpsLatitude, closeTo(gpsLatitude, 1e-6));
      expect(exif.gpsIfd.gpsLongitude, closeTo(gpsLongitude, 1e-6));
      expect(exif.imageIfd.make, 'Fake camera');
    });
  });

  group('a stored photo has no metadata', () {
    test('no EXIF block, no GPS position, no comment, nothing', () {
      final stored = processPhoto(jpegWithGps());
      for (final file in [stored.image, stored.thumbnail]) {
        expect(jpegMetadata(file), isEmpty);
        final exif = img.decodeJpgExif(file);
        expect(exif == null || exif.isEmpty, isTrue);
        // Neither the position nor the make of the camera, as text, anywhere
        // in the bytes.
        expect(
          latin1.decode(file, allowInvalid: true),
          isNot(contains('Fake')),
        );
        expect(
          latin1.decode(file, allowInvalid: true),
          isNot(contains('Exif')),
        );
        expect(
          latin1.decode(file, allowInvalid: true),
          isNot(contains('taken at')),
        );
      }
    });

    test('the colour profile is kept, as the web keeps it', () {
      final image = img.Image(width: 8, height: 8);
      image.iccProfile = img.IccProfile(
        'test',
        img.IccProfileCompression.none,
        Uint8List.fromList(List<int>.generate(128, (i) => i)),
      );
      final stored = processPhoto(img.encodeJpg(image));
      expect(img.decodeJpg(stored.image)!.iccProfile, isNotNull);
      expect(jpegMetadata(stored.image), isEmpty);
    });

    test(
      'stripJpegMetadata removes what the camera wrote and nothing else',
      () {
        final source = jpegWithGps(orientation: 1);
        final clean = stripJpegMetadata(source);
        expect(jpegMetadata(clean), isEmpty);
        final before = img.decodeJpg(source)!;
        final after = img.decodeJpg(clean)!;
        expect([after.width, after.height], [before.width, before.height]);
        expect(after.getPixel(10, 10), before.getPixel(10, 10));
      },
    );
  });

  group('a stored photo is upright and not larger than the spec says', () {
    test('a quarter turn is applied, then dropped', () {
      // 64 x 32 with the tag 6 (turn 90 degrees clockwise) is shown 32 x 64.
      final stored = processPhoto(jpegWithGps(width: 64, height: 32));
      expect([stored.width, stored.height], [32, 64]);
      final decoded = img.decodeJpg(stored.image)!;
      expect([decoded.width, decoded.height], [32, 64]);
    });

    test('the longest side is at most 2560 px, the ratio kept', () {
      final stored = processPhoto(
        jpegWithGps(width: 3200, height: 2400, orientation: 1),
      );
      expect([stored.width, stored.height], [2560, 1920]);
      final decoded = img.decodeJpg(stored.image)!;
      expect([decoded.width, decoded.height], [2560, 1920]);
    });

    test('a photo that is smaller is not enlarged', () {
      final stored = processPhoto(
        jpegWithGps(width: 800, height: 600, orientation: 1),
      );
      expect([stored.width, stored.height], [800, 600]);
    });

    test('the thumbnail is 360 px on its longest side', () {
      final stored = processPhoto(
        jpegWithGps(width: 1200, height: 800, orientation: 1),
      );
      final thumb = img.decodeJpg(stored.thumbnail)!;
      expect([thumb.width, thumb.height], [360, 240]);
    });

    test('a portrait thumbnail is limited on its height', () {
      final stored = processPhoto(
        jpegWithGps(width: 800, height: 1200, orientation: 1),
      );
      final thumb = img.decodeJpg(stored.thumbnail)!;
      expect([thumb.width, thumb.height], [240, 360]);
    });
  });

  group('the file reference of protocol section 2.9', () {
    test('size, type and dimensions; no blob and no key before the upload', () {
      final stored = processPhoto(jpegWithGps(orientation: 1));
      final reference = jsonDecode(stored.reference) as Map<String, dynamic>;
      expect(reference, {
        'size': stored.image.length,
        'type': 'image/jpeg',
        'width': 64,
        'height': 32,
      });
    });
  });

  group('what is refused', () {
    test('something that is not an image', () {
      expect(
        () => processPhoto(Uint8List.fromList([1, 2, 3, 4, 5])),
        throwsA(
          isA<PhotoRefused>().having(
            (e) => e.problem,
            'problem',
            PhotoProblem.unreadable,
          ),
        ),
      );
    });

    test('a file above 20 MiB', () {
      expect(
        () => processPhoto(Uint8List(maxFileBytes + 1)),
        throwsA(
          isA<PhotoRefused>().having(
            (e) => e.problem,
            'problem',
            PhotoProblem.tooLarge,
          ),
        ),
      );
    });

    test('the limits are those of the spec and of the web', () {
      expect(maxSide, 2560);
      expect(thumbnailSide, 360);
      expect(jpegQuality, 85);
      expect(maxFileBytes, 20 * 1024 * 1024);
      // The web files (rooms/conf.py) the numbers come from.
      expect(File('docs/spec.md').readAsStringSync(), contains('2560'));
    });
  });
}
