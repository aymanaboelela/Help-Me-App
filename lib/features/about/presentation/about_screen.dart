import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/app_config.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/app_localizations.dart';
import 'credits_screen.dart';

/// About the app: identity, version, medical disclaimer, and credits.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AboutScreen());

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                const AppLogo(size: 88),
                const SizedBox(height: 14),
                Text(
                  l10n.appName,
                  style: context.texts.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.appTagline,
                  style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.aboutVersion} ${AppConfig.version}',
                  style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.aboutBody, style: context.texts.bodyLarge),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.health_and_safety_outlined,
            title: l10n.aboutDisclaimerTitle,
            body: l10n.disclaimerBody,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.favorite_outline,
            title: l10n.aboutCreditsTitle,
            body: l10n.aboutCredits,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.collections_outlined, color: context.colors.primary),
              title: Text(l10n.creditsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(CreditsScreen.route()),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: context.texts.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
            ),
          ],
        ),
      ),
    );
  }
}
