import 'dart:async';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'models/models.dart';

enum ConnectionStatus { unknown, initialized, connected, disconnected }

class UserRepository {
  BlockchainProvider? _provider;
  final _controller = StreamController<ConnectionStatus>();

  UserRepository(List<BlockchainProvider> providers) {
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

  Future<User?> getUser() async {
    final account = _provider?.getAccount();
    final userInfo = await _provider?.getUserInfo();
    if (account == null) {
      return null;
    }
    return Future.value(User(
      account.hex,
      userInfo?['email'],
      userInfo?['name'],
      userInfo?['profileImage'],
    ));
  }
}
