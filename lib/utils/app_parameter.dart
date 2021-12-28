library marganam.utils.app_settings;

import 'dart:async';
// import 'dart:convert';

import 'package:flutter/foundation.dart';

// import 'file_provider.dart';

class Parameter<T> {
  Parameter(this.name, this._value);

  static Parameter ofType<Tp>(String name, Tp value) =>
      Parameter<Tp>(name, value);

  final String name;
  T _value;
  T get value => _value;
  set value(T val) {
    if (type == val.runtimeType) {
      _value = val;
      _controller.add(_value);
    }
  }

  @protected
  final StreamController<T> _controller = StreamController(sync: false);

  Type get type => _value.runtimeType;
  Stream<T> get stream => _controller.stream;
}

abstract class BaseTypeConverter<Base, Converted> {
  String parameterName;
  BaseTypeConverter(this.parameterName);
  Base convertFrom(Converted source);
  Converted convertTo(Base source);
}

class AppParameter<T extends Parameter> {
  @protected
  final _parameters = const <String, Parameter>{};
  @protected
  Map<String, Parameter> get parameters => _parameters;

  void setParameterValue<Tp>(String name, Tp value) =>
      _parameters[name] = Parameter.ofType(name, value);

  T setParameter(String name, T param) => _parameters[name] = param;

  T updateParameter(String name, T param) {
    if (_parameters.containsKey(name)) _parameters.remove(name);
    return setParameter(name, param);
  }

  Tp getValue<Tp>(String name) => (_parameters[name]! as Parameter<Tp>).value;
  void setValue<Tp>(String name, Tp value) =>
      _parameters.containsKey(name) ? _parameters[name]!.value = value : false;

  // static Iterable<Parameter<T>> getParamList<T extends Parameter>(
  //   String jsonText, {
  //   typeConverters = const <TypeConverter>[],
  // }) {
  //   if (jsonText.isNotEmpty) {
  //     Map<String, dynamic> jsonValue = json.decode(jsonText);
  //     if (null != typeConverters) {
  //       return jsonValue.entries.map((j) {
  //         var val = j.value;
  //         final converter =
  //             typeConverters.firstWhere((tc) => tc.parameterName == j.key);
  //         if (null != converter) val = converter.convertFrom(val);
  //         return Parameter.ofType(j.key, val);
  //       });
  //     } else {
  //       return jsonValue.entries.map((j) => Parameter.ofType(j.key, j.value));
  //     }
  //   }
  //   throw new FormatException("[jsonText] is either null or empty");
  // }

  // static Future<Iterable<T>?> loadParamsRemote<T extends Parameter>(
  //   String source, {
  //   String? identifier,
  //   headers = const <String, String>{},
  //   typeConverters = const <TypeConverter>[],
  // }) async {
  //   Uri.parse(source);
  //   final jsonText = await RemoteFileCache.universal
  //       .getRemoteText(source, identifier: identifier, headers: headers);
  //   if (null != jsonText && jsonText.isNotEmpty)
  //     return getParamList(jsonText, typeConverters: typeConverters);
  //   return null;
  // }

  // static Future<Iterable<T>> loadParamsLocal<T extends Parameter>(
  //   String source, {
  //   String? assetDirectory,
  //   typeConverters = const <TypeConverter>[],
  // }) async {
  //   final jsonText = await getAssetText(source, assetDirectory: assetDirectory);
  //   return getParamList(jsonText, typeConverters: typeConverters);
  // }
}
