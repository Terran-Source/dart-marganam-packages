import 'package:dart_marganam/extensions/enum.dart';
import 'package:test/test.dart';

void main() {
  group('Enums for Enum.values() test', () {
    // TODO:
    test('description', () {
      // act
      final result = _Dummy.values.toStrings();
    });
  }, skip: true);
  group('EnumExt test', () {
    // TODO:
  }, skip: true);
}

enum _Dummy { One, Two, Three }
enum _Days { Sun, Mon, Tues, Wed, Thu, Fri, Sat }
