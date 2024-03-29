// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"address","name":"requestor","type":"address"},{"internalType":"address","name":"acceptor","type":"address"}],"name":"acceptParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"newParticipantName","type":"string"},{"internalType":"address","name":"newParticipantAdr","type":"address"},{"internalType":"bytes","name":"newParticipantPubKey","type":"bytes"}],"name":"addParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"address","name":"sessionAccount","type":"address"},{"internalType":"uint256","name":"validUntilEpoch","type":"uint256"},{"internalType":"bytes","name":"uniqueSessionCode","type":"bytes"},{"internalType":"bytes","name":"authSig","type":"bytes"}],"name":"createSession","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"grantRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"hasRole","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"participantCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"removeParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"requestor","type":"address"},{"internalType":"bytes","name":"pubKey","type":"bytes"},{"internalType":"string","name":"deviceName","type":"string"},{"internalType":"address","name":"device","type":"address"},{"internalType":"bytes","name":"devicePubKey","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"requestParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"address","name":"sessionAccount","type":"address"},{"internalType":"bytes","name":"authSig","type":"bytes"}],"name":"revokeSession","outputs":[],"stateMutability":"payable","type":"function"}]',
  'IParticipantManager',
);

class IParticipantManager extends _i1.GeneratedContract {
  IParticipantManager({
    required _i1.EthereumAddress address,
    required _i1.Web3Client client,
    int? chainId,
  }) : super(
          _i1.DeployedContract(
            _contractAbi,
            address,
          ),
          client,
          chainId,
        );

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> acceptParticipation(
    _i1.EthereumAddress requestor,
    _i1.EthereumAddress acceptor, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '0353e732'));
    final params = [
      requestor,
      acceptor,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> addParticipation(
    String newParticipantName,
    _i1.EthereumAddress newParticipantAdr,
    _i2.Uint8List newParticipantPubKey, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '186034d7'));
    final params = [
      newParticipantName,
      newParticipantAdr,
      newParticipantPubKey,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> createSession(
    _i1.EthereumAddress account,
    _i1.EthereumAddress sessionAccount,
    BigInt validUntilEpoch,
    _i2.Uint8List uniqueSessionCode,
    _i2.Uint8List authSig, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '562db4a0'));
    final params = [
      account,
      sessionAccount,
      validUntilEpoch,
      uniqueSessionCode,
      authSig,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> grantRole(
    _i2.Uint8List role,
    _i1.EthereumAddress account, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '2f2ff15d'));
    final params = [
      role,
      account,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> hasRole(
    _i2.Uint8List role,
    _i1.EthereumAddress account, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '91d14854'));
    final params = [
      role,
      account,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> participantCount({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '362f04c0'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> removeParticipation(
    _i1.EthereumAddress participant, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'b16be945'));
    final params = [participant];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> requestParticipation(
    String name,
    _i1.EthereumAddress requestor,
    _i2.Uint8List pubKey,
    String deviceName,
    _i1.EthereumAddress device,
    _i2.Uint8List devicePubKey,
    _i2.Uint8List signature, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '39811935'));
    final params = [
      name,
      requestor,
      pubKey,
      deviceName,
      device,
      devicePubKey,
      signature,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> revokeSession(
    _i1.EthereumAddress account,
    _i1.EthereumAddress sessionAccount,
    _i2.Uint8List authSig, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, 'fb82fda5'));
    final params = [
      account,
      sessionAccount,
      authSig,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }
}
