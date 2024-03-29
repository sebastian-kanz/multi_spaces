import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/history_repository.dart';
import 'package:multi_spaces/core/error/failures.dart';

import '../../../core/usecases/usecase.dart';

class SyncHistoryUseCase implements UseCase<List<OperationEntity>, void> {
  final HistoryRepository historyRepository;

  SyncHistoryUseCase(this.historyRepository);

  @override
  Future<Either<Failure, List<OperationEntity>>> call([void params]) async {
    try {
      final localHistory = await historyRepository.getHistory();
      final remoteHistory = await historyRepository.getRemoteHistory();
      final diff = remoteHistory.length - localHistory.length;
      var localUnsynced = await historyRepository.getUnsyncedOperations();
      if (diff == 0 && localUnsynced.isEmpty) {
        return const Right([]);
      }
      final unsynced = remoteHistory.sublist(
        localHistory.length,
        remoteHistory.length,
      );
      await historyRepository.addHistory(unsynced);

      localUnsynced = await historyRepository.getUnsyncedOperations();

      return Right(localUnsynced);
    } catch (e) {
      return Left(UseCaseFailure('Syncing history failed: $e'));
    }
  }
}
