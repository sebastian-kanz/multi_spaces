import 'dart:convert';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:blockchain_repository/blockchain_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:multi_spaces/core/blockchain_providers/constants.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';

import '../models/eip155.dart';

class EthereumWcProvider implements BlockchainProvider {
  final Web3Client _client;
  WcEthereumCredentials? _credentials;
  String? _publicKey;
  String? _account;
  final SecureStorage _storage;
  final Logger _logger = Logger();
  static late Web3App _wcClient;

  static final EthereumWcProvider _instance = EthereumWcProvider._internal();
  factory EthereumWcProvider() => _instance;
  EthereumWcProvider._internal()
      : _client = MultiSpaceClient().client,
        _storage = SecureStorage() {
    _credentials = WcEthereumCredentials(provider: this);
  }

  @override
  Future<void> init() async {
    _wcClient = await Web3App.createInstance(
      projectId: Env.walletconnect_project_id,
      metadata: const PairingMetadata(
        name: Env.walletconnect_name,
        description: Env.walletconnect_description,
        url: Env.walletconnect_url,
        icons: [Env.walletconnect_icon],
      ),
    );

    _publicKey = await _storage.get(WC_AUTH_PUB_KEY);
    _account = await _storage.get(WC_ACCOUNT);

    if (_wcClient.getActiveSessions().isEmpty) {
      await logout();
    }
    _wcClient.onSessionDelete.subscribe((args) async {
      _wcClient.onSessionDelete.unsubscribeAll();
      await logout();
    });
    authNotifier.value = isAuthenticated();
  }

  static Uint8List _getPersonalMessage(Uint8List message) {
    const messagePrefix = '\u0019Ethereum Signed Message:\n';
    final prefix = messagePrefix + message.length.toString();
    final prefixBytes = ascii.encode(prefix);
    return keccak256(Uint8List.fromList(prefixBytes + message));
  }

  Future<void> _initPubKey(Map<String, dynamic> params) async {
    final storedKey = await _storage.get(WC_AUTH_PUB_KEY);
    if (storedKey != null) {
      _publicKey = storedKey;
    } else {
      final sessionTopic = await _storage.get(WC_AUTH_SESSION_TOPIC);
      final message = "Sign in to MultiSpaces on ${DateTime.now()}";
      try {
        final signatureHex = await _wcClient.signEngine.request(
          topic: sessionTopic!,
          chainId: '${Env.chain_namespace}:${Env.chain_id.toString()}',
          request: SessionRequestParams(
            method: 'personal_sign',
            params: [
              bytesToHex(
                Uint8List.fromList(utf8.encode(message)),
                include0x: true,
              ),
              _account,
            ],
          ),
        );

        final signature = MsgSignature(
          BigInt.parse(
            '0x${bytesToHex(hexToBytes(signatureHex).sublist(0, 32))}',
          ),
          BigInt.parse(
            '0x${bytesToHex(hexToBytes(signatureHex).sublist(32, 64))}',
          ),
          hexToDartInt(
            '0x${bytesToHex(hexToBytes(signatureHex).sublist(64, 65))}',
          ),
        );
        final pubKey = ecRecover(
          _getPersonalMessage(Uint8List.fromList(utf8.encode(message))),
          signature,
        );
        _publicKey = bytesToHex(pubKey);
        final address = bytesToHex(publicKeyToAddress(pubKey), include0x: true);
        if (address != _account) {
          throw Exception("Signature invalid!");
        }
        await _storage.store(WC_AUTH_PUB_KEY, _publicKey!);
      } catch (e) {
        _logger.e("Initializing public key failed: $e");
        await params[BlockchainProvider.onDisconnect]();
        rethrow;
      }
    }
  }

  Map<String, RequiredNamespace> _getNamespaces() {
    final Map<String, RequiredNamespace> requiredNamespaces = {};
    for (final chain in CHAINS) {
      // If the chain is already in the required namespaces, add it to the chains list
      final String chainName = chain.chainId.split(':')[0];
      if (requiredNamespaces.containsKey(chainName)) {
        requiredNamespaces[chainName]!.chains!.add(chain.chainId);
        continue;
      }
      final RequiredNamespace rNamespace = RequiredNamespace(
        chains: [chain.chainId],
        methods: EIP155.methods.values.toList(),
        events: EIP155.events.values.toList(),
      );
      requiredNamespaces[chainName] = rNamespace;
    }
    return requiredNamespaces;
  }

  @override
  Future<void> login(Map<String, dynamic> params) async {
    final sessionTopic = await _storage.get(WC_AUTH_SESSION_TOPIC);
    if (sessionTopic == null) {
      try {
        final ConnectResponse res = await _wcClient.connect(
          requiredNamespaces: _getNamespaces(),
        );

        _wcClient.registerEventHandler(
          chainId: '${Env.chain_namespace}:${Env.chain_id.toString()}',
          event: EIP155.events.entries.first.value,
        );
        _wcClient.registerEventHandler(
          chainId: '${Env.chain_namespace}:${Env.chain_id.toString()}',
          event: EIP155.events.entries.last.value,
        );

        _wcClient.onSessionEvent.subscribe((SessionEvent? event) {
          if (event?.name == EIP155.events[EIP155Events.chainChanged]) {
            print("Chain changed!");
          } else if (event?.name ==
              EIP155.events[EIP155Events.accountsChanged]) {
            print("Account changed!");
          }
        });

        params[BlockchainProvider.onDisplayUri](res.uri.toString());
        final session = await res.session.future;
        await _storage.store(WC_AUTH_SESSION_TOPIC, session.topic);
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Wait for walletconnect to settle id, otherwise sometimes strange id error occurs
        _account = session.namespaces.entries.first.value.accounts[0]
            .split(':')
            .last
            .toLowerCase();

        await _storage.store(WC_ACCOUNT, _account!);
      } catch (e) {
        _logger.e("Login via walletconnect failed: $e");
        await params[BlockchainProvider.onDisconnect]();
        rethrow;
      }
    } else {
      try {
        await _wcClient.ping(topic: sessionTopic);
        await _wcClient.signEngine.extendSession(topic: sessionTopic);
        _account = await _storage.get(WC_ACCOUNT);
      } catch (e) {
        _logger.e("Reconnect via walletconnect failed: $e");
        await params[BlockchainProvider.onDisconnect]();
        rethrow;
      }
    }

    await _initPubKey(params);
    authNotifier.value = true;

    final internalBalance = (await _client.getBalance(
      BlockchainProviderManager().internalProvider.getAccount(),
    ))
        .getInWei
        .toInt();
    final diff = 50000000000000000 - internalBalance;
    if (diff > 0) {
      await _credentials!.sendTransaction(
        Transaction(
          from: EthereumAddress.fromHex(_account!),
          to: BlockchainProviderManager().internalProvider.getAccount(),
          value: EtherAmount.fromInt(EtherUnit.wei, diff),
        ),
      );
    }
  }

  @override
  Future<void> logout() async {
    _wcClient.onSessionDelete.unsubscribeAll();
    _wcClient.onSessionExpire.unsubscribeAll();
    _wcClient.onSessionEvent.unsubscribeAll();

    final sessionTopic = await _storage.get(WC_AUTH_SESSION_TOPIC);
    if (sessionTopic != null && _wcClient.getActiveSessions().isNotEmpty) {
      await _wcClient.disconnectSession(
        topic: sessionTopic,
        reason: WalletConnectError(code: 0, message: "Logged out."),
      );
    }

    await _storage.delete(WC_AUTH_SESSION_TOPIC);
    await _storage.delete(WC_ACCOUNT);
    await _storage.delete(WC_AUTH_PUB_KEY);
    _account = null;
    _publicKey = null;
    authNotifier.value = false;
  }

  @override
  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List<dynamic> params,
      required int value}) async {
    // TODO: implement callContract
    throw UnimplementedError();
  }

  @override
  bool isAuthenticated() {
    final activeSessions = _wcClient.getActiveSessions();
    return activeSessions.isNotEmpty &&
        _account != null &&
        _account!.isNotEmpty &&
        _publicKey != null &&
        _publicKey!.isNotEmpty;
  }

  @override
  bool isInternal() {
    return false;
  }

  @override
  EthereumAddress getAccount() {
    if (_account != null) {
      return EthereumAddress.fromHex(_account!);
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

  @override
  Future<String> sendRawTransaction({required Uint8List data}) {
    // TODO: implement sendRawTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> sendTransaction({
    required String from,
    String? to,
    Uint8List? data,
    int? gas,
    BigInt? gasPrice,
    BigInt? value,
    int? nonce,
  }) async {
    final sessionTopic = await _storage.get(WC_AUTH_SESSION_TOPIC);
    final txJson = <String, dynamic>{
      'from': from,
      'to': to,
      'data': bytesToHex(data ?? [], include0x: true),
      'gas': gas,
      'value': bytesToHex(intToBytes(value ?? BigInt.from(0)), include0x: true),
    };
    try {
      return await _wcClient.signEngine.request(
        topic: sessionTopic!,
        chainId: '${Env.chain_namespace}:${Env.chain_id.toString()}',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [txJson],
        ),
      );
    } catch (e) {
      print(e);
      return "";
    }
  }

  @override
  Future<String> sign({
    required String message,
  }) async {
    final sessionTopic = await _storage.get(WC_AUTH_SESSION_TOPIC);
    final signature = await _wcClient.signEngine.request(
      topic: sessionTopic!,
      chainId: '${Env.chain_namespace}:${Env.chain_id.toString()}',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [
          message,
          _account,
        ],
      ),
    );
    return signature;
  }

  @override
  Future<String> signTransaction(
      {required String from,
      String? to,
      Uint8List? data,
      int? gas,
      BigInt? gasPrice,
      BigInt? value,
      int? nonce}) {
    // TODO: implement signTransaction
    throw UnimplementedError();
  }

  @override
  ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);
}
