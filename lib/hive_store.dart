import 'dart:async';

import 'package:hive/hive.dart';

import 'persistent_store_base.dart';

/// Create box for each blopName, and store single value at 0 index with hive serialization
class HiveStore<T> extends PersistentStore<T> {
  late final Box<T> box;
  late FutureOr<T> Function() defaultValue;

  final String storeName;

  HiveStore(this.storeName);

  @override
  Future<void> init() async {
    box = await Hive.openBox<T>(storeName);
  }

  @override
  Future<T> load() async {
    if (box.isNotEmpty) {
      return box.getAt(0) as T;
    } else {
      final def = await defaultValue();
      await box.add(def);
      return def;
    }
  }

  @override
  Future<T> save(T newValue) async {
    await box.putAt(0, newValue);
    return newValue;
  }

  @override
  Future<void> close() => box.flush();
}
