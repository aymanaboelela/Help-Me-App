import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../data/kit_catalogue.dart';
import 'medicines_screen.dart';

/// What a home first-aid kit should contain, ticked off.
///
/// The checklist deliberately holds no expiry dates: anything with a shelf life
/// belongs in the medicine cabinet, which is where reminders live. One place
/// per fact.
class KitScreen extends ConsumerWidget {
  const KitScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const KitScreen());

  String _sectionLabel(KitSection section, AppLocalizations l10n) =>
      switch (section) {
        KitSection.dressings => l10n.kitSectionDressings,
        KitSection.tools => l10n.kitSectionTools,
        KitSection.medicines => l10n.kitSectionMedicines,
        KitSection.protection => l10n.kitSectionProtection,
        KitSection.essentials => l10n.kitSectionEssentials,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final Set<String> checked = ref.watch(kitProvider);
    final Map<KitSection, List<KitItem>> grouped = kKitBySection;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthKitTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          _Progress(done: checked.length, total: kKitCatalogue.length),
          const SizedBox(height: 18),
          for (final KitSection section in KitSection.values) ...<Widget>[
            Text(
              _sectionLabel(section, l10n),
              style: context.texts.titleMedium?.copyWith(color: context.colors.primary),
            ),
            const SizedBox(height: 4),
            for (final KitItem item in grouped[section] ?? const <KitItem>[])
              CheckboxListTile(
                value: checked.contains(item.id),
                onChanged: (_) => ref.read(kitProvider.notifier).toggle(item.id),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Row(
                  children: <Widget>[
                    Expanded(child: Text(item.name.resolve(locale))),
                    if (item.perishable)
                      Tooltip(
                        message: l10n.kitPerishable,
                        child: Icon(
                          Icons.schedule,
                          size: 16,
                          color: context.semantic.urgent,
                        ),
                      ),
                  ],
                ),
                subtitle: item.note == null
                    ? null
                    : Text(
                        item.note!.resolve(locale),
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.semantic.muted),
                      ),
              ),
            const SizedBox(height: 14),
          ],
          Card(
            child: ListTile(
              leading: Icon(Icons.schedule, color: context.semantic.urgent),
              title: Text(
                l10n.kitPerishableNote,
                style: context.texts.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MedicinesScreen.route()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double value = total == 0 ? 0 : done / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.kitProgress(done, total), style: context.texts.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: context.colors.primary.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
