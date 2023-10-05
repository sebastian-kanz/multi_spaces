import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'key.util.dart';

class KeyRepository {
  final _logger = Logger(
    level: Level.debug,
    printer: PrettyPrinter(
      lineLength: 90,
      colors: false,
      methodCount: 1,
      errorMethodCount: 5,
    ),
  );
  final String _tenant;
  final String _bucket;
  final SecureStorage _storage;
  final String _privateKeyHex;

  KeyRepository(
    this._tenant,
    this._bucket,
    this._privateKeyHex,
  ) : _storage = SecureStorage();

  String _getKeyName(String epoch) {
    return '${_tenant}_${_bucket}_$epoch';
  }

  String getPublicKeyHex() {
    return bytesToHex(EthPrivateKey.fromHex(_privateKeyHex).encodedPublicKey);
  }

  Future<void> _store(String epoch, AESCombo aesCombo) async {
    final hex = aesComboToHex(aesCombo);
    final keyExists = await exists(epoch);
    if (keyExists) {
      final existingKey = await read(epoch);
      if (existingKey != hex) {
        throw Exception("Another key for epoch $epoch is already existing!");
      }
      return;
    }
    await _storage.store(_getKeyName(epoch), hex);
  }

  Future<void> remove(
    String epoch,
  ) async {
    await _storage.delete(_getKeyName(epoch));
  }

  Future<String> read(
    String epoch,
  ) async {
    final keyName = _getKeyName(epoch);
    final key = await _storage.get(keyName);
    if (key == null) {
      _logger.d('No key found for $keyName!');
      return '';
    }
    return key;
  }

  Future<bool> exists(
    String epoch,
  ) async {
    return _storage.exists(_getKeyName(epoch));
  }

  Future<String> generateEncryptedKey({
    required String epoch,
    required String hexOwnPrivateKey,
    required String hexPublicKey,
  }) async {
    final aesKeyCombo = await generateKey(epoch);
    return _encryptKey(
      hexOwnPrivateKey: hexOwnPrivateKey,
      hexPublicKey: hexPublicKey,
      aesKeyCombo: aesKeyCombo,
    );
  }

  Future<String> exportExistingKey({
    required String epoch,
    required String hexPublicKey,
  }) async {
    final aesKeyComboHex = await read(epoch);
    final aesKeyCombo = hexToAescombo(aesKeyComboHex);
    return _encryptKey(
      hexOwnPrivateKey: _privateKeyHex,
      hexPublicKey: hexPublicKey,
      aesKeyCombo: aesKeyCombo,
    );
  }

  Future<String> _encryptKey({
    required String hexOwnPrivateKey,
    required String hexPublicKey,
    required AESCombo aesKeyCombo,
  }) async {
    final sharedSecret = calcSharedSecret(
      hexToPrivateKey(hexOwnPrivateKey),
      hexToPublicKey(hexPublicKey),
    );
    final iv = generateRandomBytes(16);
    final aesKeyComboBytes = aesComboToBytes(aesKeyCombo);
    final encryptedAesKeyCombo = aesEncrypt(
      aesKeyComboBytes,
      bigIntToBytes(sharedSecret),
      iv,
    );
    final builder = BytesBuilder();
    builder.add(iv);
    builder.add(encryptedAesKeyCombo);
    final encrypted = bytesToHex(builder.toBytes());
    return encrypted;
  }

  Future<void> importEncryptedKey({
    required String epoch,
    required String hexEncryptedKey,
    required String hexPublicKey,
  }) async {
    try {
      final sharedSecret = calcSharedSecret(
        hexToPrivateKey(_privateKeyHex),
        hexToPublicKey(hexPublicKey),
      );
      final encrypedKeyIv = hexToBytes(hexEncryptedKey);
      final iv = encrypedKeyIv.sublist(0, 16);
      final encryptedKey = encrypedKeyIv.sublist(16);

      final decrypted = aesDecrypt(
        encryptedKey,
        bigIntToBytes(sharedSecret),
        iv,
      );
      final decryptedAesKeyCombo = bytesToAESCombo(decrypted);
      await _store(epoch, decryptedAesKeyCombo);
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<AESCombo> generateKey(String epoch) async {
    final keyExists = await exists(epoch);
    if (keyExists) {
      final aesKeyComboHex = await read(epoch);
      final aesKeyCombo = hexToAescombo(aesKeyComboHex);
      return aesKeyCombo;
    }
    final key = generateRandomBytes(32);
    final iv = generateRandomBytes(16);
    final aesCombo = AESCombo(key, iv);
    await _store(epoch, aesCombo);
    return aesCombo;
  }
}
