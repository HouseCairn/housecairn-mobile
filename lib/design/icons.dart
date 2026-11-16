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

  /// Not in the web set, which has no icon for these three entries of More: the
  /// same 24 px grid and 2 px stroke, in the same simple shapes.
  contractors([_C(12, 8, 3.5), _P('M5 20l2.5-5h9L19 20Z')]),
  templates([_R(5, 4, 14, 17, 2), _P('M9 9h6'), _P('M9 13h6'), _P('M9 17h4')]),
  reminders([_P('M6 17.5V11l2.5-5h7L18 11v6.5Z'), _P('M10 21h4')]),

  /// Not in the web set: a problem reported (More, Reports).
  reports([_P('M12 4L21 20H3Z'), _P('M12 10v4'), _C(12, 17, 0.6)]),

  /// Not in the web set, which writes "+" in text: the same stroke.
  add([_P('M12 5v14'), _P('M5 12h14')]),

  /// Not in the web set, whose date and list fields are drawn by the browser:
  /// the field of a date, the field of a list and the button that removes a
  /// date (design lot D5), in the same stroke.
  calendar([_R(4, 5, 16, 15, 2), _P('M4 10h16'), _P('M8 3v4'), _P('M16 3v4')]),

  /// The help link of the bar (`components/icon.html`, `help`).
  help([
    _C(12, 12, 9),
    _P('M9.5 9.5a2.5 2.5 0 1 1 3.6 2.2c-.7.4-1.1.9-1.1 1.8'),
    _C(12, 17, 0.6),
  ]),
  chevronDown([_P('M6 9l6 6 6-6')]),
  clear([_P('M7 7l10 10'), _P('M17 7L7 17')]);

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

/// A path of the web icon: M, L, H, V, C, A (circular, unrotated) and Z, absolute or
/// relative.
class _P extends _Shape {
  const _P(this.d);

  final String d;

  Path toPath() {
    final path = Path();
    final tokens = RegExp(r'[MmLlHhVvCcAaZz]|-?\d*\.?\d+')
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
        case 'C':
          final x1 = next(), y1 = next(), x2 = next(), y2 = next();
          final nx = next(), ny = next();
          final ox = relative ? x : 0.0, oy = relative ? y : 0.0;
          path.cubicTo(ox + x1, oy + y1, ox + x2, oy + y2, ox + nx, oy + ny);
          x = ox + nx;
          y = oy + ny;
        case 'A':
          // rx ry rotation large-arc sweep x y; the arcs of the icons are
          // circles, so the rotation is 0 and rx equals ry.
          final r = next();
          next();
          next();
          final large = next() != 0, sweep = next() != 0;
          final nx = next(), ny = next();
          x = relative ? x + nx : nx;
          y = relative ? y + ny : ny;
          path.arcToPoint(
            Offset(x, y),
            radius: Radius.circular(r),
            largeArc: large,
            clockwise: sweep,
          );
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
