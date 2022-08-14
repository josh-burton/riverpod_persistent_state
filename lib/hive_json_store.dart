import 'dart:async';
import 'dart:convert';

import 'hive_string_store.dart';

String Function(T v) _encode<T>(dynamic Function(T v)? toJson) {
  if (toJson == null) {
    return (dynamic v) {
      try {
        return jsonEncode(v.toJson());
      } on NoSuchMethodError catch (_) {
        throw Exception(
          "HiveJsonStore toJson parameter missed"
          "it can be omited only for classes that implements `toJson` method"
          "but ${v.runtimeType.toString()} does't implement it",
        );
      }
    };
  }
  return (v) => jsonEncode(toJson(v));
}

class HiveJsonStore<T> extends HiveStringStore<T> {
  HiveJsonStore({
    required FutureOr<T> Function() defaultValue,
    required String boxName,
    required T Function(dynamic v) fromJson,
    // parameter can be omit for class that implements toJson method
    dynamic Function(T v)? toJson,
  }) : super(
          defaultValue: defaultValue,
          boxName: boxName,
          encode: _encode(toJson),
          decode: (v) => fromJson(jsonDecode(v)),
        );
}
