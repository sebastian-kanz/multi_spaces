import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:web3dart/web3dart.dart';

class EthereumAddressAdapter extends TypeAdapter<EthereumAddress> {
  @override
  EthereumAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EthereumAddress(fields[0] as Uint8List);
  }

  @override
  int get typeId => hiveEthereumAddressTypeId;

  @override
  void write(BinaryWriter writer, EthereumAddress obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.addressBytes);
  }
}
