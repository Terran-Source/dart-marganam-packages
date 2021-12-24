library marganam.db;

import '../extensions/enum.dart';
import '../utils/file_provider.dart';
import 'enums.dart';

/// asset path for custom sql files
Future<String> _getSqlQueryFromAsset(String fileName) =>
    getAssetText(fileName, assetDirectory: CustomQuery.sqlSourceAssetDirectory);
Future<String?> _getSqlQueryFromRemote(CustomQuery customQuery) =>
    RemoteFileCache.universal.getRemoteText(
      customQuery.source,
      identifier: customQuery.identifier,
      headers: customQuery.headers,
    );

/// Used to get complex queries in file from either:
/// - asset (always set the [CustomQuery.sqlSourceAssetDirectory] before this)
/// - web
///
/// Either a filename(without extension) inside
/// [CustomQuery.sqlSourceAssetDirectory] or an accessible web address of the
/// file
///
/// Example:
/// ```dart
/// var customQueryFromFile = CustomQuery.fromAsset('queryFileName');
/// // or
/// var customQueryFromWeb = CustomQuery.fromWeb('customQueryFromWeb',
///   'https://example.com/some/source/queryFileName.sql');
/// // or if any custom header is required
/// var customQueryFromWeb = CustomQuery.fromWeb('customQueryFromWeb',
///   'https://example.com/some/source/queryFileName.sql',
///   headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
/// ```
class CustomQuery {
  /// Either a filename(without extension) inside [dbConfig.sqlSourceAsset]
  /// or an accessible web address of the file
  ///
  /// Example:
  /// ```dart
  /// var customQueryFromFile = CustomQuery.fromAsset('queryFileName');
  /// // or
  /// var customQueryFromWeb = CustomQuery.fromWeb('customQueryFromWeb',
  ///   'https://example.com/some/source/queryFileName.sql');
  /// // or if any custom header is required
  /// var customQueryFromWeb = CustomQuery.fromWeb('customQueryFromWeb',
  ///   'https://example.com/some/source/queryFileName.sql',
  ///   headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  /// ```
  final String source;
  final String identifier;
  final ResourceFrom from;
  final Map<String, String> headers;

  /// set this **only** once before loading any file from asset
  static String? sqlSourceAssetDirectory;

  String? _query;

  CustomQuery._(
    this.source,
    this.from,
    this.identifier, {
    this.headers = const <String, String>{},
  });

  factory CustomQuery.fromAsset(
    String fileNameWithoutExtension, {
    String? identifier,
  }) {
    ArgumentError.checkNotNull(
      sqlSourceAssetDirectory,
      'CustomQuery.sqlSourceAssetDirectory',
    );

    return CustomQuery._(
      fileNameWithoutExtension,
      ResourceFrom.asset,
      identifier ?? fileNameWithoutExtension,
    );
  }

  factory CustomQuery.fromWeb(
    String identifier,
    String address, {
    Map<String, String> headers = const <String, String>{},
  }) {
    Uri.parse(address);
    return CustomQuery._(
      address,
      ResourceFrom.web,
      identifier,
      headers: headers,
    );
  }

  Future<String?> _load() async {
    switch (from) {
      case ResourceFrom.asset:
        // return compute(_getSqlQueryFromAsset, source);
        return _getSqlQueryFromAsset(source);
      case ResourceFrom.web:
        // return compute(_getSqlQueryFromRemote, this);
        return _getSqlQueryFromRemote(this);
      default:
        throw UnimplementedError(
          'ResourceFrom: '
          '${from.toEnumString(withQuote: true)} '
          'has not been implemented yet',
        );
    }
  }

  /// Asynchronously load the sql file content
  Future<String?> load() async => _query ??= await _load();

  /// the actual sql statements after the [load] is called at least once
  String? get query => _query;

  bool get isLoaded => (_query ?? '').isNotEmpty;
}
