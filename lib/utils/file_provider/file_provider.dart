import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'file_system_provider.dart';

Future<String?> getFileText(
  String filePath, {
  Encoding encoding = utf8,
  bool isSupportFile = false,
  bool isAbsolute = false,
}) async {
  final file = await getFile(
    filePath,
    isSupportFile: isSupportFile,
    isAbsolute: isAbsolute,
  );
  if (await file.exists()) return file.readAsString(encoding: encoding);
  return null;
}

Future<Uint8List?> getFileContent(
  String filePath, {
  bool isSupportFile = false,
  bool isAbsolute = false,
}) async {
  final file = await getFile(
    filePath,
    isSupportFile: isSupportFile,
    isAbsolute: isAbsolute,
  );
  if (await file.exists()) return file.readAsBytes();
  return null;
}

Future<File> saveTextFile(
  String filePath,
  String text, {
  FileMode mode = FileMode.writeOnly,
  Encoding encoding = utf8,
  bool isSupportFile = false,
  bool isAbsolute = false,
  bool flush = true,
}) async {
  final file = await getFile(
    filePath,
    isSupportFile: isSupportFile,
    isAbsolute: isAbsolute,
  );
  return file.writeAsString(text, mode: mode, encoding: encoding, flush: flush);
}

Future<File> appendTextToFile(
  String filePath,
  String text, {
  Encoding encoding = utf8,
  bool isSupportFile = false,
  bool isAbsolute = false,
  bool flush = true,
}) =>
    saveTextFile(
      filePath,
      text,
      mode: FileMode.writeOnlyAppend,
      encoding: encoding,
      isSupportFile: isSupportFile,
      isAbsolute: isAbsolute,
      flush: flush,
    );

Future<File> saveFileAsBytes(
  String filePath,
  Uint8List fileContent, {
  FileMode mode = FileMode.writeOnly,
  bool isSupportFile = false,
  bool isAbsolute = false,
  bool flush = true,
}) async {
  final file = await getFile(
    filePath,
    isSupportFile: isSupportFile,
    isAbsolute: isAbsolute,
  );
  return file.writeAsBytes(fileContent, mode: mode, flush: flush);
}

Future<File> appendBytesToFile(
  String filePath,
  Uint8List fileContent, {
  bool isSupportFile = false,
  bool isAbsolute = false,
  bool flush = true,
}) =>
    saveFileAsBytes(
      filePath,
      fileContent,
      mode: FileMode.writeOnlyAppend,
      isSupportFile: isSupportFile,
      isAbsolute: isAbsolute,
      flush: flush,
    );

Future<IOSink> saveFileAsByteStream(
  String filePath,
  Stream<List<int>> fileContent, {
  FileMode mode = FileMode.writeOnly,
  Encoding encoding = utf8,
  bool isSupportFile = false,
  bool isAbsolute = false,
  bool flush = true,
  Function? onError,
}) async {
  final file = await getFile(
    filePath,
    isSupportFile: isSupportFile,
    isAbsolute: isAbsolute,
  );
  final sink = file.openWrite(mode: mode, encoding: encoding);
  return sink.addStream(fileContent).then(
    (_) async {
      if (flush) {
        await sink.flush();
        await sink.close();
      }
      return sink;
    },
    onError: onError,
  );
}

Future<IOSink> appendByteStreamToFile(
  String filePath,
  Stream<List<int>> fileContent, {
  Encoding encoding = utf8,
  bool isSupportFile = false,
  bool isAbsolute = false,
  bool flush = true,
  Function? onError,
}) =>
    saveFileAsByteStream(
      filePath,
      fileContent,
      mode: FileMode.writeOnlyAppend,
      encoding: encoding,
      isSupportFile: isSupportFile,
      isAbsolute: isAbsolute,
      flush: flush,
      onError: onError,
    );

Future<File> deleteFile(
  String filePath, {
  bool isSupportFile = false,
  bool isAbsolute = false,
}) async {
  final file = await getFile(
    filePath,
    isSupportFile: isSupportFile,
    isAbsolute: isAbsolute,
  );
  if (await file.exists()) await file.delete();
  return file;
}

Future<String> getAssetText(
  String fileName, {
  String? assetDirectory,
  String? extension,
}) =>
    rootBundle.loadString(
      p.join(assetDirectory ?? '', '$fileName${extension ?? ''}'),
    );

Future<Uint8List> getAssetBytes(
  String fileName, {
  String? assetDirectory,
  String? extension,
}) async =>
    (await rootBundle
            .load(p.join(assetDirectory ?? '', '$fileName${extension ?? ''}')))
        .buffer
        .asUint8List();
