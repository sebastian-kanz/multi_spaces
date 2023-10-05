import 'dart:io';
import 'dart:typed_data';

import 'package:crust_ipfs_api/crust_ipfs_api.dart';

class MultiSpaceHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MultiSpaceHttpOverrides();
  final api = CrustIpfsApi(
    address: '0x29673b8f9909036eC84c0e03E451757b16d3aFDe',
    signature:
        '0xa3c54d8d99e57d8bc75ab33dc95e1de698d7afe29b97d47e417e6e1c309ed4e00aa3c7089cfcd69643663cb11ba0e853472075185c15d9874d9575cd37231abe1c',
  );
  final hash = await api.add(Uint8List(0));
  print(hash);
  final result = await api.get(hash);
  print(result);
  await api.remove(hash);
}
