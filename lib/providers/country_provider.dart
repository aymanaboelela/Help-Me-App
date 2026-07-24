import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/emergency/data/emergency_numbers.dart';
import 'preferences.dart';

const String _kCountryKey = 'settings.country_code';

/// The user's selected country for emergency numbers (persisted; default Egypt).
class CountryNotifier extends Notifier<EmergencyCountry> {
  @override
  EmergencyCountry build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return countryByCode(prefs.getString(_kCountryKey));
  }

  Future<void> select(String code) async {
    state = countryByCode(code);
    await ref.read(sharedPreferencesProvider).setString(_kCountryKey, state.code);
  }
}

final NotifierProvider<CountryNotifier, EmergencyCountry> countryProvider =
    NotifierProvider<CountryNotifier, EmergencyCountry>(CountryNotifier.new);
