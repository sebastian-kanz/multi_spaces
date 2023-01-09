import 'dart:typed_data';

import 'package:ipfs_api/ipfs_api.dart';

abstract class IpfsApi {
  const IpfsApi();

  /// Adds data to IPFS.
  ///
  /// [data] is the data to add.
  /// Returns the hash of the added / pinned data.
  Future<String> add(Uint8List data);

  /// Removes / unpins data from IPFS.
  ///
  /// [hash] is the hash of the data to remove.
  /// Throws an [IpfsObjectNotFoundException] if the hash is not found.
  Future<void> remove(String hash);

  /// Retrieves data from IPFS.
  ///
  /// [hash] is the hash of the data to retrieve.
  /// Returns the [IpfsObject].
  /// Throws an [IpfsObjectNotFoundException] if the hash is not found.
  Future<IpfsObject> get(String hash);
}

/// Error thrown when a [IpfsObject] with a given hash is not found.
class IpfsObjectNotFoundException implements Exception {}
