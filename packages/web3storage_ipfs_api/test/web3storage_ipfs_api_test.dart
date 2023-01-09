import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ipfs_api/ipfs_api.dart';
import 'package:mockito/annotations.dart';
import 'package:web3storage_ipfs_api/web3storage_ipfs_api.dart';
import 'package:mockito/mockito.dart';
import 'web3storage_ipfs_api_test.mocks.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
void main() {
  group('PinataIpfsApi', () {
    group('get(hash)', () {
      test('returns the IpfsObject', () async {
        final client = MockClient();
        final api = Web3StorageIpfsApi(client: client);
        const hash = 'QmYwAPJzv5CZsnA625s3XfPnLrEAccz1z4Z1kCYntTn5V';
        when(client.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));
        expect(await api.get(hash),
            equals(IpfsObject(hash: hash, data: Uint8List(0))));
      });

      test('throws IpfsObjectNotFoundException for unknown hash', () async {
        final client = MockClient();
        final api = Web3StorageIpfsApi(client: client);
        when(client.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => throw http.ClientException('404'));
        expect(
            () async =>
                await api.get('QmYwAPJzv5CZsnA625s3XfPnLrEAccz1z4Z1kCYntTn5V'),
            throwsA(isA<IpfsObjectNotFoundException>()));
      });
    });
    group('add(data)', () {
      test('works as expected', () async {
        final client = MockClient();
        final api = Web3StorageIpfsApi(client: client);
        const hash = 'QmYwAPJzv5CZsnA625s3XfPnLrEAccz1z4Z1kCYntTn5V';
        const result = '{"cid": "$hash"}';
        final stream = Stream<List<int>>.value(utf8.encode(result));
        when(client.send(any))
            .thenAnswer((_) async => http.StreamedResponse(stream, 200));
        expect(await api.add(Uint8List(0)), equals(hash));
      });
    });
  });
}
