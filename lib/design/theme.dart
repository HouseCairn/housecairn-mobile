// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// The text styles of the web application, by role
/// (`src/housecairn/static/css/base.css` and `components.css`). Sizes are
/// those of the tokens; the text size of the phone scales them all.
abstract final class HcText {
  /// `h1`: the title of a page, in the app bar.
  static const pageTitle = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeXl,
    fontWeight: HcFont.heavy,
    height: HcFont.lineHeightTight,
    letterSpacing: HcFont.sizeXl * HcComponent.headingTracking,
    color: HcColors.text,
  );

  /// `h2`: the heading of a group of rows, in capitals.
  static const sectionHeading = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeXs,
    fontWeight: HcFont.bold,
    height: HcFont.lineHeightTight,
    letterSpacing: HcFont.sizeXs * HcFont.trackingCaps,
    color: HcColors.textMuted,
  );

  /// `h3`: a title inside a card.
  static const cardTitle = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeMd,
    fontWeight: HcFont.bold,
    height: HcFont.lineHeightTight,
    color: HcColors.text,
  );

  /// `.row-title`.
  static const rowTitle = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeBase,
    fontWeight: HcFont.medium,
    height: HcComponent.rowLineHeight,
    color: HcColors.text,
  );

  /// `.row-text`, `.small`.
  static const rowText = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeXs,
    fontWeight: HcFont.regular,
    height: HcComponent.rowLineHeight,
    color: HcColors.textMuted,
  );

  /// Body text.
  static const body = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeBase,
    fontWeight: HcFont.regular,
    height: HcFont.lineHeight,
    color: HcColors.text,
  );

  /// `.message`, `.facts dt`: smaller body text.
  static const bodySmall = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeSm,
    fontWeight: HcFont.regular,
    height: HcFont.lineHeight,
    color: HcColors.text,
  );

  /// `button`.
  static const button = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeBase,
    fontWeight: HcFont.bold,
    height: HcComponent.buttonLineHeight,
  );

  /// `.button-small`.
  static const buttonSmall = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeSm,
    fontWeight: HcFont.bold,
    height: HcComponent.buttonLineHeight,
  );

  /// `label` of a form field.
  static const fieldLabel = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeSm,
    fontWeight: HcFont.bold,
    height: HcFont.lineHeightTight,
    color: HcColors.textMuted,
  );

  /// `.pill`.
  static const pill = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeXs,
    fontWeight: HcFont.bold,
    height: HcFont.lineHeightTight,
  );

  /// `.nav-link`.
  static const navLabel = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.size2xs,
    fontWeight: HcFont.medium,
    height: HcFont.lineHeightTight,
  );
}

/// The theme of Housecairn, built from the design tokens: the light look of
/// the web application, adapted to a phone (docs/adr/0010). The web
/// application has no dark theme (`color-scheme: light`), so neither has the
/// app.
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
    surfaceContainerLow: HcColors.surface,
    surfaceContainer: HcColors.surface,
    surfaceContainerHigh: HcColors.surface,
    surfaceContainerHighest: HcColors.surfaceMuted,
    surfaceTint: Colors.transparent,
    outline: HcColors.borderStrong,
    outlineVariant: HcColors.border,
    shadow: HcColors.slate,
    scrim: HcColors.overlay,
    inverseSurface: HcColors.slate,
    onInverseSurface: HcColors.textInverse,
    inversePrimary: HcColors.sand,
  );
  const textTheme = TextTheme(
    headlineMedium: HcText.pageTitle,
    headlineSmall: HcText.pageTitle,
    titleLarge: HcText.pageTitle,
    titleMedium: HcText.body,
    titleSmall: HcText.sectionHeading,
    bodyLarge: HcText.body,
    bodyMedium: HcText.bodySmall,
    bodySmall: HcText.rowText,
    labelLarge: HcText.button,
    labelMedium: HcText.fieldLabel,
    labelSmall: HcText.navLabel,
  );
  final radiusMd = BorderRadius.circular(HcRadius.md);
  final radiusLg = BorderRadius.circular(HcRadius.lg);
  const minTarget = Size(HcLayout.touchTargetLg, HcLayout.touchTargetLg);
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: HcSpace.s4,
    vertical: HcSpace.s3,
  );
  OutlineInputBorder field(Color color, double width) => OutlineInputBorder(
    borderRadius: radiusMd,
    borderSide: BorderSide(color: color, width: width),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: HcFont.family,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: HcColors.background,
    canvasColor: HcColors.background,
    dividerColor: HcColors.border,
    splashColor: HcColors.sandSoft,
    highlightColor: HcColors.sandSoft,
    hoverColor: Colors.transparent,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    dividerTheme: const DividerThemeData(
      color: HcColors.border,
      thickness: HcComponent.borderWidth,
      space: HcComponent.borderWidth,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: HcColors.background,
      foregroundColor: HcColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: HcComponent.appbarMinHeight,
      titleTextStyle: HcText.pageTitle,
      iconTheme: IconThemeData(color: HcColors.primary),
      actionsIconTheme: IconThemeData(color: HcColors.primary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: HcLayout.tabbarHeight,
      backgroundColor: HcColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? HcText.navLabel.copyWith(
                color: HcColors.primary,
                fontWeight: HcFont.heavy,
              )
            : HcText.navLabel.copyWith(color: HcColors.textMuted),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: HcComponent.iconSize,
          color: states.contains(WidgetState.selected)
              ? HcColors.primary
              : HcColors.textMuted,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: HcColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radiusLg,
        side: const BorderSide(color: HcColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: HcColors.primary,
        foregroundColor: HcColors.textInverse,
        disabledBackgroundColor: HcColors.surfaceMuted,
        disabledForegroundColor: HcColors.textMuted,
        minimumSize: minTarget,
        padding: buttonPadding,
        textStyle: HcText.button,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: HcColors.surface,
        foregroundColor: HcColors.primary,
        minimumSize: minTarget,
        padding: buttonPadding,
        textStyle: HcText.button,
        side: const BorderSide(color: HcColors.borderStrong),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HcColors.primary,
        minimumSize: minTarget,
        padding: const EdgeInsets.symmetric(horizontal: HcSpace.s3),
        textStyle: HcText.button,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: HcColors.primary,
        minimumSize: minTarget,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HcRadius.pill),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: HcColors.primary,
      foregroundColor: HcColors.textInverse,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      extendedTextStyle: HcText.button,
      shape: RoundedRectangleBorder(borderRadius: radiusMd),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HcColors.surface,
      isDense: false,
      contentPadding: const EdgeInsets.all(HcSpace.s3),
      constraints: const BoxConstraints(minHeight: HcLayout.touchTargetLg),
      hintStyle: HcText.body.copyWith(color: HcColors.textMuted),
      errorStyle: HcText.bodySmall.copyWith(
        color: HcColors.danger,
        fontWeight: HcFont.medium,
      ),
      errorMaxLines: 3,
      border: field(HcColors.borderStrong, HcComponent.borderWidth),
      enabledBorder: field(HcColors.borderStrong, HcComponent.borderWidth),
      disabledBorder: field(HcColors.border, HcComponent.borderWidth),
      focusedBorder: field(HcColors.focus, HcComponent.focusRing),
      errorBorder: field(HcColors.danger, HcComponent.borderWidth),
      focusedErrorBorder: field(HcColors.danger, HcComponent.focusRing),
    ),
    listTileTheme: const ListTileThemeData(
      minTileHeight: HcComponent.rowMinHeight,
      contentPadding: EdgeInsets.symmetric(horizontal: HcSpace.s4),
      titleTextStyle: HcText.rowTitle,
      subtitleTextStyle: HcText.rowText,
      iconColor: HcColors.textMuted,
    ),
    snackBarTheme: SnackBarThemeData(
      // The undo banner of the web (`.undo-banner`): near the finger,
      // above the bar, in sage, with the action as a link.
      behavior: SnackBarBehavior.floating,
      backgroundColor: HcColors.sageSoft,
      contentTextStyle: HcText.bodySmall,
      actionTextColor: HcColors.primary,
      elevation: 0,
      insetPadding: const EdgeInsets.all(HcSpace.s4),
      shape: RoundedRectangleBorder(
        borderRadius: radiusMd,
        side: const BorderSide(color: HcColors.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: HcColors.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: HcText.cardTitle,
      contentTextStyle: HcText.body,
      shape: RoundedRectangleBorder(borderRadius: radiusLg),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: HcColors.surface,
      surfaceTintColor: Colors.transparent,
      textStyle: HcText.body,
      shape: RoundedRectangleBorder(
        borderRadius: radiusMd,
        side: const BorderSide(color: HcColors.border),
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: HcColors.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: HcColors.primary,
      headerForegroundColor: HcColors.textInverse,
    ),
  );
}
