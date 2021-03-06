library marganam.utils.file_cache;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_marganam/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../disposable.dart';
import '../formatted_exception.dart';
import '../initiated.dart';
import '../ready_or_not.dart';
import '../rest_client.dart';
import 'file_provider.dart';
import 'file_system_provider.dart';

String get _moduleName => 'file_provider.file_cache';

FormattedException<T> _moduleFormattedException<T extends Exception>(
  T exception, {
  Map<String, dynamic> messageParams = const <String, dynamic>{},
  StackTrace? stackTrace,
}) =>
    FormattedException(
      exception,
      stackTrace: stackTrace,
      messageParams: messageParams,
      moduleName: _moduleName,
    );

@protected
class DirectoryCleanUp {
  final DirectoryInfo directoryInfo;
  final Map<String, CacheFile> cache;

  DirectoryCleanUp(this.directoryInfo, this.cache);
}

class DirectoryInfo {
  final Directory current;
  //Stream<FileSystemEntity> contents;
  List<DirectoryInfo> directories = <DirectoryInfo>[];
  List<File> files = <File>[];

  static Future<DirectoryInfo> readDirectory(Directory directory) async {
    final directoryInfo = DirectoryInfo(directory);
    final contents = directory.list();
    await for (final content in contents) {
      if (content is File) {
        directoryInfo.files.add(content);
      } else if (content is Directory) {
        directoryInfo.directories.add(await compute(readDirectory, content));
      }
    }
    return directoryInfo;
  }

  static Future<void> cleanUp(DirectoryCleanUp target) async {
    final remainingFiles = <File>[];
    for (final file in target.directoryInfo.files) {
      if (target.cache.values.any(
        (cacheFile) =>
            file.path == cacheFile.path && null != cacheFile.downloadOn,
      )) {
        remainingFiles.add(file);
      } else {
        await file.delete();
      }
    }
    //if (remainingFiles.length > 0)
    target.directoryInfo.files = remainingFiles;

    final remainingDirs = <DirectoryInfo>[];
    for (final dir in target.directoryInfo.directories) {
      if (dir.isEmpty) {
        await dir.current.delete();
      } else {
        await cleanUp(DirectoryCleanUp(dir, target.cache));
        if (dir.isEmpty) {
          await dir.current.delete();
        } else {
          remainingDirs.add(dir);
        }
      }
    }
    //if (remainingDirs.length > 0)
    target.directoryInfo.directories = remainingDirs;
  }

  DirectoryInfo(this.current);

  String get name => current.name;
  bool get isEmpty => files.isEmpty && directories.isEmpty;
}

class CacheFile {
  final String identifier;
  final String source;
  Map<String, String> headers;
  final String path;
  final ContentType? contentType;
  DateTime? downloadOn;
  DateTime? lastAccessedOn;

  CacheFile(
    this.identifier,
    this.source,
    this.path, {
    this.contentType,
    this.downloadOn,
    this.lastAccessedOn,
    this.headers = const <String, String>{},
  });
}

class RemoteFileCache
    with ReadyOrNotMixin
    implements Initiated, Disposable<bool> {
  factory RemoteFileCache() => universal;

  static RemoteFileCache universal = RemoteFileCache._();

  RemoteFileCache._() {
    getReadyWorker = _getReady;
    additionalSingleJobs[_cleanUpJob] = _cleanUp;
    additionalSingleJobs[_dumpJob] = _dump;
  }

  @override
  FutureOr initiate() => getReady();

  static int maxCachedRetentionMins = 7 * 24 * 60; // 7 days

  final _cacheDirectory = '__fileCache';
  final _cacheFile = '__fileCache.json';
  final _client = RestClient();
  final _fileCache = <String, CacheFile>{};

  late DirectoryInfo _directoryInfo;
  DirectoryInfo get directoryInfo => _directoryInfo;
  String get _cleanUpJob => 'cleanUp';
  String get _dumpJob => 'dump';

  // @override
  // bool get ready => _ready && super.ready;
  // bool _ready = false;

  Future _getReady() async {
    final cacheDirectory = await getDirectory(_cacheDirectory);
    if (await cacheDirectory.exists()) {
      final oldFileCache =
          await getFileText(p.join(_cacheDirectory, _cacheFile));
      if (null != oldFileCache) {
        _fileCache
          ..clear()
          ..addAll(json.decode(oldFileCache) as Map<String, CacheFile>);
      }
    } else {
      await cacheDirectory.create(recursive: true);
    }

    // // non-essential for startup. let it be on its own.
    // // i.e. not await(ing)
    // await compute(DirectoryInfo.readDirectory, cacheDirectory).then((info) {
    //   _directoryInfo = info;
    //   _ready = true;
    // });
    _directoryInfo = await DirectoryInfo.readDirectory(cacheDirectory);
  }

  String _getIdentifier(String source, [String? identifier]) =>
      identifier ?? source.escapeMessy();

  /// Fetch the file from the [source] url and store in a the local
  /// [_cacheDirectory]. Then returns the [CacheFile] containing absolute path
  /// of the locally saved file.
  ///
  /// an optional [identifier] can be specified to speed up the cache searching
  /// process. If [identifier] is not specified, [source].[escapeMessy()] will
  /// be taken as the cache key.
  Future<CacheFile?> _getRemoteFileAndCache(
    String source, {
    String? identifier,
    Map<String, String> headers = const <String, String>{},
  }) async {
    try {
      final localIdentifier = _getIdentifier(source, identifier);
      final response =
          await _client.getFromSource(source: source, headers: headers);
      if (response.isSuccessStatusCode) {
        final fileName =
            response.fileName ?? '$localIdentifier${response.fileExtension}';
        // :Old Method:
        // var file = await saveFileAsByteStream(
        //     p.join(_cacheDirectory, fileName), response.stream,
        //     encoding: response.encoding);
        // :New Method:
        final file = await saveFileAsBytes(
          p.join(_cacheDirectory, fileName),
          response.bodyBytes,
        );
        return CacheFile(
          localIdentifier,
          source,
          file.path,
          contentType: response.contentType,
          downloadOn: DateTime.now().toUtc(),
          headers: headers,
        );
      }
    } on SocketException catch (e, st) {
      throw _moduleFormattedException(e, stackTrace: st);
    } on HttpException catch (e, st) {
      throw _moduleFormattedException(
        e,
        stackTrace: st,
        messageParams: {'method': 'get', 'host': e.uri?.host},
      );
    } on FormatException catch (e, st) {
      throw _moduleFormattedException(e, stackTrace: st);
    } finally {
      _client.close();
    }
    return null;
  }

  Future<CacheFile?> _ensureFileExists(
    String source, {
    String? identifier,
    Map<String, String> headers = const <String, String>{},
  }) async {
    // final id = identifier ?? source;
    final id = _getIdentifier(source, identifier);
    if (!(_fileCache.containsKey(id) && null != _fileCache[id]!.downloadOn)) {
      final cacheFile = await _getRemoteFileAndCache(
        source,
        identifier: id,
        headers: headers,
      );
      if (null != cacheFile) {
        _fileCache[id] = cacheFile;
      } else {
        return null;
      }
    }
    return _fileCache[id];
  }

  Future<String?> getRemoteText(
    String source, {
    String? identifier,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final cacheFile = await _ensureFileExists(
      source,
      identifier: identifier,
      headers: headers,
    );
    if (null != cacheFile) {
      cacheFile.lastAccessedOn = DateTime.now().toUtc();
      return getFileText(cacheFile.path, isAbsolute: true);
    }
    return null;
  }

  Future<Uint8List?> getRemoteContent(
    String source, {
    String? identifier,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final cacheFile = await _ensureFileExists(
      source,
      identifier: identifier,
      headers: headers,
    );
    if (null != cacheFile) {
      cacheFile.lastAccessedOn = DateTime.now().toUtc();
      return getFileContent(cacheFile.path, isAbsolute: true);
    }
    return null;
  }

  Future<T?> getRemoteTextAs<T>(
    String source,
    FutureOr<T?> Function(String? content) mapper, {
    String? identifier,
    Map<String, String> headers = const <String, String>{},
  }) async =>
      mapper(
        await getRemoteText(
          source,
          identifier: identifier,
          headers: headers,
        ),
      );

  Future<T?> getRemoteContentAs<T>(
    String source,
    FutureOr<T?> Function(Uint8List? content) mapper, {
    String? identifier,
    Map<String, String> headers = const <String, String>{},
  }) async =>
      mapper(
        await getRemoteContent(
          source,
          identifier: identifier,
          headers: headers,
        ),
      );

  Future<bool> _cleanFileCache() async {
    var result = false;
    try {
      if (_fileCache.isNotEmpty) {
        const tempFileCache = <String, CacheFile>{};
        for (final fc in _fileCache.entries) {
          // Files, which are never been accessed or not accessed
          // for last [maxCachedRetentionMins] minutes
          if (fc.value.lastAccessedOn
                  ?.add(Duration(minutes: maxCachedRetentionMins))
                  .isBefore(DateTime.now().toUtc()) ??
              true) {
            await deleteFile(fc.value.path, isAbsolute: true);
            // fc.value.downloadOn = null;
            // fc.value.lastAccessedOn = null;
          }
          tempFileCache[fc.key] = fc.value;
        }
        _fileCache
          ..clear()
          ..addAll(tempFileCache);
      }
      result = true;
    } finally {
      result = false;
    }
    return result;
  }

  Future<bool> _cleanUp() async => _cleanFileCache().whenComplete(
        () => DirectoryInfo.cleanUp(
          DirectoryCleanUp(_directoryInfo, _fileCache),
        ),
      );

  FutureOr<bool?> cleanUp() => triggerJob<bool>(_cleanUpJob, onReady: true);

  Future<File> _dump() => saveTextFile(
        p.join(_cacheDirectory, _cacheFile),
        json.encode(_fileCache),
      );

  /// Must be called before application ends (or frequently),
  /// or else, any changes after last [dump] will be lost
  FutureOr<File?> dump() => triggerJob<File>(_dumpJob, onReady: true);

  @override
  FutureOr dispose([bool? flag]) async {
    if (ready) {
      await cleanUp();
      await dump();
    }
  }
}
