import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A small key–value store for the only genuinely sensitive data this app holds.
///
/// Health information never leaves the device: there is no server, no account,
/// and no network path that could carry it. What this abstraction adds is
/// encryption at rest, and a seam that lets tests run without a keychain.
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Backed by the iOS Keychain and Android's EncryptedSharedPreferences.
class KeychainSecureStore implements SecureStore {
  const KeychainSecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  /// Android encrypts by default in this version; iOS needs the data readable
  /// after the first unlock so a scheduled reminder can still fire.
  static const AndroidOptions _android = AndroidOptions();
  static const IOSOptions _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  @override
  Future<String?> read(String key) =>
      _storage.read(key: key, aOptions: _android, iOptions: _ios);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value, aOptions: _android, iOptions: _ios);

  @override
  Future<void> delete(String key) =>
      _storage.delete(key: key, aOptions: _android, iOptions: _ios);
}

/// An in-memory stand-in, used by tests so they never touch a real keychain.
class InMemorySecureStore implements SecureStore {
  InMemorySecureStore([Map<String, String>? seed])
      : _values = <String, String>{...?seed};

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
