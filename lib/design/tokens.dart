// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

/// Design tokens of Housecairn, from `design/tokens.json`.
///
/// Every group of `design/tokens.json` but `component` is a copy of the file
/// of the web application (HouseCairn/housecairn, `design/tokens.json`), the
/// single source of the colours, type, spacing, radii and shadows of both;
/// `component` holds the few sizes the web components write in their own CSS.
/// `$sources` in the JSON file names the web path of every value.
/// test/design_tokens_test.dart fails when a value here differs from the JSON
/// file. Sizes in `rem` are converted at 16 logical pixels, the base size of
/// the web application; the text size of the phone then scales the text.
abstract final class HcColors {
  static const slate = Color(0xFF1F3A3D);
  static const slateDeep = Color(0xFF162B2D);
  static const sand = Color(0xFFC8A27C);
  static const sage = Color(0xFF8FA39A);
  static const stone = Color(0xFF5F726E);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEFEBE4);
  static const sandSoft = Color(0xFFF3EBE1);
  static const sageSoft = Color(0xFFE6ECE9);
  static const border = Color(0xFFE3DED6);
  static const borderStrong = Color(0xFF7A8783);
  static const text = Color(0xFF1B2422);
  static const textMuted = Color(0xFF4F605C);
  static const textInverse = Color(0xFFFFFFFF);
  static const textOnSand = Color(0xFF2A1E12);
  static const textSand = Color(0xFF7A5A3A);
  static const primary = Color(0xFF1F3A3D);
  static const primaryHover = Color(0xFF2B4C50);
  static const accent = Color(0xFFC8A27C);
  static const focus = Color(0xFF1F3A3D);
  static const success = Color(0xFF2E6B4F);
  static const successSoft = Color(0xFFE0EFE6);
  static const warning = Color(0xFF7A4F00);
  static const warningSoft = Color(0xFFF8EBD0);
  static const danger = Color(0xFF9A3F1D);
  static const dangerSoft = Color(0xFFF6E3DA);
  static const info = Color(0xFF2F5D8A);
  static const infoSoft = Color(0xFFE3EEF4);

  /// `rgba(20, 30, 30, 0.38)`.
  static const overlay = Color.fromRGBO(20, 30, 30, 0.38);

  /// Every colour token by its name in `design/tokens.json`.
  static const Map<String, Color> byName = {
    'slate': slate,
    'slate-deep': slateDeep,
    'sand': sand,
    'sage': sage,
    'stone': stone,
    'background': background,
    'surface': surface,
    'surface-muted': surfaceMuted,
    'sand-soft': sandSoft,
    'sage-soft': sageSoft,
    'border': border,
    'border-strong': borderStrong,
    'text': text,
    'text-muted': textMuted,
    'text-inverse': textInverse,
    'text-on-sand': textOnSand,
    'text-sand': textSand,
    'primary': primary,
    'primary-hover': primaryHover,
    'accent': accent,
    'focus': focus,
    'success': success,
    'success-soft': successSoft,
    'warning': warning,
    'warning-soft': warningSoft,
    'danger': danger,
    'danger-soft': dangerSoft,
    'info': info,
    'info-soft': infoSoft,
    'overlay': overlay,
  };
}

/// Type (`font` of the tokens): the family, the sizes in logical pixels
/// before the text size of the phone, the weights and the line heights.
abstract final class HcFont {
  /// Manrope, bundled with the app (assets/fonts/README.md). The web serves
  /// the same Manrope (a variable font, `Manrope-latin-variable.woff2`) and
  /// names system fonts only as a fallback: both draw Manrope, the app with
  /// static weights.
  static const family = 'Manrope';

  static const size2xs = 12.0;
  static const sizeXs = 13.0;
  static const sizeSm = 14.0;
  static const sizeBase = 16.0;
  static const sizeMd = 17.0;
  static const sizeLg = 20.0;
  static const sizeXl = 24.0;
  static const size2xl = 32.0;

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const heavy = FontWeight.w800;

  /// Line height, as a multiple of the size.
  static const lineHeight = 1.5;
  static const lineHeightTight = 1.25;

  /// Letter spacing of the headings in capitals, as a multiple of the size
  /// (`0.08em`).
  static const trackingCaps = 0.08;

  static const Map<String, double> sizeByName = {
    'size-2xs': size2xs,
    'size-xs': sizeXs,
    'size-sm': sizeSm,
    'size-base': sizeBase,
    'size-md': sizeMd,
    'size-lg': sizeLg,
    'size-xl': sizeXl,
    'size-2xl': size2xl,
  };

  static const Map<String, FontWeight> weightByName = {
    'weight-regular': regular,
    'weight-medium': medium,
    'weight-bold': bold,
    'weight-heavy': heavy,
  };

  /// Every weight the app draws: the only weights bundled (pubspec.yaml).
  static const weights = [regular, medium, bold, heavy];
}

/// Spacing, in logical pixels (`space` of the tokens).
abstract final class HcSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;

  static const Map<String, double> byName = {
    '1': s1,
    '2': s2,
    '3': s3,
    '4': s4,
    '5': s5,
    '6': s6,
    '8': s8,
    '12': s12,
  };
}

/// Corner radii, in logical pixels (`radius` of the tokens).
abstract final class HcRadius {
  static const sm = 10.0;
  static const md = 12.0;
  static const lg = 14.0;
  static const xl = 22.0;
  static const pill = 999.0;

  static const Map<String, double> byName = {
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
    'pill': pill,
  };
}

/// Shadows (`shadow` of the tokens).
abstract final class HcShadow {
  /// `0 1px 2px rgba(0, 0, 0, 0.08)`.
  static const sm = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, 0.08),
    ),
  ];

  /// `0 8px 20px rgba(31, 58, 61, 0.35)`.
  static const lg = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 20,
      color: Color.fromRGBO(31, 58, 61, 0.35),
    ),
  ];

  static const Map<String, List<BoxShadow>> byName = {'sm': sm, 'lg': lg};
}

/// Sizes of the layout used by the app, in logical pixels (`layout`).
abstract final class HcLayout {
  /// Smallest touch target of the web, `2.75rem`. The app uses
  /// [touchTargetLg] everywhere: 48 is the minimum of Android and the
  /// size Material's own widgets keep (docs/adr/0011).
  static const touchTarget = 44.0;

  /// Large touch target, `3rem`: every target of the app.
  static const touchTargetLg = 48.0;

  /// Height of the bottom bar, `4rem`.
  static const tabbarHeight = 64.0;

  /// The brand icon in the bar, `2.5rem`.
  static const logoIcon = 40.0;

  static const Map<String, double> byName = {
    'touch-target': touchTarget,
    'touch-target-lg': touchTargetLg,
    'tabbar-height': tabbarHeight,
    'logo-icon': logoIcon,
  };
}

/// Sizes the web components write in their own CSS (`component`).
abstract final class HcComponent {
  static const borderWidth = 1.0;
  static const focusRing = 3.0;
  static const iconSize = 22.0;
  static const iconStroke = 2.0;
  static const chevronSize = 18.0;
  static const appbarMinHeight = 56.0;
  static const rowMinHeight = 56.0;
  static const rowLineHeight = 1.3;

  /// `.row-text { line-height }`: 1.35, not a token of the web.
  static const rowTextLineHeight = 1.35;
  static const rowTextGap = 2.0;
  static const pillPaddingY = 3.0;
  static const pillPaddingX = 8.0;
  static const buttonLineHeight = 1.2;

  /// Letter spacing of the page titles, as a multiple of the size.
  static const headingTracking = -0.01;
  static const navLabelGap = 3.0;

  static const Map<String, double> byName = {
    'border-width': borderWidth,
    'focus-ring': focusRing,
    'icon-size': iconSize,
    'icon-stroke': iconStroke,
    'chevron-size': chevronSize,
    'appbar-min-height': appbarMinHeight,
    'row-min-height': rowMinHeight,
    'row-line-height': rowLineHeight,
    'row-text-gap': rowTextGap,
    'pill-padding-y': pillPaddingY,
    'pill-padding-x': pillPaddingX,
    'button-line-height': buttonLineHeight,
    'heading-tracking': headingTracking,
    'nav-label-gap': navLabelGap,
  };
}
