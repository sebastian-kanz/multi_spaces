import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_spaces/core/contracts/Space.g.dart';
import 'package:multi_spaces/core/utils/logger.util.dart';
import 'package:multi_spaces/payment/bloc/payment_bloc.dart';
import 'package:multi_spaces/space/models/bucket_instance_model.dart';
import 'package:multi_spaces/space/repository/space_repository.dart';
import 'package:multi_spaces/transaction/bloc/transaction_bloc.dart';
import 'package:web3dart/web3dart.dart';

part 'space_event.dart';
part 'space_state.dart';

class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final SpaceRepository _spaceRepository;
  final TransactionBloc _transactionBloc;
  final PaymentBloc _paymentBloc;
  final _logger = getLogger();
  late final StreamSubscription _createSubscription;
  late final StreamSubscription _removeSubscription;
  late final StreamSubscription _renameSubscription;
  late final StreamSubscription _initSubscription;

  SpaceBloc({
    required SpaceRepository spaceRepository,
    required TransactionBloc transactionBloc,
    required PaymentBloc paymentBloc,
  })  : _spaceRepository = spaceRepository,
        _transactionBloc = transactionBloc,
        _paymentBloc = paymentBloc,
        super(SpaceStateInitial(spaceRepository.getSpaceAddress())) {
    on<InitSpaceEvent>(_onInitSpaceEvent);
    on<GetBucketsEvent>(_onGetBucketsEvent);
    on<CreateBucketEvent>(_onCreateBucketEvent);
    on<AddExternalBucketEvent>(_onAddExternalBucketEvent);
    on<RenameBucketEvent>(_onRenameBucketEvent);
    on<RemoveBucketEvent>(_onRemoveBucketEvent);

    _createSubscription = _spaceRepository.listenCreate.listen(
      (createEvent) {
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.d(error),
    );

    _removeSubscription = _spaceRepository.listenRemove.listen(
      (createEvent) {
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.e(error),
    );

    _renameSubscription = _spaceRepository.listenRename.listen(
      (createEvent) {
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.e(error),
    );

    _initSubscription = _spaceRepository.listenInitialize.listen(
      (createEvent) {
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.e(error),
    );

    _paymentBloc.add(
      InitPaymentEvent(
        account: state.address,
      ),
    );
  }

  @override
  Future<void> close() {
    _createSubscription.cancel();
    _removeSubscription.cancel();
    _renameSubscription.cancel();
    _initSubscription.cancel();
    return super.close();
  }

  void _onInitSpaceEvent(
    InitSpaceEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      final owner = await _spaceRepository.getSpaceOwner();
      final bucketInstances = await _spaceRepository.getAllBuckets();
      emit(
        SpaceInitialized(
          owner,
          bucketInstances,
          _spaceRepository.getSpaceAddress(),
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e, state.address));
    }
  }

  void _onGetBucketsEvent(
    GetBucketsEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      final bucketInstances = await _spaceRepository.getAllBuckets();
      emit(
        SpaceInitialized(
          (state as SpaceInitialized).owner,
          bucketInstances,
          _spaceRepository.getSpaceAddress(),
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e, state.address));
    }
  }

  void _onCreateBucketEvent(
    CreateBucketEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      String result = '';
      if (_paymentBloc.state.runtimeType == PaymentInitialized) {
        final balance =
            (_paymentBloc.state as PaymentInitialized).addBucketVouchers +
                (_paymentBloc.state as PaymentInitialized).balance;
        if (balance > 0) {
          result = await _spaceRepository.createBucket(event.bucketName);
        } else {
          final defaultPayment =
              (_paymentBloc.state as PaymentInitialized).defaultPayment;
          result = await _spaceRepository.createBucket(
            event.bucketName,
            baseFee: defaultPayment,
          );
        }
      } else {
        result = await _spaceRepository.createBucket(event.bucketName);
      }
      _transactionBloc.add(TransactionSubmittedEvent(transactionHash: result));
      _logger.d('Bucket created: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e, state.address));
    }
  }

  void _onAddExternalBucketEvent(
    AddExternalBucketEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      final result = await _spaceRepository.addExternalBucket(
        event.bucketName,
        event.bucketAddress,
      );
      _transactionBloc.add(TransactionSubmittedEvent(transactionHash: result));
      _logger.d('External bucket added: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e, state.address));
    }
  }

  void _onRenameBucketEvent(
    RenameBucketEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      final result = await _spaceRepository.renameBucket(
        event.oldName,
        event.newName,
      );
      _transactionBloc.add(TransactionSubmittedEvent(transactionHash: result));
      _logger.d('Bucket renamed: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e, state.address));
    }
  }

  void _onRemoveBucketEvent(
    RemoveBucketEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      // TODO: Clean up. Delete remaining data like database entries, keys, etc.
      final result = await _spaceRepository.removeBucket(
        event.bucketName,
      );
      _transactionBloc.add(TransactionSubmittedEvent(transactionHash: result));
      _logger.d('Bucket removed: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e, state.address));
    }
  }
}
