// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElementModelAdapter extends TypeAdapter<ElementModel> {
  @override
  final int typeId = 2;

  @override
  ElementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElementModel(
      fields[0] as EthereumAddress,
      fields[1] as int,
      fields[2] as int,
      fields[3] as EthereumAddress,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as int,
      fields[8] as int,
      fields[9] as int,
      fields[10] as EthereumAddress,
      fields[11] as EthereumAddress,
      fields[12] as EthereumAddress,
    );
  }

  @override
  void write(BinaryWriter writer, ElementModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.element)
      ..writeByte(1)
      ..write(obj.contentType)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.creator)
      ..writeByte(4)
      ..write(obj.dataHash)
      ..writeByte(5)
      ..write(obj.metaHash)
      ..writeByte(6)
      ..write(obj.containerHash)
      ..writeByte(7)
      ..write(obj.holdersCount)
      ..writeByte(8)
      ..write(obj.redundancy)
      ..writeByte(9)
      ..write(obj.minRedundancy)
      ..writeByte(10)
      ..write(obj.parentElement)
      ..writeByte(11)
      ..write(obj.nextElement)
      ..writeByte(12)
      ..write(obj.previousElement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
