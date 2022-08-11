import 'dart:async';

import 'hive_store.dart';
import 'persistent_store_base.dart';

class HiveStringStore<T> extends PersistentStore<T> implements ResetableStore {
  final String Function(T object) encode;
  final T Function(String value) decode;

  final HiveStore<String> store;

  final String boxName;

  HiveStringStore({
    required this.encode,
    required this.decode,
    required this.boxName,
    required Future<T> Function() defaultValue,
  }) : store = HiveStore(
          boxName: boxName,
          defaultValue: () => defaultValue().then(encode),
        );

  @override
  Future<void> init() async => store.init();

  @override
  Future<T> load() async {
    return decode(await store.load());
  }

  @override
  Future<T> save(T newValue) async {
    await store.save(encode(newValue));
    return newValue;
  }

  @override
  Future<void> close() => store.close();

  @override
  Future<void> reset() => store.reset();
}
