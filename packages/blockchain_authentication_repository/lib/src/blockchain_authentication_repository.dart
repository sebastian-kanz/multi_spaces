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
  final _controller = StreamController<AuthenticationStatus>();
  StreamSubscription<bool>? _listenAuthentication;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void init() {
    _controller.add(AuthenticationStatus.initialized);
    _isInitialized = true;
  }

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    final isAuthenticated =
        BlockchainProviderManager().authenticatedProvider?.isAuthenticated() ??
            false;
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
    await BlockchainProviderManager().selectedProvider.login({
      ...params,
      BlockchainProvider.onDisconnect: logOut,
    });
    _listenAuthentication ??= BlockchainProviderManager()
        .listenAuthentication()
        .listen((authenticated) {
      if (!authenticated) {
        _controller.add(AuthenticationStatus.unauthenticated);
      } else {
        _controller.add(AuthenticationStatus.authenticated);
      }
    });
  }

  Future<void> logOut() async {
    await BlockchainProviderManager().authenticatedProvider?.logout();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    _controller.close();
    _listenAuthentication?.cancel();
  }
}
