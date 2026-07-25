import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/features/health/data/kit_catalogue.dart';
import 'package:help_me/features/health/model/medical_profile.dart';
import 'package:help_me/features/health/model/medicine.dart';
import 'package:help_me/features/health/presentation/emergency_card_screen.dart';
import 'package:help_me/features/health/presentation/health_screen.dart';
import 'package:help_me/features/health/presentation/kit_screen.dart';
import 'package:help_me/features/health/presentation/medicines_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/health_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/services/reminder_service.dart';
import 'package:help_me/services/secure_store.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget child, {
  HealthSnapshot snapshot = const HealthSnapshot(),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1400, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(InMemorySecureStore()),
      remindersProvider.overrideWithValue(FakeReminders()),
      healthSnapshotProvider.overrideWithValue(snapshot),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('The health hub lists the three areas and says where data lives',
      (WidgetTester tester) async {
    await _pump(tester, const HealthScreen());

    expect(find.text('Medical cards'), findsOneWidget);
    expect(find.text('Medicine cabinet'), findsOneWidget);
    expect(find.text('First-aid kit'), findsOneWidget);
    expect(find.textContaining('Stored on this phone only'), findsOneWidget);
  });

  testWidgets('An expiring medicine raises an alert on the hub',
      (WidgetTester tester) async {
    final DateTime soon = DateTime.now().add(const Duration(days: 3));
    await _pump(
      tester,
      const HealthScreen(),
      snapshot: HealthSnapshot(
        medicines: <Medicine>[Medicine(id: 'm1', name: 'Antiseptic', expiry: soon)],
      ),
    );

    expect(find.textContaining('needs attention'), findsOneWidget);
  });

  testWidgets('The emergency card shows blood type, allergies and a QR code',
      (WidgetTester tester) async {
    await _pump(
      tester,
      const EmergencyCardScreen(profileId: 'p1'),
      snapshot: const HealthSnapshot(
        profiles: <MedicalProfile>[
          MedicalProfile(
            id: 'p1',
            name: 'Ayman',
            bloodType: BloodType.oNeg,
            allergies: <String>['Penicillin'],
            conditions: <String>['Asthma'],
          ),
        ],
      ),
    );

    expect(find.text('Ayman'), findsOneWidget);
    expect(find.text('O−'), findsOneWidget);
    expect(find.text('Penicillin'), findsOneWidget);
    expect(find.text('Asthma'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('A missing profile does not crash the emergency card',
      (WidgetTester tester) async {
    await _pump(tester, const EmergencyCardScreen(profileId: 'gone'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('The medicine cabinet starts empty and explains why it matters',
      (WidgetTester tester) async {
    await _pump(tester, const MedicinesScreen());

    expect(find.text('Nothing in the cabinet'), findsOneWidget);
    expect(find.text('Add a medicine'), findsOneWidget);
  });

  testWidgets('Ticking a kit item moves the readiness count',
      (WidgetTester tester) async {
    final ProviderContainer container = await _pump(tester, const KitScreen());

    expect(find.text('0 of ${kKitCatalogue.length} ready'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(container.read(kitProvider).length, 1);
    expect(find.text('1 of ${kKitCatalogue.length} ready'), findsOneWidget);
  });

  testWidgets('The kit renders in Arabic', (WidgetTester tester) async {
    await _pump(tester, const KitScreen(), locale: const Locale('ar'));

    expect(find.text('شنطة الإسعاف'), findsOneWidget);
    expect(find.text('الضمادات'), findsOneWidget);
  });

  group('EmergencyCardScreen.encode', () {
    testWidgets('Given a profile, Then the QR payload is readable plain text',
        (WidgetTester tester) async {
      late String payload;
      await _pump(
        tester,
        Builder(
          builder: (BuildContext context) {
            payload = EmergencyCardScreen.encode(
              const MedicalProfile(
                id: 'p1',
                name: 'Ayman',
                bloodType: BloodType.aPos,
                allergies: <String>['Penicillin', 'Peanuts'],
              ),
              AppLocalizations.of(context),
            );
            return const SizedBox.shrink();
          },
        ),
      );

      expect(payload, contains('Ayman'));
      expect(payload, contains('A+'));
      expect(payload, contains('Penicillin, Peanuts'));
      expect(payload, isNot(contains('Conditions')));
    });
  });
}
