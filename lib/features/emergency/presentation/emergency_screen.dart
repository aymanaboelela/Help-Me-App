import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/call_action.dart';
import '../../../core/maps.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/platform/contact_import.dart';
import '../../../core/widgets/sos_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/contacts_provider.dart';
import '../../../providers/country_provider.dart';
import '../../nearby/presentation/nearby_screen.dart';
import '../data/emergency_numbers.dart';
import 'country_picker.dart';

/// Emergency numbers (per selected country), personal ICE contacts, and a
/// nearest-hospital shortcut.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final EmergencyCountry country = ref.watch(countryProvider);
    final List<EmergencyContact> contacts = ref.watch(contactsProvider);
    final List<EmergencyNumber> critical =
        country.numbers.where((EmergencyNumber e) => e.critical).toList();
    final List<EmergencyNumber> other =
        country.numbers.where((EmergencyNumber e) => !e.critical).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emergencyTitle),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => showCountryPicker(context, ref),
            icon: Text(country.flag, style: const TextStyle(fontSize: 18)),
            label: Text(country.name.resolve(context.locale)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: <Widget>[
          const SosBanner(),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openNearestHospital(
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: Text(l10n.nearestHospital),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).push(NearbyScreen.route()),
                  icon: const Icon(Icons.near_me_outlined),
                  label: Text(l10n.nearbyTitle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ContactsSection(contacts: contacts),
          const SizedBox(height: 20),
          Text(
            l10n.emergencyNote,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          ),
          const SizedBox(height: 12),
          _SectionLabel(text: l10n.emergencyCritical),
          for (final EmergencyNumber item in critical) _NumberTile(item: item),
          const SizedBox(height: 20),
          _SectionLabel(text: l10n.emergencyOther),
          for (final EmergencyNumber item in other) _NumberTile(item: item),
        ],
      ),
    );
  }

}

class _ContactsSection extends ConsumerWidget {
  const _ContactsSection({required this.contacts});

  final List<EmergencyContact> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isFull = ref.read(contactsProvider.notifier).isFull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(text: l10n.contactsTitle),
        if (contacts.isEmpty)
          Text(
            l10n.contactsEmpty,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          )
        else
          for (int i = 0; i < contacts.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  onTap: () => callWithFeedback(context, contacts[i].number),
                  leading: CircleAvatar(
                    backgroundColor: context.colors.secondary.withValues(alpha: 0.16),
                    child: Icon(Icons.person, color: context.colors.secondary),
                  ),
                  title: Text(contacts[i].name),
                  subtitle: Text(
                    contacts[i].number,
                    textDirection: TextDirection.ltr,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: context.semantic.danger),
                    tooltip: l10n.commonDelete,
                    onPressed: () => ref.read(contactsProvider.notifier).removeAt(i),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: isFull ? null : () => _addContact(context, ref),
            icon: const Icon(Icons.add),
            label: Text(isFull ? l10n.contactFull : l10n.contactAdd),
          ),
        ),
      ],
    );
  }

  /// Adds a contact, either straight from the phone's address book or typed by
  /// hand. The address book is only offered where the OS has a picker for it.
  Future<void> _addContact(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    _AddSource source = _AddSource.manual;

    if (supportsContactImport) {
      final _AddSource? chosen = await showAdaptiveOptions<_AddSource>(
        context,
        title: l10n.contactAdd,
        options: <AdaptiveOption<_AddSource>>[
          AdaptiveOption<_AddSource>(
            value: _AddSource.phonebook,
            label: l10n.contactFromPhonebook,
            icon: Icons.contacts_outlined,
          ),
          AdaptiveOption<_AddSource>(
            value: _AddSource.manual,
            label: l10n.contactManual,
            icon: Icons.dialpad,
          ),
        ],
      );
      if (chosen == null || !context.mounted) return;
      source = chosen;
    }

    // Whatever the picker gives back is still shown in the form first: names
    // come out of address books long and numbers come out formatted, and this
    // is a number someone will dial one-handed in an emergency.
    EmergencyContact draft = const EmergencyContact(name: '', number: '');
    if (source == _AddSource.phonebook) {
      final ContactImportResult result = await importDeviceContact();
      if (!context.mounted) return;
      switch (result.status) {
        case ContactImportStatus.cancelled:
          return;
        case ContactImportStatus.noNumber:
          _showMessage(context, l10n.contactImportNoNumber);
          return;
        case ContactImportStatus.failed:
          _showMessage(context, l10n.contactImportFailed);
          return;
        case ContactImportStatus.picked:
          draft = EmergencyContact(name: result.name!, number: result.number!);
      }
    }

    final EmergencyContact? contact = await showDialog<EmergencyContact>(
      context: context,
      builder: (_) => _AddContactDialog(draft: draft),
    );
    if (contact != null) {
      await ref.read(contactsProvider.notifier).add(contact);
    }
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// Where a new ICE contact's details come from.
enum _AddSource { phonebook, manual }

class _AddContactDialog extends StatefulWidget {
  const _AddContactDialog({required this.draft});

  /// Details to start from — empty when typing a contact from scratch, filled in
  /// when one was just imported from the address book.
  final EmergencyContact draft;

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.draft.name);
  late final TextEditingController _number =
      TextEditingController(text: widget.draft.number);

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    super.dispose();
  }

  void _save() {
    final String name = _name.text.trim();
    final String number = _number.text.trim();
    if (name.isEmpty || number.isEmpty) return;
    Navigator.of(context).pop(EmergencyContact(name: name, number: number));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.contactAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.contactName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _number,
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')),
            ],
            decoration: InputDecoration(labelText: l10n.contactNumber),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
      ],
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
