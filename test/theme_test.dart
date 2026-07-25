import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/app/theme/app_theme.dart';

void main() {
  test('primary is structural, not the emergency red', () {
    // Red on every chip, switch and link is why red stopped meaning anything.
    expect(AppTheme.light.colorScheme.primary, AppSemanticColors.light.structural);
    expect(AppTheme.dark.colorScheme.primary, AppSemanticColors.dark.structural);
    expect(AppTheme.dark.colorScheme.primary, isNot(AppColors.emergencyRed));
    expect(AppTheme.light.colorScheme.primary, isNot(AppColors.emergencyRed));
  });

  test('error is the immediate triage colour', () {
    expect(AppTheme.light.colorScheme.error, AppSemanticColors.light.immediate);
    expect(AppTheme.dark.colorScheme.error, AppSemanticColors.dark.immediate);
  });

  test('no container role is tinted by a seed', () {
    // ColorScheme.fromSeed derives every role the theme does not override from
    // the seed hue, so seeding with the emergency red tinted bottom sheets
    // maroon in dark and pink in light while the app's own tokens stayed
    // neutral. Each container must come from the surface ladder instead.
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      final AppSurfaces s = theme.brightness == Brightness.dark
          ? AppSurfaces.dark
          : AppSurfaces.light;
      final ColorScheme c = theme.colorScheme;
      expect(c.surface, s.surface, reason: 'surface');
      expect(c.onSurface, s.ink, reason: 'onSurface');
      expect(c.onSurfaceVariant, s.muted, reason: 'onSurfaceVariant');
      expect(c.surfaceContainerLowest, s.bg, reason: 'surfaceContainerLowest');
      expect(c.surfaceContainerLow, s.surface, reason: 'surfaceContainerLow');
      expect(c.surfaceContainer, s.raised, reason: 'surfaceContainer');
      expect(c.surfaceContainerHigh, s.raised, reason: 'surfaceContainerHigh');
      expect(c.surfaceContainerHighest, s.high, reason: 'surfaceContainerHighest');
      expect(c.surfaceTint, Colors.transparent, reason: 'surfaceTint');
      expect(c.outline, s.hairline, reason: 'outline');
    }
  });

  test('the scaffold sits on bg, not on surface', () {
    expect(AppTheme.dark.scaffoldBackgroundColor, AppSurfaces.dark.bg);
    expect(AppTheme.light.scaffoldBackgroundColor, AppSurfaces.light.bg);
    // If these were equal, cards would have nothing to stand out against —
    // which is exactly what dark mode used to look like.
    expect(AppSurfaces.dark.bg, isNot(AppSurfaces.dark.surface));
  });

  test('the dark hairline is lighter than the surface it borders', () {
    // The reverse of what a light theme wants, and the reverse of what this
    // app used to do.
    expect(
      AppColors.contrastRatio(AppSurfaces.dark.hairline, AppSurfaces.dark.bg),
      greaterThan(
        AppColors.contrastRatio(AppSurfaces.dark.surface, AppSurfaces.dark.bg),
      ),
    );
  });

  test('the radius scale has five ascending steps', () {
    expect(AppRadii.xs, 8);
    expect(AppRadii.sm, 12);
    expect(AppRadii.md, 18);
    expect(AppRadii.lg, 28);
    expect(AppRadii.pill, 999);
  });

  test('cards carry no border — they separate by tone or by shadow', () {
    // A hairline round every element is why nothing had visual hierarchy.
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      final ShapeBorder? shape = theme.cardTheme.shape;
      expect(shape, isA<RoundedRectangleBorder>());
      expect((shape! as RoundedRectangleBorder).side.style, BorderStyle.none);
    }
  });

  test('the semantic extension is registered on both themes', () {
    expect(AppTheme.light.extension<AppSemanticColors>(), AppSemanticColors.light);
    expect(AppTheme.dark.extension<AppSemanticColors>(), AppSemanticColors.dark);
  });
}
