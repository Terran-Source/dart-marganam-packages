import 'package:dart_marganam/extensions/http_response.dart';
import 'package:test/test.dart';

void main() {
  group('HttpHeaderParser test:', () {
    test('parseHeaderValue', () {
      // arrange
      const headerValue = 'type:attachment;filename="hello.txt";'
          "   spaced-key =  '   some 'spaced' value '      ; "
          'filename*=hello-world.txt;utf-8'; // Content-Disposition

      // act
      final result = headerValue.parseHeaderValue();

      // assert
      expect(result['type:attachment'], true);
      expect(result['filename'], 'hello.txt');
      expect(result['spaced-key'], "some 'spaced' value");
      expect(result['filename*'], 'hello-world.txt');
      expect(result['utf-8'], true);
      expect(result['junk'], null);
    });
  });

  group(
    'HttpResponseExtension test',
    () {
      // TODO:
    },
    skip: true,
  );
}
