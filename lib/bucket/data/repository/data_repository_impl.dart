import 'dart:io';

import 'package:file_storage_repository/file_storage_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_spaces/bucket/domain/entity/data_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/ipfs_vault_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

class DataRepositoryImpl implements DataRepository {
  final IPFSVaultRepository _ipfsVaultRepository;
  final FileStorageRepository _fileStorageRepository;
  DataRepositoryImpl(
    IPFSVaultRepository ipfsVaultRepository,
    FileStorageRepository fileStorageRepository,
  )   : _ipfsVaultRepository = ipfsVaultRepository,
        _fileStorageRepository = fileStorageRepository;

  @override
  Future<DataEntity> getData(
    String dataHash, {
    int? creationBlockNumber,
    bool sync = false,
  }) async {
    if (dataHash.isEmpty) {
      return DataEntity(dataHash, File(""));
    }
    final exists = await _fileStorageRepository.exists(dataHash);
    File file;
    if (!exists) {
      if (!sync) {
        return DataEntity.unsynced(dataHash);
      }
      final ipfsObject = await _ipfsVaultRepository.get(dataHash,
          creationBlockNumber: creationBlockNumber);
      file = await _fileStorageRepository.store(ipfsObject, dataHash);
    } else {
      file = await _fileStorageRepository.get(dataHash);
    }
    return DataEntity(dataHash, file);
  }

  @override
  Future<DataEntity> createData(Uint8List data,
      {int? creationBlockNumber}) async {
    final dataHash = await _ipfsVaultRepository.store(
      data,
      creationBlockNumber: creationBlockNumber,
    );
    final file = await _fileStorageRepository.store(data, dataHash);
    return DataEntity(dataHash, file);
  }

  @override
  Future<void> removeData(String dataHash, String containerHash) {
    // TODO: implement removeData
    throw UnimplementedError();
  }
}
