// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:housecairn_mobile/core/notifier.dart';
import 'package:housecairn_mobile/core/photo_source.dart';
import 'package:image/image.dart' as img;

/// A [Notifier] that keeps what is scheduled, and answers the permission as
/// the test sets it. [asked] counts the times the permission was asked for.
class FakeNotifier implements Notifier {
  FakeNotifier({this.allowed = true});

  /// What the system answers when asked.
  bool allowed;

  /// Whether the person has granted the permission so far.
  bool granted = false;
  int asked = 0;
  final scheduled = <int, ScheduledNotification>{};
  int cancelAlls = 0;

  @override
  Future<bool> permitted() async => granted;

  @override
  Future<bool> requestPermission() async {
    asked++;
    granted = allowed;
    return allowed;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String channel,
    String? payload,
  }) async {
    scheduled[id] = ScheduledNotification(id, title, body, at, payload);
    channels.add(channel);
  }

  /// The channel names given with each notification scheduled so far.
  final channels = <String>{};

  /// The payload of the notification that started the app, if any.
  String? launch;

  @override
  Future<String?> launchPayload() async => launch;

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  @override
  Future<void> cancelAll() async {
    cancelAlls++;
    scheduled.clear();
  }

  @override
  Future<List<int>> pending() async => scheduled.keys.toList();
}

class ScheduledNotification {
  const ScheduledNotification(
    this.id,
    this.title,
    this.body,
    this.at,
    this.payload,
  );

  final int id;
  final String title;
  final String body;
  final DateTime at;
  final String? payload;
}

/// A [PhotoSource] that gives the bytes it was given, or refuses.
class FakePhotoSource implements PhotoSource {
  FakePhotoSource({this.photo, this.denied = false, this.noCamera = false});

  Uint8List? photo;

  /// The person refuses the camera and the gallery.
  bool denied;

  /// The phone has no camera (the gallery still works).
  bool noCamera;
  int taken = 0;
  int picked = 0;

  @override
  Future<Uint8List?> takePhoto() async {
    taken++;
    if (noCamera) throw const PhotoCameraUnavailable();
    if (denied) throw const PhotoPermissionDenied();
    return photo;
  }

  @override
  Future<Uint8List?> pickPhoto() async {
    picked++;
    if (denied) throw const PhotoPermissionDenied();
    return photo;
  }
}

/// The GPS position written in [jpegWithGps].
const gpsLatitude = 51.4778;
const gpsLongitude = 0.0;

/// A JPEG of [width] by [height] pixels as a camera makes it: with an EXIF
/// block that holds a GPS position, the make of the camera and an orientation
/// (a quarter turn, [orientation] 6), and a comment.
Uint8List jpegWithGps({
  int width = 64,
  int height = 32,
  int orientation = 6,
  bool comment = true,
}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(x, y, x * 255 ~/ width, y * 255 ~/ height, 128);
    }
  }
  image.exif.imageIfd.make = 'Fake camera';
  image.exif.imageIfd.orientation = orientation;
  image.exif.gpsIfd.setGpsLocation(
    latitude: gpsLatitude,
    longitude: gpsLongitude,
  );
  var bytes = img.encodeJpg(image, quality: 90);
  if (comment) {
    // A comment segment (COM) right after the start of image.
    const text = 'taken at home';
    final segment = [0xFF, 0xFE, 0, text.length + 2, ...text.codeUnits];
    bytes = Uint8List.fromList([
      ...bytes.sublist(0, 2),
      ...segment,
      ...bytes.sublist(2),
    ]);
  }
  return bytes;
}
