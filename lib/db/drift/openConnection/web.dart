import 'package:drift/drift.dart';
import 'package:drift/web.dart';

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
  CreateWebDatabase? initializer,
}) =>
    LazyDatabase(
      () async => WebDatabase.withStorage(
        await DriftWebStorage.indexedDbIfSupported(dbFile),
        logStatements: logStatements ?? false,
        initializer: initializer,
      ),
    );
