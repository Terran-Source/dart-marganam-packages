import 'package:dart_marganam/utils/file_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Suitable for creating and using a local sqlite db file for the following
/// platforms:
///
/// - Android
/// - iOs
LazyDatabase openConnection(
  String dbFile, {
  bool? isSupportFile,
  bool? logStatements,
  bool? recreateDatabase,
  DatabaseSetup? setup,
}) =>
    LazyDatabase(
      () async => NativeDatabase(
        await getFile(
          dbFile,
          isSupportFile: isSupportFile ?? false,
          recreateFile: recreateDatabase ?? false,
        ),
        logStatements: logStatements ?? false,
        setup: setup,
      ),
    );
