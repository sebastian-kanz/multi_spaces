import '../entity/operation_entity.dart';

abstract class HistoryRepository {
  Future<List<OperationEntity>> getHistory();
  Future<List<OperationEntity>> getRemoteHistory();
  Future<List<OperationEntity>> getUnsyncedOperations();
  Future<void> addHistory(List<OperationEntity> toAdd);
  Future<void> updateOperation(OperationEntity operation);
}
