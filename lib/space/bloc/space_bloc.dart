import 'dart:async';
import 'package:blockchain_provider/blockchain_provider.dart';
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

// TODO: Make hydrated bloc
class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final SpaceRepository _spaceRepository;
  final TransactionBloc _transactionBloc;
  final PaymentBloc _paymentBloc;
  final _logger = getLogger();
  late final StreamSubscription _createSubscription;
  late final StreamSubscription _removeSubscription;
  late final StreamSubscription _renameSubscription;

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

    // TODO: Do we need these subscriptions?? Reload does its job...
    _createSubscription = _spaceRepository.listenCreate.listen(
      (createEvent) {
        _logger.d("Bucket created: ${createEvent.addr.hex}");
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.d(error),
    );

    _removeSubscription = _spaceRepository.listenRemove.listen(
      (removeEvent) {
        _logger.d("Bucket removed: ${removeEvent.addr.hex}");
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.e(error),
    );

    _renameSubscription = _spaceRepository.listenRename.listen(
      (renameEvent) {
        _logger.d("Bucket renamed: ${renameEvent.addr.hex}");
        add(const GetBucketsEvent());
      },
      onError: (error) => _logger.e(error),
    );

    _paymentBloc.add(
      InitPaymentsEvent(
        accounts: [
          state.address,
          BlockchainProviderManager().authenticatedProvider!.getAccount(),
          BlockchainProviderManager().internalProvider.getAccount(),
        ],
        selected: 0,
      ),
    );
  }

  @override
  Future<void> close() {
    _createSubscription.cancel();
    _removeSubscription.cancel();
    _renameSubscription.cancel();
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
          externalBucketToAdd: event.externalBucketToAdd,
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e as Exception, state.address));
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
      emit(SpaceError(e as Exception, state.address));
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
      if (result == "") {
        _logger.d('User rejected bucket creation!');
        emit(
          SpaceError(
            Exception('User rejected bucket creation!'),
            state.address,
          ),
        );
        return;
      }
      _transactionBloc.add(
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: result,
            description: "Create bucket",
          ),
        ),
      );
      _logger.d('Bucket created: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e as Exception, state.address));
    }
  }

  void _onAddExternalBucketEvent(
    AddExternalBucketEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      _logger.d('Adding external bucket: ${event.bucketName}');
      final result = await _spaceRepository.addExternalBucket(
        event.bucketName,
        event.bucketAddress,
      );
      _transactionBloc.add(
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: result,
            description: "Add external bucket",
          ),
        ),
      );

      emit(
        SpaceInitialized(
          (state as SpaceInitialized).owner,
          (state as SpaceInitialized).buckets,
          (state as SpaceInitialized).address,
        ),
      );
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e as Exception, state.address));
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
      _transactionBloc.add(
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: result,
            description: "Rename bucket",
          ),
        ),
      );
      _logger.d('Bucket renamed: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e as Exception, state.address));
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
      _transactionBloc.add(
        TransactionSubmittedEvent(
          transaction: NamedTransaction(
            hash: result,
            description: "Remove bucket",
          ),
        ),
      );
      _logger.d('Bucket removed: $result');
    } catch (e) {
      _logger.e(e);
      emit(SpaceError(e as Exception, state.address));
    }
  }
}
