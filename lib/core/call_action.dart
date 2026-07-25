import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'dialer.dart';

/// Dials [number] and shows a localized error snackbar if the dialer cannot open
/// (e.g. on a device without telephony).
Future<void> callWithFeedback(BuildContext context, String number) async {
  final messenger = ScaffoldMessenger.of(context);
  final String errorText = AppLocalizations.of(context).callError;
  final bool ok = await dialNumber(number);
  if (!ok && context.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(errorText)));
  }
}
