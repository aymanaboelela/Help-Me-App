import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reminder_plan.dart';
import 'preferences.dart';

/// Storage keys for the notification switches.
abstract final class NotificationKeys {
  static const String doses = 'notify.doses';
  static const String expiry = 'notify.expiry';
}

/// Reads and persists [NotificationPrefs].
///
/// Only the switches live here. Turning one on or off has to reschedule what is
/// pending, and that belongs to `reminderSyncProvider` — which needs the
/// medicine list and the daily-tip time this file deliberately knows nothing
/// about.
class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationPrefs(
      doses: prefs.getBool(NotificationKeys.doses) ?? true,
      expiry: prefs.getBool(NotificationKeys.expiry) ?? true,
    );
  }

  Future<void> setDoses(bool enabled) async {
    state = state.copyWith(doses: enabled);
    await ref.read(sharedPreferencesProvider).setBool(NotificationKeys.doses, enabled);
  }

  Future<void> setExpiry(bool enabled) async {
    state = state.copyWith(expiry: enabled);
    await ref.read(sharedPreferencesProvider).setBool(NotificationKeys.expiry, enabled);
  }

}

final NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>
    notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);
