import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/providers/contacts_provider.dart';
import 'package:help_me/providers/country_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/providers/recent_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  Future<ProviderContainer> makeContainer([
    Map<String, Object> seed = const <String, Object>{},
  ]) async {
    SharedPreferences.setMockInitialValues(seed);
    prefs = await SharedPreferences.getInstance();
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('CountryNotifier', () {
    test('Given no selection, Then it defaults to Egypt', () async {
      final ProviderContainer c = await makeContainer();
      expect(c.read(countryProvider).code, 'EG');
      expect(c.read(countryProvider).ambulance.number, '123');
    });

    test('Given a selection, Then it switches and persists', () async {
      final ProviderContainer c = await makeContainer();
      await c.read(countryProvider.notifier).select('SA');
      expect(c.read(countryProvider).code, 'SA');
      expect(c.read(countryProvider).ambulance.number, '997');
      expect(prefs.getString('settings.country_code'), 'SA');
    });

    test('Given an unknown code, Then it falls back to Egypt', () async {
      final ProviderContainer c = await makeContainer();
      await c.read(countryProvider.notifier).select('ZZ');
      expect(c.read(countryProvider).code, 'EG');
    });
  });

  group('EmergencyContact', () {
    test('Given a contact, When encoded and decoded, Then it round-trips', () {
      const EmergencyContact contact = EmergencyContact(name: 'Mom', number: '0100');
      final EmergencyContact? back = EmergencyContact.decode(contact.encode());
      expect(back?.name, 'Mom');
      expect(back?.number, '0100');
    });

    test('Given malformed data, When decoded, Then it returns null', () {
      expect(EmergencyContact.decode('no-separator'), isNull);
    });
  });

  group('ContactsNotifier', () {
    test('Given add and remove, Then state and store update', () async {
      final ProviderContainer c = await makeContainer();
      final ContactsNotifier n = c.read(contactsProvider.notifier);

      await n.add(const EmergencyContact(name: 'Dad', number: '0122'));
      expect(c.read(contactsProvider), hasLength(1));
      expect(prefs.getStringList('contacts.ice'), hasLength(1));

      await n.removeAt(0);
      expect(c.read(contactsProvider), isEmpty);
    });

    test('Given the max is reached, Then further adds are ignored', () async {
      final ProviderContainer c = await makeContainer();
      final ContactsNotifier n = c.read(contactsProvider.notifier);
      for (int i = 0; i < ContactsNotifier.maxContacts + 2; i++) {
        await n.add(EmergencyContact(name: 'C$i', number: '$i'));
      }
      expect(c.read(contactsProvider), hasLength(ContactsNotifier.maxContacts));
    });
  });

  group('RecentNotifier', () {
    test('Given repeated touches, Then newest is first and deduped', () async {
      final ProviderContainer c = await makeContainer();
      final RecentNotifier n = c.read(recentProvider.notifier);
      await n.touch('burns');
      await n.touch('cpr');
      await n.touch('burns');
      expect(c.read(recentProvider), <String>['burns', 'cpr']);
    });

    test('Given more than the cap, Then it keeps only the newest', () async {
      final ProviderContainer c = await makeContainer();
      final RecentNotifier n = c.read(recentProvider.notifier);
      for (final String id in <String>['a', 'b', 'c', 'd', 'e', 'f', 'g']) {
        await n.touch(id);
      }
      final List<String> recent = c.read(recentProvider);
      expect(recent, hasLength(RecentNotifier.maxItems));
      expect(recent.first, 'g');
    });
  });
}
