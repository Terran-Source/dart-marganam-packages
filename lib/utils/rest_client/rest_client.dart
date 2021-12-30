import 'dart:math' as math;

import 'package:http/http.dart';

enum HttpMethod { GET, POST, PUT, DELETE, PATCH }
enum RestClientType {
  /// use vanilla [package:http] implementation
  basic,

  /// use advanced [package:dio] implementation
  advanced,
}

abstract class RestClient {
  final RestClientType clientType;

  RestClient({this.clientType = RestClientType.basic});

  Future<Response> getFromUri({
    required Uri uri,
    Map<String, String>? headers,
  });

  Future<Response> getFromSource({
    required String source,
    Map<String, String>? headers,
  }) =>
      getFromUri(uri: Uri.parse(source), headers: headers);

  BaseClient withRetry({
    int retries = 3,
    bool Function(BaseResponse) when = _defaultWhen,
    bool Function(Object, StackTrace) whenError = _defaultWhenError,
    Duration Function(int retryCount) delay = _defaultDelay,
    void Function(BaseRequest, BaseResponse?, int retryCount)? onRetry,
  });

  void close();
}

bool _defaultWhen(BaseResponse response) => response.statusCode == 503;

bool _defaultWhenError(Object error, StackTrace stackTrace) => false;

Duration _defaultDelay(int retryCount) =>
    const Duration(milliseconds: 500) * math.pow(1.5, retryCount);
