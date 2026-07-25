import 'package:flutter/foundation.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart' as native;

/// Importing an ICE contact from the phone's own address book.
///
/// This hands the user to the operating system's picker (`ACTION_PICK` on
/// Android, `CNContactPickerViewController` on iOS), which runs outside the app
/// and returns only the one contact the user tapped. That means the app never
/// asks for — and never holds — contacts permission, which matters for a
/// first-aid app people install in a hurry.

/// Whether this platform has a system contact picker we can open.
///
/// The plugin ships Android and iOS only; anywhere else (macOS, web, desktop)
/// the method channel would throw, so callers hide the option instead.
bool get supportsContactImport =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// How a call to [importDeviceContact] ended.
enum ContactImportStatus {
  /// The user picked a contact that has a usable number.
  picked,

  /// The user backed out of the picker.
  cancelled,

  /// A contact came back, but with no phone number on it.
  noNumber,

  /// The picker could not be opened at all.
  failed,
}

/// The outcome of an address-book import: a status plus, on success, the
/// contact's [name] and dialable [number].
@immutable
class ContactImportResult {
  const ContactImportResult(this.status, {this.name, this.number});

  final ContactImportStatus status;
  final String? name;
  final String? number;
}

/// Opens the system address book so the user can pick one contact and one of
/// its numbers.
///
/// Never throws: every failure comes back as a [ContactImportStatus] so the
/// caller can show a message instead of losing the tap.
Future<ContactImportResult> importDeviceContact() async {
  if (!supportsContactImport) {
    return const ContactImportResult(ContactImportStatus.failed);
  }

  final native.Contact? picked;
  try {
    picked = await FlutterNativeContactPicker().selectPhoneNumber();
  } catch (_) {
    return const ContactImportResult(ContactImportStatus.failed);
  }
  if (picked == null) {
    return const ContactImportResult(ContactImportStatus.cancelled);
  }

  final String number = normalizePickedNumber(
    picked.selectedPhoneNumber ?? _firstNumber(picked.phoneNumbers),
  );
  if (number.isEmpty) {
    return const ContactImportResult(ContactImportStatus.noNumber);
  }

  // A contact with no name (a bare number, or a card the OS cannot format)
  // still deserves a row, so fall back to the number itself.
  final String name = (picked.fullName ?? '').trim();
  return ContactImportResult(
    ContactImportStatus.picked,
    name: name.isEmpty ? number : name,
    number: number,
  );
}

String? _firstNumber(List<String>? numbers) =>
    (numbers == null || numbers.isEmpty) ? null : numbers.first;

/// Cleans a number as saved in the address book into something dialable.
///
/// Address books hold whatever was pasted into them: Arabic-Indic digits,
/// right-to-left marks, non-breaking spaces, "ext. 3". Arabic-Indic digits are
/// mapped to ASCII (they are the same number, just written differently),
/// anything that is not dialable is dropped, and a `+` is only kept when it
/// leads — so `‎+٢٠ 100‑123` becomes `+20 100123`.
@visibleForTesting
String normalizePickedNumber(String? raw) {
  if (raw == null) return '';

  final StringBuffer out = StringBuffer();
  bool seenDigit = false;

  for (final int code in raw.trim().runes) {
    // Arabic-Indic (٠-٩) and extended Arabic-Indic (۰-۹) digits.
    final int digit = switch (code) {
      >= 0x0660 && <= 0x0669 => code - 0x0660 + 0x30,
      >= 0x06F0 && <= 0x06F9 => code - 0x06F0 + 0x30,
      _ => code,
    };
    final String char = String.fromCharCode(digit);

    if (RegExp(r'[0-9]').hasMatch(char)) {
      seenDigit = true;
      out.write(char);
    } else if (char == '+' && !seenDigit && out.isEmpty) {
      out.write(char);
    } else if (char == ' ' && seenDigit) {
      out.write(char);
    }
  }

  final String cleaned = out.toString().replaceAll(RegExp(r' +'), ' ').trim();
  return RegExp(r'[0-9]').hasMatch(cleaned) ? cleaned : '';
}
