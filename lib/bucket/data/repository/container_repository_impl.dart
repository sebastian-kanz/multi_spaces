import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ipfs_repository/ipfs_repository.dart';
import 'package:multi_spaces/bucket/data/mapper/container_mapper.dart';
import 'package:multi_spaces/bucket/data/models/container_model.dart';
import 'package:multi_spaces/bucket/domain/entity/container_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:multi_spaces/core/repository/initializable_storage_repository.dart';
import 'package:uuid/uuid.dart';

class ContainerRepositoryImpl
    with InitializableStorageRepository<ContainerModel>
    implements ContainerRepository {
  final IpfsRepository ipfsRepository;
  ContainerRepositoryImpl(this.ipfsRepository) {
    final adapter = ContainerModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  @override
  Future<ContainerEntity> getContainer(String hash, {bool sync = false}) async {
    var model = box.get(hash);
    if (model == null) {
      if (!sync) {
        return ContainerEntity.unsynced(hash);
      }
      final ipfsObject = await ipfsRepository.get(hash);
      model = ContainerModel(hash, String.fromCharCodes(ipfsObject.data));
      await box.put(hash, model);
      return ContainerMapper.fromModel(model);
    }
    return ContainerMapper.fromModel(model);
  }

  @override
  Future<void> removeContainer(String hash) {
    // TODO: implement removeContainer
    throw UnimplementedError();
  }

  @override
  Future<ContainerEntity> createContainer() async {
    final uuid = const Uuid().v4();
    final rawContainerData = Uint8List.fromList(uuid.codeUnits);
    final ipfsResult = await ipfsRepository.store(rawContainerData);
    final model = ContainerModel(ipfsResult.hash, uuid);
    await box.put(ipfsResult.hash, model);
    return ContainerMapper.fromModel(model);
  }
}
