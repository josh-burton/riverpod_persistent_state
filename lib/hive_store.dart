import 'dart:async';

import 'package:hive/hive.dart';

import 'persistent_store_base.dart';

/// Create box for each blopName, and store single value at 0 index with hive serialization
class HiveStore<T> extends PersistentStore<T> implements ResetableStore {
  late final Box<T> box;
  FutureOr<T> Function() defaultValue;

  final String boxName;

  HiveStore({
    required this.boxName,
    required this.defaultValue,
  });

  @override
  Future<void> init() async {
    box = await Hive.openBox<T>(boxName);
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
  Future<void> close() => box.flush().then((_) => box.close());

  @override
  Future<void> reset() async {
    await box.clear();
  }
}
