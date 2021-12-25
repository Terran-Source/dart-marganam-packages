import 'package:dart_marganam/extensions/enum.dart';
import 'package:test/test.dart';

void main() {
  group('EnumTypeConverter test for Enum.values():', () {
    // TODO:
    test('toStrings', () {
      // act
      final result = _Dummy.values.toStrings();

      // assert
      expect(result, isA<Iterable<String>>());
      expect(result.length, _Dummy.values.length);
      expect(result, [..._Dummy.values.map((e) => e.name)]);
    });
    test('toStrings(withQuote: true)', () {
      // act
      final result = _Dummy.values.toStrings(withQuote: true);

      // assert
      expect(result, isA<Iterable<String>>());
      expect(result.length, _Dummy.values.length);
      expect(result, [..._Dummy.values.map((e) => "'${e.name}'")]);
    });
  });

  _Dummy.values.forEach(testEnumExt);
  _Days.values.forEach(testEnumExt);
}

void testEnumExt(Enum testEnum) {
  group('EnumExt test:', () {
    test('toEnumString', () {
      // act
      final result = testEnum.toEnumString();

      // assert
      expect(result, isA<String>());
      expect(result, testEnum.name);
    });
    test('toEnumString(withQuote: true)', () {
      // act
      final result = testEnum.toEnumString(withQuote: true);

      // assert
      expect(result, isA<String>());
      expect(result, "'${testEnum.name}'");
    });
  });
}

enum _Dummy { One, Two, Three }
enum _Days { Sun, Mon, Tues, Wed, Thu, Fri, Sat }
