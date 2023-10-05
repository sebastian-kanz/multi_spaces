import 'dart:io';

class DataEntity {
  String hash;
  File file;

  bool synced = true;

  DataEntity(this.hash, this.file);

  static DataEntity unsynced(String hash) {
    final entity = DataEntity(hash, File(""));
    entity.synced = false;
    return entity;
  }
}
