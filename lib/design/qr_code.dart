// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../domain/labels.dart';
import 'tokens.dart';

/// The QR code of [text], drawn from its matrix (`labelMatrix`, the `qr`
/// package) with the 4 modules of white the standard asks for around it, as
/// the web draws its inline SVG (`labels/qr.py`). [semanticLabel] is what a
/// screen reader says.
class HcQrCode extends StatelessWidget {
  const HcQrCode({
    super.key,
    required this.text,
    required this.semanticLabel,
    this.side = HcComponent.qrSide,
  });

  final String text;
  final String semanticLabel;
  final double side;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: semanticLabel,
    child: ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox.square(
          dimension: constraints.maxWidth < side ? constraints.maxWidth : side,
          child: CustomPaint(painter: _QrPainter(labelMatrix(text))),
        ),
      ),
    ),
  );
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.rows);

  final List<List<bool>> rows;

  @override
  void paint(Canvas canvas, Size size) {
    final total = rows.length + 2 * labelQuietZone;
    final module = size.width / total;
    canvas.drawRect(Offset.zero & size, Paint()..color = HcColors.surface);
    final dark = Paint()
      ..color = HcColors.text
      ..isAntiAlias = false;
    final path = Path();
    for (var r = 0; r < rows.length; r++) {
      var c = 0;
      while (c < rows[r].length) {
        if (!rows[r][c]) {
          c++;
          continue;
        }
        final start = c;
        while (c < rows[r].length && rows[r][c]) {
          c++;
        }
        path.addRect(
          Rect.fromLTWH(
            (start + labelQuietZone) * module,
            (r + labelQuietZone) * module,
            (c - start) * module,
            module,
          ),
        );
      }
    }
    canvas.drawPath(path, dark);
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.rows != rows;
}
