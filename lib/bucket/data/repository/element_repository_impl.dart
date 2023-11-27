import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:hive/hive.dart';
import 'package:multi_spaces/core/networking/MultiSpaceClient.dart';
import 'package:multi_spaces/bucket/data/mapper/element_event_mapper.dart';
import 'package:multi_spaces/bucket/data/mapper/element_mapper.dart';
import 'package:multi_spaces/bucket/data/models/element_model.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/entity/element_event_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/repository/initializable_storage_repository.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/contracts/Element.g.dart';
import '../../../core/contracts/Bucket.g.dart';

class ElementRepositoryImpl
    with InitializableStorageRepository<ElementModel>
    implements ElementRepository {
  final Bucket _bucket;
  ElementRepositoryImpl(Bucket bucket) : _bucket = bucket {
    final adapter = ElementModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  @override
  Future<List<ElementEntity>> getAllLocalElements() async {
    final entities = box.values
        .map(
          (model) => ElementMapper.fromModel(model),
        )
        .toList();
    return Future.value(entities);
  }

  @override
  Future<List<ElementEntity>> getAllLatestLocalRootElements() async {
    final entities = box.values
        .map(
          (model) => ElementMapper.fromModel(model),
        )
        .toList();
    final latest = entities.where((element) => !element.hasNext()).toList();
    final elements = latest
        .where((element) => !element.hasParent() && element.dataHash != "")
        .toList();
    return Future.value(elements);
  }

  @override
  Future<List<ElementEntity>> getAllLatestLocalRootFolders() async {
    final entities = box.values
        .map(
          (model) => ElementMapper.fromModel(model),
        )
        .toList();
    final latest = entities.where((element) => !element.hasNext()).toList();
    final folders = latest
        .where((element) => !element.hasParent() && element.dataHash == "")
        .toList();
    return Future.value(folders);
  }

  @override
  Future<Element> getElement(EthereumAddress address) async {
    return Element(
      address: address,
      client: MultiSpaceClient().client,
      chainId: Env.chain_id,
    );
  }

  @override
  Future<String> updateElement(
    EthereumAddress address,
    String metaHash,
    String dataHash,
    String containerHash,
    EthereumAddress parent,
  ) async {
    return Element(
      address: address,
      client: MultiSpaceClient().client,
      chainId: Env.chain_id,
    ).update(
      [metaHash, dataHash, containerHash],
      parent,
      credentials:
          BlockchainProviderManager().internalProvider.getCredentails(),
      transaction: Transaction(
        from: BlockchainProviderManager().internalProvider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }

  @override
  Stream<ElementEventEntity> listenElementRequests(
    EthereumAddress address,
  ) {
    final element = Element(
      address: address,
      client: MultiSpaceClient().client,
      chainId: Env.chain_id,
    );
    // yield* element
    //     .requestEvents()
    //     .asyncMap((event) => ElementEventMapper.fromModel(event));
    return element
        .requestEvents()
        .asyncMap((event) => ElementEventMapper.fromModel(event));
  }

  @override
  Future<ElementEntity> getElementEntity(EthereumAddress address) async {
    var model = box.get(address.hex);
    if (model == null) {
      final elem = Element(
        address: address,
        client: MultiSpaceClient().client,
        chainId: Env.chain_id,
      );
      model = await ElementMapper.fromContract(elem);
      await box.put(address.hex, model);
      return ElementMapper.fromModel(model);
    }
    return ElementMapper.fromModel(model);
  }

  @override
  Future<String> createElement(
    String newMetaHash,
    String newDataHash,
    String newContainerHash,
    EthereumAddress parent,
    ContentType contentType, {
    bool internal = true,
    int? baseFee,
  }) async {
    try {
      if (internal) {
        return retry(
          () => _bucket.createElements(
            [newMetaHash],
            [newDataHash],
            [newContainerHash],
            [parent],
            BigInt.from(contentType.index),
            credentials:
                BlockchainProviderManager().internalProvider.getCredentails(),
            transaction: Transaction(
              from: BlockchainProviderManager().internalProvider.getAccount(),
              maxGas: 3000000,
            ),
          ),
          retryIf: (e) => e is RPCError,
        );
      } else {
        return retry(
          () => _bucket.createElements(
            [newMetaHash],
            [newDataHash],
            [newContainerHash],
            [parent],
            BigInt.from(contentType.index),
            credentials: BlockchainProviderManager()
                .authenticatedProvider!
                .getCredentails(),
            transaction: Transaction(
              from: BlockchainProviderManager()
                  .authenticatedProvider!
                  .getAccount(),
              maxGas: 3000000,
              value: baseFee != null
                  ? EtherAmount.inWei(BigInt.from(baseFee))
                  : null,
            ),
          ),
          retryIf: (e) => e is RPCError,
        );
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<List<ElementEntity>> getLatest() {
    final entities = box.values
        .map(
          (model) => ElementMapper.fromModel(model),
        )
        .toList();
    final latest = entities.where((element) => !element.hasNext()).toList();
    return Future.value(latest);
  }

  @override
  Future<List<ElementEntity>> getLatestChildren({ElementEntity? parent}) {
    final entities = box.values
        .map(
          (model) => ElementMapper.fromModel(model),
        )
        .toList();
    final latest = entities.where((element) => !element.hasNext()).toList();
    List<ElementEntity> children = [];
    if (parent != null) {
      children = latest
          .where((element) =>
              element.hasParent() &&
              element.parentElement.hex == parent.element.hex)
          .toList();
    } else {
      children = latest.where((element) => !element.hasParent()).toList();
    }
    return Future.value(children);
  }

  @override
  Future<ElementEntity> getNextVersion() {
    // TODO: implement getNextVersion
    throw UnimplementedError();
  }

  @override
  Future<ElementEntity> getParent() {
    // TODO: implement getParent
    throw UnimplementedError();
  }

  @override
  Future<ElementEntity> getPreviousVersion() {
    // TODO: implement getPreviousVersion
    throw UnimplementedError();
  }
}
