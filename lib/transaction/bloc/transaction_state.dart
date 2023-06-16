part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  final List<String> transactionHashes;
  const TransactionState(this.transactionHashes);

  @override
  List<Object> get props => [];
}

class TransactionsListening extends TransactionState {
  const TransactionsListening({required transactionHashes})
      : super(transactionHashes);

  @override
  List<Object> get props => [transactionHashes];
}
