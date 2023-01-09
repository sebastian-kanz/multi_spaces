import 'dart:typed_data';

import 'package:infura_ipfs_api/infura_ipfs_api.dart';

void main() async {
  final api = InfuraIpfsApi(
      projectId: 'YOUR_PROJECT_ID', projectSecret: 'YOUR_PROJECT_SECRET');
  final hash = await api.add(Uint8List(0));
  print(hash);
  final result = await api.get(hash);
  print(result);
  await api.remove(hash);
}
