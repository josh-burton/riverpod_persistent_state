import 'dart:async';

import 'package:hive/hive.dart';

import 'persistent_store_base.dart';

class HiveStringStore<T> extends PersistentStore<T> {
  final String Function(T object) encode;
  final T Function(String value) decode;

  late final Box<String> box;
  late FutureOr<T> Function() defaultValue;

  HiveStringStore({required this.encode, required this.decode});

  @override
  Future<void> init(
    FutureOr<T> Function() defaultValue,
    String storeName,
  ) async {
    this.defaultValue = defaultValue;
    box = await Hive.openBox<String>(storeName);
  }

  @override
  Future<T> load() async {
    if (box.isNotEmpty) {
      return decode(box.getAt(0) as String);
    } else {
      final def = await defaultValue();
      await box.add(encode(def));
      return def;
    }
  }

  @override
  Future<T> save(T newValue) async {
    await box.putAt(0, encode(newValue));
    return newValue;
  }

  @override
  Future<void> close() => box.flush();
}