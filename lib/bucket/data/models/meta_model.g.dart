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
      fields[5] as int,
      fields[6] as int?,
      fields[7] as String?,
      fields[8] as String?,
      fields[9] as String?,
      fields[10] as String?,
      fields[11] as String?,
      fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MetaModel obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.quality)
      ..writeByte(7)
      ..write(obj.metaRef)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.coordinates)
      ..writeByte(10)
      ..write(obj.language)
      ..writeByte(11)
      ..write(obj.compression)
      ..writeByte(12)
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

MetaModel _$MetaModelFromJson(Map<String, dynamic> json) => $checkedCreate(
      'MetaModel',
      json,
      ($checkedConvert) {
        final val = MetaModel(
          $checkedConvert('hash', (v) => v as String),
          $checkedConvert('name', (v) => v as String),
          $checkedConvert('type', (v) => v as String),
          $checkedConvert('format', (v) => v as String),
          $checkedConvert('created', (v) => v as int),
          $checkedConvert('size', (v) => v as int),
          $checkedConvert('quality', (v) => v as int?),
          $checkedConvert('metaRef', (v) => v as String?),
          $checkedConvert('tags', (v) => v as String?),
          $checkedConvert('coordinates', (v) => v as String?),
          $checkedConvert('language', (v) => v as String?),
          $checkedConvert('compression', (v) => v as String?),
          $checkedConvert('deeplink', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$MetaModelToJson(MetaModel instance) {
  final val = <String, dynamic>{
    'hash': instance.hash,
    'name': instance.name,
    'type': instance.type,
    'format': instance.format,
    'created': instance.created,
    'size': instance.size,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('quality', instance.quality);
  writeNotNull('metaRef', instance.metaRef);
  writeNotNull('tags', instance.tags);
  writeNotNull('coordinates', instance.coordinates);
  writeNotNull('language', instance.language);
  writeNotNull('compression', instance.compression);
  writeNotNull('deeplink', instance.deeplink);
  return val;
}
