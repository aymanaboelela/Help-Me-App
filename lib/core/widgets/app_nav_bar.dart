import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_theme.dart';
import '../platform/adaptive.dart';

/// One destination in [AppNavBar].
@immutable
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The app's bottom navigation: a floating capsule sitting close to the edge.
///
/// Only the selected destination carries its label; the others shrink to their
/// icon. Four labels shown at once cannot fit an Arabic word like "الإعدادات"
/// in a quarter of a phone's width without truncating it, and a nav bar full of
/// clipped words reads as broken. Giving the whole label budget to the one
/// destination that needs it keeps every word whole.
///
/// The bar is translucent and blurred on iOS and solid with a shadow on
/// Android, which is the difference that actually reads as native on each.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.index,
    required this.items,
    required this.onSelected,
  });

  final int index;
  final List<AppNavItem> items;
  final ValueChanged<int> onSelected;

  static const double _height = 62;
  static const double _iconSlot = 54;
  static const Duration _duration = Duration(milliseconds: 300);
  static const Curve _curve = Curves.easeOutCubic;

  /// Width the selected label needs, so the pill can be cut to fit it.
  static double _measureLabel(BuildContext context, String label) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final double width = painter.width;
    painter.dispose();
    return width;
  }

  void _select(BuildContext context, int i) {
    if (i == index) return;
    if (context.isCupertino) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.lightImpact();
    }
    onSelected(i);
  }

  @override
  Widget build(BuildContext context) {
    final bool cupertino = context.isCupertino;
    final Color surface = context.colors.surface;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    // Sit close to the bottom edge. A full SafeArea inset pushes the bar so far
    // up that a band of background is left stranded underneath it; clearing the
    // home indicator by a third of its height is enough to stay tappable.
    final double inset = MediaQuery.viewPaddingOf(context).bottom;
    final double bottom = inset > 0 ? (inset * 0.34).clamp(6, 14) : 10;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 4, 14, bottom),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: cupertino
                ? ImageFilter.blur(sigmaX: 24, sigmaY: 24)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cupertino ? surface.withValues(alpha: 0.88) : surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.semantic.cardBorder),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.40 : 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                height: _height,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // The selected destination takes whatever the icon-only
                    // ones leave behind, so its label always has room.
                    final double available = constraints.maxWidth - 12;
                    // Size the selected pill to its own label rather than to
                    // whatever is left over, so a short word like "صحتي" does
                    // not sit marooned in the middle of an oversized slab.
                    final double labelWidth = _measureLabel(
                      context,
                      items[index].label,
                    );
                    final double wanted = _iconSlot + labelWidth + 14;
                    final double minRest = _iconSlot * (items.length - 1);
                    final double selectedWidth =
                        wanted.clamp(_iconSlot, available - minRest + _iconSlot);
                    final double restWidth =
                        (available - selectedWidth) / (items.length - 1);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        children: <Widget>[
                          for (int i = 0; i < items.length; i++)
                            AnimatedContainer(
                              duration: _duration,
                              curve: _curve,
                              width: i == index ? selectedWidth : restWidth,
                              height: _height - 12,
                              child: _NavButton(
                                item: items[i],
                                selected: i == index,
                                onTap: () => _select(context, i),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color active = context.colors.primary;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: selected
            ? active.withValues(alpha: dark ? 0.24 : 0.13)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: context.isCupertino
              ? NoSplash.splashFactory
              : InkSparkle.splashFactory,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                selected ? item.activeIcon : item.icon,
                color: selected ? active : context.semantic.muted,
                size: 23,
              ),
              if (selected)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: context.texts.labelLarge?.copyWith(
                        color: active,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
