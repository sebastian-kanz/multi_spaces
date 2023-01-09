import 'dart:async';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:json_annotation/json_annotation.dart';

enum AuthenticationStatus {
  @JsonValue("unknown")
  unknown,
  @JsonValue("initialized")
  initialized,
  @JsonValue("authenticated")
  authenticated,
  @JsonValue("unauthenticated")
  unauthenticated
}

class BlockchainAuthenticationRepository {
  BlockchainProvider? _provider;

  BlockchainAuthenticationRepository(List<BlockchainProvider> providers) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  final _controller = StreamController<AuthenticationStatus>();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void init(BlockchainProvider provider) {
    _provider = provider;
    _controller.add(AuthenticationStatus.initialized);
    _isInitialized = true;
  }

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    final isAuthenticated = _provider?.isAuthenticated() ?? false;
    if (_isInitialized) {
      if (isAuthenticated) {
        yield AuthenticationStatus.authenticated;
      } else {
        yield AuthenticationStatus.unauthenticated;
      }
    } else {
      yield AuthenticationStatus.unknown;
    }
    yield* _controller.stream;
  }

  Future<void> logIn(Map<String, dynamic> params) async {
    await _provider?.login({...params, 'onDisconnect': logOut});
    _controller.add(AuthenticationStatus.authenticated);
  }

  Future<void> logOut() async {
    await _provider?.logout();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
