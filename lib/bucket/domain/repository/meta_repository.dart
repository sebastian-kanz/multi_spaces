import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';

class CreateMetaDto {
  String name;
  String type;
  String format;
  int created;
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
    this.created, {
    this.quality,
    this.metaRef,
    this.tags,
    this.coordinates,
    this.language,
    this.compression,
    this.deeplink,
  });
}

abstract class MetaRepository {
  Future<MetaEntity> getMeta(String metaHash,
      {int? creationBlockNumber, bool sync = false});
  Future<MetaEntity> createMeta(CreateMetaDto createMetaDto,
      {int? creationBlockNumber});
  Future<List<MetaEntity>> getAllLocalMetas();
  Future<void> removeMeta(String metaHash, String containerHash);
}
