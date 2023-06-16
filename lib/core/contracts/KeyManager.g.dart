// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"epoch","type":"uint256"}],"name":"KeysAdded","type":"event"},{"inputs":[],"name":"EPOCH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"GENESIS","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"participant","type":"address"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"name":"getKeyBundle","outputs":[{"internalType":"string","name":"","type":"string"},{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"}]',
  'KeyManager',
);

class KeyManager extends _i1.GeneratedContract {
  KeyManager({
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

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetKeyBundle> getKeyBundle(
    _i1.EthereumAddress participant,
    BigInt blockNumber, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, 'e4601393'));
    final params = [
      participant,
      blockNumber,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return GetKeyBundle(response);
  }

  /// Returns a live stream of all KeysAdded events emitted by this contract.
  Stream<KeysAdded> keysAddedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('KeysAdded');
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
      return KeysAdded(decoded);
    });
  }
}

class GetKeyBundle {
  GetKeyBundle(List<dynamic> response)
      : var1 = (response[0] as String),
        var2 = (response[1] as String);

  final String var1;

  final String var2;
}

class KeysAdded {
  KeysAdded(List<dynamic> response) : epoch = (response[0] as BigInt);

  final BigInt epoch;
}
