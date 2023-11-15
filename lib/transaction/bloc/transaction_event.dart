part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionSubmittedEvent extends TransactionEvent {
  final NamedTransaction transaction;
  const TransactionSubmittedEvent({
    required this.transaction,
  });

  @override
  List<Object> get props => [transaction];
}

class TransactionsCompletedEvent extends TransactionEvent {
  final List<NamedTransaction> transactions;
  const TransactionsCompletedEvent({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class TransactionsErroredEvent extends TransactionEvent {
  final List<NamedTransaction> transactions;
  const TransactionsErroredEvent({required this.transactions});

  @override
  List<Object> get props => [transactions];
}
