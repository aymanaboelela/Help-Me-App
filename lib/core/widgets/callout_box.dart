import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../features/conditions/model/first_aid_topic.dart';
import '../../l10n/app_localizations.dart';

/// A tinted, bordered highlight for a danger / caution / tip note.
class CalloutBox extends StatelessWidget {
  const CalloutBox({super.key, required this.type, required this.text});

  final CalloutType type;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final semantic = context.semantic;

    final (Color color, IconData icon, String label) = switch (type) {
      CalloutType.danger => (semantic.immediate, Icons.error_outline, l10n.calloutDanger),
      CalloutType.warning => (semantic.urgent, Icons.warning_amber_rounded, l10n.calloutWarning),
      CalloutType.tip => (semantic.structural, Icons.lightbulb_outline, l10n.calloutTip),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: context.texts.labelLarge?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(text, style: context.texts.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
