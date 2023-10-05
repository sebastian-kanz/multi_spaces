import 'dart:math';
import 'dart:typed_data';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import 'package:multi_spaces/core/blockchain_providers/constants.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:web3dart/crypto.dart';

import 'package:web3dart/web3dart.dart';

class EthereumInternalProvider implements InternalBlockchainProvider {
  final Web3Client _client;
  Credentials? _credentials;
  final SecureStorage _storage;
  String? _privateKeyHex;

  static final EthereumInternalProvider _instance =
      EthereumInternalProvider._internal();
  factory EthereumInternalProvider() => _instance;

  EthereumInternalProvider._internal()
      : _client = MultiSpaceClient().client,
        _storage = SecureStorage();

  @override
  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List params,
      required int value}) {
    if (_credentials != null) {
      final transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: params,
        from: _credentials?.address,
        value: EtherAmount.fromInt(EtherUnit.wei, value),
      );
      return _client.sendTransaction(_credentials!, transaction);
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  Future<void> init() async {
    final privateKeyExists = await _storage.exists(INTERNAL_AUTH_PRIV_KEY);
    var hexPrivateKey = "";
    if (privateKeyExists) {
      hexPrivateKey = (await _storage.get(INTERNAL_AUTH_PRIV_KEY))!;
    } else {
      final random = Random.secure();
      final privateKey = EthPrivateKey.createRandom(random);
      hexPrivateKey = bytesToHex(privateKey.privateKey);
      await _storage.store(INTERNAL_AUTH_PRIV_KEY, hexPrivateKey);
    }
    _privateKeyHex = hexPrivateKey;
    _credentials = EthPrivateKey.fromHex(hexPrivateKey);
  }

  @override
  Future<void> login(Map<String, dynamic> params) {
    throw UnsupportedError("Can't use internal provider to login!");
  }

  @override
  Future<void> logout() async {
    throw UnsupportedError("Can't use internal provider to logout!");
  }

  @override
  Future<String> sendRawTransaction({required Uint8List data}) {
    if (_credentials != null) {
      return _client.sendRawTransaction(data);
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  Future<String> sendTransaction(
      {required String from,
      String? to,
      Uint8List? data,
      int? gas,
      BigInt? gasPrice,
      BigInt? value,
      int? nonce}) async {
    if (_credentials != null) {
      return _client.sendTransaction(
        _credentials!,
        Transaction(
          from: EthereumAddress.fromHex(from),
          to: EthereumAddress.fromHex(to ?? ''),
          data: data,
          gasPrice: EtherAmount.inWei(gasPrice ?? BigInt.from(0)),
          value: EtherAmount.inWei(value ?? BigInt.from(0)),
          nonce: nonce,
        ),
      );
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  Future<String> sign({required String message}) async {
    if (_credentials != null) {
      final sig = _credentials!.signPersonalMessageToUint8List(
        hexToBytes(message),
      );
      return bytesToHex(sig);
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  Future<String> signTransaction(
      {required String from,
      String? to,
      Uint8List? data,
      int? gas,
      BigInt? gasPrice,
      BigInt? value,
      int? nonce}) async {
    if (_credentials != null) {
      final result = await _client.signTransaction(
        _credentials!,
        Transaction(
          from: EthereumAddress.fromHex(from),
          to: EthereumAddress.fromHex(to ?? ''),
          data: data,
          gasPrice: EtherAmount.inWei(gasPrice ?? BigInt.from(0)),
          value: EtherAmount.inWei(value ?? BigInt.from(0)),
          nonce: nonce,
        ),
      );
      return hex.encode(result);
    } else {
      throw Exception("No valid credentials available");
    }
  }

  @override
  bool isAuthenticated() {
    return _credentials != null;
  }

  @override
  bool isInternal() {
    return true;
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
  Uint8List getPublicKey() {
    if (_privateKeyHex != null) {
      return EthPrivateKey.fromHex(_privateKeyHex!).encodedPublicKey;
    }
    throw Exception("No valid public key available");
  }

  @override
  String getPublicKeyHex() {
    if (_privateKeyHex != null) {
      return bytesToHex(
          EthPrivateKey.fromHex(_privateKeyHex!).encodedPublicKey);
    }
    throw Exception("No valid public key available");
  }

  @override
  Future<T> callContract2<T>({required Fct fct}) {
    return fct<T>(getCredentails());
  }

  @override
  ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

  @override
  Uint8List getPrivateKey() {
    if (_privateKeyHex != null) {
      return hexToBytes(_privateKeyHex!);
    }
    throw Exception("No valid private key available");
  }

  @override
  String getPrivateKeyHex() {
    if (_privateKeyHex != null) {
      return _privateKeyHex!;
    }
    throw Exception("No valid private key available");
  }
}
