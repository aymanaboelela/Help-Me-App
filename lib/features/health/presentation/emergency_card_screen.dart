import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../model/medical_profile.dart';

/// The card as a paramedic would want to see it: high contrast, large type,
/// no navigation to get lost in, and a QR code so the details can be read from
/// another phone without installing anything.
///
/// The screen stays awake and forces the light theme — a dark card read at
/// arm's length in daylight is a card that does not get read.
class EmergencyCardScreen extends ConsumerWidget {
  const EmergencyCardScreen({super.key, required this.profileId});

  final String profileId;

  static Route<void> route(String profileId) => MaterialPageRoute<void>(
        builder: (_) => EmergencyCardScreen(profileId: profileId),
      );

  /// Plain text, so any camera app can show it without needing this app.
  static String encode(MedicalProfile profile, AppLocalizations l10n) {
    final StringBuffer buffer = StringBuffer()
      ..writeln(profile.name)
      ..writeln('${l10n.profileBloodType}: ${profile.bloodType.label}');
    if (profile.age != null) {
      buffer.writeln('${l10n.profileBirthDate}: ${profile.age}');
    }
    void list(String label, List<String> values) {
      if (values.isEmpty) return;
      buffer.writeln('$label: ${values.join(', ')}');
    }

    list(l10n.profileAllergies, profile.allergies);
    list(l10n.profileConditions, profile.conditions);
    list(l10n.profileMedications, profile.medications);
    if (profile.doctorPhone.isNotEmpty) {
      buffer.writeln('${l10n.profileDoctorName}: ${profile.doctorName} ${profile.doctorPhone}');
    }
    if (profile.notes.isNotEmpty) buffer.writeln(profile.notes);
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MedicalProfile? profile = ref
        .watch(profilesProvider)
        .where((MedicalProfile p) => p.id == profileId)
        .cast<MedicalProfile?>()
        .firstOrNull;

    if (profile == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Theme(
        data: ThemeData.light(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Colors.white,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: const Color(0xFF111317),
                displayColor: const Color(0xFF111317),
              ),
        ),
        child: Builder(
          builder: (BuildContext context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF111317),
              elevation: 0,
              title: Text(l10n.emergencyCardOpen),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: <Widget>[
                Text(
                  profile.name,
                  style: context.texts.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (profile.age != null)
                  Text(
                    l10n.profileAgeYears(profile.age!),
                    style: context.texts.titleMedium
                        ?.copyWith(color: const Color(0xFF5B6672)),
                  ),
                const SizedBox(height: 18),
                _BloodBadge(label: profile.bloodType.label, caption: l10n.profileBloodType),
                const SizedBox(height: 18),
                _Block(
                  label: l10n.profileAllergies,
                  values: profile.allergies,
                  empty: l10n.emergencyCardNone,
                  urgent: true,
                ),
                _Block(
                  label: l10n.profileConditions,
                  values: profile.conditions,
                  empty: l10n.emergencyCardNone,
                ),
                _Block(
                  label: l10n.profileMedications,
                  values: profile.medications,
                  empty: l10n.emergencyCardNone,
                ),
                if (profile.doctorName.isNotEmpty || profile.doctorPhone.isNotEmpty)
                  _Block(
                    label: l10n.profileDoctorName,
                    values: <String>[
                      if (profile.doctorName.isNotEmpty) profile.doctorName,
                      if (profile.doctorPhone.isNotEmpty) profile.doctorPhone,
                    ],
                    empty: l10n.emergencyCardNone,
                  ),
                if (profile.notes.isNotEmpty)
                  _Block(
                    label: l10n.profileNotes,
                    values: <String>[profile.notes],
                    empty: l10n.emergencyCardNone,
                  ),
                const SizedBox(height: 20),
                Center(
                  child: QrImageView(
                    data: encode(profile, l10n),
                    size: 190,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.emergencyCardHint,
                  textAlign: TextAlign.center,
                  style: context.texts.bodySmall
                      ?.copyWith(color: const Color(0xFF5B6672)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BloodBadge extends StatelessWidget {
  const _BloodBadge({required this.label, required this.caption});

  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE63946),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: context.texts.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          caption,
          style: context.texts.titleMedium?.copyWith(color: const Color(0xFF5B6672)),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.label,
    required this.values,
    required this.empty,
    this.urgent = false,
  });

  final String label;
  final List<String> values;
  final String empty;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final bool has = values.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: context.texts.labelMedium?.copyWith(
              color: const Color(0xFF5B6672),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            has ? values.join(' · ') : empty,
            style: context.texts.titleLarge?.copyWith(
              fontWeight: has && urgent ? FontWeight.w800 : FontWeight.w600,
              color: has && urgent ? const Color(0xFFC1121F) : null,
            ),
          ),
        ],
      ),
    );
  }
}
