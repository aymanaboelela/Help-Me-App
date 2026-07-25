import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../model/medicine.dart';
import 'kit_screen.dart';
import 'medical_cards_screen.dart';
import 'medicines_screen.dart';

/// The "my health" tab: the three things worth keeping up to date between
/// emergencies — who you are medically, what medicine is in the house, and
/// whether the kit is actually complete.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int cards = ref.watch(profilesProvider).length;
    final int medicines = ref.watch(medicinesProvider).length;
    final Set<String> kitDone = ref.watch(kitProvider);
    final List<Medicine> expiring = ref.watch(expiringMedicinesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          _PrivacyNote(text: l10n.healthPrivacyNote),
          if (expiring.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            _ExpiryAlert(
              text: l10n.healthExpiryAlert(expiring.length),
              onTap: () => Navigator.of(context).push(MedicinesScreen.route()),
            ),
          ],
          const SizedBox(height: 14),
          _HealthTile(
            icon: Icons.badge_outlined,
            title: l10n.healthCardsTitle,
            subtitle: l10n.healthCardsSubtitle,
            trailing: cards == 0 ? null : '$cards',
            onTap: () => Navigator.of(context).push(MedicalCardsScreen.route()),
          ),
          const SizedBox(height: 12),
          _HealthTile(
            icon: Icons.medication_outlined,
            title: l10n.healthMedicinesTitle,
            subtitle: l10n.healthMedicinesSubtitle,
            trailing: medicines == 0 ? null : '$medicines',
            onTap: () => Navigator.of(context).push(MedicinesScreen.route()),
          ),
          const SizedBox(height: 12),
          _HealthTile(
            icon: Icons.medical_services_outlined,
            title: l10n.healthKitTitle,
            subtitle: l10n.healthKitSubtitle,
            trailing: kitDone.isEmpty ? null : '${kitDone.length}',
            onTap: () => Navigator.of(context).push(KitScreen.route()),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.lock_outline, size: 18, color: context.semantic.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          ),
        ),
      ],
    );
  }
}

class _ExpiryAlert extends StatelessWidget {
  const _ExpiryAlert({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.semantic.warning.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Icon(Icons.schedule, color: context.semantic.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: context.texts.titleSmall)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthTile extends StatelessWidget {
  const _HealthTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: context.colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: context.texts.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.semantic.muted),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                Text(trailing!, style: context.texts.titleMedium),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
