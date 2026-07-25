import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'providers/health_provider.dart';
import 'providers/preferences.dart';
import 'services/secure_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Health data is read once here so the notifiers that own it can build
  // synchronously, like every other piece of state in the app. If the keychain
  // is unavailable the app still starts — it just starts with an empty card.
  const SecureStore store = KeychainSecureStore();
  HealthSnapshot health = const HealthSnapshot();
  try {
    health = await HealthSnapshot.load(store);
  } catch (_) {
    health = const HealthSnapshot();
  }

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(store),
        healthSnapshotProvider.overrideWithValue(health),
      ],
      child: const HelpMeApp(),
    ),
  );
}
