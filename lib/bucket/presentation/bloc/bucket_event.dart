part of 'bucket_bloc.dart';

abstract class BucketEvent extends Equatable {
  const BucketEvent();

  @override
  List<Object> get props => [];
}

class InitBucketEvent extends BucketEvent {
  const InitBucketEvent();
}

class LoadBucketEvent extends BucketEvent {
  const LoadBucketEvent();
}

class AccessGrantedEvent extends BucketEvent {
  const AccessGrantedEvent();
}

class GetElementsEvent extends BucketEvent {
  final List<FullElementEntity> parents;
  const GetElementsEvent({
    required this.parents,
  });
}

class GetRequestsEvent extends BucketEvent {
  const GetRequestsEvent();
}

class CreateElementEvent extends BucketEvent {
  final String name;
  final Uint8List data;
  final String type;
  final String format;
  final int created;
  final int size;
  final List<FullElementEntity> parents;

  const CreateElementEvent({
    required this.name,
    required this.data,
    required this.type,
    required this.format,
    required this.created,
    required this.size,
    required this.parents,
  });

  factory CreateElementEvent.fromJson(Map<String, dynamic> json) =>
      CreateElementEvent(
        name: json['name'],
        data: hexToBytes(json['data']),
        type: json['type'],
        format: json['format'],
        created: json['created'],
        size: json['size'],
        parents: (json['parents'] as List<Map<String, dynamic>>)
            .map((e) => FullElementEntity.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'data': bytesToHex(data),
        'type': type,
        'format': format,
        'created': created,
        'size': size,
        'parents': parents.map((e) => e.toJson()).toList(),
      };
}

class CreateKeysEvent extends BucketEvent {
  final CreateElementEvent event;
  const CreateKeysEvent(this.event);
}

class RenameElementEvent extends BucketEvent {
  final FullElementEntity element;
  final String newName;
  const RenameElementEvent(this.element, this.newName);
}

class UpdateElementEvent extends BucketEvent {
  final EthereumAddress element;
  const UpdateElementEvent(this.element);
}

class AddProviderParticipationEvent extends BucketEvent {
  const AddProviderParticipationEvent();
}

class AcceptDeviceParticipationEvent extends BucketEvent {
  const AcceptDeviceParticipationEvent();
}

class AddRequestorEvent extends BucketEvent {
  final EthereumAddress requestor;
  const AddRequestorEvent(this.requestor);
}

class AcceptLatestRequestorEvent extends BucketEvent {
  const AcceptLatestRequestorEvent();
}
