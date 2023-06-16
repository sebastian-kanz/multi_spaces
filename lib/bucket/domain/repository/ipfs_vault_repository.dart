import 'package:flutter/foundation.dart';

/// contentHash is the hash of the ipfs object
/// keyHash is the ipfs hash of the container element, which is the reference hash for keys for an element
abstract class IPFSVaultRepository {
  /// Retrieve data from ipfs and decrypts it
  /// checks if a key exists for that hash, and decrypts the data if so
  /// otherwise key is decrypted with own private key and encryptor's public key and stored
  /// then the data is decrypted and returned
  Future<Uint8List> get(String contentHash, {int? creationBlockNumber});

  /// encrypts the data and uploads it to ipfs
  /// returns the ipfs hash
  Future<String> store(Uint8List data, {int? creationBlockNumber});

  /// removes the data from IPFS and clears the key locally
  Future<void> remove(String contentHash, String keyHash);

  /// Returns the encrypted key to be updated to the contract
  Future<String> exportKey(String hexPublicKey, {int? blockNumber});

  String getOwnPublicKey();
}
