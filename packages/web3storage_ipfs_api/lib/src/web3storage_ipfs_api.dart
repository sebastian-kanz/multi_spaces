import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ipfs_api/ipfs_api.dart';
import 'package:logger/logger.dart';

class Web3StorageIpfsApi extends IpfsApi {
  Web3StorageIpfsApi({
    String? jwt,
    http.Client? client,
  })  : _jwt = jwt ?? '',
        _client = client ?? http.Client();

  final String _jwt;
  final http.Client _client;
  final Logger _logger = Logger();

  @override
  Future<IpfsObject> get(String hash) async {
    try {
      final response = await _client.get(
        Uri.parse('https://ipfs.io/ipfs/$hash'),
      );
      return IpfsObject(hash: hash, data: response.bodyBytes);
    } catch (e) {
      _logger.e('Error getting hash $hash from IPFS', e);
      throw IpfsObjectNotFoundException();
    }
  }

  @override
  Future<String> add(Uint8List data) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://api.web3.storage/upload'));
      request.headers['Authorization'] = 'Bearer $_jwt';
      request.files
          .add(http.MultipartFile.fromBytes('file', data, filename: 'data'));
      final response =
          await http.Response.fromStream(await _client.send(request));

      final json = jsonDecode(response.body);
      return json['cid'];
    } catch (e) {
      _logger.e('Error pinning data to IPFS', e);
      rethrow;
    }
  }

  @override
  Future<void> remove(String hash) async {
    _logger.i('Can not remove hash $hash from Web3Storage: Not implemented.');
  }
}
