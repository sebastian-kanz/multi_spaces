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
        super(TransactionsListening(transactionHashes: List<String>.empty())) {
    on<TransactionSubmittedEvent>(_onTransactionSubmittedEvent);
    on<TransactionsCompletedEvent>(_onTransactionCompletedEvent);
    on<TransactionsErroredEvent>(_onTransactionErroredEvent);
  }

  Future<void> _setupNewBlockListener() async {
    final blockStream = Stream<void>.periodic(const Duration(seconds: 5));
    _newBlocksSubscription ??= blockStream.listen(
      (newBlock) async {
        final hashes = List<String>.from(
          (state as TransactionsListening).transactionHashes,
        );
        final List<String> successfulTx = [];
        final List<String> failedTx = [];
        for (var hash in hashes.where((elem) => elem != "")) {
          final receipt = await _client.getTransactionReceipt(hash);
          if (receipt != null) {
            if (receipt.status == true) {
              successfulTx.add(hash);
            } else {
              failedTx.add(hash);
            }
            break;
          }
        }
        if (successfulTx.isNotEmpty) {
          add(TransactionsCompletedEvent(transactionHashes: successfulTx));
        }
        if (failedTx.isNotEmpty) {
          add(TransactionsErroredEvent(transactionHashes: failedTx));
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
      _logger.d("Transaction submitted: ${event.transactionHash}");
      _setupNewBlockListener();
      emit(TransactionsChanged(
        transactionHashes: [...state.transactionHashes, event.transactionHash],
      ));
      emit(
        TransactionsListening(
          transactionHashes: [
            ...state.transactionHashes,
            event.transactionHash
          ],
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
      final hashes = state.transactionHashes;
      final failedHashes = state.failedTransactionHashes;
      for (var hash in event.transactionHashes) {
        hashes.remove(hash);
      }
      _logger.d(
        "Transactions completed: ${event.transactionHashes.toString()}. ${hashes.length} open tx left.",
      );

      emit(TransactionsChanged(
        transactionHashes: hashes,
        failedTransactionHashes: failedHashes,
      ));
      emit(
        TransactionsListening(
          transactionHashes: hashes,
        ),
      );
      if (hashes.isEmpty) {
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
      final hashes = state.transactionHashes;
      final failedHashes = state.failedTransactionHashes;
      for (var hash in event.transactionHashes) {
        hashes.remove(hash);
      }

      _logger.d(
        "Transactions errored: ${event.transactionHashes.toString()}. ${hashes.length} open tx left.",
      );

      emit(TransactionsChanged(
        transactionHashes: hashes,
        failedTransactionHashes: failedHashes,
      ));
      emit(
        TransactionsListening(
            transactionHashes: hashes,
            failedTransactionHashes: [...event.transactionHashes]),
      );
      if (hashes.isEmpty) {
        await _newBlocksSubscription?.cancel();
        _newBlocksSubscription = null;
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
