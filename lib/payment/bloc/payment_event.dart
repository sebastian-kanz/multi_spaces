part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class InitPaymentEvent extends PaymentEvent {
  final EthereumAddress account;
  const InitPaymentEvent({required this.account});

  @override
  List<Object> get props => [account];
}

class LoadPaymentEvent extends PaymentEvent {
  final EthereumAddress account;
  const LoadPaymentEvent({required this.account});

  @override
  List<Object> get props => [account];
}

class AddFundsEvent extends PaymentEvent {
  final EthereumAddress account;
  const AddFundsEvent({required this.account});

  @override
  List<Object> get props => [account];
}
