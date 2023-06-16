import 'package:flutter/foundation.dart';
import 'package:multi_spaces/bucket/domain/entity/data_entity.dart';

abstract class DataRepository {
  Future<DataEntity> getData(String dataHash,
      {int? creationBlockNumber, bool sync = false});
  Future<DataEntity> createData(Uint8List data, {int? creationBlockNumber});
  Future<void> removeData(String dataHash, String containerHash);
}
