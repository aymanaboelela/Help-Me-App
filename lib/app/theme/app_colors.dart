import 'dart:math' as math;

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

  // ---- Category accents (one per first-aid topic), light mode ----
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

  // ---- Category accents, dark mode ----
  //
  // A topic's colour is baked into its data as a light-mode constant. Rather
  // than edit every topic entry, the theme resolves the pair here via
  // [darkAccent]. Each variant is the same hue lifted in lightness and dropped
  // in saturation, so it reads as itself against a near-black surface instead
  // of going muddy.
  static const Color accentTealDark = Color(0xFF3FC9B4);
  static const Color accentRedDark = Color(0xFFFF7A85);
  static const Color accentCrimsonDark = Color(0xFFFF6B6B);
  static const Color accentOrangeDark = Color(0xFFFF9A5C);
  static const Color accentAmberDark = Color(0xFFF0B357);
  static const Color accentBlueDark = Color(0xFF7BA9FF);
  static const Color accentIndigoDark = Color(0xFF9A9AF0);
  static const Color accentPurpleDark = Color(0xFFC08AD8);
  static const Color accentGreenDark = Color(0xFF4FC79B);
  static const Color accentPinkDark = Color(0xFFF07AA8);

  static const Map<int, Color> _darkAccents = <int, Color>{
    0xFF12A594: accentTealDark,
    0xFFE63946: accentRedDark,
    0xFFD00000: accentCrimsonDark,
    0xFFE8590C: accentOrangeDark,
    0xFFE08600: accentAmberDark,
    0xFF2F6FED: accentBlueDark,
    0xFF5B5BD6: accentIndigoDark,
    0xFF8E44AD: accentPurpleDark,
    0xFF2A9D8F: accentGreenDark,
    0xFFD6336C: accentPinkDark,
  };

  /// The dark-mode counterpart of a light category accent, or the accent
  /// unchanged if it is not one of the ten.
  static Color darkAccent(Color lightAccent) =>
      _darkAccents[lightAccent.toARGB32()] ?? lightAccent;

  /// The WCAG 2.1 contrast ratio between two opaque colours, 1.0–21.0.
  ///
  /// This lives in production code rather than in the test that uses it so a
  /// future palette edit cannot quietly route around the check that guards it.
  /// Judging contrast by eye is exactly how the shipping SOS banner ended up
  /// putting white text on a background at 2.74:1.
  static double contrastRatio(Color a, Color b) {
    final double la = _relativeLuminance(a);
    final double lb = _relativeLuminance(b);
    final double hi = la > lb ? la : lb;
    final double lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  static double _relativeLuminance(Color c) {
    // Color.r/.g/.b are already the 0.0–1.0 wide-gamut doubles that replaced
    // the old 0–255 ints, so there is nothing to divide here.
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }
}

/// One rung-by-rung surface ladder for a brightness.
///
/// Dark mode needs more than the single surface step this app used to have.
/// With background and surface only 6% apart in luminance, cards were separated
/// by nothing but a hairline — and a hairline *darker* than the surface it
/// bordered — so every screen read as one flat black sheet. Five rungs, and a
/// hairline lighter than its surface, which is what dark actually wants and the
/// reverse of what light wants.
@immutable
class AppSurfaces {
  const AppSurfaces({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.high,
    required this.hairline,
    required this.ink,
    required this.muted,
  });

  /// Behind everything.
  final Color bg;

  /// Cards.
  final Color surface;

  /// Inputs, nested content, sheets.
  final Color raised;

  /// Dialogs, menus, the selected nav pill.
  final Color high;

  final Color hairline;
  final Color ink;
  final Color muted;

  static const AppSurfaces dark = AppSurfaces(
    bg: Color(0xFF0C0F13),
    surface: Color(0xFF14191F),
    raised: Color(0xFF1C232B),
    high: Color(0xFF252E38),
    hairline: Color(0xFF2C353F),
    ink: Color(0xFFE8EDF2),
    muted: Color(0xFF96A3B1),
  );

  static const AppSurfaces light = AppSurfaces(
    bg: Color(0xFFF4F6F8),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEDF1F5),
    high: Color(0xFFFFFFFF),
    hairline: Color(0xFFDDE3EA),
    ink: Color(0xFF10151A),
    muted: Color(0xFF56626F),
  );
}

/// Semantic colours that Material's [ColorScheme] does not cover.
///
/// These are *triage* roles, not decoration. Emergency medicine already has a
/// rigorous severity colour system and this app is a triage tool, so colour
/// carries the severity: [immediate] appears only where the answer is "call
/// now", which is the only thing that makes it legible as urgency at all. When
/// the brand red was `primary`, it landed on filter chips, switches, links and
/// the tab bar — and stopped meaning anything.
///
/// [structural] is the deliberately dull ink-blue that now does the ordinary
/// interface work. It is kept far duller than any category accent so the two
/// never read as the same colour.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.immediate,
    required this.onImmediate,
    required this.urgent,
    required this.safe,
    required this.structural,
    required this.muted,
    required this.hairline,
    required this.sosGradientStart,
    required this.sosGradientEnd,
    required this.callPillFill,
    required this.callPillText,
  });

  /// Life-threatening. The SOS banner, call actions, the danger callout — and
  /// nothing else, ever.
  final Color immediate;
  final Color onImmediate;

  /// Urgent but not immediate: warnings, medicine expiry.
  final Color urgent;

  /// Non-urgent, done, safe: success, a finished lesson, the privacy note.
  final Color safe;

  /// The real interface accent: chips, switches, links, focus rings.
  final Color structural;

  final Color muted;
  final Color hairline;
  final Color sosGradientStart;
  final Color sosGradientEnd;

  /// The call button sitting on the SOS gradient. Pure white on saturated red
  /// is the brightest thing on a dark screen at 3am, so dark softens the fill.
  final Color callPillFill;
  final Color callPillText;

  // Every light value below sits at the darkest point of its hue that still
  // reads as that colour, because each has to clear 4.5:1 against the lightest
  // rungs of the ladder and not merely against white. Three of the first-pass
  // choices failed that and were corrected; see test/contrast_test.dart.
  static const AppSemanticColors light = AppSemanticColors(
    immediate: Color(0xFFCB2635),
    onImmediate: Color(0xFFFFFFFF),
    urgent: Color(0xFFA05E00),
    safe: Color(0xFF0F7857),
    structural: Color(0xFF3A5570),
    muted: Color(0xFF56626F),
    hairline: Color(0xFFDDE3EA),
    sosGradientStart: Color(0xFFC8404F),
    sosGradientEnd: Color(0xFF8E1620),
    callPillFill: Color(0xFFFFFFFF),
    callPillText: Color(0xFF8E1620),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    immediate: Color(0xFFFF7A85),
    onImmediate: Color(0xFF10151A),
    urgent: Color(0xFFF0B357),
    safe: Color(0xFF4FC79B),
    structural: Color(0xFF96B2C9),
    muted: Color(0xFF96A3B1),
    hairline: Color(0xFF2C353F),
    sosGradientStart: Color(0xFFA8323E),
    sosGradientEnd: Color(0xFF74121A),
    callPillFill: Color(0xFFE9EEF4),
    callPillText: Color(0xFFB3202E),
  );

  @override
  AppSemanticColors copyWith({
    Color? immediate,
    Color? onImmediate,
    Color? urgent,
    Color? safe,
    Color? structural,
    Color? muted,
    Color? hairline,
    Color? sosGradientStart,
    Color? sosGradientEnd,
    Color? callPillFill,
    Color? callPillText,
  }) {
    return AppSemanticColors(
      immediate: immediate ?? this.immediate,
      onImmediate: onImmediate ?? this.onImmediate,
      urgent: urgent ?? this.urgent,
      safe: safe ?? this.safe,
      structural: structural ?? this.structural,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      sosGradientStart: sosGradientStart ?? this.sosGradientStart,
      sosGradientEnd: sosGradientEnd ?? this.sosGradientEnd,
      callPillFill: callPillFill ?? this.callPillFill,
      callPillText: callPillText ?? this.callPillText,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      immediate: Color.lerp(immediate, other.immediate, t)!,
      onImmediate: Color.lerp(onImmediate, other.onImmediate, t)!,
      urgent: Color.lerp(urgent, other.urgent, t)!,
      safe: Color.lerp(safe, other.safe, t)!,
      structural: Color.lerp(structural, other.structural, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      sosGradientStart: Color.lerp(sosGradientStart, other.sosGradientStart, t)!,
      sosGradientEnd: Color.lerp(sosGradientEnd, other.sosGradientEnd, t)!,
      callPillFill: Color.lerp(callPillFill, other.callPillFill, t)!,
      callPillText: Color.lerp(callPillText, other.callPillText, t)!,
    );
  }
}
