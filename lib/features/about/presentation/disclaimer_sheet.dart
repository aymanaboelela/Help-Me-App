import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

/// A one-time, non-dismissible medical disclaimer shown on first launch.
Future<void> showDisclaimerSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (BuildContext sheetContext) {
      final AppLocalizations l10n = AppLocalizations.of(sheetContext);
      return PopScope(
        canPop: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AppLogo(size: 64),
                const SizedBox(height: 16),
                Text(
                  l10n.disclaimerTitle,
                  style: sheetContext.texts.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.disclaimerBody,
                  style: sheetContext.texts.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).acceptDisclaimer();
                    Navigator.of(sheetContext).pop();
                  },
                  child: Text(l10n.disclaimerAccept),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
