import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class LocalStorageManager {
  final String parentPath;
  const LocalStorageManager._(this.parentPath);

  Future<File> file(String name) {
    return File("$parentPath/$name").create(recursive: true);
  }

  Directory directory(String name) {
    return Directory("$parentPath/$name");
  }

  Future<bool> exists(String name) {
    return File("$parentPath/$name").exists();
  }

  Future<FileSystemEntity> copy(String name, LocalStorageManager destination,
      [bool move = false]) async {
    final path = "$parentPath/$name";
    final type = await FileSystemEntity.type(path);
    if (type == FileSystemEntityType.file) {
      final file = File(path);
      return file.copy("${destination.parentPath}/$name");
    } else if (type == FileSystemEntityType.directory) {
      final dir = Directory(path);
      final fileList = (await dir.list().toList()).whereType<File>();
      for (var file in fileList) {
        await file.copy("${destination.parentPath}/$name");
      }
      return Directory("${destination.parentPath}/$path");
    } else {
      throw ArgumentError("Path must point to whether a file or a directory");
    }
  }

  static LocalStorageManager? _data;
  static LocalStorageManager? _temporary;

  static LocalStorageManager get temporary {
    if (_temporary != null) {
      return _temporary!;
    }
    throw PlatformException(code: 'not-initialized');
  }

  static LocalStorageManager get data {
    if (_data != null) {
      return _data!;
    }
    throw PlatformException(code: 'not-initialized');
  }

  static Future<void> init() async {
    final document = await getApplicationDocumentsDirectory();
    final temporary = await getTemporaryDirectory();
    _data = LocalStorageManager._("${document.path}/data");
    _temporary = LocalStorageManager._(temporary.path);
  }
}
