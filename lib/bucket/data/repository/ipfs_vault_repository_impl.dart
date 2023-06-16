import 'package:flutter/foundation.dart';
import 'package:ipfs_repository/ipfs_repository.dart';
import 'package:key_repository/key_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/contracts/Bucket.g.dart';

class IPFSVaultRepositoryImpl implements IPFSVaultRepository {
  final String privateKey = '';
  final String publicKey = '';
  final IpfsRepository _ipfsRepository;
  final KeyRepository _keyRepository;
  final Bucket _bucket;
  final EthereumAddress _account;

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
    final genesis = (await _bucket.GENESIS()).toInt();
    final blocksPerEpoch = (await _bucket.EPOCH()).toInt();
    return ((creationBlockNumber - genesis) / blocksPerEpoch)
        .floor()
        .toString();
  }

  @override
  Future<String> exportKey(String hexPublicKey, {int? blockNumber}) async {
    final now = await _bucket.client.getBlockNumber();
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

  @override
  Future<Uint8List> get(String contentHash, {int? creationBlockNumber}) async {
    final result = await _ipfsRepository.get(contentHash);
    final now = await _bucket.client.getBlockNumber();
    final epochAtCreation = await blockToEpoch(creationBlockNumber ?? now);
    final keyBundle = await _bucket.getKeyBundle(
      _account,
      BigInt.from(creationBlockNumber ?? now),
    );
    final hexEncryptedKey = keyBundle.var1;
    final encryptorPublicKeyHex = keyBundle.var2;
    await _keyRepository.importEncryptedKey(
      epoch: epochAtCreation,
      hexEncryptedKey: hexEncryptedKey,
      hexPublicKey: encryptorPublicKeyHex,
    );
    if (!await _keyRepository.exists(epochAtCreation)) {
      throw RepositoryFailure("Could not find key for epoch $epochAtCreation!");
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
    final now = await _bucket.client.getBlockNumber();
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
    return _keyRepository.hexPublicKey;
  }
}
