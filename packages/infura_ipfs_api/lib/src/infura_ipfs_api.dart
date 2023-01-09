import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ipfs_api/ipfs_api.dart';
import 'package:logger/logger.dart';

class InfuraIpfsApi extends IpfsApi {
  InfuraIpfsApi({
    String? projectId,
    String? projectSecret,
    http.Client? client,
  })  : _projectId = projectId ?? '',
        _projectSecret = projectSecret ?? '',
        _client = client ?? http.Client();

  final String _projectId;
  final String _projectSecret;
  final http.Client _client;
  final Logger _logger = Logger();

  @override
  Future<IpfsObject> get(String hash) async {
    try {
      final response = await _client.post(
        Uri.parse('https://ipfs.infura.io:5001/api/v0/get?arg=$hash'),
        headers: <String, String>{
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_projectId:$_projectSecret'))}',
        },
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
          'POST', Uri.parse('https://ipfs.infura.io:5001/api/v0/add'));
      request.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('$_projectId:$_projectSecret'))}';
      request.files
          .add(http.MultipartFile.fromBytes('data', data, filename: 'data'));
      final response =
          await http.Response.fromStream(await _client.send(request));

      final json = jsonDecode(response.body);
      return json['Hash'];
    } catch (e) {
      _logger.e('Error pinning data to IPFS', e);
      rethrow;
    }
  }

  @override
  Future<void> remove(String hash) async {
    try {
      await _client.post(
        Uri.parse('https://ipfs.infura.io:5001/api/v0/pin/rm?arg=$hash'),
        headers: <String, String>{
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_projectId:$_projectSecret'))}',
        },
      );
    } catch (e) {
      _logger.e('Error unpinning hash $hash from IPFS', e);
      throw IpfsObjectNotFoundException();
    }
  }
}
