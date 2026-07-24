import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// A full-screen CPR compression metronome: a heartbeat pulse with a click and
/// haptic on every beat at ~110 beats/min (within the recommended 100–120).
class CprMetronomeScreen extends StatefulWidget {
  const CprMetronomeScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CprMetronomeScreen());

  @override
  State<CprMetronomeScreen> createState() => _CprMetronomeScreenState();
}

class _CprMetronomeScreenState extends State<CprMetronomeScreen>
    with SingleTickerProviderStateMixin {
  static const int _bpm = 110;
  static const Duration _interval = Duration(milliseconds: 60000 ~/ _bpm);

  late final AnimationController _thump;
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _thump = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _beat();
      _timer = Timer.periodic(_interval, (_) => _beat());
    } else {
      _timer?.cancel();
    }
  }

  void _beat() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
    _thump.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _thump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color accent = context.colors.primary;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.metronomeTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Text(l10n.metronomeRate, style: context.texts.titleMedium?.copyWith(color: context.semantic.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _thump,
              builder: (BuildContext context, Widget? child) {
                final double t = _running ? (1 - _thump.value) : 0.0;
                final double scale = 1 + 0.18 * t;
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 3),
                ),
                child: Icon(Icons.favorite, color: accent, size: 92),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _running ? l10n.metronomePush : l10n.metronomeHint,
              textAlign: TextAlign.center,
              style: context.texts.titleLarge?.copyWith(
                color: _running ? accent : context.semantic.muted,
                fontWeight: _running ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                onPressed: _toggle,
                icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                label: Text(_running ? l10n.metronomeStop : l10n.metronomeStart),
                style: FilledButton.styleFrom(
                  backgroundColor: _running ? context.semantic.danger : accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
