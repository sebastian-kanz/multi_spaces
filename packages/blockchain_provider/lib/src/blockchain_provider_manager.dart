import 'dart:async';

import '../blockchain_provider.dart';

class BlockchainProviderManager {
  List<BlockchainProvider> _providers;
  BlockchainProvider? _authenticatedProvider;
  BlockchainProvider? _selectedProvider;

  static final BlockchainProviderManager _instance =
      BlockchainProviderManager._internal();
  factory BlockchainProviderManager() => _instance;
  BlockchainProviderManager._internal() : _providers = [];

  List<BlockchainProvider> get providers => _providers;

  void set providers(List<BlockchainProvider> providers) {
    _providers = providers;

    for (final provider in _providers) {
      if (provider.isAuthenticated() && !provider.isInternal()) {
        _authenticatedProvider = provider;
      }
      provider.authNotifier.addListener(_listenProviderAuth);
    }
  }

  BlockchainProvider get selectedProvider {
    if (_selectedProvider != null) {
      return _selectedProvider!;
    }
    throw Exception("No Provider selected!");
  }

  InternalBlockchainProvider get internalProvider {
    for (final provider in _providers) {
      if (provider.isInternal()) {
        return provider as InternalBlockchainProvider;
      }
    }
    throw Exception("No internal provider existing!");
  }

  void selectProvider<Type>() {
    for (final provider in _providers) {
      if (provider.runtimeType == Type) {
        _selectedProvider = provider;
      }
    }
  }

  BlockchainProvider? get authenticatedProvider => _authenticatedProvider;

  StreamController<bool> _authStreamController = StreamController<bool>();
  Stream<bool> listenAuthentication() => _authStreamController.stream;

  void _listenProviderAuth() {
    var authenticatedProviderFound = false;
    for (final provider in _providers) {
      if (provider.isAuthenticated() && !provider.isInternal()) {
        _authenticatedProvider = provider;
        authenticatedProviderFound = true;
        _authStreamController.add(true);
      }
    }
    if (!authenticatedProviderFound) {
      _authenticatedProvider = null;
      _authStreamController.add(false);
    }
  }
}
