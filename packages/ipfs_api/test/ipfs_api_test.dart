import 'package:flutter_test/flutter_test.dart';

import 'package:ipfs_api/ipfs_api.dart';

class TestIpfsApi extends IpfsApi {
  TestIpfsApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('IpfsApi', () {
    test('can be constructed', () {
      expect(TestIpfsApi.new, returnsNormally);
    });
  });
}
