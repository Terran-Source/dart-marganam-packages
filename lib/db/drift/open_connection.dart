import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/web.dart';

LazyDatabase openConnection(
  String dbFile, {
  bool? isSupportFile,
  bool? logStatements,
  bool? recreateDatabase,
  DatabaseSetup? setup,
  CreateWebDatabase? initializer,
}) =>
    throw UnimplementedError('Cannot open a connection to a sqlite database');
