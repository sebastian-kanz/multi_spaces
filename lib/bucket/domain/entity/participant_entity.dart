import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

class ParticipantEntity {
  EthereumAddress address;
  String name;
  Uint8List publicKey;
  bool initialized;

  ParticipantEntity(
    this.address,
    this.name,
    this.publicKey,
    this.initialized,
  );
}
