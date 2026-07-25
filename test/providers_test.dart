import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/providers/favorites_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/providers/search_provider.dart';
import 'package:help_me/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  Future<ProviderContainer> makeContainer([Map<String, Object> seed = const <String, Object>{}]) async {
    SharedPreferences.setMockInitialValues(seed);
    prefs = await SharedPreferences.getInstance();
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('FavoritesNotifier', () {
    test('Given an empty store, When toggled twice, Then it adds then removes', () async {
      container = await makeContainer();
      expect(container.read(favoritesProvider), isEmpty);

      await container.read(favoritesProvider.notifier).toggle('burns');
      expect(container.read(favoritesProvider), contains('burns'));
      expect(prefs.getStringList('favorites.ids'), contains('burns'));

      await container.read(favoritesProvider.notifier).toggle('burns');
      expect(container.read(favoritesProvider).contains('burns'), isFalse);
    });

    test('Given seeded favorites, Then they load on build', () async {
      container = await makeContainer(<String, Object>{
        'favorites.ids': <String>['cpr', 'stroke'],
      });
      expect(container.read(favoritesProvider), <String>{'cpr', 'stroke'});
      final List<FirstAidTopic> topics = container.read(favoriteTopicsProvider);
      expect(topics.map((FirstAidTopic t) => t.id), containsAll(<String>['cpr', 'stroke']));
    });
  });

  group('SettingsNotifier', () {
    test('Given a theme change, Then state and store update', () async {
      container = await makeContainer();
      await container.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
      expect(prefs.getInt('settings.theme_mode'), ThemeMode.dark.index);
    });

    test('Given a locale change, Then locale resolves; null clears it', () async {
      container = await makeContainer();
      final SettingsNotifier notifier = container.read(settingsProvider.notifier);

      await notifier.setLocaleCode('ar');
      expect(container.read(settingsProvider).locale, const Locale('ar'));
      expect(prefs.getString('settings.locale_code'), 'ar');

      await notifier.setLocaleCode(null);
      expect(container.read(settingsProvider).locale, isNull);
      expect(prefs.getString('settings.locale_code'), isNull);
    });

    test('Given the disclaimer is accepted, Then it persists', () async {
      container = await makeContainer();
      expect(container.read(settingsProvider).disclaimerAccepted, isFalse);
      await container.read(settingsProvider.notifier).acceptDisclaimer();
      expect(container.read(settingsProvider).disclaimerAccepted, isTrue);
      expect(prefs.getBool('settings.disclaimer_accepted'), isTrue);
    });
  });

  group('filteredTopicsProvider', () {
    test('Given a query, Then only matching topics remain', () async {
      container = await makeContainer();
      container.read(searchQueryProvider.notifier).state = 'burn';
      final List<FirstAidTopic> result = container.read(filteredTopicsProvider);
      expect(result, isNotEmpty);
      expect(result.any((FirstAidTopic t) => t.id == 'burns'), isTrue);
      expect(result.every((FirstAidTopic t) => t.matches('burn')), isTrue);
    });

    test('Given a category, Then only that category remains', () async {
      container = await makeContainer();
      container.read(selectedCategoryProvider.notifier).state = TopicCategory.cardiac;
      final List<FirstAidTopic> result = container.read(filteredTopicsProvider);
      expect(result, isNotEmpty);
      expect(
        result.every((FirstAidTopic t) => t.category == TopicCategory.cardiac),
        isTrue,
      );
    });
  });

  group('Children filter', () {
    test('Given the filter is on, Then only child-relevant topics remain', () async {
      container = await makeContainer();

      container.read(childrenFilterProvider.notifier).state = true;
      final List<FirstAidTopic> topics = container.read(filteredTopicsProvider);

      expect(topics.map((FirstAidTopic t) => t.id).toSet(), <String>{
        'cpr',
        'choking',
        'drowning',
        'burns',
        'anaphylaxis',
        'seizures',
        'febrile_seizure',
        'child_dehydration',
        'swallowed_object',
      });
    });

    test('Given the filter is off, Then every topic is listed', () async {
      container = await makeContainer();

      expect(
        container.read(filteredTopicsProvider).length,
        kFirstAidTopics.length,
      );
    });

    test('Given the filter and a search query, Then both apply', () async {
      container = await makeContainer();

      container.read(childrenFilterProvider.notifier).state = true;
      container.read(searchQueryProvider.notifier).state = 'dehydration';

      expect(
        container.read(filteredTopicsProvider).map((FirstAidTopic t) => t.id),
        <String>['child_dehydration'],
      );
    });
  });
}
