import 'dart:convert';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_spaces/core/blockchain_providers/constants.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthereumWcProvider extends EthereumWalletConnectProvider
    implements BlockchainProvider {
  final Web3Client _client;
  WcEthereumCredentials? _credentials;
  String? _publicKey;
  final SecureStorage _storage;

  static late EthereumWcProvider _instance;

  factory EthereumWcProvider.withStorage(
    SessionStorage storage,
    WalletConnectSession? session,
  ) {
    _instance = EthereumWcProvider._internal(
      session: session,
      storage: storage,
    );
    return _instance;
  }

  factory EthereumWcProvider() => _instance;

  EthereumWcProvider._internal({
    WalletConnectSession? session,
    SessionStorage? storage,
  })  : _client = Web3Client(Env.eth_url, Client()),
        _storage = SecureStorage(),
        super(
            WalletConnect(
              bridge: Env.walletconnect_bridge,
              session: session,
              sessionStorage: storage,
              clientMeta: const PeerMeta(
                name: Env.walletconnect_name,
                description: Env.walletconnect_description,
                url: Env.walletconnect_url,
                icons: [Env.walletconnect_icon],
              ),
            ),
            chainId: 0) {
    _credentials = WcEthereumCredentials(provider: this);
  }

  @override
  Future<void> init() async {
    // await logout();
    if (connector.session.connected) {
      await initPubKey();
    }
  }

  Future<void> initPubKey() async {
    final storedKey = await _storage.get(WC_AUTH_PUB_KEY);
    if (storedKey != null) {
      _publicKey = storedKey;
    } else {
      final message = DateTime.now().toString();
      final messageHash = keccak256(Uint8List.fromList(utf8.encode(message)));
      final signature = await _credentials!.signToSignature(messageHash);
      final pubKey = ecRecover(messageHash, signature);
      _publicKey = bytesToHex(pubKey);
      await _storage.store(WC_AUTH_PUB_KEY, _publicKey!);
    }

    // print(
    //   bytesToHex(
    //     compressPublicKey(
    //       hexToBytes('0x04${bytesToHex(_publicKey ?? Uint8List(0))}'),
    //     ),
    //     include0x: true,
    //   ),
    // );
  }

  @override
  Future<void> login(Map<String, dynamic> params) async {
    connector.reconnect();
    await connector.connect(onDisplayUri: (uri) => params['onDisplayUri'](uri));
    await initPubKey();
    connector.on("disconnect", (event) => params['onDisconnect']());
  }

  @override
  Future<void> logout() async {
    if (connector.session.connected) {
      await connector.killSession();
      await connector.close();
      await _storage.delete(WC_AUTH_PUB_KEY);
    }
  }

  @override
  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List<dynamic> params,
      required int value}) async {
    if (_credentials != null) {
      final transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: params,
        from: _credentials?.address,
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, value),
      );
      return _client.sendTransaction(_credentials!, transaction);
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  bool isAuthenticated() {
    return connector.session.connected;
  }

  @override
  EthereumAddress getAccount() {
    if (_credentials != null) {
      return _credentials!.address;
    }
    throw Exception("No valid credentials available");
  }

  @override
  Future<Map<String, String?>> getUserInfo() async {
    return {};
  }

  @override
  Credentials getCredentails() {
    if (_credentials != null) {
      return _credentials!;
    }
    throw Exception("No valid credentials available");
  }

  @override
  String getPublicKeyHex() {
    if (_publicKey != null) {
      return _publicKey!;
    }
    throw Exception("No valid public key available");
  }

  @override
  Uint8List getPublicKey() {
    if (_publicKey != null) {
      return hexToBytes(_publicKey ?? "0x00");
    }
    throw Exception("No valid public key available");
  }

  @override
  Future<T> callContract2<T>({required Fct fct}) {
    return fct<T>(getCredentails());
  }
}
