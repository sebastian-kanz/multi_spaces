import 'dart:typed_data';

import 'package:pinata_ipfs_api/pinata_ipfs_api.dart';

void main() async {
  final api = PinataIpfsApi(
      apiKey: 'YOUR_API_KEY', secretApiKey: 'YOUR_SECRET_API_KEY');
  final hash = await api.add(Uint8List(0));
  print(hash);
  final result = await api.get(hash);
  print(result);
  await api.remove(hash);
}
