import 'dart:io';
import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:convert/convert.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import 'constants.dart';

class EthereumWeb3AuthProvider implements BlockchainProvider {
  final Web3Client _client;
  Credentials? credentials;
  final SecureStorage storage;
  final logger = getLogger();

  static final EthereumWeb3AuthProvider _instance =
      EthereumWeb3AuthProvider._internal();
  factory EthereumWeb3AuthProvider() => _instance;

  EthereumWeb3AuthProvider._internal()
      : _client = Web3Client(Env.eth_url, Client()),
        storage = SecureStorage();

  @override
  Future<void> init() async {
    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl =
          Uri.parse('multispaces://eth.multispaces.multi_spaces/auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('multispaces://eth.multispaces.multi_spaces');
    } else {
      throw UnKnownException('Unknown platform');
    }
    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId: Env.client_id,
        network: Network.mainnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(dark: true, name: "MultiSpaces")));

    final privKey = await storage.get(WEB3_AUTH_PRIV_KEY);
    if (privKey != null) {
      credentials = EthPrivateKey.fromHex(privKey);
    }
  }

  @override
  Future<void> login(Map<String, dynamic> params) async {
    try {
      if (credentials == null) {
        final response = await Web3AuthFlutter.login(LoginParams(
            loginProvider: params['provider'],
            mfaLevel: MFALevel.NONE,
            extraLoginOptions: params['email'].toString().isNotEmpty
                ? ExtraLoginOptions(login_hint: params['email'])
                : null));
        if (response.privKey == null) {
          throw Exception('Missing private key');
        }
        credentials = EthPrivateKey.fromHex(response.privKey!);
        await storage.store(WEB3_AUTH_PRIV_KEY, response.privKey!);
        await storage.store(
            WEB3_AUTH_EMAIL_KEY, response.userInfo?.email ?? '');
        await storage.store(WEB3_AUTH_NAME_KEY, response.userInfo?.name ?? '');
        await storage.store(
            WEB3_AUTH_PROFILE_KEY, response.userInfo?.profileImage ?? '');
      } else {
        logger.i("Already logged in.");
      }
    } on UserCancelledException {
      logger.e("User cancelled.");
    } on UnKnownException {
      logger.e("Unknown exception occurred");
    }
  }

  @override
  Future<void> logout() async {
    try {
      // This does not work! Leave out for now.
      // await Web3AuthFlutter.logout();
      credentials = null;
      await storage.delete(WEB3_AUTH_PRIV_KEY);
      await storage.delete(WEB3_AUTH_EMAIL_KEY);
      await storage.delete(WEB3_AUTH_NAME_KEY);
      await storage.delete(WEB3_AUTH_PROFILE_KEY);
    } on UserCancelledException {
      logger.e("User cancelled.");
    } on UnKnownException {
      logger.e("Unknown exception occurred");
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<String> sign(
      {required String message, required String address}) async {
    // TODO: implement sign
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
    if (credentials != null) {
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
    if (credentials != null) {
      return _client.sendTransaction(
        credentials!,
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
  Future<String> signTransaction(
      {required String from,
      String? to,
      Uint8List? data,
      int? gas,
      BigInt? gasPrice,
      BigInt? value,
      int? nonce}) async {
    if (credentials != null) {
      final result = await _client.signTransaction(
        credentials!,
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
  Future<String> signTypeData(
      {required String address, required Map<String, dynamic> typedData}) {
    // TODO: implement signTypeData
    throw UnimplementedError();
  }

  @override
  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List params,
      required int value}) {
    if (credentials != null) {
      final transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: params,
        from: credentials?.address,
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, value),
      );
      return _client.sendTransaction(credentials!, transaction);
    } else {
      throw Exception("No valid credentials available");
    }
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
    final email = await storage.get(WEB3_AUTH_EMAIL_KEY);
    final name = await storage.get(WEB3_AUTH_NAME_KEY);
    final profileImage = await storage.get(WEB3_AUTH_PROFILE_KEY);
    return {
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
  }
}
