part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionSubmittedEvent extends TransactionEvent {
  final String transactionHash;
  const TransactionSubmittedEvent({required this.transactionHash});

  @override
  List<Object> get props => [transactionHash];
}

class TransactionCompletedEvent extends TransactionEvent {
  final String transactionHash;
  const TransactionCompletedEvent({required this.transactionHash});

  @override
  List<Object> get props => [transactionHash];
}

class TransactionErroredEvent extends TransactionEvent {
  final String transactionHash;
  const TransactionErroredEvent({required this.transactionHash});

  @override
  List<Object> get props => [transactionHash];
}
