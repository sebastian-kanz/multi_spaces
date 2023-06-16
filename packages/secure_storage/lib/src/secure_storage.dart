import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

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
}
