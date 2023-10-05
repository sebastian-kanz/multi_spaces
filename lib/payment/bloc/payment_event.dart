part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class InitPaymentsEvent extends PaymentEvent {
  final List<EthereumAddress> accounts;
  final int selected;
  const InitPaymentsEvent({required this.accounts, required this.selected});

  @override
  List<Object> get props => [accounts, selected];
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
