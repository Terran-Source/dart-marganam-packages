import 'package:json_annotation/json_annotation.dart';

typedef FromJsonString<T> = T Function(String json);
typedef ToJsonString<T> = String Function(T item);

class ListStringConverter<T> implements JsonConverter<List<T>, String> {
  final String separator;

  /// A [Function] to use when decoding each element of the list as JSON string.
  ///
  /// Must be a top-level or static [Function] with one parameter compatible
  /// with the field being deserialized that returns a JSON-compatible value.
  final FromJsonString<T>? fromJsonString;

  /// A [Function] to use when encoding each element of the list to JSON string.
  ///
  /// Must be a top-level or static [Function] with one parameter compatible
  /// with the field being serialized as a String.
  ///
  /// [fromJsonString] should also be provided.
  final ToJsonString<T>? toJsonString;

  const ListStringConverter({
    this.separator = '',
    this.fromJsonString,
    this.toJsonString,
  }) : assert(
          (null != toJsonString && null != fromJsonString) ||
              null == toJsonString,
          '[fromJsonString] should be provided if [toJsonString] is provided',
        );

  @override
  List<T> fromJson(String json) {
    final items = json.split(separator);
    return items
        .map((i) => null != fromJsonString ? fromJsonString!(i) : i as T)
        .toList();
  }

  @override
  String toJson(List<T> object) => object
      .map((e) => null != toJsonString ? toJsonString!(e) : e.toString())
      .join(separator);
}

const ListStringConverter<String> defaultListStringConverter =
    ListStringConverter<String>();
