import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';

/// The palette carries triage meaning, so it has to stay legible everywhere it
/// is allowed to appear — not merely on the one background each colour was
/// picked against. Every (foreground, surface) pair the design permits is
/// checked here.
///
/// This is not a formality. It caught four real failures: light `urgent` at
/// 4.24:1 on white, light `immediate` at 4.40:1 on `raised`, light `safe` at
/// 4.32:1 on `raised`, and — already shipping — white text on the old SOS
/// gradient's light end at 2.74:1.
void main() {
  const double aa = 4.5;

  test('contrastRatio matches known WCAG values', () {
    // Black on white is the definitional maximum.
    expect(
      AppColors.contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
      closeTo(21.0, 0.01),
    );
    // #777 on white is the canonical worked example, just under AA.
    expect(
      AppColors.contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
      closeTo(4.48, 0.01),
    );
    // Order must not matter.
    expect(
      AppColors.contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(
        AppColors.contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
        0.0001,
      ),
    );
    // A colour against itself is the definitional minimum.
    expect(
      AppColors.contrastRatio(const Color(0xFF3A5570), const Color(0xFF3A5570)),
      closeTo(1.0, 0.0001),
    );
  });

  test('the retired SOS gradient failed AA, which is why the palette changed', () {
    // Kept as a regression marker: white on the old light gradient end was
    // 2.74:1 against a 4.5:1 requirement. If anyone reintroduces that colour,
    // the gradient assertions below are what will stop them.
    expect(
      AppColors.contrastRatio(Colors.white, const Color(0xFFFF6B7E)),
      closeTo(2.74, 0.01),
    );
  });

  for (final (String mode, AppSurfaces s, AppSemanticColors sem)
      in <(String, AppSurfaces, AppSemanticColors)>[
    ('dark', AppSurfaces.dark, AppSemanticColors.dark),
    ('light', AppSurfaces.light, AppSemanticColors.light),
  ]) {
    final Map<String, Color> backgrounds = <String, Color>{
      'bg': s.bg,
      'surface': s.surface,
      'raised': s.raised,
      'high': s.high,
    };
    final Map<String, Color> foregrounds = <String, Color>{
      'ink': s.ink,
      'muted': s.muted,
      'immediate': sem.immediate,
      'urgent': sem.urgent,
      'safe': sem.safe,
      'structural': sem.structural,
    };

    backgrounds.forEach((String bgName, Color bg) {
      foregrounds.forEach((String fgName, Color fg) {
        test('$mode: $fgName on $bgName clears AA', () {
          expect(
            AppColors.contrastRatio(fg, bg),
            greaterThanOrEqualTo(aa),
            reason: '$mode $fgName on $bgName is too low',
          );
        });
      });
    });

    test('$mode: white on both ends of the SOS gradient clears AA', () {
      expect(
        AppColors.contrastRatio(Colors.white, sem.sosGradientStart),
        greaterThanOrEqualTo(aa),
        reason: '$mode gradient start',
      );
      expect(
        AppColors.contrastRatio(Colors.white, sem.sosGradientEnd),
        greaterThanOrEqualTo(aa),
        reason: '$mode gradient end',
      );
    });

    test('$mode: the call pill text clears AA on its own fill', () {
      expect(
        AppColors.contrastRatio(sem.callPillText, sem.callPillFill),
        greaterThanOrEqualTo(aa),
      );
    });
  }
}
