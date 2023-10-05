part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  final List<String> transactionHashes;
  final List<String> failedTransactionHashes;
  const TransactionState(
    this.transactionHashes,
    this.failedTransactionHashes,
  );

  @override
  List<Object> get props => [];
}

class TransactionsChanged extends TransactionState {
  TransactionsChanged({
    required transactionHashes,
    failedTransactionHashes = const <String>[],
  }) : super(transactionHashes, failedTransactionHashes);

  @override
  List<Object> get props => [transactionHashes];
}

class TransactionsListening extends TransactionState {
  const TransactionsListening({
    required transactionHashes,
    failedTransactionHashes = const <String>[],
  }) : super(transactionHashes, failedTransactionHashes);

  @override
  List<Object> get props => [transactionHashes];
}
