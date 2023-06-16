import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/container_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/data_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/element_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/history_repository.dart';
import 'package:multi_spaces/bucket/domain/repository/meta_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';

class SyncOperationsUseCaseParams {
  final bool syncData;
  final bool deleteData;
  SyncOperationsUseCaseParams(this.syncData, this.deleteData);
}

class SyncElementsUseCase implements UseCase<int, SyncOperationsUseCaseParams> {
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

  @override
  Future<Either<Failure, int>> call(
    SyncOperationsUseCaseParams params,
  ) async {
    try {
      final unsynced = await historyRepository.getUnsyncedOperations();
      for (OperationEntity operation in unsynced) {
        final element = await elementRepository.getElement(
          operation.element,
        );
        switch (operation.operationType) {
          case OperationType.add:
            await containerRepository.getContainer(element.containerHash,
                sync: true);
            await metaRepository.getMeta(
              element.metaHash,
              creationBlockNumber: element.created,
              sync: true,
            );
            if (params.syncData) {
              await dataRepository.getData(
                element.dataHash,
                creationBlockNumber: element.created,
                sync: true,
              );
            }
            break;
          case OperationType.update:
            final nextElement = await elementRepository.getElement(
              element.nextElement,
            );
            await containerRepository.getContainer(
              nextElement.containerHash,
              sync: true,
            );
            await metaRepository.getMeta(
              nextElement.metaHash,
              creationBlockNumber: nextElement.created,
              sync: true,
            );
            if (params.syncData) {
              await dataRepository.getData(
                nextElement.dataHash,
                creationBlockNumber: nextElement.created,
                sync: true,
              );
            }
            break;
          case OperationType.updateParent:
            final parent = await elementRepository.getElement(
              element.parentElement,
            );
            await containerRepository.getContainer(parent.containerHash,
                sync: true);
            await metaRepository.getMeta(
              parent.metaHash,
              creationBlockNumber: parent.created,
              sync: true,
            );
            if (params.syncData) {
              await dataRepository.getData(
                parent.dataHash,
                creationBlockNumber: parent.created,
                sync: true,
              );
            }
            break;
          case OperationType.delete:
            if (params.deleteData) {
              await dataRepository.removeData(
                element.dataHash,
                element.containerHash,
              );
            }
            break;
        }
        operation.synced = true;
        await historyRepository.updateOperation(operation);
      }
      return Right(unsynced.length);
    } catch (e) {
      return Left(UseCaseFailure('Syncing elemens failed: $e'));
    }
  }
}
