import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/core/contracts/Element.g.dart';

import '../../../core/contracts/Bucket.g.dart';

class ElementEventMapper {
  static ElementEventEntity fromModel(dynamic elementEventModel) {
    switch (elementEventModel.runtimeType) {
      case Create:
        final cast = elementEventModel as Create;
        return CreateElementEventEntity(
          cast.elem,
          cast.blockNumber.toInt(),
          cast.sender,
        );
      case Update:
        final cast = elementEventModel as Update;
        return UpdateElementEventEntity(
          cast.prevElem,
          cast.newElemt,
          cast.blockNumber.toInt(),
          cast.sender,
        );
      case Delete:
        final cast = elementEventModel as Delete;
        return DeleteElementEventEntity(
          cast.elem,
          cast.blockNumber.toInt(),
          cast.sender,
        );
      case UpdateParent:
        final cast = elementEventModel as UpdateParent;
        return UpdateParentElementEventEntity(
          cast.elem,
          cast.parent,
          cast.blockNumber.toInt(),
          cast.sender,
        );
      case Request:
        final cast = elementEventModel as Request;
        return ElementRequestEventEntity(
          cast.elem,
          cast.requestor,
          cast.time.toInt(),
        );
      default:
        throw Exception("Unknown type!");
    }
  }

  // static ElementEventModel toModel(ElementEventEntity elementEventEntity) {
  //   // return ElementEventModel();
  // }
}
