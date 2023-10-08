import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/contracts/MultiSpaces.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';

class MultiSpacesRepository {
  MultiSpacesRepository()
      : _client = MultiSpaceClient().client,
        _multiSpaces = MultiSpaces(
            address: EthereumAddress.fromHex(Env.multi_spaces_contract_address),
            client: MultiSpaceClient().client,
            chainId: Env.chain_id);

  final MultiSpaces _multiSpaces;
  final Web3Client _client;

  Stream<String> get listenNewBlocks {
    // yield* _client.addedBlocks();
    return _client.addedBlocks();
  }

  Future<TransactionReceipt?> getTransactionReceipt(String hash) async {
    return _client.getTransactionReceipt(hash);
  }

  Future<EthereumAddress> getExistingSpace() async {
    final pubKey =
        BlockchainProviderManager().authenticatedProvider!.getPublicKey();
    return _multiSpaces.ownedSpaces(pubKey);
  }

  Future<EthereumAddress> getPaymentManager() async {
    return _multiSpaces.paymentManager();
  }

  Future<String> createSpace(String name) async {
    final baseFee = await _multiSpaces.baseFee();
    final account =
        BlockchainProviderManager().authenticatedProvider!.getAccount();
    final balance = await _client.getBalance(account);
    if (balance.getInWei < baseFee) {
      throw InsufficientFundsException(
        "Account: $account | Funds needed: $baseFee | Funds available: ${balance.getInWei}",
      );
    }
    return _multiSpaces.createSpace(
      name,
      BlockchainProviderManager().authenticatedProvider!.getPublicKey(),
      credentials:
          BlockchainProviderManager().authenticatedProvider!.getCredentails(),
      transaction: Transaction(
        from: account,
        maxGas: 3000000,
        value: EtherAmount.inWei(baseFee),
      ),
    );
  }
}
