// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationModelAdapter extends TypeAdapter<OperationModel> {
  @override
  final int typeId = 3;

  @override
  OperationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OperationModel(
      fields[0] as EthereumAddress,
      fields[1] as BigInt,
      fields[2] as int,
      fields[3] as int,
    )..synced = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, OperationModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.elem)
      ..writeByte(1)
      ..write(obj.operationType)
      ..writeByte(2)
      ..write(obj.blockNumber)
      ..writeByte(3)
      ..write(obj.index)
      ..writeByte(4)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
