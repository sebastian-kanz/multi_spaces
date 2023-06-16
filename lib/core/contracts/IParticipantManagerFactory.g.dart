// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"address","name":"pManager","type":"address"},{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"adr","type":"address"},{"internalType":"bytes","name":"publicKey","type":"bytes"},{"internalType":"address","name":"space","type":"address"}],"name":"createParticipantManager","outputs":[{"internalType":"contract IParticipantManager","name":"","type":"address"}],"stateMutability":"nonpayable","type":"function"}]',
  'IParticipantManagerFactory',
);

class IParticipantManagerFactory extends _i1.GeneratedContract {
  IParticipantManagerFactory({
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
  Future<String> createParticipantManager(
    _i1.EthereumAddress pManager,
    String name,
    _i1.EthereumAddress adr,
    _i2.Uint8List publicKey,
    _i1.EthereumAddress space, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '371bf055'));
    final params = [
      pManager,
      name,
      adr,
      publicKey,
      space,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }
}
