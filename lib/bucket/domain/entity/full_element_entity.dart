import 'package:multi_spaces/bucket/domain/entity/container_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/data_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';
import 'package:web3dart/web3dart.dart';

class FullElementEntity {
  final ElementEntity element;
  final ContainerEntity container;
  final MetaEntity meta;
  final DataEntity? data;

  FullElementEntity(this.element, this.container, this.meta, {this.data});

  factory FullElementEntity.fromJson(Map<String, dynamic> json) =>
      FullElementEntity(
        ElementEntity.fromJson(json['element']),
        ContainerEntity.fromJson(json['container']),
        MetaEntity.fromJson(json['meta']),
        data: DataEntity.unsynced(json['data'] ?? ""),
      );

  Map<String, dynamic> toJson() => {
        'element': element.toJson(),
        'container': container.toJson(),
        'meta': meta.toJson(),
        'data': data?.hash,
      };

  static FullElementEntity unsynced(
    ElementEntity element,
  ) {
    return FullElementEntity(
      element,
      ContainerEntity.unsynced(element.containerHash),
      MetaEntity.unsynced(element.metaHash),
      data: DataEntity.unsynced(element.dataHash),
    );
  }
}
