library marganam.extensions;

import 'dart:math';

extension Enums<T extends Enum> on Iterable<T> {
  T? find(String val, {bool caseSensitive = false}) {
    try {
      return caseSensitive
          ? byName(val)
          : firstWhere((ab) => ab.name.toLowerCase() == val.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Iterable<String> toStrings({bool withQuote = false}) =>
      map((item) => item.toEnumString(withQuote: withQuote));

  T get random => elementAt(Random().nextInt(length));

  String randomString({bool withQuote = false}) =>
      random.toEnumString(withQuote: withQuote);

  String getConstraints(String columnName) =>
      'CHECK ($columnName IN (${toStrings(withQuote: true).join(',')}))';
}

extension EnumExt on Enum {
  String toEnumString({bool withQuote = false}) => withQuote ? "'$name'" : name;
}
