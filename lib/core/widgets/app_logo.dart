import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Help Me brand mark, rendered crisply at any [size] from the bundled SVG.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/branding/logo.svg',
      width: size,
      height: size,
      semanticsLabel: 'Help Me',
    );
  }
}
