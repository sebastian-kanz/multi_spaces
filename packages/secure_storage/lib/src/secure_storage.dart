import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  SecureStorage._internal()
      : _storage = const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
            ),
            iOptions: IOSOptions());

  Future<void> store(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return _storage.read(key: key);
  }

  Future<bool> exists(String key) async {
    return _storage.containsKey(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
