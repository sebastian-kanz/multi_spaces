import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ipfs_api/ipfs_api.dart';
import 'package:logger/logger.dart';

class PinataIpfsApi extends IpfsApi {
  PinataIpfsApi({
    String? apiKey,
    String? secretApiKey,
    http.Client? client,
  })  : _apiKey = apiKey ?? '',
        _secretApiKey = secretApiKey ?? '',
        _client = client ?? http.Client();

  final String _apiKey;
  final String _secretApiKey;
  final http.Client _client;
  final Logger _logger = Logger();

  @override
  Future<IpfsObject> get(String hash) async {
    try {
      final response = await _client.get(
        Uri.parse('https://gateway.pinata.cloud/ipfs/$hash'),
        headers: <String, String>{
          'pinata_api_key': _apiKey,
          'pinata_secret_api_key': _secretApiKey,
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
          'POST', Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS'));
      request.headers['pinata_api_key'] = _apiKey;
      request.headers['pinata_secret_api_key'] = _secretApiKey;
      request.files
          .add(http.MultipartFile.fromBytes('file', data, filename: 'data'));
      final response =
          await http.Response.fromStream(await _client.send(request));

      final json = jsonDecode(response.body);
      return json['IpfsHash'];
    } catch (e) {
      _logger.e('Error pinning data to IPFS', e);
      rethrow;
    }
  }

  @override
  Future<void> remove(String hash) async {
    try {
      await _client.delete(
        Uri.parse('https://api.pinata.cloud/pinning/unpin/$hash'),
        headers: <String, String>{
          'pinata_api_key': _apiKey,
          'pinata_secret_api_key': _secretApiKey,
        },
      );
    } catch (e) {
      _logger.e('Error unpinning hash $hash from IPFS', e);
      throw IpfsObjectNotFoundException();
    }
  }
}
