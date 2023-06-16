import 'package:http/http.dart';
import 'package:multi_spaces/bucket/data/models/element_model.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/contracts/Element.g.dart';

class ElementMapper {
  static Future<ElementModel> fromContract(Element elem) async {
    final contentType = (await elem.contentType()).toInt();
    final creationTime = (await elem.creationTime()).toInt();
    final creator = await elem.creator();
    final dataHash = await elem.dataHash();
    final metaHash = await elem.metaHash();
    final containerHash = await elem.containerHash();
    final holdersCount = (await elem.holdersCount()).toInt();
    final redundancy = (await elem.redundancy()).toInt();
    final minRedundancy = (await elem.minRedundancy()).toInt();
    final parentElement = await elem.parentElement();
    final nextElement = await elem.nextElement();
    final previousElement = await elem.previousElement();

    return ElementModel(
      elem.self.address,
      contentType,
      creationTime,
      creator,
      dataHash,
      metaHash,
      containerHash,
      holdersCount,
      redundancy,
      minRedundancy,
      parentElement,
      nextElement,
      previousElement,
    );
  }

  static ElementEntity fromModel(ElementModel model) {
    return ElementEntity(
      model.element,
      ContentType.values[model.contentType],
      model.created,
      model.creator,
      model.dataHash,
      model.metaHash,
      model.containerHash,
      model.holdersCount,
      model.redundancy,
      model.minRedundancy,
      model.parentElement,
      model.nextElement,
      model.previousElement,
    );
  }

  static Element toContract(ElementEntity elementEntity) {
    return Element(
      address: elementEntity.element,
      client: Web3Client(Env.eth_url, Client()),
      chainId: Env.chain_id,
    );
  }

  static ElementModel toModel(ElementEntity entity) {
    return ElementModel(
      entity.element,
      entity.contentType.index,
      entity.created,
      entity.creator,
      entity.dataHash,
      entity.metaHash,
      entity.containerHash,
      entity.holdersCount,
      entity.redundancy,
      entity.minRedundancy,
      entity.parentElement,
      entity.nextElement,
      entity.previousElement,
    );
  }
}
