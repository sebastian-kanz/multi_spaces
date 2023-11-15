import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final _logger = getLogger();
  final Web3Client _client;
  StreamSubscription? _newBlocksSubscription;

  TransactionBloc()
      : _client = MultiSpaceClient().client,
        super(
          TransactionsListening(
            waitingTransactions: List<NamedTransaction>.empty(),
          ),
        ) {
    on<TransactionSubmittedEvent>(_onTransactionSubmittedEvent);
    on<TransactionsCompletedEvent>(_onTransactionCompletedEvent);
    on<TransactionsErroredEvent>(_onTransactionErroredEvent);
  }

  Future<void> _setupNewBlockListener() async {
    final blockStream = Stream<void>.periodic(const Duration(seconds: 5));
    _newBlocksSubscription ??= blockStream.listen(
      (newBlock) async {
        final transactions = List<NamedTransaction>.from(
          (state as TransactionsListening).waitingTransactions,
        );
        final List<NamedTransaction> successfulTx = [];
        final List<NamedTransaction> failedTx = [];
        for (var tx in transactions.where((elem) => elem.hash != "")) {
          final receipt = await _client.getTransactionReceipt(tx.hash);
          if (receipt != null) {
            if (receipt.status == true) {
              successfulTx.add(tx);
            } else {
              failedTx.add(tx);
            }
            break;
          }
        }
        if (successfulTx.isNotEmpty) {
          add(TransactionsCompletedEvent(transactions: successfulTx));
        }
        if (failedTx.isNotEmpty) {
          add(TransactionsErroredEvent(transactions: failedTx));
        }
      },
      onError: (error) => _logger.e(error),
    );
  }

  @override
  Future<void> close() {
    _newBlocksSubscription?.cancel();
    return super.close();
  }

  void _onTransactionSubmittedEvent(
    TransactionSubmittedEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      _logger.d("Transaction submitted: ${event.transaction.hash}");
      _setupNewBlockListener();
      emit(TransactionsChanged(
        waitingTransactions: [...state.waitingTransactions, event.transaction],
        failedTransactions: state.failedTransactions,
      ));
      emit(
        TransactionsListening(
          waitingTransactions: [
            ...state.waitingTransactions,
            event.transaction
          ],
          failedTransactions: state.failedTransactions,
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  void _onTransactionCompletedEvent(
    TransactionsCompletedEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final waitingTx = state.waitingTransactions;
      final failedTx = state.failedTransactions;
      for (var tx in event.transactions) {
        waitingTx.removeWhere((element) =>
            element.hash == tx.hash && element.description == tx.description);
      }
      _logger.d(
        "Transactions completed: ${event.transactions.map((e) => e.hash)}. ${waitingTx.length} open tx left.",
      );

      emit(TransactionsChanged(
        waitingTransactions: waitingTx,
        failedTransactions: failedTx,
      ));
      emit(
        TransactionsListening(
          waitingTransactions: waitingTx,
        ),
      );
      if (waitingTx.isEmpty) {
        await _newBlocksSubscription?.cancel();
        _newBlocksSubscription = null;
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void _onTransactionErroredEvent(
    TransactionsErroredEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final waitingTx = state.waitingTransactions;
      final failedTx = state.failedTransactions;
      for (var tx in event.transactions) {
        waitingTx.removeWhere((element) =>
            element.hash == tx.hash && element.description == tx.description);
      }

      _logger.d(
        "Transactions errored: ${event.transactions.map((e) => e.hash)}. ${waitingTx.length} open tx left.",
      );

      emit(TransactionsChanged(
        waitingTransactions: waitingTx,
        failedTransactions: failedTx,
      ));
      emit(
        TransactionsListening(
          waitingTransactions: waitingTx,
          failedTransactions: [...event.transactions],
        ),
      );
      if (waitingTx.isEmpty) {
        await _newBlocksSubscription?.cancel();
        _newBlocksSubscription = null;
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
