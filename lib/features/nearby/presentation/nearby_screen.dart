import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/maps.dart';
import '../../../core/platform/adaptive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/reminder_sync_provider.dart';
import '../../health/model/blood_donation.dart';
import '../../health/model/medical_profile.dart';

/// Places worth finding fast, and the blood-donation countdown.
///
/// Every place opens the phone's own maps app. The app asks for no location
/// permission and never reads a position — the maps app already knows where the
/// user is and does the job better.
class NearbyScreen extends ConsumerWidget {
  const NearbyScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const NearbyScreen());

  static const List<(NearbyPlace, IconData)> _places = <(NearbyPlace, IconData)>[
    (NearbyPlace.hospital, Icons.local_hospital_outlined),
    (NearbyPlace.pharmacy, Icons.local_pharmacy_outlined),
    (NearbyPlace.bloodBank, Icons.bloodtype_outlined),
    (NearbyPlace.clinic, Icons.medical_services_outlined),
  ];

  String _label(NearbyPlace place, AppLocalizations l10n) => switch (place) {
        NearbyPlace.hospital => l10n.nearbyHospital,
        NearbyPlace.pharmacy => l10n.nearbyPharmacy,
        NearbyPlace.bloodBank => l10n.nearbyBloodBank,
        NearbyPlace.clinic => l10n.nearbyClinic,
      };

  Future<void> _open(BuildContext context, NearbyPlace place) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool opened = await openNearby(
      place,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nearbyFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<DonationStatus> donations = ref.watch(donationStatusesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nearbyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.lock_outline, size: 18, color: context.semantic.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.nearbySubtitle,
                  style: context.texts.bodySmall
                      ?.copyWith(color: context.semantic.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: <Widget>[
              for (final (NearbyPlace place, IconData icon) in _places)
                _PlaceTile(
                  icon: icon,
                  label: _label(place, l10n),
                  onTap: () => _open(context, place),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Text(l10n.donationTitle, style: context.texts.titleLarge),
          const SizedBox(height: 4),
          Text(
            l10n.donationIntervalNote,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          ),
          const SizedBox(height: 12),
          if (donations.isEmpty)
            Text(
              l10n.profilesEmptyBody,
              style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
            )
          else
            for (final DonationStatus status in donations) ...<Widget>[
              _DonationCard(status: status),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: context.colors.primary, size: 26),
              const Spacer(),
              Text(label, style: context.texts.titleSmall),
              const SizedBox(height: 2),
              Row(
                children: <Widget>[
                  Text(
                    'Maps',
                    style: context.texts.labelSmall
                        ?.copyWith(color: context.semantic.muted),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.north_east, size: 12, color: context.semantic.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationCard extends ConsumerWidget {
  const _DonationCard({required this.status});

  final DonationStatus status;

  String _formatDate(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  Future<void> _record(BuildContext context, WidgetRef ref) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showAdaptiveDate(
      context,
      initialDate: status.lastDonation ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;

    final MedicalProfile? profile = ref
        .read(profilesProvider)
        .where((MedicalProfile p) => p.id == status.profileId)
        .cast<MedicalProfile?>()
        .firstOrNull;
    if (profile == null) return;

    await ref
        .read(profilesProvider.notifier)
        .save(profile.copyWith(lastDonation: picked));
    await ref.read(reminderSyncProvider).rebuildAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool eligible = status.isEligible;
    final Color accent =
        eligible ? context.semantic.success : context.semantic.muted;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => _record(context, ref),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.bloodtype_outlined, color: accent),
        ),
        title: Text(status.name, style: context.texts.titleSmall),
        subtitle: Text(
          status.lastDonation == null
              ? l10n.donationNoRecord
              : l10n.donationLast(_formatDate(status.lastDonation!)),
          style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
        ),
        trailing: Text(
          status.lastDonation == null
              ? l10n.donationAddDate
              : eligible
                  ? l10n.donationEligible
                  : l10n.donationWaitDays(status.daysRemaining),
          style: context.texts.labelMedium?.copyWith(color: accent),
        ),
      ),
    );
  }
}
