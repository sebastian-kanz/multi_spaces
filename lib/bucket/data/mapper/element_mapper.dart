import 'package:multi_spaces/bucket/data/models/element_model.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';

import '../../../core/contracts/Element.g.dart';

class ElementMapper {
  static Future<ElementModel> fromContract(Element elem) async {
    final contentType = (await retry(
      () => elem.contentType(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
    final creationTime = (await retry(
      () => elem.creationTime(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
    final creator = await retry(
      () => elem.creator(),
      retryIf: (e) => e is RPCError,
    );
    final dataHash = await retry(
      () => elem.dataHash(),
      retryIf: (e) => e is RPCError,
    );
    final metaHash = await retry(
      () => elem.metaHash(),
      retryIf: (e) => e is RPCError,
    );
    final containerHash = await retry(
      () => elem.containerHash(),
      retryIf: (e) => e is RPCError,
    );
    final holdersCount = (await retry(
      () => elem.holdersCount(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
    final redundancy = (await retry(
      () => elem.redundancy(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
    final minRedundancy = (await retry(
      () => elem.minRedundancy(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
    final parentElement = await retry(
      () => elem.parentElement(),
      retryIf: (e) => e is RPCError,
    );
    final nextElement = await retry(
      () => elem.nextElement(),
      retryIf: (e) => e is RPCError,
    );
    final previousElement = await retry(
      () => elem.previousElement(),
      retryIf: (e) => e is RPCError,
    );

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
      client: MultiSpaceClient().client,
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
