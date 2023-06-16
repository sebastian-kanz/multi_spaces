import 'package:multi_spaces/bucket/data/models/container_model.dart';
import 'package:multi_spaces/bucket/domain/entity/container_entity.dart';

class ContainerMapper {
  static ContainerEntity fromModel(ContainerModel model) {
    return ContainerEntity(
      model.hash,
      model.identifier,
    );
  }

  static ContainerModel toModel(ContainerEntity entity) {
    return ContainerModel(
      entity.hash,
      entity.identifier,
    );
  }
}
