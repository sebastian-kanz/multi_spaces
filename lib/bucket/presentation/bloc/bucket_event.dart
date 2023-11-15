part of 'bucket_bloc.dart';

enum BucketAction {
  initBucket,
  loadBucket,
  getElements,
  createElement,
  createKeys,
  addProviderParticipation,
  acceptDeviceParticipation,
  addRequestor,
  acceptLatestRequestor,
  waitingForKeys
}

// class GetElementsParams {
//   final List<FullElementEntity> parents;

//   GetElementsParams(this.parents);

//   factory GetElementsParams.fromJson(Map<String, dynamic> json) =>
//       GetElementsParams((json['parents'] as List<Map<String, dynamic>>)
//           .map((e) => FullElementEntity.fromJson(e))
//           .toList());

//   Map<String, dynamic> toJson() => {'parents': parents.map((e) => e.toJson())};
// }

// class CreateElementParams {
//   final String name;
//   final Uint8List data;
//   final String type;
//   final String format;
//   final int created;
//   final int size;

//   CreateElementParams(
//     this.name,
//     this.data,
//     this.type,
//     this.format,
//     this.created,
//     this.size,
//   );

//   factory CreateElementParams.fromJson(Map<String, dynamic> json) =>
//       CreateElementParams(
//         json['name'],
//         hexToBytes(json['data']),
//         json['type'],
//         json['format'],
//         json['created'],
//         json['size'],
//       );

//   Map<String, dynamic> toJson() => {
//         'name': name,
//         'data': bytesToHex(data),
//         'type': type,
//         'format': format,
//         'created': created,
//         'size': size,
//       };
// }

// class CreateKeysParams {
//   final BucketEvent event;

//   CreateKeysParams(this.event);

//   factory CreateKeysParams.fromJson(Map<String, dynamic> json) =>
//       CreateKeysParams(BucketEvent.fromJson(json['event']));

//   Map<String, dynamic> toJson() => {'event': event.toJson()};
// }

// class AddRequestorParams {
//   final EthereumAddress requestor;

//   AddRequestorParams(this.requestor);

//   factory AddRequestorParams.fromJson(Map<String, dynamic> json) =>
//       AddRequestorParams(EthereumAddress.fromHex(json['requestor']));

//   Map<String, dynamic> toJson() => {'requestor': requestor.hex};
// }

// @JsonSerializable()
// class BucketEvent extends Equatable {
//   const BucketEvent({
//     this.action = BucketAction.initBucket,
//     this.getElementsParams,
//     this.createElementParams,
//     this.createKeysParams,
//     this.addRequestorParams,
//   });

//   factory BucketEvent.fromJson(Map<String, dynamic> json) =>
//       _$BucketEventFromJson(json);

//   final BucketAction action;
//   final GetElementsParams? getElementsParams;
//   final CreateElementParams? createElementParams;
//   final CreateKeysParams? createKeysParams;
//   final AddRequestorParams? addRequestorParams;

//   Map<String, dynamic> toJson() => _$BucketEventToJson(this);

//   @override
//   List<Object> get props => [action];
// }

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
