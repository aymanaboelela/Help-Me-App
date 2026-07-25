import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/features/health/model/medicine.dart';
import 'package:help_me/features/learn/data/daily_tips.dart';
import 'package:help_me/features/learn/data/tip_of_day.dart';
import 'package:help_me/features/learn/model/learn_content.dart';
import 'package:help_me/providers/health_provider.dart';
import 'package:help_me/providers/learn_provider.dart';
import 'package:help_me/providers/notification_prefs_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/providers/reminder_sync_provider.dart';
import 'package:help_me/services/reminder_plan.dart';
import 'package:help_me/services/reminder_service.dart';
import 'package:help_me/services/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FakeReminders reminders;

  Future<ProviderContainer> makeContainer({
    Map<String, Object> seed = const <String, Object>{},
    List<Medicine> medicines = const <Medicine>[],
    bool permitted = true,
  }) async {
    SharedPreferences.setMockInitialValues(seed);
    reminders = FakeReminders(permitted: permitted);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        secureStoreProvider.overrideWithValue(InMemorySecureStore()),
        healthSnapshotProvider.overrideWithValue(
          HealthSnapshot(medicines: medicines),
        ),
        remindersProvider.overrideWithValue(reminders),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  const Medicine twiceDaily = Medicine(
    id: 'm1',
    name: 'Panadol',
    dose: '500 mg',
    dailyTimes: <int>[8 * 60, 20 * 60],
  );

  group('planMedicineReminders', () {
    final DateTime noon = DateTime(2026, 7, 25, 12);

    List<Reminder> plan(Medicine medicine, NotificationPrefs prefs) =>
        planMedicineReminders(
          medicine,
          prefs: prefs,
          doseTitle: 'Dose',
          expiryTitle: 'Expiring',
          now: noon,
        );

    test('Given both switches on, Then every dose and the expiry are planned', () {
      final List<Reminder> planned = plan(
        twiceDaily.copyWith(expiry: DateTime(2026, 12, 1)),
        const NotificationPrefs(),
      );
      expect(planned, hasLength(3));
      expect(
        planned.map((Reminder r) => r.id),
        containsAll(<int>[
          doseReminderId('m1', 0),
          doseReminderId('m1', 1),
          expiryReminderId('m1'),
        ]),
      );
    });

    test('Given doses switched off, Then only the expiry survives', () {
      final List<Reminder> planned = plan(
        twiceDaily.copyWith(expiry: DateTime(2026, 12, 1)),
        const NotificationPrefs(doses: false),
      );
      expect(planned, hasLength(1));
      expect(planned.single.id, expiryReminderId('m1'));
    });

    test('Given expiry switched off, Then only the doses survive', () {
      final List<Reminder> planned = plan(
        twiceDaily.copyWith(expiry: DateTime(2026, 12, 1)),
        const NotificationPrefs(expiry: false),
      );
      expect(planned, hasLength(2));
      expect(planned.every((Reminder r) => r.repeatDaily), isTrue);
    });

    test('Given both off, Then nothing is planned', () {
      expect(
        plan(
          twiceDaily.copyWith(expiry: DateTime(2026, 12, 1)),
          const NotificationPrefs(doses: false, expiry: false),
        ),
        isEmpty,
      );
    });

    test('Given a dose time already gone by today, Then it moves to tomorrow', () {
      final List<Reminder> planned = plan(twiceDaily, const NotificationPrefs());
      final Reminder morning = planned.firstWhere(
        (Reminder r) => r.id == doseReminderId('m1', 0),
      );
      final Reminder evening = planned.firstWhere(
        (Reminder r) => r.id == doseReminderId('m1', 1),
      );
      expect(morning.when, DateTime(2026, 7, 26, 8)); // 08:00 had passed at noon.
      expect(evening.when, DateTime(2026, 7, 25, 20));
    });

    test('Given the expiry date, Then the warning lands the month before', () {
      final List<Reminder> planned = plan(
        const Medicine(id: 'm1', name: 'Panadol', expiry: null)
            .copyWith(expiry: DateTime(2026, 12, 1)),
        const NotificationPrefs(),
      );
      expect(
        planned.single.when,
        DateTime(2026, 12, 1 - Medicine.expiryWarningDays, 9),
      );
    });

    test('Given more dose times than slots, Then the extras are dropped', () {
      final Medicine crowded = Medicine(
        id: 'm1',
        name: 'Panadol',
        dailyTimes: List<int>.generate(NotificationPrefs.maxDoseSlots + 3, (int i) => i * 60),
      );
      expect(
        plan(crowded, const NotificationPrefs()),
        hasLength(NotificationPrefs.maxDoseSlots),
      );
    });

    test('Given a dose with no strength, Then the body is just the name', () {
      final List<Reminder> planned = plan(
        const Medicine(id: 'm1', name: 'Panadol', dailyTimes: <int>[20 * 60]),
        const NotificationPrefs(),
      );
      expect(planned.single.body, 'Panadol');
    });
  });

  group('planTipReminder', () {
    final DateTime noon = DateTime(2026, 7, 25, 12);

    test('Given no time set, Then nothing is planned', () {
      expect(
        planTipReminder(tipMinutes: null, title: 'Tip', now: noon),
        isEmpty,
      );
    });

    test('Given a time still to come today, Then it repeats from today', () {
      final Reminder tip =
          planTipReminder(tipMinutes: 20 * 60, title: 'Tip', now: noon).single;
      expect(tip.when, DateTime(2026, 7, 25, 20));
      expect(tip.repeatDaily, isTrue);
    });

    test('Given a time already gone by, Then it repeats from tomorrow', () {
      final Reminder tip =
          planTipReminder(tipMinutes: 8 * 60, title: 'Tip', now: noon).single;
      expect(tip.when, DateTime(2026, 7, 26, 8));
    });

    test('Given the tip notifier, Then both use one notification id', () {
      expect(TipReminderNotifier.notificationId, tipReminderNotificationId);
    });
  });

  group('tipForDate', () {
    test('Given the same day, Then the tip is the same', () {
      expect(
        tipForDate(DateTime(2026, 7, 25, 6)).id,
        tipForDate(DateTime(2026, 7, 25, 23)).id,
      );
    });

    test('Given consecutive days, Then the tip moves on', () {
      expect(
        tipForDate(DateTime(2026, 7, 25)).id,
        isNot(tipForDate(DateTime(2026, 7, 26)).id),
      );
    });

    test('Given a month of days, Then no tip repeats', () {
      final Set<String> ids = <String>{
        for (int day = 0; day < 28; day++)
          tipForDate(DateTime(2026, 7, 1).add(Duration(days: day))).id,
      };
      expect(ids, hasLength(28));
    });

    test('Given the last day of a year, Then it still resolves', () {
      expect(kDailyTips, contains(tipForDate(DateTime(2026, 12, 31))));
    });

    test('Given the screen and the notification, Then they agree on today', () async {
      final ProviderContainer container = await makeContainer();
      final DailyTip onScreen = container.read(dailyTipProvider);
      expect(onScreen.id, tipForDate(DateTime.now()).id);
    });
  });

  group('NotificationPrefsNotifier', () {
    test('Given nothing stored, Then medicine reminders are on', () async {
      final ProviderContainer container = await makeContainer();
      final NotificationPrefs prefs = container.read(notificationPrefsProvider);
      expect(prefs.doses, isTrue);
      expect(prefs.expiry, isTrue);
    });

    test('Given a switch turned off, Then it is stored and read back', () async {
      final ProviderContainer container = await makeContainer();
      await container.read(notificationPrefsProvider.notifier).setDoses(false);
      expect(container.read(notificationPrefsProvider).doses, isFalse);

      final ProviderContainer reopened = await makeContainer(
        seed: <String, Object>{NotificationKeys.doses: false},
      );
      expect(reopened.read(notificationPrefsProvider).doses, isFalse);
    });
  });

  group('ReminderSync', () {
    test('Given medicines and a tip time, Then everything is rescheduled', () async {
      final ProviderContainer container = await makeContainer(
        seed: <String, Object>{LearnKeys.tipMinute: 20 * 60},
        medicines: <Medicine>[twiceDaily.copyWith(expiry: DateTime(2030, 1, 1))],
      );

      final bool ok = await container.read(reminderSyncProvider).rebuildAll();
      expect(ok, isTrue);
      expect(
        reminders.scheduled.keys,
        containsAll(<int>[
          doseReminderId('m1', 0),
          doseReminderId('m1', 1),
          expiryReminderId('m1'),
          tipReminderNotificationId,
        ]),
      );
    });

    test('Given a rebuild, Then stale reminders are cancelled first', () async {
      final ProviderContainer container = await makeContainer(
        medicines: <Medicine>[twiceDaily],
      );
      await reminders.schedule(
        Reminder(id: 999, title: 'Old', body: '', when: DateTime(2030, 1, 1)),
      );

      await container.read(reminderSyncProvider).rebuildAll();
      expect(reminders.scheduled.containsKey(999), isFalse);
    });

    test('Given the doses switch off, Then no dose reminder is booked', () async {
      final ProviderContainer container = await makeContainer(
        seed: <String, Object>{NotificationKeys.doses: false},
        medicines: <Medicine>[twiceDaily],
      );

      await container.read(reminderSyncProvider).rebuildAll();
      expect(reminders.scheduled, isEmpty);
    });

    test('Given no tip time, Then no tip reminder is booked', () async {
      final ProviderContainer container = await makeContainer(
        medicines: <Medicine>[twiceDaily],
      );

      await container.read(reminderSyncProvider).rebuildAll();
      expect(reminders.scheduled.containsKey(tipReminderNotificationId), isFalse);
    });

    test('Given permission refused while turning one on, Then it reports failure',
        () async {
      final ProviderContainer container = await makeContainer(
        medicines: <Medicine>[twiceDaily],
        permitted: false,
      );

      final bool ok = await container
          .read(reminderSyncProvider)
          .rebuildAll(requestPermission: true);
      expect(ok, isFalse);
      expect(reminders.scheduled, isEmpty);
    });

    test('Given nothing to schedule, Then it succeeds without asking', () async {
      final ProviderContainer container = await makeContainer(permitted: false);
      expect(
        await container.read(reminderSyncProvider).rebuildAll(requestPermission: true),
        isTrue,
      );
    });
  });
}
