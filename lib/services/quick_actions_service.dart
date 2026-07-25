import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_actions/quick_actions.dart';

/// Holds the last-triggered home-screen quick action, consumed by the shell.
final StateProvider<String?> quickActionProvider =
    StateProvider<String?>((ref) => null);

/// Registers the app-icon long-press shortcuts ("Call ambulance",
/// "Emergency numbers") and routes taps into [quickActionProvider].
abstract final class QuickActionsService {
  static const String callAmbulance = 'call_ambulance';
  static const String emergencyNumbers = 'emergency_numbers';

  static void initialize(
    WidgetRef ref, {
    required String callLabel,
    required String numbersLabel,
  }) {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    try {
      const QuickActions actions = QuickActions();
      actions.initialize((String type) {
        ref.read(quickActionProvider.notifier).state = type;
      });
      actions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(type: callAmbulance, localizedTitle: callLabel),
        ShortcutItem(type: emergencyNumbers, localizedTitle: numbersLabel),
      ]);
    } catch (_) {
      // Quick actions are a nicety; ignore platforms that do not support them.
    }
  }
}
