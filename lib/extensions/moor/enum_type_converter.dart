library marganam.extensions.moor;

import 'package:moor/moor.dart';

import '../enum.dart';

class EnumTypeConverter<T> extends TypeConverter<T, String> {
  final List<T> _values;
  final T? _default;

  const EnumTypeConverter(this._values, [this._default]);

  @override
  T? mapToDart(String? fromDb) =>
      (fromDb == null) ? _default : _values.find(fromDb);

  @override
  String? mapToSql(T? value) =>
      value?.toEnumString() ?? _default?.toEnumString();
}

class ExtendedValueSerializer extends ValueSerializer {
  final Map<Type, List> enumTypes;
  ValueSerializer get _defaultSerializer => const ValueSerializer.defaults();

  const ExtendedValueSerializer(this.enumTypes);

  @override
  T fromJson<T>(dynamic json) {
    try {
      return _defaultSerializer.fromJson<T>(json);
    } catch (_) {
      if (null == json) return null as T;
      if (T == bool && json is int) return (json == 1) as T;
      if (enumTypes.containsKey(T)) {
        return enumTypes[T]!.find(json.toString()) as T;
      }

      return json as T;
    }
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }
    if (enumTypes.containsKey(T)) return T.toEnumString();

    return value;
  }
}
