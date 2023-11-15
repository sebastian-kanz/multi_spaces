part of 'transaction_bloc.dart';

class NamedTransaction {
  final String? description;
  final String hash;
  const NamedTransaction({required this.hash, this.description});
}

abstract class TransactionState extends Equatable {
  final List<NamedTransaction> waitingTransactions;
  final List<NamedTransaction> failedTransactions;
  const TransactionState(
    this.waitingTransactions,
    this.failedTransactions,
  );

  @override
  List<Object> get props => [waitingTransactions, failedTransactions];
}

class TransactionsChanged extends TransactionState {
  const TransactionsChanged({
    required waitingTransactions,
    failedTransactions = const <NamedTransaction>[],
  }) : super(waitingTransactions, failedTransactions);
}

class TransactionsListening extends TransactionState {
  const TransactionsListening({
    required waitingTransactions,
    failedTransactions = const <NamedTransaction>[],
  }) : super(waitingTransactions, failedTransactions);
}
