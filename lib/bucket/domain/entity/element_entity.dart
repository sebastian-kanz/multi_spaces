import 'package:multi_spaces/core/constants.dart';
import 'package:web3dart/web3dart.dart';

enum ContentType { file }

class ElementEntity {
  final EthereumAddress element;
  final ContentType contentType;
  int created;
  EthereumAddress creator;
  String dataHash;
  String metaHash;
  String containerHash;
  int holdersCount;
  int redundancy;
  int minRedundancy;
  EthereumAddress parentElement;
  EthereumAddress nextElement;
  EthereumAddress previousElement;

  ElementEntity(
    this.element,
    this.contentType,
    this.created,
    this.creator,
    this.dataHash,
    this.metaHash,
    this.containerHash,
    this.holdersCount,
    this.redundancy,
    this.minRedundancy,
    this.parentElement,
    this.nextElement,
    this.previousElement,
  );

  bool hasParent() => parentElement.compareTo(zeroAddress) == 0 ? false : true;
  bool hasNext() => nextElement.compareTo(element) == 0 ? false : true;
  bool hasPrevious() =>
      parentElement.compareTo(zeroAddress) == 0 ? false : true;
  bool fulfillsRedundancy() => redundancy >= minRedundancy ? true : false;
}
