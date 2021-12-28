import '../db/enums.dart';
import '../utils/file_provider.dart';
import '../utils/ready_or_not.dart';
import 'custom_query.dart';

class QuerySet with ReadyOrNotMixin {
  final Map<String, CustomQuery> queries;

  /// Migration queries as `Map<int fromSchemaVersion, CustomQuery>` which
  /// contains mapping of migration scripts for each version upgrade starting
  /// from `1`
  ///
  /// Example:
  /// ```
  /// var migrations= {
  ///   1: CustomQuery.fromWeb(
  ///       'sprightly.drift_database.dataMigrationScriptFrom_v1_to_v2',
  ///       'https://example.com/some/source/dataMigrationFrom1.sql',
  ///   ),
  ///   2: CustomQuery.fromWeb(
  ///       'sprightly.drift_database.dataMigrationScriptFrom_v2_to_v3',
  ///       'https://example.com/some/source/dataMigrationFrom2.sql',
  ///   ),
  /// }
  /// ```
  final Map<int, CustomQuery> migrations;
  final String? sqlSourceAssetDirectory;

  QuerySet({
    required this.queries,
    this.migrations = const {},
    this.sqlSourceAssetDirectory,
  }) {
    getReadyWorker = _getReady;
  }

  CustomQuery? getCustomQuery(String identifier) {
    try {
      return queries.entries
          .firstWhere(
            (query) =>
                query.key == identifier || query.value.identifier == identifier,
          )
          .value;
    } catch (_) {
      return null;
    }
  }

  CustomQuery? getCustomQueryType(CustomQueryType queryType) =>
      getCustomQuery(queryType.name);

  bool hasCustomQuery(String identifier) => queries.entries.any(
        (query) =>
            query.key == identifier || query.value.identifier == identifier,
      );

  bool hasCustomQueryType(CustomQueryType queryType) =>
      hasCustomQuery(queryType.name);

  bool get _anyAssetQuery =>
      queries.values.any((query) => query.from == ResourceFrom.asset) ||
      migrations.values.any((query) => query.from == ResourceFrom.asset);

  bool get _anyWebQuery =>
      queries.values.any((query) => query.from == ResourceFrom.web) ||
      migrations.values.any((query) => query.from == ResourceFrom.web);

  Future _getReady() async {
    // Required to set `CustomQuery.sqlSourceAssetDirectory` for fetching custom
    // query files from asset
    if (_anyAssetQuery) {
      CustomQuery.sqlSourceAssetDirectory = sqlSourceAssetDirectory;
    }

    // Required for fetching file from web
    if (_anyWebQuery) {
      await RemoteFileCache.universal.getReady();
    }

    for (final query in queries.entries) {
      await query.value.load();
    }

    for (final query in migrations.entries) {
      await query.value.load();
    }
  }
}
