// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[],"name":"closeBucket","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string[]","name":"newMetaHashes","type":"string[]"},{"internalType":"string[]","name":"newDataHashes","type":"string[]"},{"internalType":"string[]","name":"newContainerHashes","type":"string[]"},{"internalType":"address[]","name":"parentContainerHashes","type":"address[]"},{"internalType":"uint256","name":"contentType","type":"uint256"}],"name":"createElements","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAll","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getHistory","outputs":[{"components":[{"internalType":"address","name":"elem","type":"address"},{"internalType":"enum LibElement.OperationType","name":"operationType","type":"uint8"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"internalType":"struct LibElement.Operation[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"pManager","type":"address"},{"internalType":"address","name":"partManager","type":"address"},{"internalType":"address","name":"impl","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'IBucket',
);

class IBucket extends _i1.GeneratedContract {
  IBucket({
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
  Future<String> closeBucket({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '3d4f10ff'));
    final params = [];
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
  Future<String> createElements(
    List<String> newMetaHashes,
    List<String> newDataHashes,
    List<String> newContainerHashes,
    List<_i1.EthereumAddress> parentContainerHashes,
    BigInt contentType, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, 'a41bbac6'));
    final params = [
      newMetaHashes,
      newDataHashes,
      newContainerHashes,
      parentContainerHashes,
      contentType,
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
  Future<List<_i1.EthereumAddress>> getAll({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '53ed5143'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<_i1.EthereumAddress>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<dynamic>> getHistory({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'aa15efc8'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<dynamic>();
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initialize(
    _i1.EthereumAddress pManager,
    _i1.EthereumAddress partManager,
    _i1.EthereumAddress impl, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'c0c53b8b'));
    final params = [
      pManager,
      partManager,
      impl,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }
}
