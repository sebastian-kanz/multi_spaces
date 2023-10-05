import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:ipfs_repository/ipfs_repository.dart';
import 'package:key_repository/key_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/contracts/Bucket.g.dart';

class IPFSVaultRepositoryImpl implements IPFSVaultRepository {
  final String privateKey = '';
  final String publicKey = '';
  final IpfsRepository _ipfsRepository;
  final KeyRepository _keyRepository;
  final Bucket _bucket;
  final EthereumAddress _account;
  final _logger = getLogger();

  IPFSVaultRepositoryImpl(
    IpfsRepository ipfsRepository,
    KeyRepository keyRepository,
    Bucket bucket,
    EthereumAddress account,
  )   : _ipfsRepository = ipfsRepository,
        _keyRepository = keyRepository,
        _bucket = bucket,
        _account = account;

  Future<String> blockToEpoch(int creationBlockNumber) async {
    final genesis = await _getGenesis();
    final blocksPerEpoch = await _getBlocksPerEpoch();
    return ((creationBlockNumber - genesis) / blocksPerEpoch)
        .floor()
        .toString();
  }

  Future<void> bla() async {
    final random1 = Random.secure();
    const length = 12345;
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      final nextByte = random1.nextInt(255);
      result[i] = nextByte;
    }
    final privateKey1 = EthPrivateKey.createRandom(random1);
    final hexPrivateKey1 = bytesToHex(privateKey1.privateKey);
    final hexPublicKey1 = bytesToHex(privateKey1.encodedPublicKey);
    final random2 = Random.secure();
    final privateKey2 = EthPrivateKey.createRandom(random2);
    final hexPrivateKey2 = bytesToHex(privateKey2.privateKey);
    final hexPublicKey2 = bytesToHex(privateKey2.encodedPublicKey);

    final aesKeyCombo = await _keyRepository.generateKey("1000");
    final keyHex = bytesToHex(aesKeyCombo.key);

    final sharedSecret1 = calcSharedSecret(
      hexToPrivateKey(hexPrivateKey1),
      hexToPublicKey(hexPublicKey2),
    );
    final sharedSecret2 = calcSharedSecret(
      hexToPrivateKey(hexPrivateKey2),
      hexToPublicKey(hexPublicKey1),
    );
    print(sharedSecret1 == sharedSecret2);
    print(bytesToHex(writeBigInt(sharedSecret1)));
    print(bytesToHex(writeBigInt(sharedSecret2)));

    final iv = generateRandomBytes(16);
    final aesKeyComboBytes = aesComboToBytes(aesKeyCombo);
    final encryptedAesKeyCombo = aesEncrypt(
      aesKeyComboBytes,
      writeBigInt(sharedSecret1),
      iv,
    );
    final builder = BytesBuilder();
    builder.add(iv);
    builder.add(encryptedAesKeyCombo);
    final encryptedKey = bytesToHex(builder.toBytes());

    final encrypedKeyIv = hexToBytes(encryptedKey);
    final iv2 = encrypedKeyIv.sublist(0, 16);
    // final iv2 = iv;
    final encryptedKey2 = encrypedKeyIv.sublist(16);
    // final encryptedKey2 = encryptedAesKeyCombo;
    print(bytesToHex(iv2) == bytesToHex(iv));
    print(bytesToHex(encryptedKey2) == bytesToHex(encryptedAesKeyCombo));

    final decrypted = aesDecrypt(
      encryptedKey2,
      writeBigInt(sharedSecret2),
      iv2,
    );
    final decryptedAesKeyCombo = bytesToAESCombo(decrypted);
    final decryptedKeyHex = bytesToHex(decryptedAesKeyCombo.key);
    print(decryptedKeyHex == keyHex);
    print("zfztft");

    final encryptedAesKeyCombo2 = aesEncrypt(
      result,
      writeBigInt(sharedSecret1),
      iv,
    );
    final decrypted2 = aesDecrypt(
      encryptedAesKeyCombo2,
      writeBigInt(sharedSecret2),
      iv2,
    );
    print(bytesToHex(result) == bytesToHex(decrypted2));
    print(bytesToHex(result) == bytesToHex(decrypted2));
    // final encrypedKeyIv = hexToBytes(encryptedKey);
    // final iv = encrypedKeyIv.sublist(0, 16);
    // final encryptedKeyKey = encrypedKeyIv.sublist(16);

    // final decryptedKey = aesDecrypt(
    //   encryptedKeyKey,
    //   bigIntToBytes(sharedSecret),
    //   iv,
    // );
    // final decryptedAesKeyCombo = bytesToAESCombo(decryptedKey);
    // final decryptedKeyKey = bytesToHex(decryptedAesKeyCombo.key);
  }

  @override
  Future<String> exportKey(String hexPublicKey, {int? blockNumber}) async {
    // await bla();
    // throw Exception("eorfhowhf");
    final now = await _getCurrentBlock();
    final epoch = await blockToEpoch(blockNumber ?? now);
    final keyExists = await _keyRepository.exists(epoch);
    if (!keyExists) {
      await _keyRepository.generateKey(epoch);
    }
    return _keyRepository.exportExistingKey(
      epoch: epoch,
      hexPublicKey: hexPublicKey,
    );
  }

  // TODO: Create function to check retrievability, i.e. is key available and can CID be found on network?

  @override
  Future<Uint8List> get(String contentHash, {int? creationBlockNumber}) async {
    final result = await _ipfsRepository.get(contentHash);
    final now = await _getCurrentBlock();
    final epochAtCreation = await blockToEpoch(creationBlockNumber ?? now);
    final keyBundle = await retry(
      () => _bucket.getKeyBundle(
        EthereumAddress.fromPublicKey(
          hexToBytes(
            _keyRepository.getPublicKeyHex(),
          ),
        ),
        BigInt.from(creationBlockNumber ?? now),
      ),
      retryIf: (e) => e is RPCError,
    );

    if (keyBundle.var1 == "" || keyBundle.var2 == "") {
      throw MissingKeyFailure(
        EthereumAddress.fromPublicKey(
          hexToBytes(
            _keyRepository.getPublicKeyHex(),
          ),
        ).hex,
        creationBlockNumber ?? now,
        int.parse(epochAtCreation),
      );
    }
    final hexEncryptedKey = keyBundle.var1;
    final encryptorPublicKeyHex = keyBundle.var2;
    final keyExistsLocally = await _keyRepository.exists(epochAtCreation);
    if (!keyExistsLocally) {
      await _keyRepository.importEncryptedKey(
        epoch: epochAtCreation,
        hexEncryptedKey: hexEncryptedKey,
        hexPublicKey: encryptorPublicKeyHex,
      );
      if (!await _keyRepository.exists(epochAtCreation)) {
        throw RepositoryFailure(
          "Could not find key for epoch $epochAtCreation!",
        );
      }
    }
    final hexKey = await _keyRepository.read(epochAtCreation);
    final key = hexToAescombo(hexKey);
    return aesDecrypt(result.data, key.key, key.iv);
  }

  @override
  Future<void> remove(String contentHash, String keyHash) async {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<String> store(Uint8List data, {int? creationBlockNumber}) async {
    final now = await _getCurrentBlock();
    final epochAtCreation = await blockToEpoch(creationBlockNumber ?? now);
    final keyExists = await _keyRepository.exists(epochAtCreation);
    AESCombo key;
    if (keyExists) {
      final hexKey = await _keyRepository.read(epochAtCreation);
      key = hexToAescombo(hexKey);
    } else {
      key = await _keyRepository.generateKey(epochAtCreation);
    }

    final encrypted = aesEncrypt(data, key.key, key.iv);
    final result = await _ipfsRepository.store(encrypted);
    return result.hash;
  }

  @override
  String getOwnPublicKey() {
    return _keyRepository.getPublicKeyHex();
  }

  Future<int> _getGenesis() async {
    return (await retry(
      () => _bucket.GENESIS(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }

  Future<int> _getBlocksPerEpoch() async {
    return (await retry(
      () => _bucket.EPOCH(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }

  Future<int> _getCurrentBlock() async {
    return (await retry(
      () => _bucket.client.getBlockNumber(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }
}
