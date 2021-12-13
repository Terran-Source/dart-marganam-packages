import 'package:dart_marganam/extensions/http_response.dart';
import 'package:test/test.dart';

void main() {
  group(
    'HttpHeaderParser test',
    () {
      // TODO:
      test('description', () {
        // arrange
        const headerValue =
            'type:attachment;filename="hello.txt";filename*="hello-world.txt";utf-8'; // Content-Disposition

        // act
        final result = headerValue.parseHeaderValue();
      });
    },
    skip: true,
  );

  group(
    'HttpResponseExtension test',
    () {
      // TODO:
    },
    skip: true,
  );
}
