import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/core/contracts/Element.g.dart';
import 'package:web3dart/web3dart.dart';

abstract class ElementRepository {
  Future<Element> getElement(EthereumAddress address);
  Stream<ElementEventEntity> listenElementRequests(EthereumAddress address);
  Future<ElementEntity> getElementEntity(EthereumAddress address);
  Future<String> createElement(
    String newMetaHash,
    String newDataHash,
    String newContainerHash,
    EthereumAddress parent,
    ContentType contentType, {
    bool internal = true,
    int? baseFee,
  });
  Future<String> updateElement(
    EthereumAddress address,
    String metaHash,
    String dataHash,
    String containerHash,
    EthereumAddress parent,
  );
  Future<List<ElementEntity>> getAllLocalElements();
  Future<List<ElementEntity>> getAllLatestLocalRootFolders();
  Future<List<ElementEntity>> getAllLatestLocalRootElements();
  Future<ElementEntity> getPreviousVersion();
  Future<ElementEntity> getNextVersion();
  Future<ElementEntity> getParent();
  Future<List<ElementEntity>> getLatestChildren({ElementEntity? parent});
  Future<List<ElementEntity>> getLatest();
}
