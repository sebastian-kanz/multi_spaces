import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/key_bundle_entity.dart';
import 'package:web3dart/web3dart.dart';

class KeyCreation {
  final String txHash;
  final int epoch;
  KeyCreation(this.txHash, this.epoch);
}

abstract class BucketRepository {
  Stream<ElementEventEntity> get listenCreate;
  Stream<ElementEventEntity> get listenDelete;
  Stream<ElementEventEntity> get listenUpdate;
  Stream<ElementEventEntity> get listenUpdateParent;

  Stream<int> get listenKey;

  Future<List<ElementEntity>> getAllElements();

  Future<ElementEntity> getElement(EthereumAddress address);

  Future<String> createElements(
    List<String> newMetaHashes,
    List<String> newDataHashes,
    List<String> newContainerHashes,
    List<EthereumAddress> parents,
    BigInt contentType, {
    Transaction? transaction,
  });

  Future<KeyBundleEntity> getCurrentKeyForParticipant(
    EthereumAddress participant,
  );

  Future<KeyCreation> addKeys(
    List<EthereumAddress> participants,
    List<String> keys,
    String keyCreatorPubKey,
  );
}
