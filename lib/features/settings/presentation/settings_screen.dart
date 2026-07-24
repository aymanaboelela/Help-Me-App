import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/country_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../about/presentation/about_screen.dart';
import '../../emergency/data/emergency_numbers.dart';
import '../../emergency/presentation/country_picker.dart';

/// Language, appearance, and app actions (rate / share / about).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppSettings settings = ref.watch(settingsProvider);
    final SettingsNotifier notifier = ref.read(settingsProvider.notifier);
    final EmergencyCountry country = ref.watch(countryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          _SectionHeader(text: l10n.settingsLanguage),
          _SettingsCard(
            children: <Widget>[
              _OptionTile(
                title: l10n.languageSystem,
                selected: settings.localeCode == null,
                onTap: () => notifier.setLocaleCode(null),
              ),
              const _TileDivider(),
              _OptionTile(
                title: l10n.languageArabic,
                selected: settings.localeCode == 'ar',
                onTap: () => notifier.setLocaleCode('ar'),
              ),
              const _TileDivider(),
              _OptionTile(
                title: l10n.languageEnglish,
                selected: settings.localeCode == 'en',
                onTap: () => notifier.setLocaleCode('en'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader(text: l10n.settingsAppearance),
          _SettingsCard(
            children: <Widget>[
              _OptionTile(
                title: l10n.themeSystem,
                selected: settings.themeMode == ThemeMode.system,
                onTap: () => notifier.setThemeMode(ThemeMode.system),
              ),
              const _TileDivider(),
              _OptionTile(
                title: l10n.themeLight,
                selected: settings.themeMode == ThemeMode.light,
                onTap: () => notifier.setThemeMode(ThemeMode.light),
              ),
              const _TileDivider(),
              _OptionTile(
                title: l10n.themeDark,
                selected: settings.themeMode == ThemeMode.dark,
                onTap: () => notifier.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader(text: l10n.emergencyTitle),
          _SettingsCard(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.public),
                title: Text(l10n.countryLabel),
                subtitle: Text(
                  '${country.flag}  ${country.name.resolve(context.locale)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showCountryPicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsCard(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: Text(l10n.settingsRate),
                trailing: const Icon(Icons.chevron_right),
                onTap: _rateApp,
              ),
              const _TileDivider(),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: Text(l10n.settingsShare),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Share.share(l10n.shareMessage),
              ),
              const _TileDivider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsAbout),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(AboutScreen.route()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(appStoreId: AppConfig.appStoreId);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 4),
      child: Text(
        text,
        style: context.texts.titleSmall?.copyWith(color: context.semantic.muted),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: children));
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1);
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check_circle, color: context.colors.primary)
          : const Icon(Icons.radio_button_unchecked, color: Colors.transparent),
      onTap: onTap,
    );
  }
}
