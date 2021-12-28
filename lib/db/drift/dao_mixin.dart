import 'dart:async';

import 'package:drift/drift.dart';

import '../../extensions/drift/extended_value_serializer.dart';
import '../../extensions/enum.dart';
import '../../utils/happy_hash.dart';
import '../enums.dart';
import '../query_set.dart';

mixin DaoMixin<T extends GeneratedDatabase> on DatabaseAccessor<T> {
  late QuerySet queries;
  bool _ready = false;
  int hashMinLength = 16;
  int uniqueRetry = 15;

  bool get daoMixinReady => queries.ready && _ready;

  Future<void> _ensureMixinReadiness() async {
    if (!daoMixinReady) await getDaoMixinReady();
  }

  Future<void> getDaoMixinReady() async {
    if (!_ready) {
      driftRuntimeOptions.defaultSerializer =
          ExtendedValueSerializer(enumTypes);
      await queries.getReady();
      _ready = true;
    }
  }

  Future<void> runCustomQuery(String identifier) async {
    await _ensureMixinReadiness();
    final query = await queries.getCustomQuery(identifier)?.load() ?? '';
    if (query.isNotEmpty) {
      // print('$identifier: $query'); //debug
      await customStatement(query);
    }
  }

  Future<void> runCustomQueryType(CustomQueryType queryType) =>
      runCustomQuery(queryType.name);

  Future<void> onCreate(Migrator m) async {
    await m.createAll();
    await runCustomQueryType(CustomQueryType.dataInitiation);
  }

  Future<void> onUpgrade(Migrator m, int from, int to) async {
    for (var i = from; i < to; i++) {
      await super.customStatement(await queries.migrations[i]!.load() ?? '');
    }
  }

  Future<void> beforeOpen(OpeningDetails details, Migrator m) async {
    await runCustomQueryType(CustomQueryType.defaultStartup);
    await runCustomQueryType(CustomQueryType.openingPragma);
  }

  Future<String> uniqueId(
    String tableName,
    List<String> items, {
    HashLibrary? hashLibrary,
    String? key,
    int? hashMinLength,
    int? uniqueRetry,
  }) async {
    var result = '';
    var foundUnique = false;
    var attempts = 0;
    final _hashLibrary = hashLibrary ?? HashLibrary.values.random;
    var _hashLength = hashMinLength ?? this.hashMinLength;
    final _uniqueRetry = uniqueRetry ?? this.uniqueRetry;
    do {
      result = hashedAll(
        items,
        hashLength: _hashLength,
        library: _hashLibrary,
        key: key,
        prefixLibrary: false,
      );
      foundUnique = !await recordWithIdExists(tableName, result);
      if (foundUnique) return result;
      attempts++;
      // If a unique Id is not found in every 3 attempts, increase the
      // hashLength
      if (attempts % 3 == 0) _hashLength++;
    } while (attempts < _uniqueRetry && !foundUnique);
    throw TimeoutException(
      'Can not found a suitable unique Id for '
      '$tableName after $attempts attempts',
    );
  }

  Future<bool> recordWithIdExists(String tableName, String id) =>
      recordWithColumnValueExists(tableName, 'id', id);

  Future<bool> recordWithColumnValueExists(
    String tableName,
    String column,
    String value,
  ) async =>
      await customSelect(
        'SELECT COUNT(1) AS counting FROM $tableName t WHERE t.$column=:value',
        variables: [Variable.withString(value)],
      ).map((row) => row.read<int>('counting')).getSingle() >
      0;

  Selectable<QueryRow> getRecordsWithColumnValue(
    String tableName,
    String column,
    String value, {
    TableInfo? table,
  }) =>
      customSelect(
        'SELECT t.* FROM $tableName t WHERE t.$column=:value',
        variables: [Variable.withString(value)],
        readsFrom: null == table ? {} : {table},
      );

  /// **_caution_**: use this function only if the query returns only 1 record
  /// or none
  Future<Map<String, dynamic>> getRecordWithColumnValue(
    String tableName,
    String column,
    String value, {
    TableInfo? table,
  }) async =>
      (await getRecordsWithColumnValue(tableName, column, value, table: table)
              .getSingle())
          .data;

  Future<Map<String, dynamic>> getRecord(
    String tableName,
    String id, {
    TableInfo? table,
  }) async =>
      (await getRecordsWithColumnValue(tableName, 'id', id, table: table)
              .getSingle())
          .data;

  Future<bool> updateRecord<Tbl extends Table, R extends DataClass>(
    TableInfo<Tbl, R> table,
    Insertable<R> record,
  ) =>
      update(table).replace(record);

  Future<int> deleteRecord<Tbl extends Table, R extends DataClass>(
    TableInfo<Tbl, R> table,
    Insertable<R> record,
  ) =>
      delete(table).delete(record);
}
