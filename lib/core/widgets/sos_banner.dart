import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../features/emergency/data/emergency_numbers.dart';
import '../../l10n/app_localizations.dart';
import '../call_action.dart';

/// The prominent red "call the ambulance now" banner shown at the top of the
/// home and emergency screens.
class SosBanner extends StatelessWidget {
  const SosBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final semantic = context.semantic;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[semantic.sosGradientStart, semantic.sosGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency_share, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.sosBannerTitle,
                    style: context.texts.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.sosBannerBody,
                    style: context.texts.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => callWithFeedback(context, kAmbulance.number),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: semantic.sosGradientEnd,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.call, size: 18),
                  const SizedBox(width: 6),
                  Text(l10n.sosCall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
