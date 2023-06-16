import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import '../../core/contracts/PaymentManager.g.dart';

class PaymentRepository {
  PaymentRepository(
      List<BlockchainProvider> providers, String paymentManagerContractAddress)
      : _paymentManager = PaymentManager(
          address: EthereumAddress.fromHex(paymentManagerContractAddress),
          client: Web3Client(Env.eth_url, Client()),
          chainId: Env.chain_id,
        ),
        _client = Web3Client(Env.eth_url, Client()) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  final Web3Client _client;
  final PaymentManager _paymentManager;
  late BlockchainProvider _provider;
  final _logger = getLogger();

  Stream<String> get listenNewBlocks async* {
    yield* _client.addedBlocks();
  }

  Future<TransactionReceipt?> getTransactionReceipt(String hash) async {
    return _client.getTransactionReceipt(hash);
  }

  Stream<LimitedActionEvent> get listenLimitedActions =>
      _paymentManager.limitedActionEventEvents();

  Stream<PayableActionEvent> get listenPayableActions =>
      _paymentManager.payableActionEventEvents();

  Future<String> increaseCredit(EthereumAddress account) async =>
      _paymentManager.increaseCredits(
        account,
        credentials: _provider.getCredentails(),
        transaction: Transaction(
          from: _provider.getAccount(),
          to: _paymentManager.self.address,
          value: EtherAmount.inWei(await defaultPayments(BigInt.from(1))),
        ),
      );

  Future<BigInt> defaultPayments(BigInt payment) =>
      _paymentManager.DEFAULT_PAYMENTS(payment);

  Future<BigInt> defaultLimits(BigInt limit) =>
      _paymentManager.DEFAULT_LIMITS(limit);

  Future<BigInt> getLimit(EthereumAddress account) => _paymentManager.getLimit(
        account,
        BigInt.from(0),
      );

  Future<String> initLimits(EthereumAddress account) =>
      _paymentManager.initLimits(
        account,
        credentials: _provider.getCredentails(),
        transaction: Transaction(
          from: _provider.getAccount(),
        ),
      );

  Future<bool> limitInitialized(EthereumAddress account) =>
      _paymentManager.limitsInitialized(account);

  Future<bool> isUnlimited(EthereumAddress account) =>
      _paymentManager.isUnlimited(
        account,
        BigInt.from(0),
      );

  Future<BigInt> balance(EthereumAddress account) => _paymentManager.getBalance(
        account,
      );

  Future<bool> createSpaceIsFreeOfCharge(EthereumAddress account) =>
      _paymentManager.isFreeOfCharge(
        account,
        BigInt.from(0),
      );

  Future<bool> addBucketIsFreeOfCharge(EthereumAddress account) =>
      _paymentManager.isFreeOfCharge(
        account,
        BigInt.from(1),
      );

  Future<bool> addParticipantIsFreeOfCharge(EthereumAddress account) =>
      _paymentManager.isFreeOfCharge(
        account,
        BigInt.from(2),
      );

  Future<BigInt> createSpaceVoucherCount(EthereumAddress account) =>
      _paymentManager.getVoucherCount(
        account,
        BigInt.from(0),
      );

  Future<BigInt> addBucketVoucherCount(EthereumAddress account) =>
      _paymentManager.getVoucherCount(
        account,
        BigInt.from(1),
      );

  Future<BigInt> addParticipantVoucherCount(EthereumAddress account) =>
      _paymentManager.getVoucherCount(
        account,
        BigInt.from(2),
      );
}
