import 'dart:math' as math;

import 'package:http/http.dart';
import 'package:http/retry.dart';

import 'rest_client.dart';

class HttpRestClient implements RestClient {
  final _httpClient = Client();

  @override
  RestClientType get clientType => RestClientType.http;

  // :Old Method:
  // var request = http.Request('GET', Uri.parse(source));
  // request.headers.addAll(headers);
  // final response = await _client.send(request);
  // :New Method:
  @override
  Future<Response> getFromUri({
    required Uri uri,
    Map<String, String>? headers,
  }) =>
      _httpClient.get(uri, headers: headers);

  @override
  Future<Response> getFromSource({
    required String source,
    Map<String, String>? headers,
  }) =>
      getFromUri(uri: Uri.parse(source), headers: headers);

  @override
  RetryClient withRetry({
    int retries = 3,
    bool Function(BaseResponse) when = RestClient.defaultRetryWhen,
    bool Function(Object, StackTrace) whenError =
        RestClient.defaultRetryWhenError,
    Duration Function(int retryCount) delay = RestClient.defaultRetryDelay,
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

  @override
  void close() => _httpClient.close();
}
