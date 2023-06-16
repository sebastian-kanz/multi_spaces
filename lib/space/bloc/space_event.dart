part of 'space_bloc.dart';

abstract class SpaceEvent extends Equatable {
  const SpaceEvent();

  @override
  List<Object> get props => [];
}

class InitSpaceEvent extends SpaceEvent {
  const InitSpaceEvent();
}

class GetBucketsEvent extends SpaceEvent {
  const GetBucketsEvent();
}

class CreateBucketEvent extends SpaceEvent {
  final String bucketName;
  const CreateBucketEvent(this.bucketName);
}

class AddExternalBucketEvent extends SpaceEvent {
  final String bucketName;
  final EthereumAddress bucketAddress;
  const AddExternalBucketEvent(this.bucketName, this.bucketAddress);
}

class RenameBucketEvent extends SpaceEvent {
  final String oldName;
  final String newName;
  const RenameBucketEvent(this.oldName, this.newName);
}

class RemoveBucketEvent extends SpaceEvent {
  final String bucketName;
  const RemoveBucketEvent(this.bucketName);
}
