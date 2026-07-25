import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/platform/adaptive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../model/medical_profile.dart';

/// Creates or edits one medical card.
///
/// Every field except the name is optional on purpose — a card holding only a
/// blood type is still better than no card, and asking for everything up front
/// is how forms end up abandoned.
///
/// The fields are grouped and every control wears the same shape, including the
/// date row, so the form reads as one thing rather than a pile of widgets. Save
/// sits in a bar pinned to the bottom: on a long form it should never be
/// something you have to go looking for.
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
    final DateTime? picked = await showAdaptiveDate(
      context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
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
    final bool confirmed = await showAdaptiveConfirm(
      context,
      message: l10n.profileDeleteConfirm,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(profilesProvider.notifier).remove(widget.profile!.id);
    navigator.pop();
  }

  String _formatDate(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          _FormSection(
            title: l10n.profileName,
            children: <Widget>[
              TextField(
                controller: _name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.profileName,
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              DropdownButtonFormField<BloodType>(
                initialValue: _bloodType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.profileBloodType,
                  prefixIcon: const Icon(Icons.bloodtype_outlined),
                ),
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
              _PickerField(
                label: l10n.profileBirthDate,
                value: _birthDate == null ? null : _formatDate(_birthDate!),
                placeholder: l10n.profileUnset,
                icon: Icons.cake_outlined,
                onTap: _pickBirthDate,
                onClear:
                    _birthDate == null ? null : () => setState(() => _birthDate = null),
              ),
            ],
          ),
          _FormSection(
            title: l10n.profileAllergies,
            caption: l10n.profileListHint,
            children: <Widget>[
              _MultilineField(controller: _allergies, label: l10n.profileAllergies),
              _MultilineField(controller: _conditions, label: l10n.profileConditions),
              _MultilineField(controller: _medications, label: l10n.profileMedications),
            ],
          ),
          _FormSection(
            title: l10n.profileDoctorName,
            children: <Widget>[
              TextField(
                controller: _doctorName,
                decoration: InputDecoration(
                  labelText: l10n.profileDoctorName,
                  prefixIcon: const Icon(Icons.medical_information_outlined),
                ),
              ),
              TextField(
                controller: _doctorPhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.profileDoctorPhone,
                  prefixIcon: const Icon(Icons.call_outlined),
                ),
              ),
              TextField(
                controller: _insurance,
                decoration: InputDecoration(
                  labelText: l10n.profileInsurance,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              _MultilineField(controller: _notes, label: l10n.profileNotes),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ),
    );
  }
}

/// A titled group of fields with one consistent rhythm between them.
class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children, this.caption});

  final String title;
  final String? caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: context.texts.labelLarge?.copyWith(color: context.colors.primary),
          ),
          if (caption != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
            ),
          ],
          const SizedBox(height: 10),
          for (int i = 0; i < children.length; i++) ...<Widget>[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// A read-only field that opens a picker — shaped exactly like the text fields
/// around it, so a tappable row never looks like a stray label.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: onClear == null
              ? const Icon(Icons.keyboard_arrow_down)
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                ),
        ),
        child: Text(
          value ?? placeholder,
          style: empty
              ? context.texts.bodyLarge?.copyWith(color: context.semantic.muted)
              : context.texts.bodyLarge,
        ),
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    );
  }
}
