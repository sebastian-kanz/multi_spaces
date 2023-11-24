import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';

class CreateMetaDto {
  String name;
  String type;
  String format;
  int created;
  int size;
  int? quality;
  String? metaRef;
  String? tags;
  String? coordinates;
  String? language;
  String? compression;
  String? deeplink;

  CreateMetaDto(
    this.name,
    this.type,
    this.format,
    this.created,
    this.size, {
    this.quality,
    this.metaRef,
    this.tags,
    this.coordinates,
    this.language,
    this.compression,
    this.deeplink,
  });

  CreateMetaDto copyWith({
    String? name,
    String? type,
    String? format,
    int? created,
    int? size,
    int? quality,
    String? metaRef,
    String? tags,
    String? coordinates,
    String? language,
    String? compression,
    String? deeplink,
  }) {
    return CreateMetaDto(
      name ?? this.name,
      type ?? this.type,
      format ?? this.format,
      created ?? this.created,
      size ?? this.size,
      quality: quality ?? this.quality,
      metaRef: metaRef ?? this.metaRef,
      tags: tags ?? this.tags,
      coordinates: coordinates ?? this.coordinates,
      language: language ?? this.language,
      compression: compression ?? this.compression,
      deeplink: deeplink ?? this.deeplink,
    );
  }

  factory CreateMetaDto.fromEntity(MetaEntity entity) => CreateMetaDto(
        entity.name,
        entity.type,
        entity.format,
        entity.created,
        entity.size,
        quality: entity.quality,
        metaRef: entity.metaRef,
        tags: entity.tags,
        coordinates: entity.coordinates,
        language: entity.language,
        compression: entity.compression,
        deeplink: entity.deeplink,
      );
}

abstract class MetaRepository {
  Future<MetaEntity> getMeta(String metaHash,
      {int? creationBlockNumber, bool sync = false});
  Future<MetaEntity> createMeta(CreateMetaDto createMetaDto,
      {int? creationBlockNumber});
  Future<List<MetaEntity>> getAllLocalMetas();
  Future<void> removeMeta(String metaHash);
}
