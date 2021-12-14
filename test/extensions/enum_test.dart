import 'package:dart_marganam/extensions/enum.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Enums for Enum.values() test:',
    () {
      // TODO:
      test('toStrings', () {
        // act
        final result = _Dummy.values.toStrings();

        // assert
        expect(result, isA<Iterable<String>>());
        expect(result.length, _Dummy.values.length);
        expect(result, [..._Dummy.values]);
      });
    },
    skip: true,
  );

  group(
    'EnumExt test',
    () {
      // TODO:
    },
    skip: true,
  );
}

enum _Dummy { One, Two, Three }
enum _Days { Sun, Mon, Tues, Wed, Thu, Fri, Sat }
