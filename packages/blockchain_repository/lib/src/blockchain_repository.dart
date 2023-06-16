import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:web3dart/web3dart.dart';

enum ConnectionStatus { unknown, initialized, connected, disconnected }

class BlockchainRepository {
  BlockchainProvider? _provider;

  final _controller = StreamController<ConnectionStatus>();

  BlockchainRepository(List<BlockchainProvider> providers) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  void init(BlockchainProvider provider) {
    _provider = provider;
    _controller.add(ConnectionStatus.initialized);
  }

  Stream<ConnectionStatus> get status async* {
    yield* _controller.stream;
  }

  @override
  Credentials getCredentails() {
    if (_provider != null) {
      return _provider!.getCredentails();
    }
    throw Exception("Missing provider!");
  }

  Future<T> callContract2<T>({required Fct fct}) {
    return _provider!.callContract2<T>(fct: fct);
  }

  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List<dynamic> params,
      required int value}) {
    return _provider!.callContract(
        contract: contract, function: function, params: params, value: value);
  }
}
