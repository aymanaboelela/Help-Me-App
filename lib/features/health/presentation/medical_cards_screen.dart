import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../model/medical_profile.dart';
import 'emergency_card_screen.dart';
import 'profile_edit_screen.dart';

/// One medical card per person in the household.
class MedicalCardsScreen extends ConsumerWidget {
  const MedicalCardsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MedicalCardsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<MedicalProfile> profiles = ref.watch(profilesProvider);
    final bool isFull = ref.read(profilesProvider.notifier).isFull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthCardsTitle)),
      floatingActionButton: isFull
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).push(ProfileEditScreen.route()),
              icon: const Icon(Icons.add),
              label: Text(l10n.profileAdd),
            ),
      body: profiles.isEmpty
          ? _Empty(title: l10n.profilesEmptyTitle, body: l10n.profilesEmptyBody)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: profiles.length + (isFull ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int i) {
                if (i == profiles.length) {
                  return Text(
                    l10n.profileFull,
                    style: context.texts.bodySmall
                        ?.copyWith(color: context.semantic.muted),
                  );
                }
                return _CardTile(profile: profiles[i]);
              },
            ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.profile});

  final MedicalProfile profile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> flags = <String>[
      ...profile.allergies,
      ...profile.conditions,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    profile.bloodType.label,
                    style: context.texts.titleMedium
                        ?.copyWith(color: context.colors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(profile.name, style: context.texts.titleMedium),
                      if (profile.age != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          l10n.profileAgeYears(profile.age!),
                          style: context.texts.bodySmall
                              ?.copyWith(color: context.semantic.muted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (flags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (final String flag in flags.take(4))
                    Chip(
                      label: Text(flag),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => Navigator.of(context)
                      .push(EmergencyCardScreen.route(profile.id)),
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: Text(l10n.emergencyCardOpen),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.commonEdit,
                  onPressed: () => Navigator.of(context)
                      .push(ProfileEditScreen.route(profile: profile)),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.badge_outlined, size: 56, color: context.semantic.muted),
            const SizedBox(height: 16),
            Text(title, style: context.texts.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
            ),
          ],
        ),
      ),
    );
  }
}
