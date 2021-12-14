library marganam.extensions.moor;

import 'package:drift/drift.dart';

import '../enum.dart';

@Deprecated('use `EnumTextConverter` instead')
class EnumTypeConverter<T extends Enum> extends TypeConverter<T, String> {
  final List<T> _values;
  final T? _default;

  @Deprecated('use `EnumTextConverter` instead')
  const EnumTypeConverter(this._values, [this._default]);

  @override
  T? mapToDart(String? fromDb) =>
      (fromDb == null) ? _default : _values.find(fromDb);

  @override
  String? mapToSql(T? value) =>
      value?.toEnumString() ?? _default?.toEnumString();
}

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

      final _typeList = <T>[];
      if (_typeList is List<bool?> && json is int) {
        return (json == 1) as T;
      }
      if (_typeList is List<Enum> && enumTypes.containsKey(T)) {
        return (enumTypes[T]! as List<Enum>).find(json.toString()) as T;
      }

      return json as T;
    }
  }

  @override
  dynamic toJson<T>(T value) {
    try {
      return _defaultSerializer.toJson(value);
    } catch (_) {
      if (value is DateTime) {
        return value.millisecondsSinceEpoch;
      }
      if (value is Enum) {
        return value.toEnumString();
      }

      return value;
    }
  }
}
