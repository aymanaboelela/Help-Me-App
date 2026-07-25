import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Shows the emergency stopwatch as a modal bottom sheet.
Future<void> showEmergencyTimer(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _EmergencyTimerSheet(),
  );
}

class _EmergencyTimerSheet extends StatefulWidget {
  const _EmergencyTimerSheet();

  @override
  State<_EmergencyTimerSheet> createState() => _EmergencyTimerSheetState();
}

class _EmergencyTimerSheetState extends State<_EmergencyTimerSheet> {
  static const Duration _alertAt = Duration(minutes: 5);

  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _running = false;
  bool _alerted = false;

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
        if (_elapsed >= _alertAt && !_alerted) {
          _alerted = true;
          HapticFeedback.heavyImpact();
        }
      });
    } else {
      _ticker?.cancel();
    }
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _running = false;
      _alerted = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _formatted {
    final String m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final String s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color timeColor =
        _alerted ? context.semantic.immediate : context.colors.onSurface;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.timerTitle, style: context.texts.titleLarge),
            const SizedBox(height: 16),
            Text(
              _formatted,
              style: context.texts.displaySmall?.copyWith(
                color: timeColor,
                fontWeight: FontWeight.w800,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 16),
            if (_alerted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.semantic.immediate.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  l10n.timerAlert,
                  textAlign: TextAlign.center,
                  style: context.texts.bodyMedium?.copyWith(color: context.semantic.immediate),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _toggle,
                    icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                    label: Text(_running ? l10n.metronomeStop : l10n.timerStart),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.timerReset),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
