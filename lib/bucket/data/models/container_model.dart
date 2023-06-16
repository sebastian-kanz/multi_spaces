import 'package:hive/hive.dart';
import 'package:multi_spaces/core/constants.dart';

part 'container_model.g.dart';

@HiveType(typeId: hiveContainerModelTypeId)
class ContainerModel extends HiveObject {
  @HiveField(0)
  String hash;

  @HiveField(1)
  String identifier;

  ContainerModel(this.hash, this.identifier);
}
