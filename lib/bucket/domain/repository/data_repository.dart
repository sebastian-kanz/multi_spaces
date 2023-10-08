import 'package:flutter/foundation.dart';
import 'package:multi_spaces/bucket/domain/entity/data_entity.dart';

abstract class DataRepository {
  Future<DataEntity> getData(
    String dataHash,
    String name,
    List<String> parents, {
    int? creationBlockNumber,
    bool sync = false,
  });
  Future<DataEntity> createData(
    Uint8List data,
    String name,
    List<String> parents, {
    int? creationBlockNumber,
  });
  Future<void> removeData(
    String name,
    List<String> parents,
  );
}
