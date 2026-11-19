// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/code_camera.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/scanned_code.dart';
import '../l10n/app_localizations.dart';

/// The scanner of the app (docs/adr/0014-qr-labels.md): the view of the
/// camera and one line that says what to point it at. It reads the kinds of
/// code it is given ([formats]) and closes with the first one read, as a
/// [ScannedCode]; it closes with nothing when the person goes back. The
/// labels give it [CodeFormat.qr]; the bar codes of products (EAN-8,
/// EAN-13, UPC-A) use the same screen with their formats.
///
/// The permission of the camera is asked when this screen opens, never
/// before; refused, the screen says so and how to allow it.
class CodeScannerScreen extends StatefulWidget {
  const CodeScannerScreen({
    super.key,
    required this.camera,
    required this.formats,
    required this.title,
    required this.hint,
  });

  final CodeCamera camera;
  final Set<CodeFormat> formats;
  final String title;
  final String hint;

  @override
  State<CodeScannerScreen> createState() => _CodeScannerScreenState();
}

enum _Camera { starting, running, denied, unavailable }

class _CodeScannerScreenState extends State<CodeScannerScreen> {
  _Camera _state = _Camera.starting;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await widget.camera.start(widget.formats, _read);
      if (mounted) setState(() => _state = _Camera.running);
    } on CodeCameraDenied {
      if (mounted) setState(() => _state = _Camera.denied);
    } on Object {
      if (mounted) setState(() => _state = _Camera.unavailable);
    }
  }

  void _read(ScannedCode code) {
    if (_closed || !mounted || !widget.formats.contains(code.format)) return;
    _closed = true;
    Navigator.of(context).pop(code);
  }

  @override
  void dispose() {
    _closed = true;
    unawaited(widget.camera.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: widget.title,
      body: HcScreenList(
        children: [
          const SizedBox(height: HcSpace.s2),
          switch (_state) {
            _Camera.denied => HcEmpty(l10n.scanDenied),
            _Camera.unavailable => HcEmpty(l10n.scanUnavailable),
            _Camera.starting => const SizedBox.shrink(),
            _Camera.running => HcCard(
              key: const Key('scanner-camera'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: l10n.scanCamera,
                    image: true,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(HcRadius.sm),
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: HcComponent.qrSide,
                            child: widget.camera.preview(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: HcSpace.s3),
                  Text(widget.hint, style: HcText.body),
                ],
              ),
            ),
          },
        ],
      ),
    );
  }
}
