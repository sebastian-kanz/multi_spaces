import 'package:hive/hive.dart';
import 'package:multi_spaces/bucket/data/mapper/meta_mapper.dart';
import 'package:multi_spaces/bucket/data/models/meta_model.dart';
import 'package:multi_spaces/bucket/domain/entity/meta_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/core/repository/initializable_storage_repository.dart';
import 'package:web3dart/crypto.dart';
import '../../domain/repository/meta_repository.dart';

class MetaRepositoryImpl
    with InitializableStorageRepository<MetaModel>
    implements MetaRepository {
  final IPFSVaultRepository _ipfsVaultRepository;
  MetaRepositoryImpl(IPFSVaultRepository ipfsVaultRepository)
      : _ipfsVaultRepository = ipfsVaultRepository {
    final adapter = MetaModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  @override
  Future<MetaEntity> getMeta(
    String metaHash, {
    int? creationBlockNumber,
    bool sync = false,
  }) async {
    var model = box.get(metaHash);
    if (model == null) {
      if (!sync) {
        return MetaEntity.unsynced(metaHash);
      }
      final ipfsObject = await _ipfsVaultRepository.get(
        metaHash,
        creationBlockNumber: creationBlockNumber,
      );
      model = MetaModel.fromHex(bytesToHex(ipfsObject));
      await box.put(metaHash, model);
      return MetaMapper.fromModel(model);
    }
    return MetaMapper.fromModel(model);
  }

  @override
  Future<MetaEntity> createMeta(CreateMetaDto createMetaDto,
      {int? creationBlockNumber}) async {
    final model = MetaModel(
      "",
      createMetaDto.name,
      createMetaDto.type,
      createMetaDto.format,
      createMetaDto.created,
      createMetaDto.size,
      createMetaDto.quality,
      createMetaDto.metaRef,
      createMetaDto.tags,
      createMetaDto.coordinates,
      createMetaDto.language,
      createMetaDto.compression,
      createMetaDto.deeplink,
    );
    final metaRaw = model.toBytes();
    final metaHash = await _ipfsVaultRepository.store(
      metaRaw,
      creationBlockNumber: creationBlockNumber,
    );
    model.hash = metaHash;
    await box.put(metaHash, model);
    return MetaMapper.fromModel(model);
  }

  @override
  Future<void> removeMeta(String metaHash) {
    return box.delete(metaHash);
  }

  @override
  Future<List<MetaEntity>> getAllLocalMetas() {
    final entities = box.values
        .map(
          (model) => MetaMapper.fromModel(model),
        )
        .toList();
    return Future.value(entities);
  }
}
