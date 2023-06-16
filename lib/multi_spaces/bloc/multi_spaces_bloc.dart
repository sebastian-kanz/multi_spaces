import 'dart:async';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:multi_spaces/authentication/bloc/authentication_bloc.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/multi_spaces/repository/multi_spaces_repository.dart';
import 'package:web3dart/web3dart.dart';

part 'multi_spaces_event.dart';
part 'multi_spaces_state.dart';

class MultiSpacesBloc extends HydratedBloc<MultiSpacesEvent, MultiSpaceState> {
  final MultiSpacesRepository _multiSpacesRepository;
  final AuthenticationBloc _authenticationBloc;
  final _logger = getLogger();
  late final StreamSubscription _newBlocksSubscription;
  late final StreamSubscription _authSubscription;

  MultiSpacesBloc({
    required MultiSpacesRepository multiSpacesRepository,
    required AuthenticationBloc authenticationBloc,
  })  : _multiSpacesRepository = multiSpacesRepository,
        _authenticationBloc = authenticationBloc,
        super(MultiSpacesInitial()) {
    on<MultiSpacesStarted>(_onMultiSpacesStarted);
    on<CreateSpacePressed>(_onCreateSpacePressed);
    on<SpaceCreated>(_onSpaceCreated);

    _newBlocksSubscription = _multiSpacesRepository.listenNewBlocks.listen(
      (newBlock) async {
        if (state.runtimeType == SpaceCreationInProgress) {
          final receipt = await _multiSpacesRepository.getTransactionReceipt(
              (state as SpaceCreationInProgress).transactionHash);
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

    _authSubscription = _authenticationBloc.stream.listen((state) {
      // This does not work!
      // if (state == const AuthenticationState.unauthenticated()) {
      //   clear();
      //   add(const MultiSpacesInitialized());
      // }
    });
  }

  @override
  Future<void> close() {
    _newBlocksSubscription.cancel();
    _authSubscription.cancel();
    return super.close();
  }

  @override
  MultiSpaceState fromJson(Map<String, dynamic> json) {
    final spaceAddressHex = json['spaceAddress'];
    final paymentManagerAddress = json['paymentManagerAddress'];
    if (spaceAddressHex != null && paymentManagerAddress != null) {
      MultiSpacesReady(
        EthereumAddress.fromHex(spaceAddressHex),
        EthereumAddress.fromHex(paymentManagerAddress),
      );
    }
    return MultiSpacesInitial();
  }

  @override
  Map<String, dynamic> toJson(MultiSpaceState state) => {
        'spaceAddress': state.runtimeType == MultiSpacesReady
            ? (state as MultiSpacesReady).spaceAddress.hex
            : null,
        'paymentManagerAddress': state.runtimeType == MultiSpacesReady
            ? (state as MultiSpacesReady).paymentManagerAddress.hex
            : null,
      };

  void _onMultiSpacesStarted(
    MultiSpacesStarted event,
    Emitter<MultiSpaceState> emit,
  ) async {
    try {
      if (state.runtimeType != SpaceCreationInProgress &&
          state.runtimeType != MultiSpacesReady) {
        final spaceAddress = await _multiSpacesRepository.getExistingSpace();
        final paymentManager = await _multiSpacesRepository.getPaymentManager();
        if (spaceAddress != ZERO_ADDRESS) {
          emit(MultiSpacesReady(spaceAddress, paymentManager));
        } else {
          emit(NoSpaceExisting());
        }
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
}
