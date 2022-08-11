import 'dart:convert';

import 'hive_string_store.dart';

class HiveJsonStore<T> extends HiveStringStore<T> {
  HiveJsonStore({
    required String boxName,
    required dynamic Function(T v) toJson,
    required T Function(dynamic v) fromJson,
  }) : super(
          boxName: boxName,
          encode: (v) => jsonEncode(toJson(v)),
          decode: (v) => fromJson(jsonDecode(v)),
        );
}
