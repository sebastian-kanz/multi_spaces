import 'package:multi_spaces/bucket/domain/entity/container_entity.dart';

abstract class ContainerRepository {
  Future<ContainerEntity> getContainer(String hash, {bool sync = false});
  Future<ContainerEntity> createContainer();
  Future<void> removeContainer(String hash);
}
