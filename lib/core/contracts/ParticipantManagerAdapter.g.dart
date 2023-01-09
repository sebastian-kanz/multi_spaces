// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[],"name":"participantManager","outputs":[{"internalType":"contract IParticipantManager","name":"","type":"address"}],"stateMutability":"view","type":"function"}]',
  'ParticipantManagerAdapter',
);

class ParticipantManagerAdapter extends _i1.GeneratedContract {
  ParticipantManagerAdapter({
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
  Future<_i1.EthereumAddress> participantManager(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '464dbe6e'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }
}
