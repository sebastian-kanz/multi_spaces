part of 'space_bloc.dart';

abstract class SpaceState extends Equatable {
  final EthereumAddress address;
  const SpaceState(this.address);

  @override
  List<Object> get props => [address];
}

class SpaceStateInitial extends SpaceState {
  const SpaceStateInitial(EthereumAddress address) : super(address);
}

class SpaceInitialized extends SpaceState {
  final SpaceOwner owner;
  final List<BucketInstance> buckets;
  final EthereumAddress? externalBucketToAdd;
  const SpaceInitialized(
    this.owner,
    this.buckets,
    EthereumAddress address, {
    this.externalBucketToAdd,
  }) : super(address);

  @override
  List<Object> get props => [owner, buckets, address];
}

class SpaceError extends SpaceState {
  final Exception error;
  const SpaceError(this.error, EthereumAddress address) : super(address);

  @override
  List<Object> get props => [error, address];
}
