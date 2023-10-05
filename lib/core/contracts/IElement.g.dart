// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_elem","type":"address"},{"indexed":true,"internalType":"address","name":"requestor","type":"address"},{"indexed":true,"internalType":"uint256","name":"time","type":"uint256"}],"name":"Request","type":"event"},{"inputs":[],"name":"announceHolding","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"announceRemoval","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"remove","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"requestData","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"parent","type":"address"}],"name":"setParent","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"enum LibElement.RedundancyLevel","name":"level","type":"uint8"}],"name":"setRedundancyLevel","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"string","name":"meta","type":"string"},{"internalType":"string","name":"data","type":"string"},{"internalType":"string","name":"container","type":"string"}],"internalType":"struct LibElement.HashBundle","name":"hashes","type":"tuple"},{"internalType":"address","name":"parent","type":"address"}],"name":"update","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'IElement',
);

class IElement extends _i1.GeneratedContract {
  IElement({
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
  Future<String> announceHolding({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '039b302d'));
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
  Future<String> announceRemoval({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '165aec98'));
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
  Future<String> remove({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, 'a7f43779'));
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
  Future<String> requestData({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '606deecd'));
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
  Future<String> setParent(
    _i1.EthereumAddress parent, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '1499c592'));
    final params = [parent];
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
  Future<String> setRedundancyLevel(
    BigInt level, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '3e83062a'));
    final params = [level];
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
  Future<String> update(
    dynamic hashes,
    _i1.EthereumAddress parent, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '04ff2bec'));
    final params = [
      hashes,
      parent,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// Returns a live stream of all Request events emitted by this contract.
  Stream<Request> requestEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Request');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Request(
        decoded,
        result,
      );
    });
  }
}

class Request {
  Request(
    List<dynamic> response,
    this.event,
  )   : elem = (response[0] as _i1.EthereumAddress),
        requestor = (response[1] as _i1.EthereumAddress),
        time = (response[2] as BigInt);

  final _i1.EthereumAddress elem;

  final _i1.EthereumAddress requestor;

  final BigInt time;

  final _i1.FilterEvent event;
}
