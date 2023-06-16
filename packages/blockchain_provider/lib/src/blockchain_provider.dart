import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

typedef Fct = Future<T> Function<T>(Credentials creds);

abstract class BlockchainProvider {
  EthereumAddress getAccount();
  Future<Map<String, String?>> getUserInfo();
  Future<void> login(Map<String, dynamic> params);
  Future<void> logout();
  bool isAuthenticated();
  Future<void> init();
  Credentials getCredentails();
  String getPublicKeyHex();
  Uint8List getPublicKey();

  /// Signs method calculates an Ethereum specific signature.
  /// [address] - 20B address
  /// [message] - message to sign
  ///
  /// Returns signature.
  Future<String> sign({
    required String message,
    required String address,
  });

  /// Signs method calculates an Ethereum specific signature.
  /// [address] - 20B address
  /// [message] - message to sign
  /// [password] - The password of the account to sign data with
  ///
  /// Returns signature.
  Future<String> personalSign({
    required String message,
    required String address,
    required String password,
  });

  /// Calculates an Ethereum-specific signature.
  /// [address] - 20B address
  /// [typedData] - message to sign containing type information, a domain separator, and data
  ///
  /// Returns a signature.
  Future<String> signTypeData({
    required String address,
    required Map<String, dynamic> typedData,
  });

  /// Creates new message call transaction or a contract creation, if the data field contains code
  /// [from] - The address the transaction is send from.
  /// [to] - The address the transaction is directed to.
  /// [data] - The compiled code of a contract OR the hash of the invoked method signature and encoded parameters. For details see Ethereum Contract ABI
  /// [gas] - (default: 90000) Integer of the gas provided for the transaction execution. It will return unused gas.
  /// [gasPrice] - Integer of the gasPrice used for each paid gas (in Wei).
  /// [value] - Integer of the value sent with this transaction (in Wei).
  /// [nonce] - Integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce.
  ///
  /// Returns the transaction hash, or the zero hash if the transaction is not yet available.
  Future<String> sendTransaction({
    required String from,
    String? to,
    Uint8List? data,
    int? gas,
    BigInt? gasPrice,
    BigInt? value,
    int? nonce,
  });

  /// Signs a transaction that can be submitted to the network at a later time using with [eth_sendRawTransaction].
  /// [from] - The address the transaction is send from.
  /// [to] - The address the transaction is directed to.
  /// [data] - The compiled code of a contract OR the hash of the invoked method signature and encoded parameters. For details see Ethereum Contract ABI.
  /// [gas] - (default: 90000) Integer of the gas provided for the transaction execution. It will return unused gas.
  /// [gasPrice] - Integer of the gasPrice used for each paid gas (in Wei).
  /// [value] - Integer of the value sent with this transaction (in Wei).
  /// [nonce] - Integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce.
  ///
  /// Returns the signed transaction data.
  Future<String> signTransaction({
    required String from,
    String? to,
    Uint8List? data,
    int? gas,
    BigInt? gasPrice,
    BigInt? value,
    int? nonce,
  });

  /// Creates new message call transaction or a contract creation for signed transactions.
  /// [data] - The signed transaction data.
  ///
  /// Returns the transaction hash, or the zero hash if the transaction is not yet available.
  Future<String> sendRawTransaction({
    required Uint8List data,
  });

  Future<String> callContract(
      {required DeployedContract contract,
      required ContractFunction function,
      required List<dynamic> params,
      required int value});

  Future<T> callContract2<T>({
    required Fct fct,
  });
}
