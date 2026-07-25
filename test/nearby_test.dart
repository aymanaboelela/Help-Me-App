import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/maps.dart';
import 'package:help_me/features/health/model/blood_donation.dart';
import 'package:help_me/features/health/model/medical_profile.dart';
import 'package:help_me/services/reminder_plan.dart';
import 'package:help_me/services/reminder_service.dart';

void main() {
  group('NearbyPlace', () {
    test('Given Arabic, Then the search term is Arabic', () {
      expect(NearbyPlace.pharmacy.query('ar'), 'صيدلية');
      expect(NearbyPlace.bloodBank.query('ar'), 'بنك دم');
    });

    test('Given any other language, Then the term falls back to English', () {
      expect(NearbyPlace.pharmacy.query('en'), 'pharmacy');
      expect(NearbyPlace.hospital.query('fr'), 'hospital');
    });

    test('Given every place, Then both terms are filled in', () {
      for (final NearbyPlace place in NearbyPlace.values) {
        expect(place.en.trim(), isNotEmpty, reason: place.name);
        expect(place.ar.trim(), isNotEmpty, reason: place.name);
      }
    });
  });

  group('DonationStatus', () {
    final DateTime today = DateTime(2026, 7, 25);

    test('Given no record, Then the person counts as able to donate', () {
      final DonationStatus status = DonationStatus.of(
        const MedicalProfile(id: 'p1', name: 'Ayman'),
        now: today,
      );

      expect(status.lastDonation, isNull);
      expect(status.eligibleOn, isNull);
      expect(status.isEligible, isTrue);
    });

    test('Given a donation today, Then the full interval remains', () {
      final DonationStatus status = DonationStatus.of(
        MedicalProfile(id: 'p1', name: 'Ayman', lastDonation: today),
        now: today,
      );

      expect(status.daysRemaining, DonationStatus.intervalDays);
      expect(status.isEligible, isFalse);
      expect(status.eligibleOn, DateTime(2026, 10, 23));
    });

    test('Given the interval has passed, Then they are eligible again', () {
      final DonationStatus status = DonationStatus.of(
        MedicalProfile(
          id: 'p1',
          name: 'Ayman',
          lastDonation: today.subtract(const Duration(days: 91)),
        ),
        now: today,
      );

      expect(status.daysRemaining, lessThanOrEqualTo(0));
      expect(status.isEligible, isTrue);
    });

    test('Given the day the interval ends, Then they are eligible', () {
      final DonationStatus status = DonationStatus.of(
        MedicalProfile(
          id: 'p1',
          name: 'Ayman',
          lastDonation:
              today.subtract(const Duration(days: DonationStatus.intervalDays)),
        ),
        now: today,
      );

      expect(status.daysRemaining, 0);
      expect(status.isEligible, isTrue);
    });

    test('Given a time of day on the record, Then only the date counts', () {
      final DonationStatus lateNight = DonationStatus.of(
        MedicalProfile(
          id: 'p1',
          name: 'Ayman',
          lastDonation: DateTime(2026, 7, 25, 23, 59),
        ),
        now: DateTime(2026, 7, 25, 0, 1),
      );

      expect(lateNight.daysRemaining, DonationStatus.intervalDays);
    });
  });

  group('planDonationReminders', () {
    final DateTime now = DateTime(2026, 7, 25);

    List<DonationStatus> statuses(List<MedicalProfile> profiles) => <DonationStatus>[
          for (final MedicalProfile p in profiles) DonationStatus.of(p, now: now),
        ];

    test('Given someone still waiting, Then a reminder is planned for that day', () {
      final List<Reminder> planned = planDonationReminders(
        statuses(<MedicalProfile>[
          MedicalProfile(
            id: 'p1',
            name: 'Ayman',
            lastDonation: now.subtract(const Duration(days: 30)),
          ),
        ]),
        title: 'You can give blood again',
        now: now,
      );

      expect(planned, hasLength(1));
      expect(planned.single.id, donationReminderId('p1'));
      expect(planned.single.body, 'Ayman');
      expect(planned.single.when.isAfter(now), isTrue);
      expect(planned.single.repeatDaily, isFalse);
    });

    test('Given nobody has recorded a donation, Then nothing is planned', () {
      final List<Reminder> planned = planDonationReminders(
        statuses(<MedicalProfile>[const MedicalProfile(id: 'p1', name: 'Ayman')]),
        title: 'ready',
        now: now,
      );
      expect(planned, isEmpty);
    });

    test('Given someone already eligible, Then no reminder is planned', () {
      final List<Reminder> planned = planDonationReminders(
        statuses(<MedicalProfile>[
          MedicalProfile(
            id: 'p1',
            name: 'Ayman',
            lastDonation: now.subtract(const Duration(days: 200)),
          ),
        ]),
        title: 'ready',
        now: now,
      );
      expect(planned, isEmpty);
    });

    test('Given several people, Then each gets their own notification id', () {
      final List<Reminder> planned = planDonationReminders(
        statuses(<MedicalProfile>[
          MedicalProfile(
            id: 'p1',
            name: 'Ayman',
            lastDonation: now.subtract(const Duration(days: 10)),
          ),
          MedicalProfile(
            id: 'p2',
            name: 'Salma',
            lastDonation: now.subtract(const Duration(days: 20)),
          ),
        ]),
        title: 'ready',
        now: now,
      );

      expect(planned, hasLength(2));
      expect(planned.map((Reminder r) => r.id).toSet(), hasLength(2));
    });
  });
}
