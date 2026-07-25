import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// The coloured square behind a topic, service or lesson icon.
///
/// In light mode a wash of the accent works. In dark mode it does not: the
/// accent at low alpha composited over a near-black surface goes muddy brown,
/// which is what made every icon in the app look dirty — the teal tile came out
/// bottle-green, the red one maroon, the orange one brown, all at once and on
/// every screen.
///
/// So in dark the tile is a raised neutral with a faint accent hairline and the
/// colour moves to the glyph, lifted to its dark-mode variant so it still reads
/// as itself. Same idea either way: the accent identifies the topic. Only the
/// mechanism has to change with the background.
class AccentTile extends StatelessWidget {
  const AccentTile({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 52,
    this.iconSize = 26,
  });

  final IconData icon;

  /// The topic's light-mode accent, as stored in its data.
  final Color accent;

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final Color resolved = context.accent(accent);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppSurfaces.dark.raised : accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: dark ? Border.all(color: resolved.withValues(alpha: 0.24)) : null,
      ),
      child: Icon(icon, color: resolved, size: iconSize),
    );
  }
}
