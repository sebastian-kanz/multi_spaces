import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ipfs_api/ipfs_api.dart';
import 'package:mockito/annotations.dart';
import 'package:infura_ipfs_api/infura_ipfs_api.dart';
import 'package:mockito/mockito.dart';
import 'infura_ipfs_api_test.mocks.dart';
import 'dart:convert';

class TestInfuraIpfsApi extends InfuraIpfsApi {
  TestInfuraIpfsApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

@GenerateMocks([http.Client])
void main() {
  group('InfuraIpfsApi', () {
    group('get(hash)', () {
      test('returns the IpfsObject', () async {
        final client = MockClient();
        final api = InfuraIpfsApi(client: client);
        const hash = 'QmYwAPJzv5CZsnA625s3XfPnLrEAccz1z4Z1kCYntTn5V';
        when(client.post(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));
        expect(await api.get(hash),
            equals(IpfsObject(hash: hash, data: Uint8List(0))));
      });

      test('throws IpfsObjectNotFoundException for unknown hash', () async {
        final client = MockClient();
        final api = InfuraIpfsApi(client: client);
        when(client.post(any, headers: anyNamed('headers')))
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
        final api = InfuraIpfsApi(client: client);
        const hash = 'QmYwAPJzv5CZsnA625s3XfPnLrEAccz1z4Z1kCYntTn5V';
        const result = '{"Name": "test.pdf","Hash": "$hash","Size": "1234"}';
        final stream = Stream<List<int>>.value(utf8.encode(result));
        when(client.send(any))
            .thenAnswer((_) async => http.StreamedResponse(stream, 200));
        expect(await api.add(Uint8List(0)), equals(hash));
      });
    });

    group('remove(hash)', () {
      test('works as expected', () async {
        final client = MockClient();
        final api = InfuraIpfsApi(client: client);
        const hash = 'QmYwAPJzv5CZsnA625s3XfPnLrEAccz1z4Z1kCYntTn5V';
        when(client.post(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));
        try {
          await api.remove(hash);
        } catch (e) {
          expect(true, false);
        }
      });
      test('throws IpfsObjectNotFoundException for unknown hash', () async {
        final client = MockClient();
        final api = InfuraIpfsApi(client: client);
        const hash = 'blabla';
        when(client.post(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => throw http.ClientException('404'));
        try {
          await api.remove(hash);
          expect(true, false);
        } catch (e) {
          expect(e, isA<IpfsObjectNotFoundException>());
        }
      });
    });
  });
}
