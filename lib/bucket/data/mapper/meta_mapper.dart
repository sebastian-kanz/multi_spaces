import 'package:multi_spaces/bucket/data/models/meta_model.dart';
import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';

class MetaMapper {
  static MetaEntity fromModel(MetaModel model) {
    return MetaEntity(
      model.hash,
      model.name,
      model.type,
      model.format,
      model.created,
      model.size,
      model.quality,
      model.metaRef,
      model.tags,
      model.coordinates,
      model.language,
      model.compression,
      model.deeplink,
    );
  }

  static MetaModel toModel(MetaEntity entity) {
    return MetaModel(
      entity.hash,
      entity.name,
      entity.type,
      entity.format,
      entity.created,
      entity.size,
      entity.quality,
      entity.metaRef,
      entity.tags,
      entity.coordinates,
      entity.language,
      entity.compression,
      entity.deeplink,
    );
  }
}
