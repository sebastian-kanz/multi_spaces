import 'dart:math';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'key.util.dart';

// Repository for storing and retrieving Keys locally
// publicA: "041b0dd3979da1493ce91feb876ca03a52671a4a5c7609abbc8637956562806822fdae4933e3f65d83f1ef15c47f2f7becbd200713f3a8106596be1f74516e1cb5";
// privateA: "36861dc672ac95f92f205fc57de7837d7b5fe1a8541e975f10f082e2743039df";
// publicB: "0488d99dad75a8dd5dd070db01f651c426f7957e20e5adfa6b08db85a7cf63d6ef0846b2dff03d18790c295df4cbd5ee5f294eae170a9cd41d9d8d51dff3560388";
// privateB: "68885bb45ac9f2baaa1de3d570e9869a0fe9195e6d88db66f2cc96d827465332";
class KeyRepository {
  final _logger = Logger();
  final String _tenant;
  final String _bucket;
  final SecureStorage _storage;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  final String _privateKeyName = "PRIVATE_KEY_NAME";
  final String _publicKeyName = "PUBLIC_KEY_NAME";
  late final String _hexPrivateKey;
  late final String hexPublicKey;

  KeyRepository(this._tenant, this._bucket) : _storage = SecureStorage();

  Future<void> initialize() async {
    if (!_isInitialized) {
      final privateKeyExists = await _storage.exists(
        '${_tenant}_${_bucket}_$_privateKeyName',
      );
      final publicKeyExists = await _storage.exists(
        '${_tenant}_${_bucket}_$_publicKeyName',
      );
      if (privateKeyExists && publicKeyExists) {
        _hexPrivateKey = (await _storage.get(
          '${_tenant}_${_bucket}_$_privateKeyName',
        ))!;
        hexPublicKey = (await _storage.get(
          '${_tenant}_${_bucket}_$_publicKeyName',
        ))!;
        _isInitialized = true;
        return;
      }
      var random = Random.secure();
      final privateKey = EthPrivateKey.createRandom(random);
      _hexPrivateKey = bytesToHex(privateKey.privateKey);
      hexPublicKey = bytesToHex(privateKey.publicKey.getEncoded(false));
      _isInitialized = true;
      return;
    }
  }

  String _getKeyName(String epoch) {
    return '${_tenant}_${_bucket}_$epoch';
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
      hexOwnPrivateKey: _hexPrivateKey,
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
    return bytesToHex(builder.toBytes());
  }

  Future<void> importEncryptedKey({
    required String epoch,
    required String hexEncryptedKey,
    required String hexPublicKey,
  }) async {
    final sharedSecret = calcSharedSecret(
      hexToPrivateKey(_hexPrivateKey),
      hexToPublicKey(hexPublicKey),
    );
    final encrypedKeyIv = hexToBytes(hexEncryptedKey);
    final iv = encrypedKeyIv.sublist(0, 16);
    final encryptedKey = encrypedKeyIv.sublist(16);

    final decrypted = aesDecrypt(encryptedKey, bigIntToBytes(sharedSecret), iv);
    final decryptedAesKeyCombo = bytesToAESCombo(decrypted);
    await _store(epoch, decryptedAesKeyCombo);
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
