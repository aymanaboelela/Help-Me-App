import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/app_config.dart';
import '../../../core/platform/adaptive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/country_provider.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/learn_provider.dart';
import '../../../providers/notification_prefs_provider.dart';
import '../../../providers/reminder_sync_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/reminder_plan.dart';
import '../../../services/reminder_service.dart';
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
          _SectionHeader(text: l10n.settingsNotifications),
          const _NotificationsCard(),
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

/// The notification switches.
///
/// Each change rebuilds the whole pending schedule rather than editing it, so
/// switching something off really does cancel what it had already booked, and
/// switching it back on reschedules from the medicines currently saved.
class _NotificationsCard extends ConsumerWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NotificationPrefs prefs = ref.watch(notificationPrefsProvider);
    final NotificationPrefsNotifier notifier =
        ref.read(notificationPrefsProvider.notifier);

    // The daily tip stores a time rather than a flag: null means off. It is the
    // same setting the Learn screen offers, not a second copy of it.
    final int? tipMinutes = ref.watch(tipReminderProvider);

    return _SettingsCard(
      children: <Widget>[
        SwitchListTile.adaptive(
          title: Text(l10n.notifyDoses),
          subtitle: Text(l10n.notifyDosesHint),
          value: prefs.doses,
          onChanged: (bool on) => _apply(context, ref, notifier.setDoses(on), on),
        ),
        const _TileDivider(),
        SwitchListTile.adaptive(
          title: Text(l10n.notifyExpiry),
          subtitle: Text(l10n.notifyExpiryHint),
          value: prefs.expiry,
          onChanged: (bool on) => _apply(context, ref, notifier.setExpiry(on), on),
        ),
        const _TileDivider(),
        SwitchListTile.adaptive(
          title: Text(l10n.tipReminder),
          subtitle: Text(
            tipMinutes == null ? l10n.tipReminderOff : _formatMinutes(tipMinutes),
          ),
          value: tipMinutes != null,
          onChanged: (bool on) => _setTipTime(
            context,
            ref,
            on ? _defaultTipMinutes : null,
          ),
        ),
        if (tipMinutes != null) ...<Widget>[
          const _TileDivider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.notifyTipTime),
            subtitle: Text(_formatMinutes(tipMinutes)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTipTime(context, ref, tipMinutes),
          ),
        ],
        const _TileDivider(),
        ListTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: Text(l10n.notifyTest),
          onTap: () => _sendTest(context, ref),
        ),
      ],
    );
  }

  /// Persists a switch, then puts the phone's pending reminders back in line
  /// with it. Asks for the notification permission only when turning one on.
  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    Future<void> saved,
    bool turningOn,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String blocked = AppLocalizations.of(context).notificationsBlocked;
    await saved;
    final bool ok = await ref
        .read(reminderSyncProvider)
        .rebuildAll(requestPermission: turningOn);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(blocked)));
  }

  /// Turns the daily tip on at [minutes], or off when it is null.
  Future<void> _setTipTime(BuildContext context, WidgetRef ref, int? minutes) =>
      _apply(
        context,
        ref,
        ref.read(tipReminderProvider.notifier).setMinutes(minutes),
        minutes != null,
      );

  Future<void> _pickTipTime(BuildContext context, WidgetRef ref, int current) async {
    final TimeOfDay? picked = await showAdaptiveTime(
      context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null || !context.mounted) return;
    await _setTipTime(context, ref, picked.hour * 60 + picked.minute);
  }

  /// 9am when switching the tip on: late enough not to wake anybody, early
  /// enough to still be read.
  static const int _defaultTipMinutes = 9 * 60;

  Future<void> _sendTest(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Reminders reminders = ref.read(remindersProvider);

    if (!await reminders.ensurePermission()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.notificationsBlocked)));
      return;
    }
    await reminders.showNow(title: l10n.appName, body: l10n.notifyTestBody);
    messenger.showSnackBar(SnackBar(content: Text(l10n.notifyTestSent)));
  }

  String _formatMinutes(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';
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
