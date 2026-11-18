// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/scanned_code.dart';

/// The camera of the scanner, behind an interface so that the tests give
/// frames of their own (docs/adr/0014-qr-labels.md). The system asks for the
/// permission of the camera when [start] is called, that is when the person
/// opens the scanner, never at the start of the app.
abstract interface class CodeCamera {
  /// Opens the camera on the back of the phone and reads [formats] in its
  /// frames; [onCode] is called with the first code read. Throws
  /// [CodeCameraDenied] when the person refused the camera and
  /// [CodeCameraUnavailable] when there is none.
  Future<void> start(
    Set<CodeFormat> formats,
    void Function(ScannedCode code) onCode,
  );

  /// The view of the camera, once [start] returned.
  Widget preview();

  /// Closes the camera; the scanner calls it when it closes.
  Future<void> stop();
}

class CodeCameraDenied implements Exception {
  const CodeCameraDenied();

  @override
  String toString() => 'CodeCameraDenied';
}

class CodeCameraUnavailable implements Exception {
  const CodeCameraUnavailable();

  @override
  String toString() => 'CodeCameraUnavailable';
}

/// The luminance of a frame of the camera: the Y plane as it comes on
/// Android (YUV 420), worked out from blue, green and red on iOS (BGRA).
LumaFrame? lumaOf(CameraImage image) {
  final planes = image.planes;
  if (planes.isEmpty) return null;
  final plane = planes.first;
  if (image.format.group == ImageFormatGroup.bgra8888) {
    final stride = plane.bytesPerRow;
    final out = Uint8List(image.width * image.height);
    final bytes = plane.bytes;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final i = y * stride + x * 4;
        // Rec. 601 weights, in integers: (29 B + 150 G + 77 R) / 256.
        out[y * image.width + x] =
            (29 * bytes[i] + 150 * bytes[i + 1] + 77 * bytes[i + 2]) >> 8;
      }
    }
    return LumaFrame(out, image.width, image.height);
  }
  return LumaFrame(
    Uint8List.fromList(plane.bytes),
    image.width,
    image.height,
    rowStride: plane.bytesPerRow,
  );
}

ScannedCode? _read((LumaFrame, Set<CodeFormat>) job) =>
    readCode(job.$1, job.$2);

/// [CodeCamera] on the `camera` plugin of flutter.dev: CameraX on Android,
/// AVFoundation on iOS, no service of anyone else. Frames are read in an
/// isolate, one at a time; the others are dropped while one is read. No
/// sound is recorded and no picture is kept.
class PluginCodeCamera implements CodeCamera {
  CameraController? _controller;
  bool _reading = false;
  bool _done = false;

  @override
  Future<void> start(
    Set<CodeFormat> formats,
    void Function(ScannedCode code) onCode,
  ) async {
    final List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      throw _refusal(e);
    }
    if (cameras.isEmpty) throw const CodeCameraUnavailable();
    final camera =
        cameras
            .where((c) => c.lensDirection == CameraLensDirection.back)
            .firstOrNull ??
        cameras.first;
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.yuv420,
    );
    _controller = controller;
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      throw _refusal(e);
    }
    await controller.startImageStream((image) {
      if (_reading || _done) return;
      final frame = lumaOf(image);
      if (frame == null) return;
      _reading = true;
      unawaited(
        compute(_read, (frame, formats))
            .then((code) {
              if (code != null && !_done) {
                _done = true;
                onCode(code);
              }
            })
            .whenComplete(() => _reading = false),
      );
    });
  }

  static Exception _refusal(CameraException e) => switch (e.code) {
    'CameraAccessDenied' ||
    'CameraAccessDeniedWithoutPrompt' ||
    'CameraAccessRestricted' => const CodeCameraDenied(),
    _ => const CodeCameraUnavailable(),
  };

  @override
  Widget preview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }

  @override
  Future<void> stop() async {
    _done = true;
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    await controller.dispose();
  }
}
