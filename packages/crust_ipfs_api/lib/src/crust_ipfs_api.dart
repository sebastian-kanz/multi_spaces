import 'dart:typed_data';
import 'package:cid/cid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ipfs_api/ipfs_api.dart';
import 'package:logger/logger.dart';

class CrustIpfsApi extends IpfsApi {
  CrustIpfsApi({
    required String address,
    required String signature,
    http.Client? client,
  })  : _address = address,
        _signature = signature,
        _client = client ?? http.Client();

  final String _address;
  final String _signature;
  final http.Client _client;
  final Logger _logger = Logger();

  @override
  Future<IpfsObject> get(String hash) async {
    try {
      final cid = Cid(hash);
      final response = await _client.post(
        Uri.parse(
            'https://crustgateway.online/api/v0/cat?arg=${cid.asV0String()}'),
        headers: <String, String>{
          'Authorization':
              'Bearer ${base64Encode(utf8.encode('eth-$_address:$_signature'))}',
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
      final addRequest = http.MultipartRequest(
          'POST', Uri.parse('https://crustgateway.online/api/v0/add'));
      addRequest.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('eth-$_address:$_signature'))}';
      addRequest.files
          .add(http.MultipartFile.fromBytes('data', data, filename: 'data'));
      final addResponse =
          await http.Response.fromStream(await _client.send(addRequest));

      final addJson = jsonDecode(addResponse.body);

      final pinResponse = await _client.post(
        Uri.parse('https://pin.crustcode.com/psa/pins'),
        headers: <String, String>{
          'Authorization':
              'Bearer ${base64Encode(utf8.encode('eth-$_address:$_signature'))}',
        },
        body: {
          "cid": addJson['Hash'],
          // "name": 'data',
          // "meta": 'meta'
        },
      );

      final pinJson = jsonDecode(pinResponse.body);
      return pinJson['pin']['cid'];
    } catch (e) {
      _logger.e('Error pinning data to IPFS', e);
      rethrow;
    }
  }

  @override
  Future<void> remove(String hash) async {
    try {
      final getPinsResponse = await _client.get(
        Uri.parse('https://pin.crustcode.com/psa/pins'),
        headers: <String, String>{
          'Authorization':
              'Bearer ${base64Encode(utf8.encode('eth-$_address:$_signature'))}',
        },
      );

      final pinsJson = jsonDecode(getPinsResponse.body);

      for (final result in pinsJson['results']) {
        if (result['pin']['cid'] == hash) {
          await _client.delete(
            Uri.parse(
                'https://pin.crustcode.com/psa/pins/${result['requestid']}'),
            headers: <String, String>{
              'Authorization':
                  'Bearer ${base64Encode(utf8.encode('eth-$_address:$_signature'))}',
            },
          );
        }
      }
    } catch (e) {
      _logger.e('Error unpinning hash $hash from IPFS', e);
      throw IpfsObjectNotFoundException();
    }
  }
}
