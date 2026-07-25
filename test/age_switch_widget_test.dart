import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/conditions/presentation/condition_detail_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gives the test a surface tall enough to build the whole condition screen.
///
/// The screen is a lazy [ListView]: on the default 800x600 surface the age
/// switch and the steps below it are never built, so a finder that should match
/// finds nothing and the test lies about what the screen does.
void _tallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<Widget> _app(Widget home, {Locale locale = const Locale('en')}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

/// A trivial home screen with one button that pushes the condition screen, so a
/// test can leave it and come back the way a user does.
class _OpenerHome extends StatelessWidget {
  const _OpenerHome({required this.topic});

  final FirstAidTopic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (BuildContext inner) => TextButton(
            onPressed: () =>
                Navigator.of(inner).push(ConditionDetailScreen.route(topic)),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }
}

void main() {
  final FirstAidTopic cpr = topicById('cpr')!;
  final FirstAidTopic bleeding = topicById('bleeding')!;

  testWidgets('Given a topic with variants, Then the switch is shown',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.text('Adult'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
    expect(find.text('Infant'), findsOneWidget);
  });

  testWidgets('Given a topic without variants, Then no switch is shown',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: bleeding)));
    await tester.pumpAndSettle();

    expect(find.text('Adult'), findsNothing);
    expect(find.text('Infant'), findsNothing);
  });

  testWidgets('Given the screen opens, Then adult steps render',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.textContaining('heel of one hand'), findsOneWidget);
    expect(find.textContaining('two fingers'), findsNothing);
  });

  testWidgets('Given infant is selected, Then infant steps and the banner render',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();

    expect(find.text('Infant — under 1 year'), findsOneWidget);
    expect(find.textContaining('two fingers in the centre'), findsOneWidget);
    expect(find.textContaining('heel of one hand'), findsNothing);
  });

  testWidgets('Given adult is selected, Then no banner is shown',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.text('Infant — under 1 year'), findsNothing);
    expect(find.text('Child — 1 year to puberty'), findsNothing);
  });

  testWidgets(
      'Given infant was selected, When the screen is reopened, Then it is adult again',
      (WidgetTester tester) async {
    _tallSurface(tester);
    // Real navigation, not a re-pump: pumping the same widget type again
    // reuses the State, which would prove nothing about leaving and coming
    // back. Only a fresh route builds a fresh State, and that is the
    // guarantee under test.
    await tester.pumpWidget(await _app(_OpenerHome(topic: cpr)));
    await tester.pumpAndSettle();

    Future<void> openDetail() async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    await openDetail();
    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();
    expect(find.text('Infant — under 1 year'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await openDetail();

    expect(find.text('Infant — under 1 year'), findsNothing);
    expect(find.textContaining('heel of one hand'), findsOneWidget);
  });

  testWidgets(
      'Given infant is selected, When focus mode opens, Then it shows infant steps',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();

    // The focus-mode chip in _ToolsRow.
    await tester.tap(find.byIcon(Icons.view_carousel_outlined));
    await tester.pumpAndSettle();

    expect(find.textContaining('tap the sole of the foot'), findsOneWidget);
  });

  testWidgets(
      'Given choking, When the age changes, Then the illustration changes with it',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final FirstAidTopic choking = topicById('choking')!;
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: choking)));
    await tester.pumpAndSettle();

    // Adult: the first gallery caption is the back-blows one, and the infant
    // drawing is nowhere on the screen.
    expect(find.textContaining('Lean them well forward'), findsOneWidget);
    expect(find.textContaining('A baby goes face down'), findsNothing);

    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();

    expect(find.textContaining('A baby goes face down'), findsOneWidget);
    expect(find.textContaining('Lean them well forward'), findsNothing);
  });

  testWidgets('Given Arabic, Then the switch renders right-to-left',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(
      await _app(ConditionDetailScreen(topic: cpr), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();

    expect(find.text('رضيع'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('رضيع'))),
      TextDirection.rtl,
    );
  });
}
