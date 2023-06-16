part of 'bucket_bloc.dart';

abstract class BucketEvent extends Equatable {
  const BucketEvent();

  @override
  List<Object> get props => [];
}

class InitBucketEvent extends BucketEvent {
  const InitBucketEvent();
}

class GetElementsEvent extends BucketEvent {
  const GetElementsEvent();
}

class CreateElementEvent extends BucketEvent {
  final String name;
  final Uint8List data;
  final String type;
  final String format;
  final int created;

  const CreateElementEvent({
    required this.name,
    required this.data,
    required this.type,
    required this.format,
    required this.created,
  });
}

class CreateKeysEvent extends BucketEvent {
  final BucketEvent event;
  const CreateKeysEvent(this.event);
}

class KeysCreatedEvent extends BucketEvent {
  final BucketEvent event;
  const KeysCreatedEvent(this.event);
}
