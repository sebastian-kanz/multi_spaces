import 'dart:typed_data';

import 'package:cid/cid.dart';
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
  Future<IpfsUploadResult> store(Uint8List data) async {
    try {
      List<Cid> cids = [];
      var successes = 0;
      var failures = 0;
      for (final api in _apis) {
        try {
          final hash = await api.add(data);

          final cid = Cid(hash);
          cids.add(cid);
          successes++;
        } catch (e) {
          _logger.w('Api call to add data to IPFS failed: ${e.toString()}');
          failures++;
        }
      }
      final valid =
          cids.every((cid) => cid.asV1String() == cids[0].asV1String());
      if (!valid) {
        _logger.w('Some hashes do not match: $cids');
      }
      return IpfsUploadResult(
          hash: cids[0].asV1String(), successes: successes, failures: failures);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Uploads data to IPFS.
  Future<IpfsObject> get(String hash) async {
    return _apis[0].get(hash);
  }
}
