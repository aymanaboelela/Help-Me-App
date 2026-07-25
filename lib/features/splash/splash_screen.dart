import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/root_scaffold.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../l10n/app_localizations.dart';

/// A brief, animated brand splash that hands off to [RootScaffold].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 1700), _goToApp);
  }

  void _goToApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RootScaffold()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Animation<double> fade =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AppLogo(size: 132),
                const SizedBox(height: 20),
                Text(
                  l10n.appName,
                  style: context.texts.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.appTagline,
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.semantic.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
