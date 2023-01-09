// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"hasRole","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"participantCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"inviter","type":"address"},{"internalType":"address","name":"invitee","type":"address"},{"internalType":"bytes","name":"signature","type":"bytes"},{"internalType":"string","name":"randomCode","type":"string"},{"internalType":"bytes","name":"pubKey","type":"bytes"}],"name":"redeemParticipationCode","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"}],"name":"removeParticipation","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
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

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> hasRole(
    _i2.Uint8List role,
    _i1.EthereumAddress account, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[0];
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
    final function = self.abi.functions[1];
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
  Future<String> redeemParticipationCode(
    String name,
    _i1.EthereumAddress inviter,
    _i1.EthereumAddress invitee,
    _i2.Uint8List signature,
    String randomCode,
    _i2.Uint8List pubKey, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '1c17f2cc'));
    final params = [
      name,
      inviter,
      invitee,
      signature,
      randomCode,
      pubKey,
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
  Future<String> removeParticipation(
    _i1.EthereumAddress participant, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'b16be945'));
    final params = [participant];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }
}
