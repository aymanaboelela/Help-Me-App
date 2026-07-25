import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';

/// The palette carries triage meaning, so it has to stay legible everywhere it
/// is allowed to appear — not merely on the one background each colour was
/// picked against.
///
/// The full (foreground, surface) matrix arrives with the surface ladders. This
/// file starts with the measurement itself, checked against values anyone can
/// verify by hand.
void main() {
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

  test('the shipping SOS gradient fails AA, which is why the palette changes', () {
    // Recorded as a fact, not a wish: white on the old light gradient end is
    // 2.74:1 against a 4.5:1 requirement. The surface-ladder commit replaces
    // it and the matrix test then holds the replacement to the line.
    expect(
      AppColors.contrastRatio(Colors.white, const Color(0xFFFF6B7E)),
      closeTo(2.74, 0.01),
    );
  });
}
