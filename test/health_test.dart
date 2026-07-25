import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/features/health/data/kit_catalogue.dart';
import 'package:help_me/features/health/model/medical_profile.dart';
import 'package:help_me/features/health/model/medicine.dart';
import 'package:help_me/providers/health_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/services/reminder_plan.dart';
import 'package:help_me/services/reminder_service.dart';
import 'package:help_me/services/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([
  Map<String, Object> seed = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

ProviderContainer _container({
  required SharedPreferences prefs,
  InMemorySecureStore? store,
  FakeReminders? reminders,
  HealthSnapshot snapshot = const HealthSnapshot(),
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(store ?? InMemorySecureStore()),
      remindersProvider.overrideWithValue(reminders ?? FakeReminders()),
      healthSnapshotProvider.overrideWithValue(snapshot),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('MedicalProfile', () {
    test('Given a full profile, When encoded and decoded, Then it round-trips', () {
      final MedicalProfile profile = MedicalProfile(
        id: 'p1',
        name: 'Ayman',
        bloodType: BloodType.oPos,
        birthDate: DateTime(1990, 5, 4),
        allergies: const <String>['Penicillin'],
        conditions: const <String>['Asthma'],
        medications: const <String>['Ventolin'],
        doctorName: 'Dr Salma',
        doctorPhone: '0100000000',
        insurance: 'Misr',
        notes: 'Carries an inhaler',
        lastDonation: DateTime(2026, 1, 2),
      );

      final MedicalProfile back =
          MedicalProfile.fromJson(jsonDecode(jsonEncode(profile.toJson())) as Map<String, dynamic>);

      expect(back.name, 'Ayman');
      expect(back.bloodType, BloodType.oPos);
      expect(back.birthDate, DateTime(1990, 5, 4));
      expect(back.allergies, <String>['Penicillin']);
      expect(back.doctorPhone, '0100000000');
      expect(back.lastDonation, DateTime(2026, 1, 2));
    });

    test('Given junk in stored lists, When decoded, Then blanks are dropped', () {
      final MedicalProfile back = MedicalProfile.fromJson(<String, dynamic>{
        'id': 'p1',
        'name': 'Test',
        'allergies': <Object?>['Nuts', '', '   ', 7, null],
        'bloodType': 'not_a_blood_type',
      });

      expect(back.allergies, <String>['Nuts']);
      expect(back.bloodType, BloodType.unknown);
    });

    test('Given a birth date, Then age counts whole years only', () {
      final DateTime now = DateTime.now();
      final MedicalProfile justTurned = MedicalProfile(
        id: 'a',
        name: 'A',
        birthDate: DateTime(now.year - 30, now.month, now.day),
      );
      final MedicalProfile notYet = MedicalProfile(
        id: 'b',
        name: 'B',
        birthDate: DateTime(now.year - 30, now.month, now.day).add(const Duration(days: 1)),
      );

      expect(justTurned.age, 30);
      expect(notYet.age, 29);
    });

    test('Given no birth date, Then age is null', () {
      expect(const MedicalProfile(id: 'a', name: 'A').age, isNull);
    });
  });

  group('Medicine expiry', () {
    Medicine withExpiry(int daysFromNow) {
      final DateTime now = DateTime.now();
      return Medicine(
        id: 'm',
        name: 'Test',
        expiry: DateTime(now.year, now.month, now.day).add(Duration(days: daysFromNow)),
      );
    }

    test('Given a date in the past, Then it reads as expired', () {
      expect(withExpiry(-1).isExpired, isTrue);
      expect(withExpiry(-1).expiresSoon, isFalse);
    });

    test('Given today, Then it is neither expired nor safe', () {
      expect(withExpiry(0).isExpired, isFalse);
      expect(withExpiry(0).expiresSoon, isTrue);
      expect(withExpiry(0).daysUntilExpiry, 0);
    });

    test('Given a date inside the warning window, Then it expires soon', () {
      expect(withExpiry(Medicine.expiryWarningDays).expiresSoon, isTrue);
      expect(withExpiry(Medicine.expiryWarningDays + 1).expiresSoon, isFalse);
    });

    test('Given no expiry date, Then nothing is flagged', () {
      const Medicine none = Medicine(id: 'm', name: 'Test');
      expect(none.daysUntilExpiry, isNull);
      expect(none.isExpired, isFalse);
      expect(none.expiresSoon, isFalse);
    });

    test('Given out-of-range dose times, When decoded, Then they are dropped', () {
      final Medicine back = Medicine.fromJson(<String, dynamic>{
        'id': 'm',
        'name': 'Test',
        'dailyTimes': <Object?>[540, -1, 1440, 1439, 'noon'],
      });
      expect(back.dailyTimes, <int>[540, 1439]);
    });
  });

  group('stableNotificationId', () {
    test('Given the same key, Then the id is identical every time', () {
      expect(stableNotificationId('dose:m1:0'), stableNotificationId('dose:m1:0'));
    });

    test('Given different keys, Then the ids differ', () {
      expect(
        stableNotificationId('dose:m1:0'),
        isNot(stableNotificationId('dose:m1:1')),
      );
      expect(
        stableNotificationId('dose:m1:0'),
        isNot(stableNotificationId('expiry:m1')),
      );
    });

    test('Given any key, Then the id fits a positive 32-bit int', () {
      for (final String key in <String>['a', 'dose:xyz:7', 'expiry:long-id-here']) {
        final int id = stableNotificationId(key);
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThan(0x80000000));
      }
    });
  });

  group('HealthSnapshot.load', () {
    test('Given empty storage, Then it loads nothing', () async {
      final HealthSnapshot snapshot = await HealthSnapshot.load(InMemorySecureStore());
      expect(snapshot.profiles, isEmpty);
      expect(snapshot.medicines, isEmpty);
    });

    test('Given corrupt storage, Then it starts clean instead of throwing', () async {
      final InMemorySecureStore store = InMemorySecureStore(<String, String>{
        HealthKeys.profiles: 'not json at all',
        HealthKeys.medicines: '{"not":"a list"}',
      });
      final HealthSnapshot snapshot = await HealthSnapshot.load(store);
      expect(snapshot.profiles, isEmpty);
      expect(snapshot.medicines, isEmpty);
    });

    test('Given stored profiles, Then they come back', () async {
      final InMemorySecureStore store = InMemorySecureStore(<String, String>{
        HealthKeys.profiles: jsonEncode(<Map<String, dynamic>>[
          const MedicalProfile(id: 'p1', name: 'Ayman', bloodType: BloodType.aPos).toJson(),
        ]),
      });
      final HealthSnapshot snapshot = await HealthSnapshot.load(store);
      expect(snapshot.profiles.single.name, 'Ayman');
      expect(snapshot.profiles.single.bloodType, BloodType.aPos);
    });
  });

  group('ProfilesNotifier', () {
    test('Given a new profile, Then it is stored encrypted and readable back', () async {
      final InMemorySecureStore store = InMemorySecureStore();
      final ProviderContainer container =
          _container(prefs: await _prefs(), store: store);

      await container
          .read(profilesProvider.notifier)
          .save(const MedicalProfile(id: 'p1', name: 'Ayman', bloodType: BloodType.oNeg));

      expect(container.read(profilesProvider).single.name, 'Ayman');
      final HealthSnapshot reloaded = await HealthSnapshot.load(store);
      expect(reloaded.profiles.single.bloodType, BloodType.oNeg);
    });

    test('Given an existing id, When saved again, Then it replaces rather than duplicates', () async {
      final ProviderContainer container = _container(prefs: await _prefs());
      final ProfilesNotifier notifier = container.read(profilesProvider.notifier);

      await notifier.save(const MedicalProfile(id: 'p1', name: 'Ayman'));
      await notifier.save(const MedicalProfile(id: 'p1', name: 'Ayman Abo El Ela'));

      expect(container.read(profilesProvider).length, 1);
      expect(container.read(profilesProvider).single.name, 'Ayman Abo El Ela');
    });

    test('Given the maximum is reached, Then further cards are ignored', () async {
      final ProviderContainer container = _container(prefs: await _prefs());
      final ProfilesNotifier notifier = container.read(profilesProvider.notifier);

      for (int i = 0; i < ProfilesNotifier.maxProfiles + 3; i++) {
        await notifier.save(MedicalProfile(id: 'p$i', name: 'Person $i'));
      }

      expect(container.read(profilesProvider).length, ProfilesNotifier.maxProfiles);
    });

    test('Given a removal, Then it disappears from state and storage', () async {
      final InMemorySecureStore store = InMemorySecureStore();
      final ProviderContainer container =
          _container(prefs: await _prefs(), store: store);
      final ProfilesNotifier notifier = container.read(profilesProvider.notifier);

      await notifier.save(const MedicalProfile(id: 'p1', name: 'Ayman'));
      await notifier.remove('p1');

      expect(container.read(profilesProvider), isEmpty);
      expect((await HealthSnapshot.load(store)).profiles, isEmpty);
    });
  });

  group('MedicinesNotifier reminders', () {
    test('Given dose times, Then one repeating reminder is scheduled per time', () async {
      final FakeReminders reminders = FakeReminders();
      final ProviderContainer container =
          _container(prefs: await _prefs(), reminders: reminders);

      await container.read(medicinesProvider.notifier).save(
            const Medicine(id: 'm1', name: 'Ventolin', dailyTimes: <int>[480, 1200]),
            doseTitle: 'Dose',
            expiryTitle: 'Expiring',
          );

      expect(reminders.scheduled.length, 2);
      expect(reminders.scheduled.values.every((Reminder r) => r.repeatDaily), isTrue);
      expect(
        reminders.scheduled.containsKey(doseReminderId('m1', 0)),
        isTrue,
      );
    });

    test('Given an expiry date, Then a warning is scheduled before it', () async {
      final FakeReminders reminders = FakeReminders();
      final ProviderContainer container =
          _container(prefs: await _prefs(), reminders: reminders);
      final DateTime expiry = DateTime.now().add(const Duration(days: 365));

      await container.read(medicinesProvider.notifier).save(
            Medicine(id: 'm1', name: 'Antiseptic', expiry: expiry),
            doseTitle: 'Dose',
            expiryTitle: 'Expiring',
          );

      final Reminder? warning =
          reminders.scheduled[expiryReminderId('m1')];
      expect(warning, isNotNull);
      expect(warning!.repeatDaily, isFalse);
      expect(warning.when.isBefore(expiry), isTrue);
      expect(
        expiry.difference(warning.when).inDays,
        closeTo(Medicine.expiryWarningDays, 1),
      );
    });

    test('Given fewer dose times than before, Then the dropped ones are cancelled', () async {
      final FakeReminders reminders = FakeReminders();
      final ProviderContainer container =
          _container(prefs: await _prefs(), reminders: reminders);
      final MedicinesNotifier notifier = container.read(medicinesProvider.notifier);

      await notifier.save(
        const Medicine(id: 'm1', name: 'Ventolin', dailyTimes: <int>[480, 1200]),
        doseTitle: 'Dose',
        expiryTitle: 'Expiring',
      );
      await notifier.save(
        const Medicine(id: 'm1', name: 'Ventolin', dailyTimes: <int>[480]),
        doseTitle: 'Dose',
        expiryTitle: 'Expiring',
      );

      expect(reminders.scheduled.length, 1);
      expect(
        reminders.scheduled.containsKey(doseReminderId('m1', 1)),
        isFalse,
      );
    });

    test('Given a removal, Then every reminder for it is cancelled', () async {
      final FakeReminders reminders = FakeReminders();
      final ProviderContainer container =
          _container(prefs: await _prefs(), reminders: reminders);
      final MedicinesNotifier notifier = container.read(medicinesProvider.notifier);

      await notifier.save(
        Medicine(
          id: 'm1',
          name: 'Ventolin',
          dailyTimes: const <int>[480],
          expiry: DateTime.now().add(const Duration(days: 200)),
        ),
        doseTitle: 'Dose',
        expiryTitle: 'Expiring',
      );
      await notifier.remove('m1');

      expect(container.read(medicinesProvider), isEmpty);
      expect(reminders.scheduled, isEmpty);
      expect(
        reminders.cancelled,
        contains(expiryReminderId('m1')),
      );
    });

    test('Given permission is refused, Then saving still works and nothing schedules', () async {
      final FakeReminders reminders = FakeReminders(permitted: false);
      final ProviderContainer container =
          _container(prefs: await _prefs(), reminders: reminders);

      await container.read(medicinesProvider.notifier).save(
            const Medicine(id: 'm1', name: 'Ventolin', dailyTimes: <int>[480]),
            doseTitle: 'Dose',
            expiryTitle: 'Expiring',
          );

      expect(container.read(medicinesProvider).single.name, 'Ventolin');
      expect(reminders.scheduled, isEmpty);
    });
  });

  group('expiringMedicinesProvider', () {
    test('Given a mix, Then only the urgent ones surface, worst first', () async {
      final DateTime today = DateTime.now();
      DateTime inDays(int d) =>
          DateTime(today.year, today.month, today.day).add(Duration(days: d));

      final ProviderContainer container = _container(
        prefs: await _prefs(),
        snapshot: HealthSnapshot(
          medicines: <Medicine>[
            Medicine(id: 'safe', name: 'Safe', expiry: inDays(400)),
            Medicine(id: 'soon', name: 'Soon', expiry: inDays(10)),
            Medicine(id: 'gone', name: 'Gone', expiry: inDays(-5)),
            const Medicine(id: 'none', name: 'No date'),
          ],
        ),
      );

      final List<Medicine> flagged = container.read(expiringMedicinesProvider);
      expect(flagged.map((Medicine m) => m.id), <String>['gone', 'soon']);
    });
  });

  group('KitNotifier', () {
    test('Given a toggle, Then it flips and persists', () async {
      final SharedPreferences prefs = await _prefs();
      final ProviderContainer container = _container(prefs: prefs);
      final KitNotifier notifier = container.read(kitProvider.notifier);

      await notifier.toggle('gloves');
      expect(container.read(kitProvider), contains('gloves'));
      expect(prefs.getStringList(HealthKeys.kit), contains('gloves'));

      await notifier.toggle('gloves');
      expect(container.read(kitProvider), isEmpty);
      expect(prefs.getStringList(HealthKeys.kit), isEmpty);
    });
  });

  group('First-aid kit catalogue', () {
    test('Given the catalogue, Then every id is unique', () {
      final List<String> ids = kKitCatalogue.map((KitItem i) => i.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('Given every item, Then its text is bilingual and complete', () {
      for (final KitItem item in kKitCatalogue) {
        expect(item.name.isComplete, isTrue, reason: item.id);
        if (item.note != null) {
          expect(item.note!.isComplete, isTrue, reason: '${item.id}: note');
        }
      }
    });

    test('Given the grouping, Then every section has items and nothing is lost', () {
      final Map<KitSection, List<KitItem>> grouped = kKitBySection;
      expect(grouped.keys.length, KitSection.values.length);
      for (final KitSection section in KitSection.values) {
        expect(grouped[section], isNotEmpty, reason: section.name);
      }
      expect(
        grouped.values.fold<int>(0, (int sum, List<KitItem> l) => sum + l.length),
        kKitCatalogue.length,
      );
    });
  });
}
