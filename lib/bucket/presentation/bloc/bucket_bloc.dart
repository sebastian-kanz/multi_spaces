import 'dart:async';
import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/full_element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/bucket/domain/usecase/accept_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/add_device_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/check_device_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/check_provider_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/create_keys_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/get_full_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/get_requests_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_bucket_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_key_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_participation_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_request_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/request_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_history_usecase.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

part 'bucket_event.dart';
part 'bucket_state.dart';
part 'bucket_bloc.g.dart';

class BucketBloc extends HydratedBloc<BucketEvent, BucketState> {
  final ListenBucketEventsUseCase _listenElementsInBucketUseCase;
  final GetFullElementsUseCase _getFullElementsUseCase;
  final SyncElementsUseCase _syncElementsUseCase;
  final SyncHistoryUseCase _syncHistoryUseCase;
  final CreateElementUseCase _createElementUseCase;
  final CreateKeysUseCase _createKeysUseCase;
  final ListenKeyEventsUseCase _listenKeyEventsUseCase;
  final CheckDeviceParticipationUseCase _checkDeviceParticipationUseCase;
  final CheckProviderParticipationUseCase _checkProviderParticipationUseCase;
  final RequestParticipationUseCase _requestParticipationUseCase;
  final AcceptParticipationUseCase _acceptParticipationUseCase;
  final ListenRequestEventsUseCase _listenRequestEventsUseCase;
  final ListenElementUseCase _listenElementUseCase;
  final ListenParticipationEventsUseCase _listenParticipationEventsUseCase;
  final GetActiveRequestsUseCase _getActiveRequestsUseCase;
  final AddDeviceParticipationUseCase _addDeviceParticipationUseCase;
  final TransactionBloc _transactionBloc;
  final _logger = getLogger();
  StreamSubscription? _elementEventsSubscription;
  StreamSubscription? _listenKeyEventsSubscription;
  StreamSubscription? _listenParticipationEventsSubscription;
  StreamSubscription? _listenRequestEventsSubscription;
  final List<StreamSubscription> _listenElementsSubscriptions = [];
  final String _bucketName;
  final String _tenant;
  final String _bucketAddress;
  final bool _isExternal;

  BucketBloc({
    required ListenBucketEventsUseCase listenBucketEventsUseCase,
    required GetFullElementsUseCase getFullElementsUseCase,
    required SyncElementsUseCase syncElementsUseCase,
    required SyncHistoryUseCase syncHistoryUseCase,
    required CreateElementUseCase createElementUseCase,
    required CreateKeysUseCase createKeysUseCase,
    required ListenKeyEventsUseCase listenKeyEventsUseCase,
    required CheckDeviceParticipationUseCase checkDeviceParticipationUseCase,
    required CheckProviderParticipationUseCase
        checkProviderParticipationUseCase,
    required RequestParticipationUseCase requestParticipationUseCase,
    required AcceptParticipationUseCase acceptParticipationUseCase,
    required GetActiveRequestsUseCase getActiveRequestsUseCase,
    required AddDeviceParticipationUseCase addDeviceParticipationUseCase,
    required ListenElementUseCase listenElementUseCase,
    required ListenParticipationEventsUseCase listenParticipationEventsUseCase,
    required ListenRequestEventsUseCase listenRequestEventsUseCase,
    required TransactionBloc transactionBloc,
    required String bucketName,
    required String tenant,
    required String bucketAddress,
    required bool isExternal,
  })  : _listenElementsInBucketUseCase = listenBucketEventsUseCase,
        _getFullElementsUseCase = getFullElementsUseCase,
        _syncElementsUseCase = syncElementsUseCase,
        _syncHistoryUseCase = syncHistoryUseCase,
        _createElementUseCase = createElementUseCase,
        _createKeysUseCase = createKeysUseCase,
        _listenKeyEventsUseCase = listenKeyEventsUseCase,
        _checkDeviceParticipationUseCase = checkDeviceParticipationUseCase,
        _checkProviderParticipationUseCase = checkProviderParticipationUseCase,
        _requestParticipationUseCase = requestParticipationUseCase,
        _acceptParticipationUseCase = acceptParticipationUseCase,
        _getActiveRequestsUseCase = getActiveRequestsUseCase,
        _addDeviceParticipationUseCase = addDeviceParticipationUseCase,
        _listenElementUseCase = listenElementUseCase,
        _listenParticipationEventsUseCase = listenParticipationEventsUseCase,
        _listenRequestEventsUseCase = listenRequestEventsUseCase,
        _transactionBloc = transactionBloc,
        _bucketName = bucketName,
        _tenant = tenant,
        _bucketAddress = bucketAddress,
        _isExternal = isExternal,
        super(const BucketState()) {
    on<InitBucketEvent>(_onInitBucketEvent);
    on<LoadBucketEvent>(_onLoadBucketEvent);
    on<GetElementsEvent>(_onGetElementsEvent);
    on<GetRequestsEvent>(_onGetRequestsEvent);
    on<CreateKeysEvent>(_onCreateKeysEvent);
    on<CreateElementEvent>(_onCreateElementEvent);
    // on<AddProviderParticipationEvent>(_onAddProviderParticipationEvent);
    // on<AcceptDeviceParticipationEvent>(_onAcceptDeviceParticipationEvent);
    on<AddRequestorEvent>(_onAddRequestorEvent);
    on<AcceptLatestRequestorEvent>(_onAcceptLatestRequestorEvent);
  }
  @override
  String get id =>
      '${Env.multi_spaces_contract_address}:$_tenant:$_bucketAddress:$_bucketName';

  @override
  BucketState fromJson(Map<String, dynamic> json) {
    final loadedState = BucketState.fromJson(json);
    return loadedState;
  }

  @override
  Map<String, dynamic> toJson(BucketState state) {
    return state.copyWith(status: BucketStatus.success).toJson();
  }

  @override
  Future<void> close() async {
    try {
      await _elementEventsSubscription?.cancel();
      await _listenKeyEventsSubscription?.cancel();
      await _listenParticipationEventsSubscription?.cancel();
      await _listenRequestEventsSubscription?.cancel();
      await _cancelElementSubscriptions();
      return super.close();
    } catch (e) {
      _logger.e("An error occured while closing bucket bloc: $e");
    }
  }

  Future<void> _cancelElementSubscriptions() async {
    for (var subscription in _listenElementsSubscriptions) {
      await subscription.cancel();
    }
  }

  void _onInitBucketEvent(
    InitBucketEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      _logger.d("Setting up listeners.");
      _setupElementListener();
      _setupKeyListener();
      _setupParticipationListener();
      _setupRequestListener();

      if (state.status == BucketStatus.success) {
        final syncHistoryResult = await _syncHistoryUseCase.call(null);
        if (syncHistoryResult.isLeft()) {
          throw (syncHistoryResult as Left<Failure, List<OperationEntity>>)
              .value;
        }
        final operations =
            (syncHistoryResult as Right<Failure, List<OperationEntity>>).value;
        if (operations.isEmpty) {
          _logger.d("Nothing to sync.");
        } else {
          _logger.d("Bucket is out of date. Need to sync.");
          add(GetElementsEvent(parents: state.parents));
        }
      }
      emit(state);
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _onLoadBucketEvent(
    LoadBucketEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      final isParticipantResult =
          await _checkProviderParticipationUseCase.call();
      if (isParticipantResult.isLeft()) {
        throw (isParticipantResult as Left<Failure, bool>).value;
      }
      if (!((isParticipantResult as Right<Failure, bool>).value)) {
        final result = await _requestParticipationUseCase.call();
        if (result.isLeft()) {
          throw (result as Left<Failure, String>).value;
        }
        emit(state.copyWith(status: BucketStatus.waitingForParticipation));
      } else {
        // TODO: Only if this is my bucket!!!
        if (!_isExternal) {
          final deviceIsParticipant =
              await _checkDeviceParticipationUseCase.call();
          if (deviceIsParticipant.isLeft()) {
            throw (deviceIsParticipant as Left<Failure, bool>).value;
          }
          if (!((deviceIsParticipant as Right<Failure, bool>).value)) {
            final result = await _addDeviceParticipationUseCase.call();
            if (result.isLeft()) {
              throw (result as Left<Failure, String>).value;
            }
            _transactionBloc.add(
              TransactionSubmittedEvent(
                transactionHash: (result as Right<Failure, String>).value,
              ),
            );
            emit(state.copyWith(status: BucketStatus.waitingForParticipation));
          } else {
            emit(state.copyWith(status: BucketStatus.initialized));
          }
        } else {
          print("this should not happen!");
        }
      }
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _setupElementListener() async {
    final listenElementsResult = await _listenElementsInBucketUseCase.call();
    _elementEventsSubscription = listenElementsResult.listen(
      (elementEvent) {
        switch (elementEvent.runtimeType) {
          case CreateElementEventEntity:
            {
              _logger.d("Received event: CreateElementEventEntity");
              add(GetElementsEvent(parents: state.parents));
              break;
            }
          case UpdateParentElementEventEntity:
            {
              _logger.d("Received event: UpdateParentElementEventEntity");
              add(GetElementsEvent(parents: state.parents));
              break;
            }
          case UpdateElementEventEntity:
            {
              _logger.d("Received event: UpdateElementEventEntity");
              add(GetElementsEvent(parents: state.parents));
              break;
            }
          case DeleteElementEventEntity:
            {
              _logger.d("Received event: DeleteElementEventEntity");
              add(GetElementsEvent(parents: state.parents));
              break;
            }
        }
      },
      onError: (error) => _logger.d(error),
    );
  }

  Future<void> _setupKeyListener() async {
    final listenKeysResult = await _listenKeyEventsUseCase.call();
    _listenKeyEventsSubscription = listenKeysResult.listen(
      (keyEvent) async {
        if (state.status == BucketStatus.waitingForKeys &&
            state.epoch == keyEvent) {
          _logger.i(
            "Key created for epoch $keyEvent. Proceeding with event ${state.nestedEvent?.toString()}.",
          );
          if (state.nestedEvent != null) {
            final event = state.nestedEvent!;
            add(
              CreateElementEvent(
                name: event.name,
                data: event.data,
                type: event.type,
                format: event.format,
                created: event.created,
                size: event.size,
                parents: state.parents,
              ),
            );
          }
        }
      },
      onError: (error) => _logger.d(error),
    );
  }

  Future<void> _setupParticipationListener() async {
    final internalProvider = BlockchainProviderManager().internalProvider;
    final externalProvider = BlockchainProviderManager().authenticatedProvider!;

    final listenParticipationResult =
        await _listenParticipationEventsUseCase.call();
    _listenParticipationEventsSubscription = listenParticipationResult.listen(
      (participationEvent) {
        if (state.status == BucketStatus.waitingForParticipation) {
          // Either waiting for device to be accepted or for device and user (which will be accepted together)
          if (participationEvent.hex == internalProvider.getAccount().hex ||
              participationEvent.hex == externalProvider.getAccount().hex) {
            _logger.d("Access granted.");
            add(const GetElementsEvent(parents: []));
          }
        } else {
          _logger.d("Access was granted to ${participationEvent.hex}.");
          // TODO: Update requestors
        }
      },
      onError: (error) => _logger.d(error),
    );
  }

  Future<void> _setupRequestListener() async {
    final listenRequestResult = await _listenRequestEventsUseCase.call();
    _listenRequestEventsSubscription = listenRequestResult.listen(
      (requestEvent) {
        if (state.status == BucketStatus.waitingForParticipation) {
          _logger.d("Requested access. Waiting for acceptance...");
        } else {
          _logger.d("Someone else requested access: ${requestEvent.hex}");
          // TODO: Show requests to user and accept it
          add(AddRequestorEvent(requestEvent));
        }
      },
      onError: (error) => _logger.d(error),
    );
  }

  void _onAddRequestorEvent(
    AddRequestorEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BucketStatus.loading));
      emit(
        state.copyWith(
          status: BucketStatus.success,
          requestors: [...state.requestors, event.requestor],
        ),
      );
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _onAcceptLatestRequestorEvent(
    AcceptLatestRequestorEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      if (state.requestors.isNotEmpty) {
        final result = await _acceptParticipationUseCase.call(
          AcceptParticipationUseCaseParams(
            state.requestors.last,
          ),
        );
        if (result.isLeft()) {
          throw (result as Left<Failure, String>).value;
        }
        _transactionBloc.add(
          TransactionSubmittedEvent(
              transactionHash: (result as Right<Failure, String>).value),
        );
        emit(
          state.copyWith(
            status: BucketStatus.success,
            requestors: [
              ...state.requestors.sublist(0, state.requestors.length - 1)
            ],
          ),
        );
      }
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _onGetElementsEvent(
    GetElementsEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      List<FullElementEntity> parents = event.parents
          .where((element) => element.element.dataHash == "")
          .toList();
      if (event.parents.isNotEmpty &&
          event.parents.last.element.dataHash != "") {
        _logger.d("Selected parent is not a container.");
        return;
      }

      emit(
        state.copyWith(
          status: BucketStatus.loading,
          parents: event.parents,
        ),
      );
      final syncHistoryResult = await _syncHistoryUseCase.call();
      if (syncHistoryResult.isLeft()) {
        throw (syncHistoryResult as Left<Failure, List<OperationEntity>>).value;
      }
      final operations =
          (syncHistoryResult as Right<Failure, List<OperationEntity>>).value;
      if (operations.isEmpty) {
        _logger.d("No elements to sync.");
      } else {
        final syncElementsResult = await _syncElementsUseCase
            .call(SyncElementsUseCaseParams(true, false));
        if (syncElementsResult.isLeft()) {
          final failure = (syncElementsResult as Left<Failure, int>).value;
          if (failure.runtimeType == MissingKeyFailure) {
            _logger.e(
              "Inconsitency found! Missing key for block #${(failure as MissingKeyFailure).block} and participant ${failure.address}",
            );
            throw failure;
          } else {
            throw failure;
          }
        }
        final count = (syncElementsResult as Right<Failure, int>).value;

        if (count == 0) {
          throw Exception("Nothing was synced!");
        }
        _logger.d("Updated $count element(s).");
      }

      final fullElementsResult = await _getFullElementsUseCase
          .call(GetFullElementsUseCaseParams(false, parents));
      if (fullElementsResult.isLeft()) {
        throw (fullElementsResult as Left<Failure, List<FullElementEntity>>)
            .value;
      }
      final fullElements =
          (fullElementsResult as Right<Failure, List<FullElementEntity>>).value;
      await _setupElementListeners(fullElements);

      emit(
        state.copyWith(
          status: BucketStatus.success,
          parents: parents,
          elements: fullElements,
        ),
      );
      add(const GetRequestsEvent());
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _onGetRequestsEvent(
    GetRequestsEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      final activeRequests = await _getActiveRequestsUseCase.call();
      if (activeRequests.isLeft()) {
        throw (activeRequests as Left<Failure, List<EthereumAddress>>).value;
      }
      emit(
        state.copyWith(
          status: BucketStatus.loading,
        ),
      );
      emit(
        state.copyWith(
          status: BucketStatus.success,
          requestors:
              (activeRequests as Right<Failure, List<EthereumAddress>>).value,
        ),
      );
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _onCreateKeysEvent(
    CreateKeysEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      _logger.d("Creating keys for new element ${event.event.name}");

      emit(
        state.copyWith(
          status: BucketStatus.loading,
        ),
      );
      final keyResult = await _createKeysUseCase.call();
      if (keyResult.isLeft()) {
        throw (keyResult as Left<Failure, KeyCreation?>).value;
      }
      if ((keyResult as Right<Failure, KeyCreation?>).value == null) {
        _logger.d("Keys are up to date. Proceeding with creation.");
        emit(
          state.copyWith(
            status: BucketStatus.ready,
            nestedEvent: event.event,
          ),
        );
        return;
      }
      _logger.d("Keys submitted. Waiting for confirmation.");
      _transactionBloc.add(
        TransactionSubmittedEvent(transactionHash: keyResult.value!.txHash),
      );
      emit(
        state.copyWith(
          status: BucketStatus.waitingForKeys,
          nestedEvent: event.event,
          epoch: keyResult.value!.epoch,
        ),
      );
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _onCreateElementEvent(
    CreateElementEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      _logger.d("Creating element: ${event.name}.");
      final creationResult = await _createElementUseCase.call(
        CreateElementUseCaseParams(
          event.data,
          CreateMetaDto(
            event.name,
            event.type,
            event.format,
            event.created,
            event.size,
          ),
          event.parents,
        ),
      );
      if (creationResult.isLeft()) {
        throw (creationResult as Left<Failure, String>).value;
      }
      final txHash = (creationResult as Right<Failure, String>).value;

      _transactionBloc.add(
        TransactionSubmittedEvent(transactionHash: txHash),
      );
    } catch (e) {
      _logger.e(e);
      if (e is Failure) {
        emit(state.copyWith(status: BucketStatus.failure, error: e));
      } else {
        emit(
          state.copyWith(
            status: BucketStatus.failure,
            error: BlocFailure(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _setupElementListeners(List<FullElementEntity> elements) async {
    await _cancelElementSubscriptions();
    for (var element in elements) {
      final listener = await _listenElementUseCase.call(
        ListenElementUseCaseParams(element.element.element),
      );
      final subscription = listener.listen((event) {
        print(event as ElementRequestEventEntity);

        /// TODO: upload data to ipfs
      });
      _listenElementsSubscriptions.add(subscription);
    }
  }
}
