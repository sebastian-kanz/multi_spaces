import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/history_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/core/constants.dart';
import 'package:multi_spaces/core/error/failures.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/usecases/usecase.dart';

class SyncElementsUseCaseParams {
  final bool syncData;
  final bool deleteData;
  SyncElementsUseCaseParams(this.syncData, this.deleteData);
}

class SyncElementsUseCase implements UseCase<int, SyncElementsUseCaseParams> {
  final HistoryRepository historyRepository;
  final MetaRepository metaRepository;
  final DataRepository dataRepository;
  final ContainerRepository containerRepository;
  final ElementRepository elementRepository;

  SyncElementsUseCase(
    this.historyRepository,
    this.metaRepository,
    this.dataRepository,
    this.containerRepository,
    this.elementRepository,
  );

  Future<List<String>> _getNamesRecursive(EthereumAddress parentAdr) async {
    if (parentAdr.hex == zeroAddress.hex) {
      return [];
    }
    final parent = await elementRepository.getElementEntity(
      parentAdr,
    );
    final parentMeta = await metaRepository.getMeta(
      parent.metaHash,
      creationBlockNumber: parent.created,
    );
    if (parent.parentElement.hex == zeroAddress.hex) {
      return [parentMeta.name];
    }
    return [
      parentMeta.name,
      ...await _getNamesRecursive(parent.parentElement),
    ];
  }

  @override
  Future<Either<Failure, int>> call(
    SyncElementsUseCaseParams params,
  ) async {
    try {
      final unsynced = await historyRepository.getUnsyncedOperations();
      for (OperationEntity operation in unsynced) {
        final element = await elementRepository.getElementEntity(
          operation.element,
        );
        final parents = await _getNamesRecursive(element.parentElement);
        try {
          switch (operation.operationType) {
            case OperationType.add:
              await containerRepository.getContainer(element.containerHash,
                  sync: true);
              final meta = await metaRepository.getMeta(
                element.metaHash,
                creationBlockNumber: element.created,
                sync: true,
              );
              if (params.syncData) {
                await dataRepository.getData(
                  element.dataHash,
                  meta.name,
                  parents,
                  creationBlockNumber: element.created,
                  sync: true,
                );
              }
              break;
            case OperationType.update:
              final nextElement = await elementRepository.getElementEntity(
                element.nextElement,
              );
              await containerRepository.getContainer(
                nextElement.containerHash,
                sync: true,
              );
              final meta = await metaRepository.getMeta(
                nextElement.metaHash,
                creationBlockNumber: nextElement.created,
                sync: true,
              );
              if (params.syncData) {
                await dataRepository.getData(
                  nextElement.dataHash,
                  meta.name,
                  parents,
                  creationBlockNumber: nextElement.created,
                  sync: true,
                );
              }
              break;
            case OperationType.updateParent:
              final parent = await elementRepository.getElementEntity(
                element.parentElement,
              );
              await containerRepository.getContainer(parent.containerHash,
                  sync: true);
              final meta = await metaRepository.getMeta(
                parent.metaHash,
                creationBlockNumber: parent.created,
                sync: true,
              );
              if (params.syncData) {
                await dataRepository.getData(
                  parent.dataHash,
                  meta.name,
                  parents,
                  creationBlockNumber: parent.created,
                  sync: true,
                );
              }
              break;
            case OperationType.delete:
              if (params.deleteData) {
                final meta = await metaRepository.getMeta(
                  element.metaHash,
                  creationBlockNumber: element.created,
                  sync: true,
                );
                await dataRepository.removeData(
                  meta.name,
                  parents,
                );
              }
              break;
          }
          operation.synced = true;
          await historyRepository.updateOperation(operation);
        } catch (e) {
          print(e);
        }
      }
      return Right(unsynced.length);
    } catch (e) {
      return Left(UseCaseFailure('Syncing elemens failed: $e'));
    }
  }
}
