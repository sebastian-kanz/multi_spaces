import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/full_element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_keys_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/get_full_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_bucket_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_key_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_history_usecase.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';

part 'bucket_event.dart';
part 'bucket_state.dart';

class BucketBloc extends Bloc<BucketEvent, BucketState> {
  final ListenBucketEventsUseCase _listenElementsInBucketUseCase;
  final GetFullElementsUseCase _getFullElementsUseCase;
  final SyncElementsUseCase _syncElementsUseCase;
  final SyncHistoryUseCase _syncHistoryUseCase;
  final CreateElementUseCase _createElementUseCase;
  final CreateKeysUseCase _createKeysUseCase;
  final ListenKeyEventsUseCase _listenKeyEventsUseCase;
  final TransactionBloc _transactionBloc;
  final _logger = getLogger();
  StreamSubscription? _elementEventsSubscription;
  StreamSubscription? _listenKeyEventsSubscription;

  BucketBloc({
    required ListenBucketEventsUseCase listenBucketEventsUseCase,
    required GetFullElementsUseCase getFullElementsUseCase,
    required SyncElementsUseCase syncElementsUseCase,
    required SyncHistoryUseCase syncHistoryUseCase,
    required CreateElementUseCase createElementUseCase,
    required CreateKeysUseCase createKeysUseCase,
    required ListenKeyEventsUseCase listenKeyEventsUseCase,
    required TransactionBloc transactionBloc,
    required String bucketName,
    required String tenant,
  })  : _listenElementsInBucketUseCase = listenBucketEventsUseCase,
        _getFullElementsUseCase = getFullElementsUseCase,
        _syncElementsUseCase = syncElementsUseCase,
        _syncHistoryUseCase = syncHistoryUseCase,
        _createElementUseCase = createElementUseCase,
        _createKeysUseCase = createKeysUseCase,
        _listenKeyEventsUseCase = listenKeyEventsUseCase,
        _transactionBloc = transactionBloc,
        super(BucketStateInitial()) {
    on<InitBucketEvent>(_onInitBucketEvent);
    on<GetElementsEvent>(_onGetElementsEvent);
    on<CreateKeysEvent>(_onCreateKeysEvent);
    on<CreateElementEvent>(_onCreateElementEvent);
    on<KeysCreatedEvent>(_onKeysCreatedEvent);
  }

  @override
  Future<void> close() {
    try {
      _elementEventsSubscription?.cancel();
      _listenKeyEventsSubscription?.cancel();
    } catch (e) {
      print(e);
    }
    return super.close();
  }

  void _onInitBucketEvent(
    InitBucketEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      final listenElementsResult = await _listenElementsInBucketUseCase.call();
      final listenKeysResult = await _listenKeyEventsUseCase.call();
      _elementEventsSubscription = listenElementsResult.listen(
        (createEvent) {
          switch (createEvent.runtimeType) {
            case CreateElementEventEntity:
              {
                add(const GetElementsEvent());
                break;
              }
            case UpdateParentElementEventEntity:
              {
                // TODO: To be implemented
                break;
              }
            case UpdateElementEventEntity:
              {
                // TODO: To be implemented
                break;
              }
            case DeleteElementEventEntity:
              {
                // TODO: To be implemented
                break;
              }
          }
        },
        onError: (error) => _logger.d(error),
      );
      _listenKeyEventsSubscription = listenKeysResult.listen(
        (keyEvent) async {
          if (state.runtimeType == WaitingForKeys &&
              (state as WaitingForKeys).epoch == keyEvent) {
            _logger.i(
              "Key created for epoch $keyEvent. Proceeding with event ${(state as WaitingForKeys).event.toString()}.",
            );
            add(
              CreateElementEvent(
                name: ((state as WaitingForKeys).event as CreateElementEvent)
                    .name,
                data: ((state as WaitingForKeys).event as CreateElementEvent)
                    .data,
                type: ((state as WaitingForKeys).event as CreateElementEvent)
                    .type,
                format: ((state as WaitingForKeys).event as CreateElementEvent)
                    .format,
                created: ((state as WaitingForKeys).event as CreateElementEvent)
                    .created,
              ),
            );
          }
        },
        onError: (error) => _logger.d(error),
      );
      emit(BucketInitialized());
    } catch (e) {
      _logger.e(e);
      emit(BucketError(e));
    }
  }

  void _onGetElementsEvent(
    GetElementsEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      final syncHistoryResult = await _syncHistoryUseCase.call(null);
      if (syncHistoryResult.isLeft()) {
        throw (syncHistoryResult as Left<Failure, List<OperationEntity>>);
      }
      final operations =
          (syncHistoryResult as Right<Failure, List<OperationEntity>>).value;
      final syncElementsResult = await _syncElementsUseCase
          .call(SyncOperationsUseCaseParams(true, false));
      if (syncElementsResult.isLeft()) {
        throw (syncElementsResult as Left<Failure, int>);
      }
      final count = (syncElementsResult as Right<Failure, int>).value;
      if (operations.isEmpty) {
        _logger.i("No elements to sync.");
      } else {
        if (count == 0) {
          throw Exception("Nothing was synced!");
        }
      }
      _logger.i("Found $count elements.");
      final fullElementsResult = await _getFullElementsUseCase.call(false);
      if (fullElementsResult.isLeft()) {
        throw (fullElementsResult as Left<Failure, List<FullElementEntity>>);
      }
      final fullElements =
          (fullElementsResult as Right<Failure, List<FullElementEntity>>).value;
      emit(BucketLoaded(fullElements));
    } catch (e) {
      _logger.e(e);
      emit(BucketError(e));
    }
  }

  void _onKeysCreatedEvent(
    KeysCreatedEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      emit(BucketReady(state.elements, event.event));
    } catch (e) {
      _logger.e(e);
      emit(BucketError(e));
    }
  }

  void _onCreateKeysEvent(
    CreateKeysEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      final keyResult = await _createKeysUseCase.call(null);
      if (keyResult.isLeft()) {
        throw (keyResult as Left<Failure, KeyCreation?>);
      }
      if ((keyResult as Right<Failure, KeyCreation?>).value == null) {
        emit(BucketReady(state.elements, event.event));
        return;
      }
      _transactionBloc.add(
        TransactionSubmittedEvent(transactionHash: keyResult.value!.txHash),
      );
      // TODO: How to get notified when key creation is done, so we can proceed with creation?
      emit(WaitingForKeys(state.elements, event.event, keyResult.value!.epoch));
    } catch (e) {
      _logger.e(e);
      emit(BucketError(e));
    }
  }

  void _onCreateElementEvent(
    CreateElementEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      final creationResult = await _createElementUseCase.call(
        CreateElementUseCaseParams(
          event.data,
          CreateMetaDto(
            event.name,
            event.type,
            event.format,
            event.created,
          ),
          zeroAddress,
        ),
      );
      if (creationResult.isLeft()) {
        throw (creationResult as Left<Failure, String>);
      }
      final txHash = (creationResult as Right<Failure, String>).value;

      _transactionBloc.add(
        TransactionSubmittedEvent(transactionHash: txHash),
      );
    } catch (e) {
      _logger.e(e);
      emit(BucketError(e));
    }
  }
}
