import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/call_action.dart';
import '../features/about/presentation/disclaimer_sheet.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/health/presentation/health_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../providers/country_provider.dart';
import '../providers/settings_provider.dart';
import '../services/quick_actions_service.dart';

/// The main shell: four tabs kept alive via [IndexedStack], plus the one-time
/// disclaimer on first launch.
class RootScaffold extends ConsumerStatefulWidget {
  const RootScaffold({super.key});

  @override
  ConsumerState<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<RootScaffold> {
  int _index = 0;

  /// Kept as a named constant so the quick-action handler below cannot drift
  /// out of step with the tab order.
  static const int _emergencyTab = 1;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    EmergencyScreen(),
    HealthScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context);
      if (!ref.read(settingsProvider).disclaimerAccepted) {
        showDisclaimerSheet(context, ref);
      }
      QuickActionsService.initialize(
        ref,
        callLabel: l10n.callAmbulance,
        numbersLabel: l10n.emergencyTitle,
      );
    });
  }

  void _handleQuickAction(String? action) {
    if (action == null) return;
    if (action == QuickActionsService.emergencyNumbers) {
      setState(() => _index = _emergencyTab);
    } else if (action == QuickActionsService.callAmbulance) {
      callWithFeedback(context, ref.read(countryProvider).ambulance.number);
    }
    ref.read(quickActionProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    ref.listen<String?>(quickActionProvider, (String? _, String? next) {
      _handleQuickAction(next);
    });
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emergency_outlined),
            selectedIcon: const Icon(Icons.emergency),
            label: l10n.navEmergency,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navHealth,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
