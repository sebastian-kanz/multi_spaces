import 'package:web3dart/web3dart.dart';

class BucketInstance {
  const BucketInstance(
    this.name,
    this.address,
    this.creation,
    this.minRedundancy,
    this.elementCount,
    this.isActive,
    this.isExternal,
  );

  final String name;
  final EthereumAddress address;
  final DateTime creation;
  final int minRedundancy;
  final int elementCount;
  final bool isActive;
  final bool isExternal;
}
