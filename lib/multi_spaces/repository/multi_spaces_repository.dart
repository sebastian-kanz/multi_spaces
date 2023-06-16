import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/contracts/MultiSpaces.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class MultiSpacesRepository {
  MultiSpacesRepository(List<BlockchainProvider> providers)
      : _client = Web3Client(Env.eth_url, Client()),
        _multiSpaces = MultiSpaces(
            address: EthereumAddress.fromHex(Env.multi_spaces_contract_address),
            client: Web3Client(Env.eth_url, Client()),
            chainId: Env.chain_id) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  final MultiSpaces _multiSpaces;
  late BlockchainProvider _provider;
  final Web3Client _client;

  Stream<String> get listenNewBlocks async* {
    yield* _client.addedBlocks();
  }

  Future<TransactionReceipt?> getTransactionReceipt(String hash) async {
    return _client.getTransactionReceipt(hash);
  }

  Future<EthereumAddress> getExistingSpace() async {
    final pubKey = _provider.getPublicKey();
    return _multiSpaces.ownedSpaces(pubKey);
  }

  Future<EthereumAddress> getPaymentManager() async {
    return _multiSpaces.paymentManager();
  }

  Future<String> createSpace() async {
    final baseFee = await _multiSpaces.baseFee();
    final account = _provider.getAccount();
    final balance = await _client.getBalance(account);
    if (balance.getInWei < baseFee) {
      throw InsufficientFundsException(
        "Account: $account | Funds needed: $baseFee | Funds available: ${balance.getInWei}",
      );
    }
    return _multiSpaces.createSpace(
      "MySpace",
      _provider.getPublicKey(),
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: account,
        maxGas: 3000000,
        value: EtherAmount.inWei(baseFee),
      ),
    );
  }
}
