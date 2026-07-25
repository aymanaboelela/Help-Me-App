import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Pickers and dialogs that look native on whichever platform they run on.
///
/// A Material date picker on an iPhone reads as a port, and a Cupertino wheel on
/// Android reads as the same mistake in the other direction. Flutter already
/// ships adaptive constructors for switches, dialogs and progress indicators;
/// what it does not ship is an adaptive date or time picker, so those live here.
///
/// Everything keys off [ThemeData.platform] rather than `Platform.isIOS`, which
/// keeps it overridable in tests and honest inside a themed subtree.
extension AdaptivePlatform on BuildContext {
  bool get isCupertino {
    final TargetPlatform platform = Theme.of(this).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }
}

/// A date picker: the iOS wheel in a sheet, or the Material calendar dialog.
Future<DateTime?> showAdaptiveDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  DateTime clamp(DateTime value) {
    if (value.isBefore(firstDate)) return firstDate;
    if (value.isAfter(lastDate)) return lastDate;
    return value;
  }

  if (!context.isCupertino) {
    return showDatePicker(
      context: context,
      initialDate: clamp(initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  DateTime selected = clamp(initialDate);
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (BuildContext context) => _CupertinoPickerSheet(
      onDone: () => Navigator.of(context).pop(selected),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: selected,
        minimumDate: firstDate,
        maximumDate: lastDate,
        onDateTimeChanged: (DateTime value) => selected = value,
      ),
    ),
  );
}

/// A time picker: the iOS wheel in a sheet, or the Material clock dialog.
Future<TimeOfDay?> showAdaptiveTime(
  BuildContext context, {
  required TimeOfDay initialTime,
}) async {
  if (!context.isCupertino) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  final DateTime today = DateTime.now();
  DateTime selected = DateTime(
    today.year,
    today.month,
    today.day,
    initialTime.hour,
    initialTime.minute,
  );

  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (BuildContext context) => _CupertinoPickerSheet(
      onDone: () => Navigator.of(context)
          .pop(TimeOfDay(hour: selected.hour, minute: selected.minute)),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: selected,
        use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        onDateTimeChanged: (DateTime value) => selected = value,
      ),
    ),
  );
}

/// A yes/no confirmation that uses each platform's own dialog.
Future<bool> showAdaptiveConfirm(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  String? title,
  bool destructive = false,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool? result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog.adaptive(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: <Widget>[
        adaptiveAction(
          context: context,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        adaptiveAction(
          context: context,
          isDestructive: destructive,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// One choice offered by [showAdaptiveOptions].
@immutable
class AdaptiveOption<T> {
  const AdaptiveOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

/// Asks the user to pick one of a short list of actions: an iOS action sheet, or
/// a Material bottom sheet. Returns `null` if they dismissed it.
Future<T?> showAdaptiveOptions<T>(
  BuildContext context, {
  required String title,
  required List<AdaptiveOption<T>> options,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);

  if (context.isCupertino) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext sheetContext) => CupertinoActionSheet(
        title: Text(title),
        actions: <Widget>[
          for (final AdaptiveOption<T> option in options)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(option.value),
              child: Text(option.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(l10n.commonCancel),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    builder: (BuildContext sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
          ),
          for (final AdaptiveOption<T> option in options)
            ListTile(
              leading: Icon(option.icon),
              title: Text(option.label),
              onTap: () => Navigator.of(sheetContext).pop(option.value),
            ),
        ],
      ),
    ),
  );
}

/// A dialog action button in the platform's own style.
Widget adaptiveAction({
  required BuildContext context,
  required VoidCallback onPressed,
  required Widget child,
  bool isDestructive = false,
}) {
  if (context.isCupertino) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      isDestructiveAction: isDestructive,
      child: child,
    );
  }
  return TextButton(
    onPressed: onPressed,
    style: isDestructive
        ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error)
        : null,
    child: child,
  );
}

/// The sheet the Cupertino pickers sit in: a cancel/done bar over the wheel,
/// which is what iOS users expect to be able to reach for.
class _CupertinoPickerSheet extends StatelessWidget {
  const _CupertinoPickerSheet({required this.child, required this.onDone});

  final Widget child;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Container(
      height: 320,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Row(
                children: <Widget>[
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: onDone,
                    child: Text(
                      l10n.commonDone,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: theme.brightness,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: theme.textTheme.titleMedium,
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
