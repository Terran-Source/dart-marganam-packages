library marganam.utils.rest_client;

import 'package:http/http.dart' as http;

enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

class RestClient {
  final _client = http.Client();

  // :Old Method:
  // var request = http.Request('GET', Uri.parse(source));
  // request.headers.addAll(headers);
  // final response = await _client.send(request);
  // :New Method:
  Future<http.Response> getFromUri({
    required Uri uri,
    Map<String, String>? headers,
  }) =>
      _client.get(uri, headers: headers);

  Future<http.Response> getFromSource({
    required String source,
    Map<String, String>? headers,
  }) =>
      getFromUri(uri: Uri.parse(source), headers: headers);

  void close() => _client.close();
}
