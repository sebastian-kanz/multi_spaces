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
    String dataHash,
    String name,
    List<String> parents, {
    int? creationBlockNumber,
    bool sync = false,
  }) async {
    if (dataHash.isEmpty) {
      final exists = await _fileStorageRepository.exists(name, parents);
      Directory dir;
      if (!exists) {
        dir = await _fileStorageRepository.createDirectory(name, parents);
      } else {
        dir = await _fileStorageRepository.getDirectoryy(name, parents);
      }
      return DataEntity(dataHash, dir);
    }

    final exists = await _fileStorageRepository.exists(name, parents);
    File file;
    if (!exists) {
      if (!sync) {
        return DataEntity.unsynced(dataHash);
      }
      final ipfsObject = await _ipfsVaultRepository.get(
        dataHash,
        creationBlockNumber: creationBlockNumber,
      );
      file = await _fileStorageRepository.store(ipfsObject, name, parents);
    } else {
      file = await _fileStorageRepository.get(name, parents);
    }
    return DataEntity(dataHash, file);
  }

  @override
  Future<DataEntity> createData(
    Uint8List data,
    String name,
    List<String> parents, {
    int? creationBlockNumber,
  }) async {
    String dataHash = "";
    if (data.isNotEmpty) {
      final exists = await _fileStorageRepository.exists(name, parents);
      if (exists) {
        throw RepositoryFailure("File $name already exists!");
      }
      dataHash = await _ipfsVaultRepository.store(
        data,
        creationBlockNumber: creationBlockNumber,
      );
      final file = await _fileStorageRepository.store(data, name, parents);
      return DataEntity(dataHash, file);
    }
    final exists = await _fileStorageRepository.exists(name, parents);
    if (exists) {
      throw RepositoryFailure("Directory $name already exists!");
    }
    final dir = await _fileStorageRepository.createDirectory(name, parents);
    return DataEntity(dataHash, dir);
  }

  @override
  Future<void> removeData(
    String name,
    List<String> parents,
  ) async {
    // TODO:
    final exists = await _fileStorageRepository.exists(name, parents);
    if (exists) {}
    throw UnimplementedError();
  }
}
