import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/health/model/medical_profile.dart';
import '../features/health/model/medicine.dart';
import '../services/reminder_service.dart';
import '../services/secure_store.dart';
import 'preferences.dart';

/// Storage keys. Health data lives under its own prefix so a future "delete
/// everything" can find all of it without guessing.
abstract final class HealthKeys {
  static const String profiles = 'health.profiles';
  static const String medicines = 'health.medicines';
  static const String kit = 'health.kit.checked';
}

/// A notification id that survives an app restart.
///
/// `String.hashCode` is not guaranteed to be stable between runs, and a
/// reminder we cannot compute the id of again is a reminder we cannot cancel.
/// FNV-1a is small, deterministic, and good enough for this.
int stableNotificationId(String key) {
  int hash = 0x811c9dc5;
  for (final int unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// Everything read out of secure storage at boot, so the notifiers below can
/// build synchronously like the rest of the app's state.
@immutable
class HealthSnapshot {
  const HealthSnapshot({
    this.profiles = const <MedicalProfile>[],
    this.medicines = const <Medicine>[],
  });

  final List<MedicalProfile> profiles;
  final List<Medicine> medicines;

  static Future<HealthSnapshot> load(SecureStore store) async {
    return HealthSnapshot(
      profiles: await _decode(store, HealthKeys.profiles, MedicalProfile.fromJson),
      medicines: await _decode(store, HealthKeys.medicines, Medicine.fromJson),
    );
  }

  static Future<List<T>> _decode<T>(
    SecureStore store,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final String? raw = await store.read(key);
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    } on FormatException {
      // Corrupt or truncated storage: start clean rather than crash on launch.
      return <T>[];
    }
  }
}

final Provider<SecureStore> secureStoreProvider = Provider<SecureStore>(
  (Ref ref) => throw UnimplementedError('secureStoreProvider must be overridden'),
);

final Provider<HealthSnapshot> healthSnapshotProvider = Provider<HealthSnapshot>(
  (Ref ref) => throw UnimplementedError('healthSnapshotProvider must be overridden'),
);

final Provider<Reminders> remindersProvider = Provider<Reminders>(
  (Ref ref) => LocalReminders(),
);

/// Medical cards for the household, encrypted on this device only.
class ProfilesNotifier extends Notifier<List<MedicalProfile>> {
  static const int maxProfiles = 6;

  @override
  List<MedicalProfile> build() => ref.watch(healthSnapshotProvider).profiles;

  bool get isFull => state.length >= maxProfiles;

  Future<void> save(MedicalProfile profile) async {
    final int index = state.indexWhere((MedicalProfile p) => p.id == profile.id);
    if (index == -1) {
      if (isFull) return;
      state = <MedicalProfile>[...state, profile];
    } else {
      final List<MedicalProfile> next = <MedicalProfile>[...state];
      next[index] = profile;
      state = next;
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((MedicalProfile p) => p.id != id).toList();
    await _persist();
  }

  Future<void> _persist() => ref.read(secureStoreProvider).write(
        HealthKeys.profiles,
        jsonEncode(state.map((MedicalProfile p) => p.toJson()).toList()),
      );
}

final NotifierProvider<ProfilesNotifier, List<MedicalProfile>> profilesProvider =
    NotifierProvider<ProfilesNotifier, List<MedicalProfile>>(ProfilesNotifier.new);

/// The medicine cabinet: what is in the house, when it expires, when to take it.
class MedicinesNotifier extends Notifier<List<Medicine>> {
  @override
  List<Medicine> build() => ref.watch(healthSnapshotProvider).medicines;

  static int doseReminderId(String medicineId, int slot) =>
      stableNotificationId('dose:$medicineId:$slot');

  static int expiryReminderId(String medicineId) =>
      stableNotificationId('expiry:$medicineId');

  Future<void> save(
    Medicine medicine, {
    required String doseTitle,
    required String expiryTitle,
  }) async {
    final int index = state.indexWhere((Medicine m) => m.id == medicine.id);
    if (index == -1) {
      state = <Medicine>[...state, medicine];
    } else {
      final List<Medicine> next = <Medicine>[...state];
      next[index] = medicine;
      state = next;
    }
    await _persist();
    await _syncReminders(medicine, doseTitle: doseTitle, expiryTitle: expiryTitle);
  }

  Future<void> remove(String id) async {
    final Medicine? gone =
        state.where((Medicine m) => m.id == id).cast<Medicine?>().firstOrNull;
    state = state.where((Medicine m) => m.id != id).toList();
    await _persist();
    await _cancelReminders(gone ?? Medicine(id: id, name: ''));
  }

  /// Rebuilds this medicine's reminders from scratch, so editing a dose time
  /// never leaves an orphaned notification behind.
  Future<void> _syncReminders(
    Medicine medicine, {
    required String doseTitle,
    required String expiryTitle,
  }) async {
    final Reminders reminders = ref.read(remindersProvider);
    await _cancelReminders(medicine, slots: 8);

    if (medicine.dailyTimes.isNotEmpty || medicine.expiry != null) {
      final bool allowed = await reminders.ensurePermission();
      if (!allowed) return;
    }

    final DateTime now = DateTime.now();
    for (int slot = 0; slot < medicine.dailyTimes.length; slot++) {
      final int minutes = medicine.dailyTimes[slot];
      DateTime at = DateTime(now.year, now.month, now.day, minutes ~/ 60, minutes % 60);
      if (at.isBefore(now)) at = at.add(const Duration(days: 1));
      await reminders.schedule(
        Reminder(
          id: doseReminderId(medicine.id, slot),
          title: doseTitle,
          body: medicine.dose.isEmpty ? medicine.name : '${medicine.name} · ${medicine.dose}',
          when: at,
          repeatDaily: true,
        ),
      );
    }

    final DateTime? expiry = medicine.expiry;
    if (expiry != null) {
      final DateTime warnAt = DateTime(
        expiry.year,
        expiry.month,
        expiry.day - Medicine.expiryWarningDays,
        9,
      );
      await reminders.schedule(
        Reminder(
          id: expiryReminderId(medicine.id),
          title: expiryTitle,
          body: medicine.name,
          when: warnAt,
        ),
      );
    }
  }

  Future<void> _cancelReminders(Medicine medicine, {int slots = 8}) async {
    final Reminders reminders = ref.read(remindersProvider);
    for (int slot = 0; slot < slots; slot++) {
      await reminders.cancel(doseReminderId(medicine.id, slot));
    }
    await reminders.cancel(expiryReminderId(medicine.id));
  }

  Future<void> _persist() => ref.read(secureStoreProvider).write(
        HealthKeys.medicines,
        jsonEncode(state.map((Medicine m) => m.toJson()).toList()),
      );
}

final NotifierProvider<MedicinesNotifier, List<Medicine>> medicinesProvider =
    NotifierProvider<MedicinesNotifier, List<Medicine>>(MedicinesNotifier.new);

/// Which first-aid kit items the user has ticked off.
///
/// Not health data — just a shopping list — so it stays in plain preferences
/// alongside favourites and the theme.
class KitNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref.watch(sharedPreferencesProvider).getStringList(HealthKeys.kit)?.toSet() ??
      <String>{};

  Future<void> toggle(String id) async {
    final Set<String> next = <String>{...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(HealthKeys.kit, next.toList());
  }
}

final NotifierProvider<KitNotifier, Set<String>> kitProvider =
    NotifierProvider<KitNotifier, Set<String>>(KitNotifier.new);

/// Medicines that have expired or are about to, worst first.
final Provider<List<Medicine>> expiringMedicinesProvider = Provider<List<Medicine>>(
  (Ref ref) {
    final List<Medicine> flagged = ref
        .watch(medicinesProvider)
        .where((Medicine m) => m.isExpired || m.expiresSoon)
        .toList();
    flagged.sort(
      (Medicine a, Medicine b) =>
          (a.daysUntilExpiry ?? 0).compareTo(b.daysUntilExpiry ?? 0),
    );
    return flagged;
  },
);
