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
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BucketRepositoryImpl implements BucketRepository {
  BucketRepositoryImpl(
      List<BlockchainProvider> providers, String bucketContractAddress)
      : _bucket = Bucket(
          address: EthereumAddress.fromHex(bucketContractAddress),
          client: Web3Client(Env.eth_url, Client()),
          chainId: Env.chain_id,
        ) {
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
    }
  }

  final Bucket _bucket;
  late BlockchainProvider _provider;

  @override
  Stream<ElementEventEntity> get listenCreate async* {
    yield* _bucket
        .createEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<ElementEventEntity> get listenDelete async* {
    yield* _bucket
        .deleteEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<ElementEventEntity> get listenUpdate async* {
    yield* _bucket
        .updateEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<ElementEventEntity> get listenUpdateParent async* {
    yield* _bucket
        .updateParentEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Stream<int> get listenKey async* {
    yield* _bucket.keysAddedEvents().asyncMap((event) => event.epoch.toInt());
  }

  @override
  Future<List<ElementEntity>> getAllElements() async {
    final result = await _bucket.getAll();
    final allElements = result
        .map(
          (e) => Element(
            address: e,
            client: Web3Client(Env.eth_url, Client()),
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
      client: Web3Client(Env.eth_url, Client()),
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
    return _bucket.createElements(
      newMetaHashes,
      newDataHashes,
      newContainerHashes,
      parents,
      contentType,
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  @override
  Future<KeyBundleEntity> getCurrentKeyForParticipant(
    EthereumAddress participant,
  ) async {
    final blockNumber = await _bucket.client.getBlockNumber();
    final result = await _bucket.getKeyBundle(
      participant,
      BigInt.from(blockNumber),
    );
    return KeyBundleEntity(result.var1, result.var2);
  }

  Future<int> blockToEpoch(int creationBlockNumber) async {
    final genesis = (await _bucket.GENESIS()).toInt();
    final blocksPerEpoch = (await _bucket.EPOCH()).toInt();
    return ((creationBlockNumber - genesis) / blocksPerEpoch).floor();
  }

  @override
  Future<KeyCreation> addKeys(
    List<EthereumAddress> participants,
    List<String> keys,
    String keyCreatorPubKey,
  ) async {
    final result = await _bucket.addKeys(
      keys,
      participants,
      keyCreatorPubKey,
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
    final block = await _bucket.client.getBlockNumber();
    final epoch = await blockToEpoch(block);
    return KeyCreation(result, epoch);
  }
}
