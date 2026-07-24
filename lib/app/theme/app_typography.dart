import 'package:flutter/material.dart';

/// Cairo-based typography. Cairo is bundled (see `assets/fonts`), so the app
/// renders identically offline — critical for an emergency guide — and reads
/// cleanly in both Arabic and Latin scripts.
abstract final class AppTypography {
  static const String fontFamily = 'Cairo';

  /// Applies Cairo to a base [TextTheme] and tunes weights/heights for a
  /// calm, highly legible reading experience.
  static TextTheme apply(TextTheme base) {
    final TextTheme t = base.apply(
      fontFamily: fontFamily,
      bodyColor: base.bodyLarge?.color,
      displayColor: base.bodyLarge?.color,
    );
    return t.copyWith(
      displaySmall: t.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.1),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: t.bodyLarge?.copyWith(height: 1.55),
      bodyMedium: t.bodyMedium?.copyWith(height: 1.55),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
