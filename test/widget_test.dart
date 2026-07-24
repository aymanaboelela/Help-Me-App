import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/root_scaffold.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/features/home/home_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/favorites_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([
  Map<String, Object> seed = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget child, {
  required SharedPreferences prefs,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1400, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
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
  testWidgets('Home shows the SOS banner and topic cards', (WidgetTester tester) async {
    await _pump(tester, const HomeScreen(), prefs: await _prefs());

    expect(find.text('Call 123'), findsOneWidget);
    expect(find.text('Swallowed tongue'), findsOneWidget);
    expect(find.text('Fainting'), findsOneWidget);
  });

  testWidgets('Searching filters the topic list', (WidgetTester tester) async {
    await _pump(tester, const HomeScreen(), prefs: await _prefs());

    expect(find.text('Fainting'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'cpr');
    await tester.pumpAndSettle();

    expect(find.text('CPR (resuscitation)'), findsOneWidget);
    expect(find.text('Fainting'), findsNothing);
  });

  testWidgets('Tapping a topic opens its detail with steps', (WidgetTester tester) async {
    await _pump(tester, const HomeScreen(), prefs: await _prefs());

    await tester.tap(find.text('Burns'));
    await tester.pumpAndSettle();

    expect(find.text('Minor burns without blisters'), findsOneWidget);
    expect(find.text('Call ambulance · 123'), findsOneWidget);
  });

  testWidgets('Tapping the heart favorites a topic', (WidgetTester tester) async {
    final ProviderContainer container =
        await _pump(tester, const HomeScreen(), prefs: await _prefs());

    expect(container.read(favoritesProvider), isEmpty);
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();
    expect(container.read(favoritesProvider), isNotEmpty);
  });

  testWidgets('Arabic locale renders RTL and Arabic content', (WidgetTester tester) async {
    await _pump(
      tester,
      const HomeScreen(),
      prefs: await _prefs(),
      locale: const Locale('ar'),
    );

    expect(find.text('ماذا حدث؟'), findsOneWidget);
    final TextDirection direction =
        Directionality.of(tester.element(find.text('ماذا حدث؟')));
    expect(direction, TextDirection.rtl);
  });

  testWidgets('First launch shows the disclaimer', (WidgetTester tester) async {
    await _pump(tester, const RootScaffold(), prefs: await _prefs());
    expect(find.text('Before you start'), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);
  });

  testWidgets('An accepted launch hides the disclaimer', (WidgetTester tester) async {
    await _pump(
      tester,
      const RootScaffold(),
      prefs: await _prefs(<String, Object>{'settings.disclaimer_accepted': true}),
    );
    expect(find.text('Before you start'), findsNothing);
    expect(find.text('Home'), findsWidgets);
  });
}
