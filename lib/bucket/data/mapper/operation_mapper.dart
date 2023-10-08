import 'package:multi_spaces/bucket/data/models/operation_model.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';

class OperationMapper {
  static Future<OperationEntity> fromModel(OperationModel model) async {
    return OperationEntity(
      model.elem,
      OperationType.values[model.operationType.toInt()],
      model.blockNumber,
      model.synced,
      model.index,
    );
  }

  static OperationModel toModel(OperationEntity entity) {
    final model = OperationModel(
      entity.element,
      BigInt.from(entity.operationType.index),
      entity.blockNumber,
      entity.index,
    );
    model.synced = entity.synced;
    return model;
  }
}
