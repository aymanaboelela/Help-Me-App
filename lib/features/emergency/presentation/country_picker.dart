import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/country_provider.dart';
import '../data/emergency_numbers.dart';

/// A bottom sheet for choosing the country whose emergency numbers are shown.
Future<void> showCountryPicker(BuildContext context, WidgetRef ref) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.countryPick, style: sheetContext.texts.titleLarge),
            ),
            for (final EmergencyCountry c in kCountries)
              ListTile(
                leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                title: Text(c.name.resolve(sheetContext.locale)),
                onTap: () {
                  ref.read(countryProvider.notifier).select(c.code);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      );
    },
  );
}
