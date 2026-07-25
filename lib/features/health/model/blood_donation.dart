import 'package:flutter/foundation.dart';

import 'medical_profile.dart';

/// Where someone stands on giving blood again.
///
/// Kept as pure data so the countdown, the badge on the card and the reminder
/// all read the same answer instead of each doing the arithmetic their own way.
@immutable
class DonationStatus {
  const DonationStatus({
    required this.profileId,
    required this.name,
    required this.lastDonation,
    required this.eligibleOn,
    required this.daysRemaining,
  });

  final String profileId;
  final String name;

  /// Null when nothing has been recorded yet.
  final DateTime? lastDonation;

  /// Null when nothing has been recorded — there is nothing to count towards.
  final DateTime? eligibleOn;

  /// Days until eligible; zero or less means eligible now.
  final int daysRemaining;

  bool get isEligible => lastDonation == null || daysRemaining <= 0;

  /// The standard wait between whole-blood donations. Deliberately the
  /// conservative end of what blood services ask for — a countdown that says
  /// "go" a fortnight early would send somebody on a wasted trip.
  static const int intervalDays = 90;

  /// Reads [profile]'s donation state as of [now].
  static DonationStatus of(MedicalProfile profile, {DateTime? now}) {
    final DateTime today = _dateOnly(now ?? DateTime.now());
    final DateTime? last = profile.lastDonation;
    if (last == null) {
      return DonationStatus(
        profileId: profile.id,
        name: profile.name,
        lastDonation: null,
        eligibleOn: null,
        daysRemaining: 0,
      );
    }
    final DateTime eligible =
        _dateOnly(last).add(const Duration(days: intervalDays));
    return DonationStatus(
      profileId: profile.id,
      name: profile.name,
      lastDonation: last,
      eligibleOn: eligible,
      daysRemaining: eligible.difference(today).inDays,
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
