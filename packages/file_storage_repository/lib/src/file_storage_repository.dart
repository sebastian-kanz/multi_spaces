import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Repository for storing and retrieving files locally
/// This does not work with Web
class FileStorageRepository {
  final String _tenant;
  final String _bucket;
  FileStorageRepository(this._tenant, this._bucket);

  Future<String> _getRootDir() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/multi_spaces');
    await directory.create(recursive: true);
    return directory.path;
  }

  Future<String> _getDirectory() async {
    final rootDir = await _getRootDir();
    final directory = Directory('$rootDir/$_tenant/$_bucket');
    await directory.create(recursive: true);
    return directory.path;
  }

  Future<File> store(
    Uint8List data,
    String name,
  ) async {
    final absoluteDir = await _getDirectory();
    final file = File('$absoluteDir/$name');
    await file.writeAsBytes(data);
    return file;
  }

  Future<File> get(
    String name,
  ) async {
    final absoluteDir = await _getDirectory();
    return File('$absoluteDir/$name');
  }

  Future<Uint8List> getData(
    String name,
  ) async {
    final absoluteDir = await _getDirectory();
    final file = File('$absoluteDir/$name');
    return file.readAsBytes();
  }

  Future<List<FileSystemEntity>> readAll(
    String name,
  ) async {
    final absoluteDir = await _getDirectory();
    final directory = Directory(absoluteDir);
    return directory.listSync();
  }

  Future<bool> exists(
    String name,
  ) async {
    final absoluteDir = await _getDirectory();
    final file = File('$absoluteDir/$name');
    return file.exists();
  }
}
