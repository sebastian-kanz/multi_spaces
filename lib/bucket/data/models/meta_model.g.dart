// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetaModelAdapter extends TypeAdapter<MetaModel> {
  @override
  final int typeId = 1;

  @override
  MetaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetaModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as int,
      fields[5] as int?,
      fields[6] as String?,
      fields[7] as String?,
      fields[8] as String?,
      fields[9] as String?,
      fields[10] as String?,
      fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MetaModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.format)
      ..writeByte(4)
      ..write(obj.created)
      ..writeByte(5)
      ..write(obj.quality)
      ..writeByte(6)
      ..write(obj.metaRef)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.coordinates)
      ..writeByte(9)
      ..write(obj.language)
      ..writeByte(10)
      ..write(obj.compression)
      ..writeByte(11)
      ..write(obj.deeplink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetaModel _$MetaModelFromJson(Map<String, dynamic> json) => MetaModel(
      json['hash'] as String,
      json['name'] as String,
      json['type'] as String,
      json['format'] as String,
      json['created'] as int,
      json['quality'] as int?,
      json['metaRef'] as String?,
      json['tags'] as String?,
      json['coordinates'] as String?,
      json['language'] as String?,
      json['compression'] as String?,
      json['deeplink'] as String?,
    );

Map<String, dynamic> _$MetaModelToJson(MetaModel instance) => <String, dynamic>{
      'hash': instance.hash,
      'name': instance.name,
      'type': instance.type,
      'format': instance.format,
      'created': instance.created,
      'quality': instance.quality,
      'metaRef': instance.metaRef,
      'tags': instance.tags,
      'coordinates': instance.coordinates,
      'language': instance.language,
      'compression': instance.compression,
      'deeplink': instance.deeplink,
    };
