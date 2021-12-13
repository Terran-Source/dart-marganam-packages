import 'package:dart_marganam/extensions/string.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Trimmer test',
    () {
      // TODO:
    },
    skip: true,
  );

  group('CleanString test', () {
    test('escapeMessy() test', () {
      // arrange
      const testString = '  *^#%*^\$#*^%#%\$@  '
          'https://www.example.com/path/to/file?'
          'param_1=value24%26ffd&param2=heavy+duty'
          ' (&^\$*^%\$&^\$&%\$) ';

      // act
      final result = testString.escapeMessy();

      // asset
      expect(
        result,
        'https_www_example_com_path_to_file_param_1'
        '_value24_26ffd_param2_heavy_duty',
      );
    });
    test('escapeMessy() test with custom escapeWith', () {
      // arrange
      const testString = '  *^#%*^\$#*^%#%\$@  '
          'https://www.example.com/path/to/file?'
          'param_1=value24%26ffd&param2=heavy+duty'
          ' (&^\$*^%\$&^\$&%\$) ';

      // act
      final result = testString.escapeMessy('-');

      // asset
      expect(
        result,
        'https-www-example-com-path-to-file-'
        'param_1-value24-26ffd-param2-heavy-duty',
      );
    });
    test('escapeMessy() test with empty escapeWith', () {
      // arrange
      const testString = '  *^#%*^\$#*^%#%\$@  '
          'https://www.example.com/path/to/file?'
          'param_1=value24%26ffd&param2=heavy+duty'
          ' (&^\$*^%\$&^\$&%\$) ';

      // act
      final result = testString.escapeMessy('');

      // asset
      expect(
        result,
        'httpswwwexamplecompathtofileparam_1value2426ffdparam2heavyduty',
      );
    });
  });
}
