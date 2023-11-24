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
import 'package:multi_spaces/bucket/domain/usecase/keys_existing_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_bucket_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_element_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_key_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_participation_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/listen_request_events_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/request_participation_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_elements_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/sync_history_usecase.dart';
import 'package:multi_spaces/bucket/domain/usecase/update_element_usecase.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:open_app_file/open_app_file.dart';
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
  final KeysExistingUseCase _keysExistingUseCase;
  final UpdateElementUseCase _updateElementUseCase;
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
    required KeysExistingUseCase keysExistingUseCase,
    required UpdateElementUseCase updateElementUseCase,
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
        _keysExistingUseCase = keysExistingUseCase,
        _updateElementUseCase = updateElementUseCase,
        _transactionBloc = transactionBloc,
        _bucketName = bucketName,
        _tenant = tenant,
        _bucketAddress = bucketAddress,
        _isExternal = isExternal,
        super(const BucketState().copyWith(isExternal: isExternal)) {
    on<InitBucketEvent>(_onInitBucketEvent);
    on<LoadBucketEvent>(_onLoadBucketEvent);
    on<AccessGrantedEvent>(_onAccessGrantedEvent);
    on<GetElementsEvent>(_onGetElementsEvent);
    on<GetRequestsEvent>(_onGetRequestsEvent);
    on<CreateKeysEvent>(_onCreateKeysEvent);
    on<CreateElementEvent>(_onCreateElementEvent);
    on<AddRequestorEvent>(_onAddRequestorEvent);
    on<AcceptLatestRequestorEvent>(_onAcceptLatestRequestorEvent);
    on<RenameElementEvent>(_onRenameElementEvent);
    on<UpdateElementEvent>(_onUpdateElementEvent);
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
    return state.toJson();
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

  Future<bool> _isFullyParticipating() async {
    final isParticipantResult = await _checkProviderParticipationUseCase.call();
    if (isParticipantResult.isLeft()) {
      throw (isParticipantResult as Left<Failure, bool>).value;
    }

    final deviceIsParticipant = await _checkDeviceParticipationUseCase.call();
    if (deviceIsParticipant.isLeft()) {
      throw (deviceIsParticipant as Left<Failure, bool>).value;
    }

    return (isParticipantResult as Right<Failure, bool>).value &&
        (deviceIsParticipant as Right<Failure, bool>).value;
  }

  Future<void> _setupListeners() async {
    _logger.d("Setting up listeners.");
    if (state.participationFulfilled) {
      _setupElementListener();
      _setupKeyListener();
      _setupRequestListener();
    }
    _setupParticipationListener();
  }

  void _onInitBucketEvent(
    InitBucketEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      await _setupListeners();

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
        add(const GetRequestsEvent());
      }
      if (!state.participationFulfilled) {
        if (await _isFullyParticipating()) {
          emit(state.copyWith(participationFulfilled: true));
        } else if (!state.isExternal) {
          return add(const LoadBucketEvent());
        }
      }
      if ([
        BucketStatus.initial,
        BucketStatus.initialized,
        BucketStatus.ready,
      ].contains(state.status)) {
        // do nothing
      } else if (state.status == BucketStatus.failure) {
        add(GetElementsEvent(parents: state.parents));
      } else if (state.status == BucketStatus.waitingForKeys) {
        add(CreateKeysEvent(state.nestedEvent!));
      } else if (state.status == BucketStatus.waitingForParticipation) {
        add(const LoadBucketEvent());
      } else if (state.status == BucketStatus.loading) {
        add(GetElementsEvent(parents: state.parents));
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
        // TODO: Show explanation to user
        emit(state.copyWith(status: BucketStatus.loading));
        final result = await _requestParticipationUseCase.call();
        if (result.isLeft()) {
          throw (result as Left<Failure, String>).value;
        }
        if ((result as Right<Failure, String>).value == "") {
          throw const BlocFailure("Request ");
        }
        emit(state.copyWith(status: BucketStatus.waitingForParticipation));
      } else {
        if (!_isExternal) {
          final deviceIsParticipant =
              await _checkDeviceParticipationUseCase.call();
          if (deviceIsParticipant.isLeft()) {
            throw (deviceIsParticipant as Left<Failure, bool>).value;
          }
          if (!((deviceIsParticipant as Right<Failure, bool>).value)) {
            emit(state.copyWith(status: BucketStatus.loading, confirmTx: true));
            final keyExistingResult = await _keysExistingUseCase.call();
            if (keyExistingResult.isLeft()) {
              throw (keyExistingResult as Left<Failure, bool>).value;
            }
            // No keys were created yet, so we can safely add the device
            if (!(keyExistingResult as Right<Failure, bool>).value) {
              // TODO: Show explanation to user
              final result = await _addDeviceParticipationUseCase.call();
              if (result.isLeft()) {
                throw (result as Left<Failure, String>).value;
              }
              if ((result as Right<Failure, String>).value == "") {
                emit(state.copyWith(
                  status: BucketStatus.failure,
                  error: const BlocFailure("User rejected."),
                  confirmTx: false,
                ));
                return;
              }
              _transactionBloc.add(
                TransactionSubmittedEvent(
                  transaction: NamedTransaction(
                    hash: result.value,
                    description: "Add device to bucket",
                  ),
                ),
              );
              emit(state.copyWith(
                status: BucketStatus.waitingForParticipation,
                confirmTx: false,
              ));
            } else {
              // Some keys were already created, so we need to request device participation. Some other device need to accept and add the keys
              // TODO: Show explanation to user
              final result = await _requestParticipationUseCase.call();
              if (result.isLeft()) {
                throw (result as Left<Failure, String>).value;
              }
              emit(state.copyWith(
                status: BucketStatus.waitingForParticipation,
                confirmTx: false,
              ));
            }
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
    _elementEventsSubscription ??= listenElementsResult.listen(
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
              add(
                UpdateElementEvent(
                  (elementEvent as UpdateElementEventEntity).previousElement,
                ),
              );
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
    _listenKeyEventsSubscription ??= listenKeysResult.listen(
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
    _listenParticipationEventsSubscription ??= listenParticipationResult.listen(
      (participationEvent) async {
        if (state.status == BucketStatus.waitingForParticipation) {
          // Either waiting for device to be accepted or for device and user (which will be accepted together)
          if (participationEvent.hex == internalProvider.getAccount().hex ||
              participationEvent.hex == externalProvider.getAccount().hex) {
            add(const AccessGrantedEvent());
            add(const GetElementsEvent(parents: []));
          }
        } else {
          _logger.d("Access was granted to ${participationEvent.hex}.");
          add(const GetRequestsEvent());
        }
      },
      onError: (error) => _logger.d(error),
    );
  }

  Future<void> _setupRequestListener() async {
    final listenRequestResult = await _listenRequestEventsUseCase.call();
    _listenRequestEventsSubscription ??= listenRequestResult.listen(
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
      // TODO: Make this more interactive and show to user
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
            transaction: NamedTransaction(
              hash: (result as Right<Failure, String>).value,
              description: "Accept latest requestor",
            ),
          ),
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

  void _onAccessGrantedEvent(
    AccessGrantedEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      _logger.d("Access granted.");
      emit(state.copyWith(participationFulfilled: true));
      await _setupListeners();
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
      if (!state.participationFulfilled) {
        _logger.d("Can not get elements. Please participate first.");
        return;
      }
      List<FullElementEntity> parents = event.parents
          .where((element) => element.element.dataHash == "")
          .toList();
      if (event.parents.isNotEmpty &&
          event.parents.last.element.dataHash != "") {
        _logger.d("Selected parent is not a container. Opening file...");
        await OpenAppFile.open(event.parents.last.data?.entity.path ?? "");
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

      final fullElementsResult =
          await _getFullElementsUseCase.call(GetFullElementsUseCaseParams(
        true,
        parents,
      ));
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
          newElement: "",
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

  void _onRenameElementEvent(
    RenameElementEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: BucketStatus.loading,
          parents: state.parents,
        ),
      );
      final result = await _updateElementUseCase.call(
        UpdateElementUseCaseParams(
          event.element,
          event.newName,
        ),
      );
      _transactionBloc.add(
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: (result as Right<Failure, String>).value,
            description: "Rename element",
          ),
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

  void _onUpdateElementEvent(
    UpdateElementEvent event,
    Emitter<BucketState> emit,
  ) async {
    try {
      // final result = await _updateElementUseCase.call(
      //   UpdateElementUseCaseParams(
      //     event.element.,
      //     refreshOnly: true,
      //   ),
      // );
      add(GetElementsEvent(parents: state.parents));
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
          newElement: event.event.name,
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
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: keyResult.value!.txHash,
            description: "Create encryption keys",
          ),
        ),
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
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: txHash,
            description: "Create elements",
          ),
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
