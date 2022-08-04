import 'dart:convert';

import 'hive_string_store.dart';

class HiveJsonStore<T> extends HiveStringStore<T> {
  HiveJsonStore({
    required dynamic Function(T v) toJson,
    required T Function(dynamic v) fromJson,
  }) : super(
          encode: (v) => jsonEncode(toJson(v)),
          decode: (v) => fromJson(jsonDecode(v)),
        );
}
