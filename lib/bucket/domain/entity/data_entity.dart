import 'dart:io';

class DataEntity {
  String hash;
  FileSystemEntity entity;

  bool synced = true;

  DataEntity(this.hash, this.entity);

  bool get isFile => entity is File;

  bool get isDirectory => entity is Directory;

  static DataEntity unsynced(String hash) {
    final entity = DataEntity(hash, File(""));
    entity.synced = false;
    return entity;
  }
}
