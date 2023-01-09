// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[],"name":"EPOCH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"GENESIS","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"signer","type":"address"},{"internalType":"bytes","name":"authSig","type":"bytes"},{"internalType":"uint256","name":"epoch","type":"uint256"},{"internalType":"bytes","name":"random","type":"bytes"}],"name":"addDelegation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"delegate","type":"address"}],"name":"removeDelegation","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'Delegation',
);

class Delegation extends _i1.GeneratedContract {
  Delegation({
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
  Future<BigInt> EPOCH({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'a0dc2758'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> GENESIS({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, 'b7dec1b7'));
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
  Future<String> addDelegation(
    _i1.EthereumAddress signer,
    _i2.Uint8List authSig,
    BigInt epoch,
    _i2.Uint8List random, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '9527fd9c'));
    final params = [
      signer,
      authSig,
      epoch,
      random,
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
  Future<String> removeDelegation(
    _i1.EthereumAddress delegate, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'f0466c73'));
    final params = [delegate];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }
}
