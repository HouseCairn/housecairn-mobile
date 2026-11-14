// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// The Material 3 theme of Housecairn, built from the design tokens.
///
/// Text uses the system font: Manrope, the font of the web application, is
/// not bundled (no font file in the app until a lot decides it). Text sizes
/// are Material's, so that the system's text size applies.
ThemeData housecairnTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: HcColors.primary,
    onPrimary: HcColors.textInverse,
    primaryContainer: HcColors.sageSoft,
    onPrimaryContainer: HcColors.slateDeep,
    secondary: HcColors.sand,
    onSecondary: HcColors.textOnSand,
    secondaryContainer: HcColors.sandSoft,
    onSecondaryContainer: HcColors.textOnSand,
    tertiary: HcColors.stone,
    onTertiary: HcColors.textInverse,
    error: HcColors.danger,
    onError: HcColors.textInverse,
    errorContainer: HcColors.dangerSoft,
    onErrorContainer: HcColors.danger,
    surface: HcColors.surface,
    onSurface: HcColors.text,
    onSurfaceVariant: HcColors.textMuted,
    surfaceContainerLowest: HcColors.surface,
    surfaceContainerLow: HcColors.background,
    surfaceContainer: HcColors.background,
    surfaceContainerHigh: HcColors.surfaceMuted,
    surfaceContainerHighest: HcColors.surfaceMuted,
    outline: HcColors.borderStrong,
    outlineVariant: HcColors.border,
    scrim: HcColors.overlay,
    inverseSurface: HcColors.slate,
    onInverseSurface: HcColors.textInverse,
    inversePrimary: HcColors.sand,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: HcColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: HcColors.surface,
      foregroundColor: HcColors.text,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: HcLayout.tabbarHeight,
      backgroundColor: HcColors.surface,
      indicatorColor: HcColors.sageSoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HcRadius.pill),
      ),
    ),
    cardTheme: CardThemeData(
      color: HcColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HcRadius.lg),
        side: const BorderSide(color: HcColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(HcLayout.touchTarget, HcLayout.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.md),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      minVerticalPadding: HcSpace.s3,
      iconColor: HcColors.stone,
    ),
  );
}
