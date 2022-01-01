import 'dart:io';

Future<String> getAbsolutePath(
  String path, {
  bool isSupportDirectory = false,
  bool isAbsolute = false,
}) =>
    throw UnimplementedError('Cannot get the Absolute path location');

Future<Directory> getDirectory(
  String path, {
  bool isSupportDirectory = false,
  bool isAbsolute = false,
}) =>
    throw UnimplementedError('Cannot get the Directory location');

Future<File> getFile(
  String filePath, {
  bool isSupportFile = false,
  bool recreateFile = false,
  bool isAbsolute = false,
}) =>
    throw UnimplementedError('Cannot get the File location');
