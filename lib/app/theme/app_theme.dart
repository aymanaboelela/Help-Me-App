import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Corner radii, tied to the size of the thing being drawn.
///
/// The previous set (10/16/22/24/999) was picked per call site rather than from
/// a rule, so a chip, a card and a sheet could all end up looking like the same
/// kind of object.
abstract final class AppRadii {
  /// Small chrome: badges, indicator dots, inline markers.
  static const double xs = 8;

  /// Buttons, inputs, and icon tiles.
  ///
  /// Icon tiles were specced at [xs] and rendered visibly boxy against the
  /// cards holding them, so they sit here instead.
  static const double sm = 12;

  /// Cards.
  static const double md = 18;

  /// Sheets and the nav bar.
  static const double lg = 28;

  /// Chips only.
  static const double pill = 999;
}

/// Builds the light and dark [ThemeData] for Help Me / ساعِدني.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final AppSurfaces surfaces = isDark ? AppSurfaces.dark : AppSurfaces.light;
    final AppSemanticColors semantic =
        isDark ? AppSemanticColors.dark : AppSemanticColors.light;

    // Built rung by rung from the ladder rather than derived from a seed.
    // `ColorScheme.fromSeed` generates every role the caller does not override
    // from the seed hue, so seeding with the emergency red quietly tinted
    // bottom sheets maroon in dark and pink in light while the app's own tokens
    // stayed neutral. Naming each role is what removes that.
    //
    // `primary` is the structural ink-blue, not the brand red: when red was
    // primary it landed on filter chips, switches, links and the tab bar, and
    // a colour that appears everywhere cannot also mean "call an ambulance".
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: semantic.structural,
      onPrimary: isDark ? surfaces.bg : Colors.white,
      primaryContainer: surfaces.raised,
      onPrimaryContainer: surfaces.ink,
      secondary: AppColors.medicalTeal,
      onSecondary: Colors.white,
      secondaryContainer: surfaces.raised,
      onSecondaryContainer: surfaces.ink,
      tertiary: semantic.safe,
      onTertiary: isDark ? surfaces.bg : Colors.white,
      tertiaryContainer: surfaces.raised,
      onTertiaryContainer: surfaces.ink,
      error: semantic.immediate,
      onError: semantic.onImmediate,
      errorContainer: surfaces.raised,
      onErrorContainer: semantic.immediate,
      surface: surfaces.surface,
      onSurface: surfaces.ink,
      onSurfaceVariant: surfaces.muted,
      surfaceContainerLowest: surfaces.bg,
      surfaceContainerLow: surfaces.surface,
      surfaceContainer: surfaces.raised,
      surfaceContainerHigh: surfaces.raised,
      surfaceContainerHighest: surfaces.high,
      surfaceTint: Colors.transparent,
      outline: surfaces.hairline,
      outlineVariant: surfaces.hairline,
      inverseSurface: surfaces.ink,
      onInverseSurface: surfaces.bg,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final Color background = surfaces.bg;
    final TextTheme textTheme = AppTypography.apply(
      (isDark ? ThemeData.dark() : ThemeData.light()).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      extensions: <ThemeExtension<dynamic>>[semantic],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        // Cards separate by tone in dark and by one soft shadow in light. A
        // hairline round every element is what made the old UI read flat: if
        // the card, the chip, the input and the banner all carry the same
        // 1px outline, none of them is more important than the others.
        elevation: isDark ? 0 : 1,
        color: surfaces.surface,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide.none,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaces.high,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: semantic.hairline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: semantic.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // An input is a recessed surface, so it takes the `raised` rung in both
        // modes rather than sitting at the same level as the card holding it.
        fillColor: surfaces.raised,
        hintStyle: textTheme.bodyMedium?.copyWith(color: semantic.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: semantic.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: semantic.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: semantic.hairline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: surfaces.raised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
      ),
    );
  }
}

/// Ergonomic access to theme values: `context.colors`, `context.texts`, etc.
extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// The surface ladder for the current brightness.
  AppSurfaces get surfaces => isDark ? AppSurfaces.dark : AppSurfaces.light;

  /// A topic's accent resolved for the current brightness.
  ///
  /// Topic colours are baked into the data as light-mode constants, so a dark
  /// screen needs the lifted variant or the icon disappears into its tile.
  Color accent(Color lightAccent) =>
      isDark ? AppColors.darkAccent(lightAccent) : lightAccent;
  Locale get locale => Localizations.localeOf(this);
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}
