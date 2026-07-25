import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/platform/adaptive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/health_provider.dart';
import '../model/medicine.dart';

/// The medicine cabinet: what is in the house, when it expires, when it is due.
class MedicinesScreen extends ConsumerWidget {
  const MedicinesScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MedicinesScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Medicine> medicines = <Medicine>[...ref.watch(medicinesProvider)]
      ..sort((Medicine a, Medicine b) {
        final int ax = a.daysUntilExpiry ?? 1 << 20;
        final int bx = b.daysUntilExpiry ?? 1 << 20;
        return ax.compareTo(bx);
      });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthMedicinesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showMedicineEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.medicineAdd),
      ),
      body: medicines.isEmpty
          ? _Empty(title: l10n.medicinesEmptyTitle, body: l10n.medicinesEmptyBody)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int i) =>
                  _MedicineTile(medicine: medicines[i]),
            ),
    );
  }
}

class _MedicineTile extends ConsumerWidget {
  const _MedicineTile({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int? days = medicine.daysUntilExpiry;

    final (String status, Color colour) = switch (medicine) {
      final Medicine m when m.isExpired => (l10n.medicineExpired, context.semantic.immediate),
      final Medicine m when m.expiresSoon =>
        (l10n.medicineExpiresInDays(days ?? 0), context.semantic.urgent),
      final Medicine m when m.expiry == null =>
        (l10n.medicineNoExpiry, context.semantic.muted),
      _ => (l10n.medicineExpiresInDays(days ?? 0), context.semantic.safe),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => showMedicineEditor(context, ref, medicine: medicine),
        title: Text(medicine.name, style: context.texts.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (medicine.dose.isNotEmpty)
              Text(
                medicine.dose,
                style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
              ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Icon(Icons.schedule, size: 14, color: colour),
                const SizedBox(width: 5),
                Text(status, style: context.texts.labelMedium?.copyWith(color: colour)),
                if (medicine.dailyTimes.isNotEmpty) ...<Widget>[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 14,
                    color: context.semantic.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${medicine.dailyTimes.length}',
                    style: context.texts.labelMedium
                        ?.copyWith(color: context.semantic.muted),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Adds a medicine, or edits the one passed in.
Future<void> showMedicineEditor(
  BuildContext context,
  WidgetRef ref, {
  Medicine? medicine,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => _MedicineEditor(medicine: medicine),
  );
}

class _MedicineEditor extends ConsumerStatefulWidget {
  const _MedicineEditor({this.medicine});

  final Medicine? medicine;

  @override
  ConsumerState<_MedicineEditor> createState() => _MedicineEditorState();
}

class _MedicineEditorState extends ConsumerState<_MedicineEditor> {
  late final TextEditingController _name;
  late final TextEditingController _dose;
  DateTime? _expiry;
  late List<int> _times;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.medicine?.name ?? '');
    _dose = TextEditingController(text: widget.medicine?.dose ?? '');
    _expiry = widget.medicine?.expiry;
    _times = <int>[...?widget.medicine?.dailyTimes];
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showAdaptiveDate(
      context,
      initialDate: _expiry ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _addTime() async {
    final TimeOfDay? picked = await showAdaptiveTime(
      context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;
    final int minutes = picked.hour * 60 + picked.minute;
    if (_times.contains(minutes) || _times.length >= 8) return;
    setState(() => _times = <int>[..._times, minutes]..sort());
  }

  String _format(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.medicineNameRequired);
      return;
    }
    final Medicine medicine = Medicine(
      id: widget.medicine?.id ??
          'm${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
      name: _name.text.trim(),
      dose: _dose.text.trim(),
      expiry: _expiry,
      dailyTimes: _times,
      forProfileId: widget.medicine?.forProfileId,
    );
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool wantsReminders = _times.isNotEmpty || _expiry != null;
    final bool allowed =
        !wantsReminders || await ref.read(remindersProvider).ensurePermission();

    await ref.read(medicinesProvider.notifier).save(
          medicine,
          doseTitle: l10n.medicineReminderTitle,
          expiryTitle: l10n.medicineExpiryReminderTitle,
        );
    navigator.pop();
    if (!allowed) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.notificationsBlocked)));
    }
  }

  Future<void> _delete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showAdaptiveConfirm(
      context,
      message: l10n.medicineDeleteConfirm,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(medicinesProvider.notifier).remove(widget.medicine!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool editing = widget.medicine != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    editing ? l10n.medicineEdit : l10n.medicineAdd,
                    style: context.texts.titleLarge,
                  ),
                ),
                if (editing)
                  IconButton(
                    tooltip: l10n.commonDelete,
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: !editing,
              decoration: InputDecoration(
                labelText: l10n.medicineName,
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _dose,
              decoration: InputDecoration(
                labelText: l10n.medicineDose,
                hintText: l10n.medicineDoseHint,
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.medicineExpiry),
              subtitle: Text(
                _expiry == null
                    ? l10n.medicineNoExpiry
                    : '${_expiry!.year}-${_expiry!.month.toString().padLeft(2, '0')}-${_expiry!.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickExpiry,
            ),
            const SizedBox(height: 6),
            Text(l10n.medicineDoseTimes, style: context.texts.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final int minutes in _times)
                  InputChip(
                    label: Text(_format(minutes)),
                    onDeleted: () =>
                        setState(() => _times = _times.where((int t) => t != minutes).toList()),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.medicineAddTime),
                  onPressed: _addTime,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
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
            Icon(Icons.medication_outlined, size: 56, color: context.semantic.muted),
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
