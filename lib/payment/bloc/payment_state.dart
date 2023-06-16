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
  final String transactionHash;
  final EthereumAddress account;
  const LimitsUninitialized(
      {required this.transactionHash, required this.account});

  @override
  List<Object> get props => [transactionHash, account];
}

class LimitsInitialized extends PaymentState {
  const LimitsInitialized();
}

class PaymentInitialized extends PaymentState {
  final int limit;
  final bool isUnlimited;
  final int balance;
  final int createSpaceVouchers;
  final int addBucketVouchers;
  final int addParticipantVouchers;
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
