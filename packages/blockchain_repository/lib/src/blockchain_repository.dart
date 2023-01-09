import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';

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
}
