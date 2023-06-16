import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:web3dart/web3dart.dart';

enum OperationType { add, update, updateParent, delete }

class OperationEntity {
  EthereumAddress element;
  OperationType operationType;
  int blockNumber;
  bool synced;
  int index;

  OperationEntity(
    this.element,
    this.operationType,
    this.blockNumber,
    this.synced,
    this.index,
  );
}
