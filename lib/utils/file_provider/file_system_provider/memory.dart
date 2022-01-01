import 'dart:io';

import 'package:file/memory.dart';
import 'package:path/path.dart' as p;

const _baseLocation = '/mem/';

Future<String> getAbsolutePath(
  String path, {
  bool isSupportDirectory = false,
  bool isAbsolute = false,
}) async {
  final targetDirectory = isAbsolute ? '' : _baseLocation;
  return p.join(targetDirectory, path);
}

Future<Directory> getDirectory(
  String path, {
  bool isSupportDirectory = false,
  bool isAbsolute = false,
}) async =>
    MemoryFileSystem().directory(
      await getAbsolutePath(
        path,
        isSupportDirectory: isSupportDirectory,
        isAbsolute: isAbsolute,
      ),
    );

Future<File> getFile(
  String filePath, {
  bool isSupportFile = false,
  bool recreateFile = false,
  bool isAbsolute = false,
}) async {
  final file = MemoryFileSystem().file(
    await getAbsolutePath(
      filePath,
      isSupportDirectory: isSupportFile,
      isAbsolute: isAbsolute,
    ),
  );
  if (recreateFile && await file.exists()) await file.delete();
  return file;
}
