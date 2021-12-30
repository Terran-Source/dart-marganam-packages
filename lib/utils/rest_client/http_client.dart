import 'dart:math' as math;

import 'package:http/http.dart';
import 'package:http/retry.dart';

class HttpClient {
  final _httpClient = Client();

  // :Old Method:
  // var request = http.Request('GET', Uri.parse(source));
  // request.headers.addAll(headers);
  // final response = await _client.send(request);
  // :New Method:
  Future<Response> getFromUri({
    required Uri uri,
    Map<String, String>? headers,
  }) =>
      _httpClient.get(uri, headers: headers);

  Future<Response> getFromSource({
    required String source,
    Map<String, String>? headers,
  }) =>
      getFromUri(uri: Uri.parse(source), headers: headers);

  /// Creates a RetryClient from `package:http/retry.dart` that retries HTTP
  /// requests. doc from [RetryClient]
  ///
  /// This retries a failing request [retries] times (3 by default). Note that
  /// `n` retries means that the request will be sent at most `n + 1` times.
  ///
  /// By default, this retries requests whose responses have status code 503
  /// Temporary Failure. If [when] is passed, it retries any request for whose
  /// response [when] returns `true`. If [whenError] is passed, it also retries
  /// any request that throws an error for which [whenError] returns `true`.
  ///
  /// By default, this waits 500ms between the original request and the first
  /// retry, then increases the delay by 1.5x for each subsequent retry. If
  /// [delay] is passed, it's used to determine the time to wait before the
  /// given (zero-based) retry.
  ///
  /// If [onRetry] is passed, it's called immediately before each retry so that
  /// the client has a chance to perform side effects like logging. The
  /// `response` parameter will be null if the request was retried due to an
  /// error for which [whenError] returned `true`.
  RetryClient withRetry({
    int retries = 3,
    bool Function(BaseResponse) when = _defaultWhen,
    bool Function(Object, StackTrace) whenError = _defaultWhenError,
    Duration Function(int retryCount) delay = _defaultDelay,
    void Function(BaseRequest, BaseResponse?, int retryCount)? onRetry,
  }) =>
      RetryClient(
        _httpClient,
        retries: retries,
        when: when,
        whenError: whenError,
        delay: delay,
        onRetry: onRetry,
      );

  void close() => _httpClient.close();
}

bool _defaultWhen(BaseResponse response) => response.statusCode == 503;

bool _defaultWhenError(Object error, StackTrace stackTrace) => false;

Duration _defaultDelay(int retryCount) =>
    const Duration(milliseconds: 500) * math.pow(1.5, retryCount);
