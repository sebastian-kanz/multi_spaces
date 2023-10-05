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

  bool synced = true;

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

  factory ElementEntity.fromJson(Map<String, dynamic> json) => ElementEntity(
        EthereumAddress.fromHex(json['element']),
        ContentType.values[json['contentType']],
        json['created'],
        EthereumAddress.fromHex(json['creator']),
        json['dataHash'],
        json['metaHash'],
        json['containerHash'],
        json['holdersCount'],
        json['redundancy'],
        json['minRedundancy'],
        EthereumAddress.fromHex(json['parentElement']),
        EthereumAddress.fromHex(json['nextElement']),
        EthereumAddress.fromHex(json['previousElement']),
      );

  Map<String, dynamic> toJson() => {
        'element': element.hex,
        'contentType': contentType.index,
        'created': created,
        'creator': creator.hex,
        'dataHash': dataHash,
        'metaHash': metaHash,
        'containerHash': containerHash,
        'holdersCount': holdersCount,
        'redundancy': redundancy,
        'minRedundancy': minRedundancy,
        'parentElement': parentElement.hex,
        'nextElement': nextElement.hex,
        'previousElement': previousElement.hex,
      };
}
