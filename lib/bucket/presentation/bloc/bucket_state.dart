part of 'bucket_bloc.dart';

abstract class BucketState extends Equatable {
  final List<FullElementEntity> elements;
  const BucketState(this.elements);

  @override
  List<Object> get props => [];
}

class BucketStateInitial extends BucketState {
  BucketStateInitial() : super([]);
}

class BucketInitialized extends BucketState {
  BucketInitialized() : super([]);
}

class BucketError extends BucketState {
  final Object error;
  BucketError(this.error) : super([]);

  @override
  List<Object> get props => [elements, error];
}

class BucketLoaded extends BucketState {
  const BucketLoaded(elements) : super(elements);
}

class BucketReady extends BucketState {
  final BucketEvent event;
  const BucketReady(elements, this.event) : super(elements);

  @override
  List<Object> get props => [elements, event];
}

class WaitingForKeys extends BucketState {
  final BucketEvent event;
  final int epoch;
  const WaitingForKeys(elements, this.event, this.epoch) : super(elements);

  @override
  List<Object> get props => [elements, event, epoch];
}
