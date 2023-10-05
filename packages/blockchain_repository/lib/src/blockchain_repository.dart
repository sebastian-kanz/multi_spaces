import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:web3dart/web3dart.dart';

enum ConnectionStatus { unknown, initialized, connected, disconnected }

class BlockchainRepository {
  final _controller = StreamController<ConnectionStatus>();

  void init() {
    _controller.add(ConnectionStatus.initialized);
  }

  Stream<ConnectionStatus> get status async* {
    yield* _controller.stream;
  }

  @override
  Credentials getCredentails() {
    if (BlockchainProviderManager().authenticatedProvider != null) {
      return BlockchainProviderManager()
          .authenticatedProvider!
          .getCredentails();
    }
    throw Exception("Missing provider!");
  }

  Future<T> callContract2<T>({required Fct fct}) {
    return BlockchainProviderManager()
        .authenticatedProvider!
        .callContract2<T>(fct: fct);
  }

  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List<dynamic> params,
      required int value}) {
    return BlockchainProviderManager().authenticatedProvider!.callContract(
        contract: contract, function: function, params: params, value: value);
  }
}
