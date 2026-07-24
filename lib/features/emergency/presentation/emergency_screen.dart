import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/call_action.dart';
import '../../../core/widgets/sos_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../data/emergency_numbers.dart';

/// Egyptian emergency and utility numbers, tap-to-dial.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<EmergencyNumber> critical =
        kEmergencyNumbers.where((EmergencyNumber e) => e.critical).toList();
    final List<EmergencyNumber> other =
        kEmergencyNumbers.where((EmergencyNumber e) => !e.critical).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emergencyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: <Widget>[
          const SosBanner(),
          const SizedBox(height: 16),
          Text(
            l10n.emergencyNote,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          ),
          const SizedBox(height: 16),
          _SectionLabel(text: l10n.emergencyCritical),
          for (final EmergencyNumber item in critical)
            _NumberTile(item: item),
          const SizedBox(height: 20),
          _SectionLabel(text: l10n.emergencyOther),
          for (final EmergencyNumber item in other) _NumberTile(item: item),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: context.texts.titleSmall?.copyWith(color: context.semantic.muted),
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.item});

  final EmergencyNumber item;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        item.critical ? context.colors.primary : context.colors.secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: () => callWithFeedback(context, item.number),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: accent),
          ),
          title: Text(
            item.name.resolve(context.locale),
            style: context.texts.titleMedium,
          ),
          subtitle: Text(
            item.number,
            textDirection: TextDirection.ltr,
            style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
          ),
          trailing: Icon(Icons.call, color: accent),
        ),
      ),
    );
  }
}
