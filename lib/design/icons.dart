// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// The outline icons of the web application
/// (`src/housecairn/templates/components/icon.html`): a 24 px grid, a stroke
/// of 2 px with round ends, in the colour of the text. Each icon is the same
/// list of shapes as the web one, drawn by [HcIcon]; the app has no icon font
/// of its own for them.
enum HcIcons {
  today([_P('M4 12.5l5 5L20 6.5')]),
  rooms([
    _P('M6 20V4.5L16 6v14'),
    _P('M3.5 20h17'),
    _P('M16 8h2.5V20'),
    _C(13, 13, 0.8),
  ]),
  projects([_R(3, 4, 5, 16, 1.5), _R(10, 4, 5, 10, 1.5), _R(17, 4, 4, 7, 1.5)]),
  budget([_P('M4 19V9'), _P('M10 19V5'), _P('M16 19v-7'), _P('M21 19H3')]),
  more([_C(5.5, 12, 1.2), _C(12, 12, 1.2), _C(18.5, 12, 1.2)]),
  home([
    _P('M3 11.5 12 4l9 7.5'),
    _P('M5.5 10v9.5h13V10'),
    _P('M10 19.5v-5h4v5'),
  ]),
  homes([
    _P('M4 20V9l6-4 6 4v11'),
    _P('M16 20V12l4 2.5V20'),
    _P('M2.5 20h19'),
    _P('M8 20v-4h4v4'),
  ]),
  chevron([_P('M9 6l6 6-6 6')]),
  info([_C(12, 12, 9), _P('M12 11v5.5'), _C(12, 7.8, 0.6)]),

  /// Not in the web set, which writes "+" in text: the same stroke.
  add([_P('M12 5v14'), _P('M5 12h14')]);

  const HcIcons(this.shapes);

  final List<Object> shapes;
}

/// An icon of [HcIcons], [size] logical pixels square, in [color] or the
/// colour of the [IconTheme]. Decorative, as on the web: the text next to it,
/// or the tooltip of its button, carries the meaning.
class HcIcon extends StatelessWidget {
  const HcIcon(this.icon, {super.key, this.size, this.color});

  final HcIcons icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? HcComponent.iconSize;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: side,
        child: CustomPaint(
          painter: _IconPainter(
            icon,
            color ?? theme.color ?? DefaultTextStyle.of(context).style.color!,
          ),
        ),
      ),
    );
  }
}

sealed class _Shape {
  const _Shape();
}

/// A path of the web icon: M, L, H, V and Z, absolute or relative.
class _P extends _Shape {
  const _P(this.d);

  final String d;

  Path toPath() {
    final path = Path();
    final tokens = RegExp(r'[MmLlHhVvZz]|-?\d*\.?\d+')
        .allMatches(d)
        .map((m) => m.group(0)!)
        .toList();
    var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
    var command = 'M';
    var i = 0;
    double next() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      if (RegExp(r'[A-Za-z]').hasMatch(tokens[i])) command = tokens[i++];
      final relative = command == command.toLowerCase();
      switch (command.toUpperCase()) {
        case 'M':
          final nx = next(), ny = next();
          x = relative ? x + nx : nx;
          y = relative ? y + ny : ny;
          startX = x;
          startY = y;
          path.moveTo(x, y);
          // Pairs after a moveto are linetos (SVG).
          command = relative ? 'l' : 'L';
        case 'L':
          final nx = next(), ny = next();
          x = relative ? x + nx : nx;
          y = relative ? y + ny : ny;
          path.lineTo(x, y);
        case 'H':
          final nx = next();
          x = relative ? x + nx : nx;
          path.lineTo(x, y);
        case 'V':
          final ny = next();
          y = relative ? y + ny : ny;
          path.lineTo(x, y);
        case 'Z':
          path.close();
          x = startX;
          y = startY;
        default:
          throw FormatException('Unsupported command', command);
      }
    }
    return path;
  }
}

class _C extends _Shape {
  const _C(this.cx, this.cy, this.r);

  final double cx, cy, r;
}

class _R extends _Shape {
  const _R(this.x, this.y, this.width, this.height, this.rx);

  final double x, y, width, height, rx;
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);

  final HcIcons icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = HcComponent.iconStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final shape in icon.shapes) {
      switch (shape) {
        case _P():
          canvas.drawPath(shape.toPath(), paint);
        case _C(:final cx, :final cy, :final r):
          canvas.drawCircle(Offset(cx, cy), r, paint);
        case _R(:final x, :final y, :final width, :final height, :final rx):
          canvas.drawRRect(
            RRect.fromLTRBR(x, y, x + width, y + height, Radius.circular(rx)),
            paint,
          );
      }
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color;
}
