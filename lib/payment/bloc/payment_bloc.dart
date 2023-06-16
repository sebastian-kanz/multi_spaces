import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/payment/repository/payment_repository.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:web3dart/web3dart.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;
  final _logger = getLogger();
  late final StreamSubscription _limitedActionSubscription;
  late final StreamSubscription _payableActionSubscription;
  late final StreamSubscription _newBlocksSubscription;

  PaymentBloc(
      {required PaymentRepository paymentRepository,
      required TransactionBloc transactionBloc})
      : _paymentRepository = paymentRepository,
        super(const PaymentStateInitial()) {
    on<InitPaymentEvent>(_onInitPaymentEvent);
    on<LoadPaymentEvent>(_onLoadPaymentEvent);
    on<AddFundsEvent>(_onAddFundsEvent);

    _limitedActionSubscription = _paymentRepository.listenLimitedActions.listen(
      (limitedActionEvent) {
        _logger.d(
          'Processed limited action of type ${limitedActionEvent.action} from ${limitedActionEvent.sender}. Limit now: ${limitedActionEvent.limitLeftOver} | Unlimited: ${limitedActionEvent.unlimited}.',
        );
      },
      onError: (error) => _logger.d(error),
    );

    _payableActionSubscription = _paymentRepository.listenPayableActions.listen(
      (payableActionEvent) {
        _logger.d(
          'Processed payable action of type ${payableActionEvent.action} from ${payableActionEvent.sender}. Paid: ${payableActionEvent.fee} | Used voucher: ${payableActionEvent.voucher} | Unlimited: ${payableActionEvent.unlimited}.',
        );
      },
      onError: (error) => _logger.d(error),
    );

    _newBlocksSubscription = _paymentRepository.listenNewBlocks.listen(
      (newBlock) async {
        if (state.runtimeType == LimitsUninitialized) {
          final receipt = await _paymentRepository.getTransactionReceipt(
              (state as LimitsUninitialized).transactionHash);
          if (receipt != null) {
            if (receipt.status == true) {
              add(
                LoadPaymentEvent(
                  account: (state as LimitsUninitialized).account,
                ),
              );
            } else {
              _logger.d(receipt);
            }
          }
        }
      },
      onError: (error) => _logger.e(error),
    );
  }

  @override
  Future<void> close() {
    _limitedActionSubscription.cancel();
    _payableActionSubscription.cancel();
    _newBlocksSubscription.cancel();
    return super.close();
  }

  void _onLoadPaymentEvent(
    LoadPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const LimitsInitialized());
      final limit = await _paymentRepository.getLimit(event.account);
      final defaultPayment =
          await _paymentRepository.defaultPayments(BigInt.from(0));
      final defaultLimit =
          await _paymentRepository.defaultLimits(BigInt.from(0));
      final isUnlimited = await _paymentRepository.isUnlimited(event.account);
      final balance = await _paymentRepository.balance(event.account);
      final createSpaceIsFreeOfCharge =
          await _paymentRepository.createSpaceIsFreeOfCharge(event.account);
      final addBucketIsFreeOfCharge =
          await _paymentRepository.addBucketIsFreeOfCharge(event.account);
      final addParticipantIsFreeOfCharge =
          await _paymentRepository.addParticipantIsFreeOfCharge(event.account);
      final createSpaceVoucherCount =
          await _paymentRepository.createSpaceVoucherCount(event.account);
      final addBucketVoucherCount =
          await _paymentRepository.addBucketVoucherCount(event.account);
      final addParticipantVoucherCount =
          await _paymentRepository.addParticipantVoucherCount(event.account);
      emit(
        PaymentInitialized(
          limit: limit.toInt(),
          isUnlimited: isUnlimited,
          balance: balance.toInt() ~/ defaultPayment.toInt(),
          createSpaceVouchers: createSpaceVoucherCount.toInt(),
          addBucketVouchers: addBucketVoucherCount.toInt(),
          addParticipantVouchers: addParticipantVoucherCount.toInt(),
          createSpaceIsFreeOfCharge: createSpaceIsFreeOfCharge,
          addBucketIsFreeOfCharge: addBucketIsFreeOfCharge,
          addParticipantIsFreeOfCharge: addParticipantIsFreeOfCharge,
          defaultLimit: defaultLimit.toInt(),
          defaultPayment: defaultPayment.toInt(),
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(PaymentError(e));
    }
  }

  void _onInitPaymentEvent(
    InitPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final limitsInitialized =
          await _paymentRepository.limitInitialized(event.account);
      if (limitsInitialized) {
        final limit = await _paymentRepository.getLimit(event.account);
        final defaultPayment =
            await _paymentRepository.defaultPayments(BigInt.from(0));
        final defaultLimit =
            await _paymentRepository.defaultLimits(BigInt.from(0));
        final isUnlimited = await _paymentRepository.isUnlimited(event.account);
        final balance = await _paymentRepository.balance(event.account);
        final createSpaceIsFreeOfCharge =
            await _paymentRepository.createSpaceIsFreeOfCharge(event.account);
        final addBucketIsFreeOfCharge =
            await _paymentRepository.addBucketIsFreeOfCharge(event.account);
        final addParticipantIsFreeOfCharge = await _paymentRepository
            .addParticipantIsFreeOfCharge(event.account);
        final createSpaceVoucherCount =
            await _paymentRepository.createSpaceVoucherCount(event.account);
        final addBucketVoucherCount =
            await _paymentRepository.addBucketVoucherCount(event.account);
        final addParticipantVoucherCount =
            await _paymentRepository.addParticipantVoucherCount(event.account);
        emit(
          PaymentInitialized(
            limit: limit.toInt(),
            isUnlimited: isUnlimited,
            balance: balance.toInt() ~/ defaultPayment.toInt(),
            createSpaceVouchers: createSpaceVoucherCount.toInt(),
            addBucketVouchers: addBucketVoucherCount.toInt(),
            addParticipantVouchers: addParticipantVoucherCount.toInt(),
            createSpaceIsFreeOfCharge: createSpaceIsFreeOfCharge,
            addBucketIsFreeOfCharge: addBucketIsFreeOfCharge,
            addParticipantIsFreeOfCharge: addParticipantIsFreeOfCharge,
            defaultLimit: defaultLimit.toInt(),
            defaultPayment: defaultPayment.toInt(),
          ),
        );
      } else {
        final receipt = await _paymentRepository.initLimits(event.account);
        emit(LimitsUninitialized(
            transactionHash: receipt, account: event.account));
      }
    } catch (e) {
      _logger.e(e);
      emit(PaymentError(e));
    }
  }

  void _onAddFundsEvent(
    AddFundsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      await _paymentRepository.increaseCredit(event.account);
      final defaultPayment =
          await _paymentRepository.defaultPayments(BigInt.from(0));
      final defaultLimit =
          await _paymentRepository.defaultLimits(BigInt.from(0));
      final limit = await _paymentRepository.getLimit(event.account);
      final isUnlimited = await _paymentRepository.isUnlimited(event.account);
      final balance = await _paymentRepository.balance(event.account);
      final createSpaceIsFreeOfCharge =
          await _paymentRepository.createSpaceIsFreeOfCharge(event.account);
      final addBucketIsFreeOfCharge =
          await _paymentRepository.addBucketIsFreeOfCharge(event.account);
      final addParticipantIsFreeOfCharge =
          await _paymentRepository.addParticipantIsFreeOfCharge(event.account);
      final createSpaceVoucherCount =
          await _paymentRepository.createSpaceVoucherCount(event.account);
      final addBucketVoucherCount =
          await _paymentRepository.addBucketVoucherCount(event.account);
      final addParticipantVoucherCount =
          await _paymentRepository.addParticipantVoucherCount(event.account);
      emit(
        PaymentInitialized(
          limit: limit.toInt(),
          isUnlimited: isUnlimited,
          balance: balance.toInt(),
          createSpaceVouchers: createSpaceVoucherCount.toInt(),
          addBucketVouchers: addBucketVoucherCount.toInt(),
          addParticipantVouchers: addParticipantVoucherCount.toInt(),
          createSpaceIsFreeOfCharge: createSpaceIsFreeOfCharge,
          addBucketIsFreeOfCharge: addBucketIsFreeOfCharge,
          addParticipantIsFreeOfCharge: addParticipantIsFreeOfCharge,
          defaultLimit: defaultLimit.toInt(),
          defaultPayment: defaultPayment.toInt(),
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(PaymentError(e));
    }
  }
}
