import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/key_bundle_entity.dart';
import 'package:multi_spaces/core/contracts/Bucket.g.dart';
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
  Stream<int> get listenAllKeys;

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

  Future<KeyCreation> setKeyForParticipant(
    EthereumAddress participant,
    String key,
    int epoch,
  );

  Future<String> addParticipation(
    String name,
    EthereumAddress requestor,
    Uint8List pubKey,
  );

  Future<String> requestParticipation(
    String name,
    EthereumAddress requestor,
    Uint8List pubKey,
    String deviceName,
    EthereumAddress device,
    Uint8List devicePubKey,
    Uint8List signature,
  );

  Future<String> acceptParticipation(
    EthereumAddress requestor, {
    int? baseFee,
  });

  Future<int> blockToEpoch(int creationBlockNumber);

  Future<int> epochToBlock(int epoch);

  Future<int> getAllEpochsCount();

  Future<int> getEpoch(int number);

  Future<EpochToParticipantToKeyMapping> getKeyMapping(
    int epoch,
    EthereumAddress participant,
  );
}
