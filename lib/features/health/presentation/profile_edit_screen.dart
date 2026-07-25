import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../model/medical_profile.dart';

/// Creates or edits one medical card.
///
/// Every field except the name is optional on purpose — a card holding only a
/// blood type is still better than no card, and asking for everything up front
/// is how forms end up abandoned.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.profile});

  final MedicalProfile? profile;

  static Route<void> route({MedicalProfile? profile}) =>
      MaterialPageRoute<void>(builder: (_) => ProfileEditScreen(profile: profile));

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _allergies;
  late final TextEditingController _conditions;
  late final TextEditingController _medications;
  late final TextEditingController _doctorName;
  late final TextEditingController _doctorPhone;
  late final TextEditingController _insurance;
  late final TextEditingController _notes;

  late BloodType _bloodType;
  DateTime? _birthDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    final MedicalProfile? p = widget.profile;
    _name = TextEditingController(text: p?.name ?? '');
    _allergies = TextEditingController(text: p?.allergies.join('\n') ?? '');
    _conditions = TextEditingController(text: p?.conditions.join('\n') ?? '');
    _medications = TextEditingController(text: p?.medications.join('\n') ?? '');
    _doctorName = TextEditingController(text: p?.doctorName ?? '');
    _doctorPhone = TextEditingController(text: p?.doctorPhone ?? '');
    _insurance = TextEditingController(text: p?.insurance ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
    _bloodType = p?.bloodType ?? BloodType.unknown;
    _birthDate = p?.birthDate;
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _allergies,
      _conditions,
      _medications,
      _doctorName,
      _doctorPhone,
      _insurance,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _lines(TextEditingController controller) => controller.text
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList();

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.profileNameRequired);
      return;
    }
    final MedicalProfile profile = MedicalProfile(
      id: widget.profile?.id ??
          'p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
      name: _name.text.trim(),
      bloodType: _bloodType,
      birthDate: _birthDate,
      allergies: _lines(_allergies),
      conditions: _lines(_conditions),
      medications: _lines(_medications),
      doctorName: _doctorName.text.trim(),
      doctorPhone: _doctorPhone.text.trim(),
      insurance: _insurance.text.trim(),
      notes: _notes.text.trim(),
      lastDonation: widget.profile?.lastDonation,
    );
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(profilesProvider.notifier).save(profile);
    navigator.pop();
  }

  Future<void> _delete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(l10n.profileDeleteConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(profilesProvider.notifier).remove(widget.profile!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool editing = widget.profile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.profileEdit : l10n.profileAdd),
        actions: <Widget>[
          if (editing)
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: <Widget>[
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.profileName,
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BloodType>(
            initialValue: _bloodType,
            decoration: InputDecoration(labelText: l10n.profileBloodType),
            items: <DropdownMenuItem<BloodType>>[
              for (final BloodType type in BloodType.values)
                DropdownMenuItem<BloodType>(
                  value: type,
                  child: Text(
                    type == BloodType.unknown ? l10n.profileUnset : type.label,
                  ),
                ),
            ],
            onChanged: (BloodType? value) =>
                setState(() => _bloodType = value ?? BloodType.unknown),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.profileBirthDate),
            subtitle: Text(
              _birthDate == null
                  ? l10n.profileUnset
                  : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 8),
          _MultilineField(
            controller: _allergies,
            label: l10n.profileAllergies,
            hint: l10n.profileListHint,
          ),
          const SizedBox(height: 16),
          _MultilineField(
            controller: _conditions,
            label: l10n.profileConditions,
            hint: l10n.profileListHint,
          ),
          const SizedBox(height: 16),
          _MultilineField(
            controller: _medications,
            label: l10n.profileMedications,
            hint: l10n.profileListHint,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _doctorName,
            decoration: InputDecoration(labelText: l10n.profileDoctorName),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _doctorPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.profileDoctorPhone),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _insurance,
            decoration: InputDecoration(labelText: l10n.profileInsurance),
          ),
          const SizedBox(height: 16),
          _MultilineField(controller: _notes, label: l10n.profileNotes),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({required this.controller, required this.label, this.hint});

  final TextEditingController controller;
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
