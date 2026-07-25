import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

/// A personal "In Case of Emergency" contact, stored only on the device.
@immutable
class EmergencyContact {
  const EmergencyContact({required this.name, required this.number});

  final String name;
  final String number;

  /// Unit-separator control char (0x1F) — cannot appear in a name or number.
  static final String _sep = String.fromCharCode(31);

  String encode() => '$name$_sep$number';

  static EmergencyContact? decode(String raw) {
    final List<String> parts = raw.split(_sep);
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return null;
    return EmergencyContact(name: parts[0], number: parts[1]);
  }
}

/// Up to [maxContacts] personal emergency contacts, persisted locally.
class ContactsNotifier extends Notifier<List<EmergencyContact>> {
  static const String _key = 'contacts.ice';
  static const int maxContacts = 5;

  @override
  List<EmergencyContact> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return (prefs.getStringList(_key) ?? const <String>[])
        .map(EmergencyContact.decode)
        .whereType<EmergencyContact>()
        .toList();
  }

  bool get isFull => state.length >= maxContacts;

  Future<void> add(EmergencyContact contact) async {
    if (isFull) return;
    state = <EmergencyContact>[...state, contact];
    await _persist();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final List<EmergencyContact> next = <EmergencyContact>[...state]..removeAt(index);
    state = next;
    await _persist();
  }

  Future<void> _persist() => ref
      .read(sharedPreferencesProvider)
      .setStringList(_key, state.map((EmergencyContact c) => c.encode()).toList());
}

final NotifierProvider<ContactsNotifier, List<EmergencyContact>> contactsProvider =
    NotifierProvider<ContactsNotifier, List<EmergencyContact>>(ContactsNotifier.new);
