// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_elem","type":"address"},{"indexed":true,"internalType":"address","name":"requestor","type":"address"},{"indexed":true,"internalType":"uint256","name":"time","type":"uint256"}],"name":"Request","type":"event"},{"inputs":[],"name":"announceHolding","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"announceRemoval","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"containerHash","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"contentType","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"creationTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"creator","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"dataHash","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"elemImpl","outputs":[{"internalType":"contract Element","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"holders","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"holdersCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"creator","type":"address"},{"internalType":"address","name":"participantManager","type":"address"},{"internalType":"address","name":"parent","type":"address"},{"internalType":"address","name":"previous","type":"address"},{"internalType":"address","name":"bucket","type":"address"},{"internalType":"address","name":"elemImpl","type":"address"}],"internalType":"struct LibElement.AddressBundle","name":"addresses","type":"tuple"},{"components":[{"internalType":"string","name":"meta","type":"string"},{"internalType":"string","name":"data","type":"string"},{"internalType":"string","name":"container","type":"string"}],"internalType":"struct LibElement.HashBundle","name":"hashes","type":"tuple"},{"internalType":"uint256","name":"cType","type":"uint256"},{"internalType":"enum LibElement.RedundancyLevel","name":"mRedundandy","type":"uint8"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"metaHash","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"minRedundancy","outputs":[{"internalType":"enum LibElement.RedundancyLevel","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"nextElement","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"parentBucket","outputs":[{"internalType":"contract Bucket","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"parentElement","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"participantManager","outputs":[{"internalType":"contract IParticipantManager","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"previousElement","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"redundancy","outputs":[{"internalType":"enum LibElement.RedundancyLevel","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"remove","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"requestData","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"parent","type":"address"}],"name":"setParent","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"enum LibElement.RedundancyLevel","name":"level","type":"uint8"}],"name":"setRedundancyLevel","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"string","name":"meta","type":"string"},{"internalType":"string","name":"data","type":"string"},{"internalType":"string","name":"container","type":"string"}],"internalType":"struct LibElement.HashBundle","name":"hashes","type":"tuple"},{"internalType":"address","name":"parent","type":"address"}],"name":"update","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'Element',
);

class Element extends _i1.GeneratedContract {
  Element({
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

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> containerHash({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '9ccda9df'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> contentType({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '36ebffca'));
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
  Future<BigInt> creationTime({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'd8270dce'));
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
  Future<_i1.EthereumAddress> creator({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '02d05d3f'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> dataHash({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '1b3012a3'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> elemImpl({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '6c61bc40'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> holders(
    _i1.EthereumAddress $param0, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '18a5bbdc'));
    final params = [$param0];
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
  Future<BigInt> holdersCount({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '6b4ed21b'));
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
  Future<String> initialize(
    dynamic addresses,
    dynamic hashes,
    BigInt cType,
    BigInt mRedundandy, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '1fc4504a'));
    final params = [
      addresses,
      hashes,
      cType,
      mRedundandy,
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
  Future<String> metaHash({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, '827c62fb'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> minRedundancy({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, 'd19fa220'));
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
  Future<_i1.EthereumAddress> nextElement({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, 'f177063b'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> parentBucket({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, '88956834'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> parentElement({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, 'bfa0dbc4'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> participantManager(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, '464dbe6e'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> previousElement({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, '598059c3'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> redundancy({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, '356b827f'));
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
  Future<String> remove({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[19];
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
    final function = self.abi.functions[20];
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
    final function = self.abi.functions[21];
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
    final function = self.abi.functions[22];
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
    final function = self.abi.functions[23];
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

  /// Returns a live stream of all Initialized events emitted by this contract.
  Stream<Initialized> initializedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Initialized');
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
      return Initialized(decoded);
    });
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
      return Request(decoded);
    });
  }
}

class Initialized {
  Initialized(List<dynamic> response) : version = (response[0] as BigInt);

  final BigInt version;
}

class Request {
  Request(List<dynamic> response)
      : elem = (response[0] as _i1.EthereumAddress),
        requestor = (response[1] as _i1.EthereumAddress),
        time = (response[2] as BigInt);

  final _i1.EthereumAddress elem;

  final _i1.EthereumAddress requestor;

  final BigInt time;
}
