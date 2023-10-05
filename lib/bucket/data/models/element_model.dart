import 'package:hive/hive.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:multi_spaces/core/contracts/Element.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';

part 'element_model.g.dart';

@HiveType(typeId: hiveElementModelTypeId)
class ElementModel extends HiveObject {
  @HiveField(0)
  final EthereumAddress element;

  @HiveField(1)
  final int contentType;

  @HiveField(2)
  final int created;

  @HiveField(3)
  final EthereumAddress creator;

  @HiveField(4)
  final String dataHash;

  @HiveField(5)
  final String metaHash;

  @HiveField(6)
  final String containerHash;

  @HiveField(7)
  int holdersCount;

  @HiveField(8)
  int redundancy;

  @HiveField(9)
  int minRedundancy;

  @HiveField(10)
  EthereumAddress parentElement;

  @HiveField(11)
  EthereumAddress nextElement;

  @HiveField(12)
  final EthereumAddress previousElement;

  ElementModel(
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

  Future<void> update() async {
    final elem = Element(
      address: element,
      client: MultiSpaceClient().client,
      chainId: Env.chain_id,
    );
    parentElement = await elem.parentBucket();
    nextElement = await elem.nextElement();
    holdersCount = (await elem.holdersCount()).toInt();
    minRedundancy = (await elem.minRedundancy()).toInt();
    redundancy = (await elem.redundancy()).toInt();
  }

  Element getElement() => Element(
        address: element,
        client: MultiSpaceClient().client,
        chainId: Env.chain_id,
      );
}
