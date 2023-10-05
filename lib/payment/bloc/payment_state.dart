part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentStateInitial extends PaymentState {
  const PaymentStateInitial();
}

class LimitsUninitialized extends PaymentState {
  final List<String> transactionHashes;
  final List<EthereumAddress> accounts;
  final int selected;
  const LimitsUninitialized(
      {required this.transactionHashes,
      required this.accounts,
      required this.selected});

  @override
  List<Object> get props => [transactionHashes, accounts, selected];
}

class LimitsInitialized extends PaymentState {
  const LimitsInitialized();
}

class PaymentInitialized extends PaymentState {
  final int limit;
  final bool isUnlimited;
  final int balance; // credits
  final int createSpaceVouchers; // voucher
  final int addBucketVouchers; // voucher
  final int addParticipantVouchers; // voucher
  final bool createSpaceIsFreeOfCharge;
  final bool addBucketIsFreeOfCharge;
  final bool addParticipantIsFreeOfCharge;
  final int defaultLimit;
  final int defaultPayment;

  const PaymentInitialized({
    required this.limit,
    required this.isUnlimited,
    required this.balance,
    required this.createSpaceVouchers,
    required this.addBucketVouchers,
    required this.addParticipantVouchers,
    required this.createSpaceIsFreeOfCharge,
    required this.addBucketIsFreeOfCharge,
    required this.addParticipantIsFreeOfCharge,
    required this.defaultLimit,
    required this.defaultPayment,
  });

  @override
  List<Object> get props => [
        limit,
        isUnlimited,
        balance,
        createSpaceVouchers,
        addBucketVouchers,
        addParticipantVouchers,
        createSpaceIsFreeOfCharge,
        addBucketIsFreeOfCharge,
        addParticipantIsFreeOfCharge,
        defaultLimit,
        defaultPayment
      ];
}

class PaymentError extends PaymentState {
  final Object error;
  const PaymentError(this.error);

  @override
  List<Object> get props => [error];
}
