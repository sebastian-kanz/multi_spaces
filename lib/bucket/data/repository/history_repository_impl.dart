import 'package:hive/hive.dart';
import 'package:multi_spaces/bucket/data/mapper/operation_mapper.dart';
import 'package:multi_spaces/bucket/data/models/operation_model.dart';
import 'package:multi_spaces/bucket/domain/entity/operation_entity.dart';
import 'package:multi_spaces/bucket/domain/repository/history_repository.dart';
import 'package:multi_spaces/core/repository/initializable_storage_repository.dart';
import 'package:multi_spaces/core/contracts/Bucket.g.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';

class HistoryRepositoryImpl
    with InitializableStorageRepository<OperationModel>
    implements HistoryRepository {
  final Bucket _bucket;
  HistoryRepositoryImpl(Bucket bucket) : _bucket = bucket {
    final adapter = OperationModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  @override
  Future<List<OperationEntity>> getHistory() async {
    return Future.wait(
      box.values
          .map((model) async => await OperationMapper.fromModel(model))
          .toList(),
    );
  }

  @override
  Future<List<OperationEntity>> getRemoteHistory() async {
    try {
      final result = (await retry(
        () => _bucket.getHistory(),
        retryIf: (e) => e is RPCError,
      ))
          .toList();
      // final result = await _bucket.getHistory() as List<OperationModel>;
      List<OperationModel> history = [];
      result.asMap().forEach(
            (index, model) => history.add(
              OperationModel(
                model[0],
                model[1],
                (model[2] as BigInt).toInt(),
                index,
              ),
            ),
          );
      return Future.wait(
        history.map((e) async => await OperationMapper.fromModel(e)).toList(),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<List<OperationEntity>> getUnsyncedOperations() async {
    try {
      final unsynced = box.values.where((model) => !model.synced).toList();
      return Future.wait(
        unsynced
            .map((model) async => await OperationMapper.fromModel(model))
            .toList(),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<void> updateOperation(OperationEntity operation) async {
    try {
      return box.put(operation.index, OperationMapper.toModel(operation));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<void> addHistory(List<OperationEntity> operations) async {
    try {
      for (final operation in operations) {
        await box.put(operation.index, OperationMapper.toModel(operation));
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
