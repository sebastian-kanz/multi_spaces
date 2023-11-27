import 'dart:typed_data';

import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:multi_spaces/bucket/data/mapper/element_event_mapper.dart';
import 'package:multi_spaces/bucket/data/mapper/element_mapper.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/key_bundle_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/bucket_repository.dart';
import 'package:multi_spaces/core/contracts/Bucket.g.dart';
import 'package:multi_spaces/core/contracts/Element.g.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

class BucketRepositoryImpl implements BucketRepository {
  BucketRepositoryImpl(String bucketContractAddress)
      : _bucket = Bucket(
          address: EthereumAddress.fromHex(bucketContractAddress),
          client: MultiSpaceClient().client,
          chainId: Env.chain_id,
        );

  final Bucket _bucket;

  @override
  Stream<ElementEventEntity> get listenCreate {
    // yield* _bucket
    //     .createEvents()
    //     .asyncMap((event) => ElementEventMapper.fromModel(event));
    return _bucket
        .createEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<ElementEventEntity> get listenDelete {
    // yield* _bucket
    //     .deleteEvents()
    //     .asyncMap((event) => ElementEventMapper.fromModel(event));
    return _bucket
        .deleteEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<ElementEventEntity> get listenUpdate {
    // yield* _bucket
    //     .updateEvents()
    //     .asyncMap((event) => ElementEventMapper.fromModel(event));
    return _bucket
        .updateEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<ElementEventEntity> get listenUpdateParent {
    // yield* _bucket
    //     .updateParentEvents()
    //     .asyncMap((event) => ElementEventMapper.fromModel(event));
    return _bucket
        .updateParentEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<int> get listenKey {
    // yield* _bucket.keysAddedEvents().asyncMap((event) => event.epoch.toInt());
    return _bucket.keysAddedEvents().asyncMap((event) => event.epoch.toInt());
  }

  @override
  Stream<int> get listenAllKeys async* {
    final genesis = await _getGenesis();
    yield* _bucket
        .keysAddedEvents(
            fromBlock: BlockNum.exact(genesis),
            toBlock: const BlockNum.current())
        .asyncMap((event) => event.epoch.toInt());
  }

  @override
  Future<List<ElementEntity>> getAllElements() async {
    final result = await retry(
      () => _bucket.getAll(),
      retryIf: (e) => e is RPCError,
    );
    final allElements = result
        .map(
          (e) => Element(
            address: e,
            client: MultiSpaceClient().client,
            chainId: Env.chain_id,
          ),
        )
        .toList();
    return Future.wait(
      allElements
          .map((e) async =>
              ElementMapper.fromModel(await ElementMapper.fromContract(e)))
          .toList(),
    );
  }

  @override
  Future<ElementEntity> getElement(EthereumAddress address) async {
    final result = Element(
      address: address,
      client: MultiSpaceClient().client,
      chainId: Env.chain_id,
    );
    return ElementMapper.fromModel(
      await ElementMapper.fromContract(result),
    );
  }

  @override
  Future<String> createElements(
    List<String> newMetaHashes,
    List<String> newDataHashes,
    List<String> newContainerHashes,
    List<EthereumAddress> parents,
    BigInt contentType, {
    Transaction? transaction,
  }) async {
    return retry(
      () => _bucket.createElements(
        newMetaHashes,
        newDataHashes,
        newContainerHashes,
        parents,
        contentType,
        credentials:
            BlockchainProviderManager().authenticatedProvider!.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
          maxGas: 3000000,
        ),
      ),
      retryIf: (e) => e is RPCError,
    );
  }

  @override
  Future<KeyBundleEntity> getCurrentKeyForParticipant(
    EthereumAddress participant,
  ) async {
    final blockNumber = await _getCurrentBlock();
    final result = await retry(
      () => _bucket.getKeyBundle(
        participant,
        BigInt.from(blockNumber),
      ),
      retryIf: (e) => e is RPCError,
    );

    return KeyBundleEntity(result.var1, result.var2);
  }

  @override
  Future<int> blockToEpoch(int creationBlockNumber) async {
    final genesis = await _getGenesis();
    final blocksPerEpoch = await _getBlocksPerEpoch();
    return ((creationBlockNumber - genesis) / blocksPerEpoch).floor();
  }

  @override
  Future<int> epochToBlock(int epoch) async {
    final genesis = await _getGenesis();
    final blocksPerEpoch = await _getBlocksPerEpoch();
    final block = genesis + epoch * blocksPerEpoch;
    return block;
  }

  @override
  Future<KeyCreation> addKeys(
    List<EthereumAddress> participants,
    List<String> keys,
    String keyCreatorPubKey,
  ) async {
    final result = await retry(
      () => _bucket.addKeys(
        keys,
        participants,
        keyCreatorPubKey,
        credentials:
            BlockchainProviderManager().internalProvider.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().internalProvider.getAccount(),
          maxGas: 3000000,
        ),
      ),
      retryIf: (e) => e is RPCError,
    );
    final blockNumber = await _getCurrentBlock();
    final epoch = await blockToEpoch(blockNumber);
    return KeyCreation(result, epoch);
  }

  @override
  Future<KeyCreation> setKeyForParticipant(
    EthereumAddress participant,
    String key,
    int epoch,
  ) async {
    final block = await epochToBlock(epoch);
    final result = await retry(
      () async => _bucket.setKeyForParticipant(
        key,
        participant,
        BlockchainProviderManager().internalProvider.getPublicKeyHex(),
        BigInt.from(block),
        credentials:
            BlockchainProviderManager().internalProvider.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().internalProvider.getAccount(),
          maxGas: 3000000,
        ),
      ),
      retryIf: (e) => e is RPCError,
    );
    return KeyCreation(result, epoch);
  }

  @override
  Future<String> addParticipation(
    String name,
    EthereumAddress requestor,
    Uint8List pubKey,
  ) async {
    return retry(
      () => _bucket.addParticipation(
        name,
        requestor,
        pubKey,
        credentials:
            BlockchainProviderManager().authenticatedProvider!.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
        ),
      ),
      retryIf: (e) => e is RPCError,
    );
  }

  @override
  Future<String> requestParticipation(
    String name,
    EthereumAddress requestor,
    Uint8List pubKey,
    String deviceName,
    EthereumAddress device,
    Uint8List devicePubKey,
    Uint8List signature,
  ) async {
    return retry(
      () => _bucket.requestParticipation(
        name,
        requestor,
        pubKey,
        deviceName,
        device,
        devicePubKey,
        signature,
        credentials:
            BlockchainProviderManager().authenticatedProvider!.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().authenticatedProvider!.getAccount(),
        ),
      ),
      retryIf: (e) => e is RPCError,
    );
  }

  @override
  Future<String> acceptParticipation(
    EthereumAddress requestor, {
    int? baseFee,
  }) async {
    return retry(
      () => _bucket.acceptParticipation(
        requestor,
        credentials:
            BlockchainProviderManager().internalProvider.getCredentails(),
        transaction: Transaction(
          from: BlockchainProviderManager().internalProvider.getAccount(),
          maxGas: 3000000,
          value:
              baseFee != null ? EtherAmount.inWei(BigInt.from(baseFee)) : null,
        ),
      ),
      retryIf: (e) => e is RPCError,
    );
  }

  @override
  Future<int> getAllEpochsCount() async {
    return (await retry(
      () => _bucket.allEpochsCount(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }

  @override
  Future<int> getEpoch(int number) async {
    return (await retry(
      () => _bucket.allEpochs(BigInt.from(number)),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }

  @override
  Future<EpochToParticipantToKeyMapping> getKeyMapping(
    int epoch,
    EthereumAddress participant,
  ) async {
    final epochToParticipantToKeyMapping = await retry(
      () => _bucket.epochToParticipantToKeyMapping(
        BigInt.from(epoch),
        participant,
      ),
      retryIf: (e) => e is RPCError,
    );
    return epochToParticipantToKeyMapping;
  }

  Future<int> _getGenesis() async {
    return (await retry(
      () => _bucket.GENESIS(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }

  Future<int> _getBlocksPerEpoch() async {
    return (await retry(
      () => _bucket.EPOCH(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }

  Future<int> _getCurrentBlock() async {
    return (await retry(
      () => _bucket.client.getBlockNumber(),
      retryIf: (e) => e is RPCError,
    ))
        .toInt();
  }
}
