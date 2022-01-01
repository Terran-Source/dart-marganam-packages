import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> getAbsolutePath(
  String path, {
  bool isSupportDirectory = false,
  bool isAbsolute = false,
}) async {
  final targetDirectory = isAbsolute
      ? ''
      : (isSupportDirectory
              ? await getApplicationSupportDirectory()
              : await getApplicationDocumentsDirectory())
          .path;
  return p.join(targetDirectory, path);
}

Future<Directory> getDirectory(
  String path, {
  bool isSupportDirectory = false,
  bool isAbsolute = false,
}) async =>
    Directory(
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
  final file = File(
    await getAbsolutePath(
      filePath,
      isSupportDirectory: isSupportFile,
      isAbsolute: isAbsolute,
    ),
  );
  if (recreateFile && await file.exists()) await file.delete();
  return file;
}
