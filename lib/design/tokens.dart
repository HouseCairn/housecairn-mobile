// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

/// Design tokens of Housecairn, from `design/tokens.json`.
///
/// `design/tokens.json` is a copy of the file of the web application
/// (HouseCairn/housecairn, `design/tokens.json`), the single source of the
/// colours, radii and spacing of both. test/design_tokens_test.dart fails when
/// a value here differs from the JSON file. Sizes in `rem` are converted at
/// 16 logical pixels, the base size of the web application.
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

/// Sizes of the layout used by the app, in logical pixels (`layout`).
abstract final class HcLayout {
  /// Smallest touch target, `2.75rem`.
  static const touchTarget = 44.0;

  /// Large touch target, `3rem`.
  static const touchTargetLg = 48.0;

  /// Height of the bottom bar, `4rem`.
  static const tabbarHeight = 64.0;

  static const Map<String, double> byName = {
    'touch-target': touchTarget,
    'touch-target-lg': touchTargetLg,
    'tabbar-height': tabbarHeight,
  };
}
