import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/health/model/medicine.dart';
import '../l10n/app_localizations.dart';
import '../services/reminder_plan.dart';
import '../services/reminder_service.dart';
import 'health_provider.dart';
import 'learn_provider.dart';
import 'notification_prefs_provider.dart';
import 'settings_provider.dart';

/// The language reminders are written in: whatever the app itself is showing,
/// falling back the same way the app does for a language it has no strings for.
final Provider<Locale> reminderLocaleProvider = Provider<Locale>((Ref ref) {
  final String? chosen = ref.watch(settingsProvider).localeCode;
  if (chosen != null) return Locale(chosen);
  final String system = PlatformDispatcher.instance.locale.languageCode;
  return Locale(system == 'en' ? 'en' : 'ar');
});

/// Brings the phone's pending notifications back in line with the app's state.
///
/// Everything goes through one rebuild rather than incremental edits: a switch
/// flipped, a medicine saved, a language changed and an app launch all end at
/// the same set of pending reminders, so there is no path that leaves an
/// orphaned notification behind.
class ReminderSync {
  const ReminderSync(this._ref);

  final Ref _ref;

  /// Cancels everything and reschedules what the user has left switched on.
  ///
  /// Returns whether the reminders they asked for are actually in place —
  /// `false` only when the phone refuses notifications, so the caller can say so.
  ///
  /// [requestPermission] is off by default so this can run at launch without
  /// throwing a permission prompt at someone who only opened a first-aid guide.
  /// The screens that turn a reminder *on* pass `true`.
  Future<bool> rebuildAll({bool requestPermission = false}) async {
    final Reminders reminders = _ref.read(remindersProvider);
    await reminders.cancelAll();

    final List<Reminder> planned = plan();
    if (planned.isEmpty) return true;
    if (requestPermission && !await reminders.ensurePermission()) return false;

    for (final Reminder reminder in planned) {
      await reminders.schedule(reminder);
    }
    return true;
  }

  /// Every reminder the app wants right now.
  List<Reminder> plan() {
    final NotificationPrefs prefs = _ref.read(notificationPrefsProvider);
    final AppLocalizations l10n =
        lookupAppLocalizations(_ref.read(reminderLocaleProvider));
    final DateTime now = DateTime.now();

    return <Reminder>[
      for (final Medicine medicine in _ref.read(medicinesProvider))
        ...planMedicineReminders(
          medicine,
          prefs: prefs,
          doseTitle: l10n.medicineReminderTitle,
          expiryTitle: l10n.medicineExpiryReminderTitle,
          now: now,
        ),
      ...planTipReminder(
        tipMinutes: _ref.read(tipReminderProvider),
        title: l10n.tipReminderTitle,
        now: now,
      ),
    ];
  }
}

final Provider<ReminderSync> reminderSyncProvider = Provider<ReminderSync>(
  (Ref ref) => ReminderSync(ref),
);
