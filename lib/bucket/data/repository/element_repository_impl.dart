import 'package:blockchain_provider/blockchain_provider.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:multi_spaces/bucket/data/mapper/element_mapper.dart';
import 'package:multi_spaces/bucket/data/models/element_model.dart';
import 'package:multi_spaces/bucket/domain/entity/element_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/core/env/Env.dart';
import 'package:multi_spaces/core/repository/initializable_storage_repository.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/contracts/Element.g.dart';
import '../../../core/contracts/Bucket.g.dart';

class ElementRepositoryImpl
    with InitializableStorageRepository<ElementModel>
    implements ElementRepository {
  final Bucket _bucket;
  late BlockchainProvider _provider;
  ElementRepositoryImpl(List<BlockchainProvider> providers, Bucket bucket)
      : _bucket = bucket {
    final adapter = ElementModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
    for (var provider in providers) {
      if (provider.isAuthenticated()) {
        _provider = provider;
      }
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
  Future<ElementEntity> getElement(EthereumAddress address) async {
    var model = box.get(address.hex);
    if (model == null) {
      final elem = Element(
        address: address,
        client: Web3Client(Env.eth_url, Client()),
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
    ContentType contentType,
  ) async {
    return _bucket.createElements(
      [newMetaHash],
      [newDataHash],
      [newContainerHash],
      [parent],
      BigInt.from(contentType.index),
      credentials: _provider.getCredentails(),
      transaction: Transaction(
        from: _provider.getAccount(),
        maxGas: 3000000,
      ),
    );
  }
}
