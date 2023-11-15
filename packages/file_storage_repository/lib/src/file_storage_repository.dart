import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Repository for storing and retrieving files locally
/// This does not work with Web
class FileStorageRepository {
  final String _tenant;
  final String _bucketName;
  FileStorageRepository(this._tenant, this._bucketName);

  Future<String> _getRootDir() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/multi_spaces');
    await directory.create(recursive: true);
    return directory.path;
  }

  Future<String> _getDirectory(
    List<String> parents,
  ) async {
    final rootDir = await _getRootDir();
    Directory directory = Directory(
      '$rootDir/$_tenant/$_bucketName',
    );
    await directory.create(recursive: true);
    if (parents.isNotEmpty) {
      final parentsDir = parents.join("/");
      directory = Directory('$rootDir/$_tenant/$_bucketName/$parentsDir');
    }
    return directory.path;
  }

  Future<Directory> createDirectory(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    Directory directory = Directory('$absoluteDir/$name');
    return directory.create(recursive: true);
  }

  Future<Directory> getDirectoryy(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    return Directory('$absoluteDir/$name');
  }

  Future<File> store(
    Uint8List data,
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    final dir = Directory(absoluteDir);
    final dirExists = await dir.exists();
    if (!dirExists) {
      await dir.create(recursive: true);
    }
    final file = File('$absoluteDir/$name');
    await file.writeAsBytes(data);
    return file;
  }

  Future<File> get(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    return File('$absoluteDir/$name');
  }

  Future<Uint8List> getData(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    final file = File('$absoluteDir/$name');
    return file.readAsBytes();
  }

  Future<List<FileSystemEntity>> readAll(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    final directory = Directory(absoluteDir);
    return directory.listSync();
  }

  Future<bool> exists(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    final dir = Directory('$absoluteDir/$name');
    final dirExists = await dir.exists();
    final file = File('$absoluteDir/$name');
    final fileExists = await file.exists();
    return dirExists || fileExists;
  }

  Future<void> remove(
    String name,
    List<String> parents,
  ) async {
    final absoluteDir = await _getDirectory(parents);
    final isFile = await FileSystemEntity.isFile('$absoluteDir/$name');
    if (isFile) {
      final file = File('$absoluteDir/$name');
      await file.delete();
    } else {
      final dir = Directory('$absoluteDir/$name');
      await dir.delete();
    }
  }
}
