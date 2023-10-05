import 'dart:io';
import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:convert/convert.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import 'constants.dart';

class EthereumWeb3AuthProvider implements BlockchainProvider {
  final Web3Client _client;
  Credentials? _credentials;
  String? _publicKey;
  final SecureStorage _storage;
  final logger = getLogger();

  static final EthereumWeb3AuthProvider _instance =
      EthereumWeb3AuthProvider._internal();
  factory EthereumWeb3AuthProvider() => _instance;

  EthereumWeb3AuthProvider._internal()
      : _client = MultiSpaceClient().client,
        _storage = SecureStorage();

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
    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId: Env.client_id,
        network: Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(dark: true, name: "MultiSpaces"),
      ),
    );

    final privKey = await _storage.get(WEB3_AUTH_PRIV_KEY);
    if (privKey != null) {
      _publicKey = bytesToHex(
        EthPrivateKey.fromHex(privKey).encodedPublicKey,
      );
      _credentials = EthPrivateKey.fromHex(privKey);
    }
    authNotifier.value = isAuthenticated();
  }

  @override
  Future<void> login(Map<String, dynamic> params) async {
    try {
      if (_credentials == null) {
        final response = await Web3AuthFlutter.login(LoginParams(
            loginProvider: params['provider'],
            mfaLevel: MFALevel.NONE,
            extraLoginOptions: params['email'].toString().isNotEmpty
                ? ExtraLoginOptions(login_hint: params['email'])
                : null));
        if (response.privKey == null) {
          throw Exception('Missing private key');
        }
        _credentials = EthPrivateKey.fromHex(response.privKey!);
        _publicKey = bytesToHex(
          EthPrivateKey.fromHex(response.privKey!).encodedPublicKey,
        );
        await _storage.store(WEB3_AUTH_PRIV_KEY, response.privKey!);
        await _storage.store(
            WEB3_AUTH_EMAIL_KEY, response.userInfo?.email ?? '');
        await _storage.store(WEB3_AUTH_NAME_KEY, response.userInfo?.name ?? '');
        await _storage.store(
            WEB3_AUTH_PROFILE_KEY, response.userInfo?.profileImage ?? '');
      } else {
        logger.i("Already logged in.");
      }
      authNotifier.value = true;
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
      _credentials = null;
      await _storage.delete(WEB3_AUTH_PRIV_KEY);
      await _storage.delete(WEB3_AUTH_EMAIL_KEY);
      await _storage.delete(WEB3_AUTH_NAME_KEY);
      await _storage.delete(WEB3_AUTH_PROFILE_KEY);
      authNotifier.value = false;
    } on UserCancelledException {
      logger.e("User cancelled.");
    } on UnKnownException {
      logger.e("Unknown exception occurred");
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<String> sign({required String message}) {
    if (_credentials != null) {
      return Future.value(
        bytesToHex(
          _credentials!.signPersonalMessageToUint8List(
            Uint8List.fromList(message.codeUnits),
          ),
        ),
      );
    } else {
      throw Exception("No valid credentials available");
    }
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
  bool isAuthenticated() {
    return _credentials != null;
  }

  @override
  bool isInternal() {
    return false;
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
    final email = await _storage.get(WEB3_AUTH_EMAIL_KEY);
    final name = await _storage.get(WEB3_AUTH_NAME_KEY);
    final profileImage = await _storage.get(WEB3_AUTH_PROFILE_KEY);
    return {
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
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
    if (_publicKey != null) {
      return hexToBytes(_publicKey ?? "0x00");
    }
    // else if(_credentials != null) {
    //   _publicKey = _credentials.
    // }
    throw Exception("No valid public key available");
  }

  @override
  String getPublicKeyHex() {
    if (_publicKey != null) {
      return _publicKey!;
    }
    throw Exception("No valid public key available");
  }

  @override
  Future<T> callContract2<T>({required Fct fct}) {
    return fct<T>(getCredentails());
  }

  @override
  ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);
}
