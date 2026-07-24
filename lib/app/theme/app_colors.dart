import 'package:flutter/material.dart';

/// Raw brand + palette tokens for Help Me / ساعِدني.
///
/// These are static constants; semantic, theme-aware colors live in
/// [AppSemanticColors] (a [ThemeExtension]) so they adapt between light and dark.
abstract final class AppColors {
  // ---- Brand ----
  static const Color emergencyRed = Color(0xFFE63946);
  static const Color emergencyRedBright = Color(0xFFFF6B7E);
  static const Color emergencyRedDeep = Color(0xFFC1121F);
  static const Color medicalTeal = Color(0xFF1D9A8A);

  // ---- Light scheme ----
  static const Color lightBackground = Color(0xFFF5F6F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDF0F4);
  static const Color lightInk = Color(0xFF1A1C1E);
  static const Color lightMuted = Color(0xFF5B6672);
  static const Color lightOutline = Color(0xFFE1E5EA);

  // ---- Dark scheme ----
  static const Color darkBackground = Color(0xFF111317);
  static const Color darkSurface = Color(0xFF1B1E23);
  static const Color darkSurfaceVariant = Color(0xFF262B32);
  static const Color darkInk = Color(0xFFECEFF3);
  static const Color darkMuted = Color(0xFF9BA6B2);
  static const Color darkOutline = Color(0xFF2E343C);

  // ---- Category accents (one per first-aid topic) ----
  static const Color accentTeal = Color(0xFF12A594);
  static const Color accentRed = Color(0xFFE63946);
  static const Color accentCrimson = Color(0xFFD00000);
  static const Color accentOrange = Color(0xFFE8590C);
  static const Color accentAmber = Color(0xFFE08600);
  static const Color accentBlue = Color(0xFF2F6FED);
  static const Color accentIndigo = Color(0xFF5B5BD6);
  static const Color accentPurple = Color(0xFF8E44AD);
  static const Color accentGreen = Color(0xFF2A9D8F);
  static const Color accentPink = Color(0xFFD6336C);
}

/// Semantic, theme-aware colors that Material's [ColorScheme] does not cover
/// (warnings, danger, success, the SOS gradient, etc.).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.danger,
    required this.onDanger,
    required this.warning,
    required this.success,
    required this.info,
    required this.muted,
    required this.cardBorder,
    required this.sosGradientStart,
    required this.sosGradientEnd,
  });

  final Color danger;
  final Color onDanger;
  final Color warning;
  final Color success;
  final Color info;
  final Color muted;
  final Color cardBorder;
  final Color sosGradientStart;
  final Color sosGradientEnd;

  static const AppSemanticColors light = AppSemanticColors(
    danger: Color(0xFFD62828),
    onDanger: Color(0xFFFFFFFF),
    warning: Color(0xFFCC7A00),
    success: Color(0xFF1E8E7E),
    info: Color(0xFF2F6FED),
    muted: AppColors.lightMuted,
    cardBorder: AppColors.lightOutline,
    sosGradientStart: Color(0xFFFF6B7E),
    sosGradientEnd: Color(0xFFC1121F),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    danger: Color(0xFFFF6B6B),
    onDanger: Color(0xFF1A1C1E),
    warning: Color(0xFFF4A261),
    success: Color(0xFF3DBFAE),
    info: Color(0xFF6FA8FF),
    muted: AppColors.darkMuted,
    cardBorder: AppColors.darkOutline,
    sosGradientStart: Color(0xFFFF6B7E),
    sosGradientEnd: Color(0xFFC1121F),
  );

  @override
  AppSemanticColors copyWith({
    Color? danger,
    Color? onDanger,
    Color? warning,
    Color? success,
    Color? info,
    Color? muted,
    Color? cardBorder,
    Color? sosGradientStart,
    Color? sosGradientEnd,
  }) {
    return AppSemanticColors(
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
      muted: muted ?? this.muted,
      cardBorder: cardBorder ?? this.cardBorder,
      sosGradientStart: sosGradientStart ?? this.sosGradientStart,
      sosGradientEnd: sosGradientEnd ?? this.sosGradientEnd,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      sosGradientStart: Color.lerp(sosGradientStart, other.sosGradientStart, t)!,
      sosGradientEnd: Color.lerp(sosGradientEnd, other.sosGradientEnd, t)!,
    );
  }
}
