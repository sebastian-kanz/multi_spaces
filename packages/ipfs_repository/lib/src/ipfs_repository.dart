import 'dart:typed_data';

import 'package:ipfs_api/ipfs_api.dart';
import 'package:ipfs_repository/src/models/ipfs_upload_result.dart';
import 'package:logger/logger.dart';

/// A repository that handles IPFS related requests.
///
class IpfsRepository {
  IpfsRepository({
    required List<IpfsApi> apis,
  }) : _apis = apis;

  final List<IpfsApi> _apis;
  final Logger _logger = Logger();

  /// Uploads data to IPFS.
  Future<IpfsUploadResult> upload(Uint8List data) async {
    List<String> hashes = [];
    var successes = 0;
    var failures = 0;
    for (final api in _apis) {
      try {
        final hash = await api.add(data);
        hashes.add(hash);
        successes++;
      } catch (e) {
        _logger.w('Api call to add data to IPFS failed: ${e.toString()}');
        failures++;
      }
    }
    final valid = hashes.every((hash) => hash == hashes[0]);
    if (!valid) {
      _logger.w('Some hashes do not match: $hashes');
    }
    return IpfsUploadResult(
        hash: hashes[0], successes: successes, failures: failures);
  }
}
