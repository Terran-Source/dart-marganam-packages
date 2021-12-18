library marganam.extensions.drift;

import 'package:drift/drift.dart';

import '../enum.dart';

class EnumTextConverter<T extends Enum> extends TypeConverter<T, String> {
  final List<T> _values;
  final T? _default;

  const EnumTextConverter(this._values, [this._default]);

  @override
  T? mapToDart(String? fromDb) =>
      (null == fromDb ? null : _values.find(fromDb)) ?? _default;

  @override
  String? mapToSql(T? value) => value?.toEnumString();
}
