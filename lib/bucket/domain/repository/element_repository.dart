import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:web3dart/web3dart.dart';

abstract class ElementRepository {
  Future<ElementEntity> getElement(EthereumAddress address);
  Future<String> createElement(
    String newMetaHash,
    String newDataHash,
    String newContainerHash,
    EthereumAddress parent,
    ContentType contentType,
  );
  Future<List<ElementEntity>> getAllLocalElements();
}
