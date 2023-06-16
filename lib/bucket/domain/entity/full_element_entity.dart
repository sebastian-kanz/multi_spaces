import 'package:multi_spaces/bucket/domain/entity/container_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/data_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';

enum ContentType { file }

class FullElementEntity {
  final ElementEntity element;
  final ContainerEntity container;
  final MetaEntity meta;
  final DataEntity? data;

  FullElementEntity(this.element, this.container, this.meta, {this.data});
}
