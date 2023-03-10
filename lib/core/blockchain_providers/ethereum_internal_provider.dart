import 'dart:typed_data';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:http/http.dart';
import 'package:multi_spaces/core/env/Env.dart';

import 'package:web3dart/web3dart.dart';
// import 'dart:math';

class EthereumInternalProvider implements BlockchainProvider {
  final Web3Client _client;
  Credentials? credentials;

  static final EthereumInternalProvider _instance =
      EthereumInternalProvider._internal();
  factory EthereumInternalProvider() => _instance;

  EthereumInternalProvider._internal()
      : _client = Web3Client(Env.eth_url, Client());

  @override
  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List params,
      required int value}) {
    // TODO: implement callContract
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    return Future.value(null);
    // TODO: implement init
  }

  @override
  Future<void> login(Map<String, dynamic> params) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<String> personalSign(
      {required String message,
      required String address,
      required String password}) {
    // TODO: implement personalSign
    throw UnimplementedError();
  }

  @override
  Future<String> sendRawTransaction({required Uint8List data}) {
    // TODO: implement sendRawTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> sendTransaction(
      {required String from,
      String? to,
      Uint8List? data,
      int? gas,
      BigInt? gasPrice,
      BigInt? value,
      int? nonce}) {
    // TODO: implement sendTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> sign({required String message, required String address}) {
    // TODO: implement sign
    throw UnimplementedError();
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
  Future<String> signTypeData(
      {required String address, required Map<String, dynamic> typedData}) {
    // TODO: implement signTypeData
    throw UnimplementedError();
  }

  @override
  bool isAuthenticated() {
    return credentials != null;
  }

  @override
  EthereumAddress? getAccount() {
    return credentials?.address;
  }

  @override
  Future<Map<String, String?>> getUserInfo() async {
    return {};
  }
}
