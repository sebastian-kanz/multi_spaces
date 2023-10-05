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
  late final StreamSubscription _limitsInitializedSubscription;

  PaymentBloc(
      {required PaymentRepository paymentRepository,
      required TransactionBloc transactionBloc})
      : _paymentRepository = paymentRepository,
        super(const PaymentStateInitial()) {
    on<InitPaymentsEvent>(_onInitPaymentEvent);
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

    _limitsInitializedSubscription =
        _paymentRepository.listenLimitsInitialized.listen(
      (limitsInitializedEvent) async {
        _logger.d(
          'Limits initialized for account ${limitsInitializedEvent.account}',
        );
        if (state.runtimeType == LimitsUninitialized) {
          for (var i = 0;
              i < (state as LimitsUninitialized).accounts.length;
              i++) {
            final receipt = await _paymentRepository.getTransactionReceipt(
              (state as LimitsUninitialized).transactionHashes[i],
            );
            if (receipt != null) {
              if (receipt.status == true &&
                  (state as LimitsUninitialized).selected == i) {
                add(
                  LoadPaymentEvent(
                    account: (state as LimitsUninitialized).accounts[i],
                  ),
                );
              } else {
                _logger.d(receipt);
              }
            }
          }
        }
      },
      onError: (error) => _logger.d(error),
    );
  }

  @override
  Future<void> close() {
    _limitedActionSubscription.cancel();
    _payableActionSubscription.cancel();
    _limitsInitializedSubscription.cancel();
    return super.close();
  }

  void _onLoadPaymentEvent(
    LoadPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const LimitsInitialized());
      final paymentState = await _paymentRepository.getPaymentState(
        event.account,
      );
      emit(
        PaymentInitialized(
          limit: paymentState.var1.toInt(),
          isUnlimited: paymentState.var2,
          balance: paymentState.var3.toInt() ~/ paymentState.var11.toInt(),
          createSpaceVouchers: paymentState.var4.toInt(),
          addBucketVouchers: paymentState.var5.toInt(),
          addParticipantVouchers: paymentState.var6.toInt(),
          createSpaceIsFreeOfCharge: paymentState.var7,
          addBucketIsFreeOfCharge: paymentState.var8,
          addParticipantIsFreeOfCharge: paymentState.var9,
          defaultLimit: paymentState.var10.toInt(),
          defaultPayment: paymentState.var11.toInt(),
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(PaymentError(e));
    }
  }

  void _onInitPaymentEvent(
    InitPaymentsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // TODO: Add info banner to user that explains current action
      var limitsInitialized = true;
      for (final account in event.accounts) {
        final accLimitsInitialized =
            await _paymentRepository.limitInitialized(account);
        if (!accLimitsInitialized) {
          limitsInitialized = false;
        }
      }

      if (limitsInitialized) {
        final paymentState = await _paymentRepository.getPaymentState(
          event.accounts[event.selected],
        );
        emit(
          PaymentInitialized(
            limit: paymentState.var1.toInt(),
            isUnlimited: paymentState.var2,
            balance: paymentState.var3.toInt() ~/ paymentState.var11.toInt(),
            createSpaceVouchers: paymentState.var4.toInt(),
            addBucketVouchers: paymentState.var5.toInt(),
            addParticipantVouchers: paymentState.var6.toInt(),
            createSpaceIsFreeOfCharge: paymentState.var7,
            addBucketIsFreeOfCharge: paymentState.var8,
            addParticipantIsFreeOfCharge: paymentState.var9,
            defaultLimit: paymentState.var10.toInt(),
            defaultPayment: paymentState.var11.toInt(),
          ),
        );
      } else {
        // TODO: What about buckets later?
        final receipts = await _paymentRepository.initLimits(event.accounts);
        emit(LimitsUninitialized(
          transactionHashes: receipts,
          accounts: event.accounts,
          selected: event.selected,
        ));
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

      final paymentState = await _paymentRepository.getPaymentState(
        event.account,
      );
      emit(
        PaymentInitialized(
          limit: paymentState.var1.toInt(),
          isUnlimited: paymentState.var2,
          balance: paymentState.var3.toInt() ~/ paymentState.var11.toInt(),
          createSpaceVouchers: paymentState.var4.toInt(),
          addBucketVouchers: paymentState.var5.toInt(),
          addParticipantVouchers: paymentState.var6.toInt(),
          createSpaceIsFreeOfCharge: paymentState.var7,
          addBucketIsFreeOfCharge: paymentState.var8,
          addParticipantIsFreeOfCharge: paymentState.var9,
          defaultLimit: paymentState.var10.toInt(),
          defaultPayment: paymentState.var11.toInt(),
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(PaymentError(e));
    }
  }
}
