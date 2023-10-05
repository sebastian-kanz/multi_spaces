import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:multi_spaces/authentication/bloc/authentication_bloc.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/multi_spaces/repository/multi_spaces_repository.dart';
import 'package:web3dart/web3dart.dart';

part 'multi_spaces_event.dart';
part 'multi_spaces_state.dart';

class MultiSpacesBloc extends HydratedBloc<MultiSpacesEvent, MultiSpaceState> {
  final MultiSpacesRepository _multiSpacesRepository;
  final AuthenticationBloc _authenticationBloc;
  final _logger = getLogger();
  late StreamSubscription _newBlocksSubscription;
  late final StreamSubscription _authSubscription;

  MultiSpacesBloc({
    required MultiSpacesRepository multiSpacesRepository,
    required AuthenticationBloc authenticationBloc,
  })  : _multiSpacesRepository = multiSpacesRepository,
        _authenticationBloc = authenticationBloc,
        super(MultiSpacesLoading()) {
    on<MultiSpacesStarted>(_onMultiSpacesStarted);
    on<CreateSpacePressed>(_onCreateSpacePressed);
    on<SpaceCreated>(_onSpaceCreated);
    on<InternetConnectionLost>(_onInternetConnectionLost);

    _authSubscription = _authenticationBloc.stream.listen((state) {
      // This only works if no space exists
      // TODO: Clear state when logging out and space exists
      if (state == const AuthenticationState.unauthenticated()) {
        clear();
      }
    });

    final blockStream = Stream<void>.periodic(const Duration(seconds: 10));
    _newBlocksSubscription = blockStream.listen(
      (newBlock) async {
        if (state.runtimeType == SpaceCreationInProgress) {
          final receipt = await _multiSpacesRepository.getTransactionReceipt(
            (state as SpaceCreationInProgress).transactionHash,
          );
          if (receipt != null) {
            if (receipt.status == true) {
              final spaceAddress =
                  await _multiSpacesRepository.getExistingSpace();
              if (spaceAddress != ZERO_ADDRESS) {
                add(SpaceCreated(spaceAddress.hex));
              }
            } else {
              _logger.d(receipt);
            }
          }
        }
      },
      onError: (error) => _logger.e(error),
    );
  }

  @override
  Future<void> close() {
    _newBlocksSubscription.cancel();
    _authSubscription.cancel();
    return super.close();
  }

  @override
  MultiSpaceState fromJson(Map<String, dynamic> json) {
    final currentAccount = _authenticationBloc.state.user.address;
    final account = json['account'];
    final multiSpaceAddress = json['multiSpaceAddress'];
    if (currentAccount != account ||
        multiSpaceAddress != Env.multi_spaces_contract_address) {
      clear();
      return MultiSpacesLoading();
    }
    final spaceAddressHex = json['spaceAddress'];
    final paymentManagerAddress = json['paymentManagerAddress'];
    if (spaceAddressHex != null && paymentManagerAddress != null) {
      return MultiSpacesReady(
        EthereumAddress.fromHex(spaceAddressHex),
        EthereumAddress.fromHex(paymentManagerAddress),
      );
    }
    return MultiSpacesLoading();
  }

  @override
  Map<String, dynamic> toJson(MultiSpaceState state) => {
        'account': _authenticationBloc.state.user.address,
        'spaceAddress': state.runtimeType == MultiSpacesReady
            ? (state as MultiSpacesReady).spaceAddress.hex
            : null,
        'paymentManagerAddress': state.runtimeType == MultiSpacesReady
            ? (state as MultiSpacesReady).paymentManagerAddress.hex
            : null,
        'multiSpaceAddress': Env.multi_spaces_contract_address,
      };

  void _onMultiSpacesStarted(
    MultiSpacesStarted event,
    Emitter<MultiSpaceState> emit,
  ) async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        return emit(NoInternetConnectionAvailable());
      }

      if (state.runtimeType != SpaceCreationInProgress &&
          state.runtimeType != MultiSpacesReady) {
        final connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult != ConnectivityResult.none) {
          final spaceAddress = await _multiSpacesRepository.getExistingSpace();
          final paymentManager =
              await _multiSpacesRepository.getPaymentManager();
          if (spaceAddress != ZERO_ADDRESS) {
            emit(MultiSpacesReady(spaceAddress, paymentManager));
            _newBlocksSubscription.cancel();
          } else {
            emit(NoSpaceExisting());
          }
        } else {
          emit(NoInternetConnectionAvailable());
        }
      } else {
        if (state.runtimeType == MultiSpacesReady) {
          _newBlocksSubscription.cancel();
        }
        emit(state);
      }
    } catch (e) {
      if (e.runtimeType == RangeError) {
        _logger.i("No space existing for current user.");
        emit(NoSpaceExisting());
      } else {
        _logger.e(e);
        emit(NoSpaceExisting());
        // rethrow;
      }
    }
  }

  void _onCreateSpacePressed(
    CreateSpacePressed event,
    Emitter<MultiSpaceState> emit,
  ) async {
    try {
      try {
        final spaceAddress = await _multiSpacesRepository.getExistingSpace();
        final paymentManager = await _multiSpacesRepository.getPaymentManager();
        if (spaceAddress != ZERO_ADDRESS && paymentManager != ZERO_ADDRESS) {
          emit(MultiSpacesReady(spaceAddress, paymentManager));
        }
      } catch (e) {
        if (e.runtimeType == RangeError) {
          _logger.i("No space existing for current user.");
        } else {
          _logger.e(e);
          rethrow;
        }
      }

      final transactionHash = await _multiSpacesRepository.createSpace();
      _logger.i("Transaction $transactionHash submitted.");
      emit(SpaceCreationInProgress(transactionHash));
    } catch (e) {
      if (e.runtimeType == RangeError) {
        _logger.i("No space existing for current user.");
        emit(NoSpaceExisting());
      } else if (e.runtimeType == InsufficientFundsException) {
        _logger.e((e as InsufficientFundsException).error);
      } else {
        rethrow;
      }
      // emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  void _onSpaceCreated(
    SpaceCreated event,
    Emitter<MultiSpaceState> emit,
  ) async {
    try {
      final spaceAddress = await _multiSpacesRepository.getExistingSpace();
      final paymentManager = await _multiSpacesRepository.getPaymentManager();
      if (spaceAddress != ZERO_ADDRESS && paymentManager != ZERO_ADDRESS) {
        emit(MultiSpacesReady(spaceAddress, paymentManager));
      } else {
        emit(NoSpaceExisting());
      }
    } catch (e) {
      if (e.runtimeType == RangeError) {
        _logger.i("No space existing for current user.");
        emit(NoSpaceExisting());
      } else {
        _logger.e(e);
        rethrow;
      }
    }
  }

  void _onInternetConnectionLost(
    InternetConnectionLost event,
    Emitter<MultiSpaceState> emit,
  ) async {
    emit(NoInternetConnectionAvailable());
  }
}
