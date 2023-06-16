import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final _logger = getLogger();
  final Web3Client _client;
  late final StreamSubscription _newBlocksSubscription;

  TransactionBloc()
      : _client = Web3Client(Env.eth_url, Client()),
        super(TransactionsListening(transactionHashes: List<String>.empty())) {
    on<TransactionSubmittedEvent>(_onTransactionSubmittedEvent);
    on<TransactionCompletedEvent>(_onTransactionCompletedEvent);
    on<TransactionErroredEvent>(_onTransactionErroredEvent);
    _newBlocksSubscription = _client.addedBlocks().listen(
      (newBlock) async {
        final hashes = List<String>.from(
          (state as TransactionsListening).transactionHashes,
        );
        for (var hash in hashes) {
          final receipt = await _client.getTransactionReceipt(hash);
          if (receipt != null) {
            if (bytesToHex(receipt.blockHash, include0x: true) == newBlock) {
              if (receipt.status == true) {
                add(TransactionCompletedEvent(transactionHash: hash));
              } else {
                _logger.d(receipt);
                add(TransactionErroredEvent(transactionHash: hash));
              }
            }
          }
        }
      },
      onError: (error) => _logger.e(error),
    );
  }

  void _onTransactionSubmittedEvent(
    TransactionSubmittedEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(
        TransactionsListening(
          transactionHashes: [
            ...(state as TransactionsListening).transactionHashes,
            event.transactionHash
          ],
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  void _onTransactionCompletedEvent(
    TransactionCompletedEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final hashes = (state as TransactionsListening).transactionHashes;
      hashes.remove(event.transactionHash);
      emit(
        TransactionsListening(
          transactionHashes: hashes,
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  void _onTransactionErroredEvent(
    TransactionErroredEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final hashes = (state as TransactionsListening).transactionHashes;
      hashes.remove(event.transactionHash);
      emit(
        TransactionsListening(
          transactionHashes: hashes,
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }
}
