// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'file_reference.dart';

/// Photos, re-encoded on the phone before anything is stored, as the web
/// re-encodes them on upload (`rooms/images.py:75-101`, docs/spec.md, "Photos
/// and files"): turned upright, every metadata removed but the colour profile
/// (the location included), the longest side at most [maxSide] pixels (JPEG
/// quality [jpegQuality]), and a thumbnail of [thumbnailSide] pixels.
///
/// Pure Dart on purpose: the rule is the same on the phone and in the tests,
/// which run it on a fixture with GPS data (a native encoder would only run
/// on a device).

/// Longest side of a stored photo (`rooms/conf.py:17`).
const maxSide = 2560;

/// Longest side of a thumbnail (`rooms/conf.py:18`).
const thumbnailSide = 360;

/// JPEG quality of the stored photo and of the thumbnail (`rooms/images.py`).
const jpegQuality = 85;

/// The most a file may weigh before it is read: 20 MiB (docs/spec.md).
const maxFileBytes = 20 * 1024 * 1024;

/// The most pixels an image may have, to bound the memory of the decoder
/// (`rooms/conf.py`, `MAX_PIXELS`).
const maxPixels = 40000000;

/// Why a photo was refused.
enum PhotoProblem {
  /// Not an image the app reads (JPEG, PNG, GIF, WebP, BMP, TIFF).
  unreadable,

  /// More than [maxFileBytes].
  tooLarge,

  /// More than [maxPixels] pixels.
  tooManyPixels,
}

class PhotoRefused implements Exception {
  const PhotoRefused(this.problem);

  final PhotoProblem problem;

  @override
  String toString() => 'PhotoRefused: ${problem.name}';
}

/// A photo ready to store: the image and its thumbnail, both JPEG without
/// metadata.
class ProcessedPhoto {
  const ProcessedPhoto({
    required this.image,
    required this.thumbnail,
    required this.width,
    required this.height,
  });

  final Uint8List image;
  final Uint8List thumbnail;
  final int width;
  final int height;

  /// The file reference of a new photo in the form of a Housecairn server
  /// (web ADR 0077, need 10): an id made now, the SHA-256 of [image], its
  /// size, type and dimensions. It is the JSON of the column `photos.image`.
  FileReference fileReference() => FileReference.fresh(
    image,
    type: 'image/jpeg',
    width: width,
    height: height,
  );

  /// The reference of docs/protocol.md section 2.9 without a file id nor a
  /// digest, as the column of a stock article's label and of a report's
  /// photo hold it until a lot of their own.
  String get reference => jsonEncode({
    'size': image.length,
    'type': 'image/jpeg',
    'width': width,
    'height': height,
  });
}

/// Re-encodes [bytes] (what the camera or the gallery gave) as a stored
/// photo. Throws [PhotoRefused].
ProcessedPhoto processPhoto(Uint8List bytes) {
  if (bytes.length > maxFileBytes) {
    throw const PhotoRefused(PhotoProblem.tooLarge);
  }
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const PhotoRefused(PhotoProblem.unreadable);
  if (decoded.width * decoded.height > maxPixels) {
    throw const PhotoRefused(PhotoProblem.tooManyPixels);
  }
  // Upright first: the orientation tag is metadata, and it is dropped.
  final upright = img.bakeOrientation(decoded);
  final stored = _fit(upright, maxSide);
  final thumb = _fit(stored, thumbnailSide);
  return ProcessedPhoto(
    image: _encode(stored),
    thumbnail: _encode(thumb),
    width: stored.width,
    height: stored.height,
  );
}

/// The thumbnail of a photo another phone made (what a server gives back),
/// as [processPhoto] makes one; `null` when [bytes] are not an image.
Uint8List? makeThumbnail(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null || decoded.width * decoded.height > maxPixels) {
    return null;
  }
  return _encode(_fit(img.bakeOrientation(decoded), thumbnailSide));
}

/// [source] reduced so that its longest side is at most [side]; never
/// enlarged.
img.Image _fit(img.Image source, int side) {
  final longest = source.width > source.height ? source.width : source.height;
  if (longest <= side) return source;
  return source.width >= source.height
      ? img.copyResize(
          source,
          width: side,
          interpolation: img.Interpolation.average,
        )
      : img.copyResize(
          source,
          height: side,
          interpolation: img.Interpolation.average,
        );
}

/// JPEG of [source] without any metadata block but its colour profile.
Uint8List _encode(img.Image source) {
  // A fresh, empty EXIF block: nothing of the original travels.
  source.exif = img.ExifData();
  return stripJpegMetadata(img.encodeJpg(source, quality: jpegQuality));
}

/// The names of the metadata segments of a JPEG file: `Exif`, `XMP`,
/// `APP<n>` for the other application segments except the colour profile
/// (`ICC_PROFILE`) and the JFIF header, and `COM` for a comment.
List<String> jpegMetadata(Uint8List jpeg) {
  final found = <String>[];
  _walk(jpeg, (marker, start, end) {
    final name = _metadataName(jpeg, marker, start, end);
    if (name != null) found.add(name);
    return true;
  });
  return found;
}

/// [jpeg] without its metadata segments (see [jpegMetadata]); the colour
/// profile, the JFIF header and the image data are kept as they are.
Uint8List stripJpegMetadata(Uint8List jpeg) {
  final out = BytesBuilder(copy: false)..add(jpeg.sublist(0, 2));
  var tail = jpeg.length;
  _walk(jpeg, (marker, start, end) {
    if (marker == 0xDA) {
      tail = start;
      return false;
    }
    if (_metadataName(jpeg, marker, start, end) == null) {
      out.add(jpeg.sublist(start, end));
    }
    return true;
  });
  out.add(jpeg.sublist(tail));
  return out.toBytes();
}

/// Calls [visit] for each segment before the image data (and for the start
/// of scan, `0xDA`, which ends the walk) with its marker byte and the range
/// of the whole segment, marker included. [visit] returns `false` to stop.
void _walk(
  Uint8List jpeg,
  bool Function(int marker, int start, int end) visit,
) {
  if (jpeg.length < 4 || jpeg[0] != 0xFF || jpeg[1] != 0xD8) return;
  var i = 2;
  while (i + 4 <= jpeg.length) {
    if (jpeg[i] != 0xFF) return;
    final marker = jpeg[i + 1];
    if (marker == 0xFF) {
      i++;
      continue;
    }
    final length = (jpeg[i + 2] << 8) | jpeg[i + 3];
    final end = i + 2 + length;
    if (marker == 0xDA) {
      visit(marker, i, end);
      return;
    }
    if (end > jpeg.length || !visit(marker, i, end)) return;
    i = end;
  }
}

String? _metadataName(Uint8List jpeg, int marker, int start, int end) {
  if (marker == 0xFE) return 'COM';
  if (marker < 0xE0 || marker > 0xEF) return null;
  final body = String.fromCharCodes(
    jpeg.sublist(start + 4, end < start + 16 ? end : start + 16),
    0,
  );
  if (marker == 0xE0 && body.startsWith('JFIF')) return null;
  if (marker == 0xE2 && body.startsWith('ICC_PROFILE')) return null;
  if (marker == 0xE1 && body.startsWith('Exif')) return 'Exif';
  if (marker == 0xE1 && body.startsWith('http://ns.adobe.com/xap')) {
    return 'XMP';
  }
  return 'APP${marker - 0xE0}';
}
