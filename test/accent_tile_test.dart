import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/widgets/accent_tile.dart';

Future<Container> _pumpTile(WidgetTester tester, ThemeData theme) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: const Scaffold(
        body: AccentTile(icon: Icons.healing, accent: AppColors.accentTeal),
      ),
    ),
  );
  return tester.widget<Container>(
    find.descendant(of: find.byType(AccentTile), matching: find.byType(Container)),
  );
}

void main() {
  testWidgets('in light the tile is a wash of its own accent',
      (WidgetTester tester) async {
    final Container tile = await _pumpTile(tester, AppTheme.light);
    final BoxDecoration d = tile.decoration! as BoxDecoration;
    expect(d.color, AppColors.accentTeal.withValues(alpha: 0.10));
    expect(d.border, isNull);
  });

  testWidgets('in dark the tile is a raised surface, not a tinted wash',
      (WidgetTester tester) async {
    // An accent at low alpha over a near-black surface composites to mud. That
    // is why every icon tile in the app used to look brown.
    final Container tile = await _pumpTile(tester, AppTheme.dark);
    final BoxDecoration d = tile.decoration! as BoxDecoration;
    expect(d.color, AppSurfaces.dark.raised);
    expect(d.border, isNotNull);
  });

  testWidgets('the glyph takes the dark accent variant in dark mode',
      (WidgetTester tester) async {
    await _pumpTile(tester, AppTheme.dark);
    final Icon icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppColors.accentTealDark);
    expect(icon.color, isNot(AppColors.accentTeal));
  });

  testWidgets('the glyph keeps the light accent in light mode',
      (WidgetTester tester) async {
    await _pumpTile(tester, AppTheme.light);
    final Icon icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppColors.accentTeal);
  });

  test('every category accent has a distinct dark variant', () {
    const List<Color> lights = <Color>[
      AppColors.accentTeal,
      AppColors.accentRed,
      AppColors.accentCrimson,
      AppColors.accentOrange,
      AppColors.accentAmber,
      AppColors.accentBlue,
      AppColors.accentIndigo,
      AppColors.accentPurple,
      AppColors.accentGreen,
      AppColors.accentPink,
    ];
    for (final Color light in lights) {
      final Color dark = AppColors.darkAccent(light);
      expect(dark, isNot(light), reason: '$light has no dark variant');
      // The variant has to be legible on the tile it sits in, or the icon
      // disappears into its own background.
      expect(
        AppColors.contrastRatio(dark, AppSurfaces.dark.raised),
        greaterThanOrEqualTo(3.0),
        reason: '$dark is too dim on the raised rung',
      );
    }
  });
}
