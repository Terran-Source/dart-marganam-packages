library marganam.extensions;

import 'dart:math';

extension Enums<T> on List<T> {
  static String toEnumString<T>(T value, {bool withQuote = false}) {
    final val = value.toString().split(".").last;
    return withQuote ? "'$val'" : val;
  }

  T? find(String val) {
    try {
      return firstWhere((ab) => ab.toString() == '${ab.runtimeType}.$val');
    } catch (_) {
      return null;
    }
  }

  Iterable<String> toStrings({bool withQuote = false}) =>
      map((item) => toEnumString(item, withQuote: withQuote));

  T get random => this[Random().nextInt(length)];

  String randomString({bool withQuote = false}) =>
      toEnumString(random, withQuote: withQuote);

  String getConstraints(String columnName) =>
      'CHECK ($columnName IN (${toStrings(withQuote: true).join(',')}))';
}

extension EnumExt<T> on T {
  String toEnumString({bool withQuote = false}) =>
      Enums.toEnumString(this, withQuote: withQuote);
}
