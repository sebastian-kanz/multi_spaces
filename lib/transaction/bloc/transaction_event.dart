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

class TransactionsCompletedEvent extends TransactionEvent {
  final List<String> transactionHashes;
  const TransactionsCompletedEvent({required this.transactionHashes});

  @override
  List<Object> get props => [transactionHashes];
}

class TransactionsErroredEvent extends TransactionEvent {
  final List<String> transactionHashes;
  const TransactionsErroredEvent({required this.transactionHashes});

  @override
  List<Object> get props => [transactionHashes];
}
