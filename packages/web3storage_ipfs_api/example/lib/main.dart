import 'dart:typed_data';

import 'package:web3storage_ipfs_api/web3storage_ipfs_api.dart';

void main() async {
  final api = Web3StorageIpfsApi(jwt: 'YOUR_JWT');
  final hash = await api.add(Uint8List.fromList("bla".codeUnits));
  print(hash);
  final result = await api.get(hash);
  print(String.fromCharCodes(result.data));
}
