// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContainerModelAdapter extends TypeAdapter<ContainerModel> {
  @override
  final int typeId = 4;

  @override
  ContainerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContainerModel(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContainerModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.identifier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
