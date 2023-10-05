import 'dart:async';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'models/models.dart';

enum ConnectionStatus { unknown, initialized, connected, disconnected }

class UserRepository {
  final _controller = StreamController<ConnectionStatus>();

  void init() {
    _controller.add(ConnectionStatus.initialized);
  }

  Stream<ConnectionStatus> get status async* {
    yield* _controller.stream;
  }

  Future<User?> getUser() async {
    final account =
        BlockchainProviderManager().authenticatedProvider?.getAccount();
    final userInfo =
        await BlockchainProviderManager().authenticatedProvider?.getUserInfo();
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
