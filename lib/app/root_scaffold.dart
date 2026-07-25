import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/call_action.dart';
import '../core/widgets/app_nav_bar.dart';
import '../features/about/presentation/disclaimer_sheet.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/health/presentation/health_screen.dart';
import '../features/home/home_screen.dart';
import '../features/learn/presentation/learn_screen.dart';
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
  static const int _emergencyTab = 2;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    LearnScreen(),
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
      bottomNavigationBar: AppNavBar(
        index: _index,
        onSelected: (int i) => setState(() => _index = i),
        items: <AppNavItem>[
          AppNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l10n.navHome,
          ),
          AppNavItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school_rounded,
            label: l10n.navLearn,
          ),
          AppNavItem(
            icon: Icons.emergency_outlined,
            activeIcon: Icons.emergency_rounded,
            label: l10n.navEmergency,
          ),
          AppNavItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite_rounded,
            label: l10n.navHealth,
          ),
          AppNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
