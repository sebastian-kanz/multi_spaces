// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BucketState _$BucketStateFromJson(Map<String, dynamic> json) => BucketState(
      status: $enumDecodeNullable(_$BucketStatusEnumMap, json['status']) ??
          BucketStatus.initial,
      elements: (json['elements'] as List<dynamic>?)
              ?.map(
                  (e) => FullElementEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      parents: (json['parents'] as List<dynamic>?)
              ?.map(
                  (e) => FullElementEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      requestors: json['requestors'] == null
          ? const []
          : _requestorsFromJson(json['requestors'] as List<String>),
      nestedEvent: json['nestedEvent'] == null
          ? null
          : CreateElementEvent.fromJson(
              json['nestedEvent'] as Map<String, dynamic>),
      error: json['error'],
      epoch: json['epoch'] as int?,
    );

Map<String, dynamic> _$BucketStateToJson(BucketState instance) =>
    <String, dynamic>{
      'status': _$BucketStatusEnumMap[instance.status]!,
      'elements': instance.elements,
      'parents': instance.parents,
      'requestors': _requestorsToJson(instance.requestors),
      'nestedEvent': instance.nestedEvent,
      'error': instance.error,
      'epoch': instance.epoch,
    };

const _$BucketStatusEnumMap = {
  BucketStatus.initial: 'initial',
  BucketStatus.initialized: 'initialized',
  BucketStatus.loading: 'loading',
  BucketStatus.success: 'success',
  BucketStatus.ready: 'ready',
  BucketStatus.failure: 'failure',
  BucketStatus.waitingForParticipation: 'waitingForParticipation',
  BucketStatus.waitingForKeys: 'waitingForKeys',
};
