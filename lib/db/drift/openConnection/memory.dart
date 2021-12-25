import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Suitable for creating an in-memory (non-persistent) sqlite db for all
/// supported platforms
LazyDatabase openConnection(
  String dbFile, {
  bool? isSupportFile,
  bool? logStatements,
  bool? recreateDatabase,
  DatabaseSetup? setup,
}) =>
    LazyDatabase(
      () async => NativeDatabase.memory(
        logStatements: logStatements ?? false,
        setup: setup,
      ),
    );
