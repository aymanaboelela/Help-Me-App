import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/country_provider.dart';
import '../call_action.dart';

/// The prominent red "call the ambulance now" banner shown at the top of the
/// home and emergency screens. Dials the selected country's ambulance number.
class SosBanner extends ConsumerWidget {
  const SosBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final semantic = context.semantic;
    final String number = ref.watch(countryProvider).ambulance.number;

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
              onPressed: () => callWithFeedback(context, number),
              style: FilledButton.styleFrom(
                // Pure white on saturated red is the brightest thing on the
                // screen at 3am, and this is an app people open in the dark.
                // The dark variant softens the fill without costing the button
                // any of its affordance — it is still the obvious thing to hit.
                backgroundColor: semantic.callPillFill,
                foregroundColor: semantic.callPillText,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.call, size: 18),
                  const SizedBox(width: 6),
                  Text('${l10n.callAction} $number'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
