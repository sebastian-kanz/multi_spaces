import 'dart:async';
import 'dart:io';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import '../../core/contracts/PaymentManager.g.dart';

class PaymentRepository {
  PaymentRepository(String paymentManagerContractAddress)
      : _paymentManager = PaymentManager(
          address: EthereumAddress.fromHex(paymentManagerContractAddress),
          client: MultiSpaceClient().client,
          chainId: Env.chain_id,
        ),
        _client = MultiSpaceClient().client;

  final Web3Client _client;
  final PaymentManager _paymentManager;
  final _logger = getLogger();

  Future<GetPaymentState> getPaymentState(EthereumAddress account) {
    return _paymentManager.getPaymentState(account);
  }

  Stream<String> get listenNewBlocks {
    // yield* _client.addedBlocks();
    return _client.addedBlocks();
  }

  Future<TransactionReceipt?> getTransactionReceipt(String hash) async {
    return _client.getTransactionReceipt(hash);
  }

  Stream<LimitedActionEvent> get listenLimitedActions =>
      _paymentManager.limitedActionEventEvents();

  Stream<PayableActionEvent> get listenPayableActions =>
      _paymentManager.payableActionEventEvents();

  Stream<LimitsInitialized> get listenLimitsInitialized =>
      _paymentManager.limitsInitializedEvents();

  Future<String> increaseCredit(EthereumAddress account) async =>
      _paymentManager.increaseCredits(
        account,
        credentials:
            BlockchainProviderManager().authenticatedProvider!.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
          to: _paymentManager.self.address,
          value: EtherAmount.inWei(await defaultPayments(BigInt.from(1))),
        ),
      );

  Future<BigInt> defaultPayments(BigInt payment) => retry(
        () => _paymentManager.DEFAULT_PAYMENTS(payment),
        retryIf: (e) => e is RPCError,
      );

  Future<BigInt> defaultLimits(BigInt limit) => retry(
        () => _paymentManager.DEFAULT_LIMITS(limit),
        retryIf: (e) => e is RPCError,
      );

  Future<BigInt> getLimit(EthereumAddress account) => retry(
        () => _paymentManager.getLimit(
          account,
          BigInt.from(0),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<List<String>> initLimits(List<EthereumAddress> accounts) async {
    var nonce = await _client.getTransactionCount(
      BlockchainProviderManager().internalProvider.getAccount(),
    );
    List<String> receipts = [];
    for (final account in accounts) {
      final receipt = await _paymentManager.initLimits(
        account,
        credentials:
            BlockchainProviderManager().internalProvider.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().internalProvider.getAccount(),
          maxGas: 3000000,
          nonce: nonce,
        ),
      );
      nonce++;
      receipts.add(receipt);
      sleep(const Duration(seconds: 1));
    }
    return receipts;
  }

  Future<bool> limitInitialized(EthereumAddress account) => retry(
        () => _paymentManager.limitsInitialized(account),
        retryIf: (e) => e is RPCError,
      );

  Future<bool> isUnlimited(EthereumAddress account) => retry(
        () => _paymentManager.isUnlimited(
          account,
          BigInt.from(0),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<BigInt> balance(EthereumAddress account) => retry(
        () => _paymentManager.getBalance(
          account,
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<bool> createSpaceIsFreeOfCharge(EthereumAddress account) => retry(
        () => _paymentManager.isFreeOfCharge(
          account,
          BigInt.from(0),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<bool> addBucketIsFreeOfCharge(EthereumAddress account) => retry(
        () => _paymentManager.isFreeOfCharge(
          account,
          BigInt.from(1),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<bool> addParticipantIsFreeOfCharge(EthereumAddress account) => retry(
        () => _paymentManager.isFreeOfCharge(
          account,
          BigInt.from(2),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<BigInt> createSpaceVoucherCount(EthereumAddress account) => retry(
        () => _paymentManager.getVoucherCount(
          account,
          BigInt.from(0),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<BigInt> addBucketVoucherCount(EthereumAddress account) => retry(
        () => _paymentManager.getVoucherCount(
          account,
          BigInt.from(1),
        ),
        retryIf: (e) => e is RPCError,
      );

  Future<BigInt> addParticipantVoucherCount(EthereumAddress account) => retry(
        () => _paymentManager.getVoucherCount(
          account,
          BigInt.from(2),
        ),
        retryIf: (e) => e is RPCError,
      );
}
