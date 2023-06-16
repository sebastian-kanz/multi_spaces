import 'package:hive/hive.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:web3dart/web3dart.dart';

part 'operation_model.g.dart';

@HiveType(typeId: hiveOperationModelTypeId)
class OperationModel extends HiveObject {
  @HiveField(0)
  EthereumAddress elem;

  @HiveField(1)
  BigInt operationType;

  @HiveField(2)
  int blockNumber;

  @HiveField(3)
  int index;

  @HiveField(4)
  bool synced = false;

  OperationModel(this.elem, this.operationType, this.blockNumber, this.index);
}
