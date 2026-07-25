import 'package:flutter/foundation.dart';

import '../features/health/model/blood_donation.dart';
import '../features/health/model/medicine.dart';
import 'reminder_service.dart';

/// Which medicine reminders the user has left switched on.
///
/// Both default on: they only exist for a medicine somebody deliberately gave a
/// time or an expiry date to, so asking again with a switch would be asking
/// twice. The daily tip is not here — it is owned by `tipReminderProvider`,
/// which stores a time rather than a flag.
@immutable
class NotificationPrefs {
  const NotificationPrefs({this.doses = true, this.expiry = true});

  final bool doses;
  final bool expiry;

  /// The most dose times one medicine can hold. Cancelling walks this range, so
  /// a slot dropped from a medicine still gets its reminder cleared.
  static const int maxDoseSlots = 8;

  NotificationPrefs copyWith({bool? doses, bool? expiry}) => NotificationPrefs(
        doses: doses ?? this.doses,
        expiry: expiry ?? this.expiry,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPrefs && other.doses == doses && other.expiry == expiry;

  @override
  int get hashCode => Object.hash(doses, expiry);
}

int doseReminderId(String medicineId, int slot) =>
    stableNotificationId('dose:$medicineId:$slot');

int expiryReminderId(String medicineId) =>
    stableNotificationId('expiry:$medicineId');

/// The reminders one medicine wants right now, honouring [prefs].
///
/// Pure, so what the app intends to schedule can be checked without a device.
List<Reminder> planMedicineReminders(
  Medicine medicine, {
  required NotificationPrefs prefs,
  required String doseTitle,
  required String expiryTitle,
  required DateTime now,
}) {
  final List<Reminder> planned = <Reminder>[];

  if (prefs.doses) {
    final int slots = medicine.dailyTimes.length.clamp(0, NotificationPrefs.maxDoseSlots);
    for (int slot = 0; slot < slots; slot++) {
      final int minutes = medicine.dailyTimes[slot];
      DateTime at =
          DateTime(now.year, now.month, now.day, minutes ~/ 60, minutes % 60);
      if (at.isBefore(now)) at = at.add(const Duration(days: 1));
      planned.add(
        Reminder(
          id: doseReminderId(medicine.id, slot),
          title: doseTitle,
          body: medicine.dose.isEmpty
              ? medicine.name
              : '${medicine.name} · ${medicine.dose}',
          when: at,
          repeatDaily: true,
        ),
      );
    }
  }

  final DateTime? expiry = medicine.expiry;
  if (prefs.expiry && expiry != null) {
    planned.add(
      Reminder(
        id: expiryReminderId(medicine.id),
        title: expiryTitle,
        body: medicine.name,
        when: DateTime(
          expiry.year,
          expiry.month,
          expiry.day - Medicine.expiryWarningDays,
          9,
        ),
      ),
    );
  }

  return planned;
}

/// The daily-tip nudge, or nothing when [tipMinutes] is null (switched off).
///
/// One repeating reminder rather than one per day: it says only that today's tip
/// is waiting, because a repeating notification carries the same text every time
/// it fires and a specific tip would be stale by the second morning. The tip
/// itself is on the Learn screen the notification opens.
List<Reminder> planTipReminder({
  required int? tipMinutes,
  required String title,
  required DateTime now,
}) {
  if (tipMinutes == null) return const <Reminder>[];

  DateTime at =
      DateTime(now.year, now.month, now.day, tipMinutes ~/ 60, tipMinutes % 60);
  if (at.isBefore(now)) at = at.add(const Duration(days: 1));
  return <Reminder>[
    Reminder(
      id: tipReminderNotificationId,
      title: title,
      body: '',
      when: at,
      repeatDaily: true,
    ),
  ];
}

/// Shared with `TipReminderNotifier`, so the two places that can schedule the
/// tip write to the same notification instead of stacking two of them.
final int tipReminderNotificationId = stableNotificationId('daily_tip');

int donationReminderId(String profileId) =>
    stableNotificationId('donation:$profileId');

/// A nudge on the morning each person becomes able to give blood again.
///
/// Only for someone who has recorded a donation: this reminds people who
/// already give that they can give again, rather than asking anyone to start.
List<Reminder> planDonationReminders(
  List<DonationStatus> statuses, {
  required String title,
  required DateTime now,
}) {
  return <Reminder>[
    for (final DonationStatus status in statuses)
      if (status.eligibleOn != null && status.daysRemaining > 0)
        Reminder(
          id: donationReminderId(status.profileId),
          title: title,
          body: status.name,
          when: DateTime(
            status.eligibleOn!.year,
            status.eligibleOn!.month,
            status.eligibleOn!.day,
            10,
          ),
        ),
  ];
}
