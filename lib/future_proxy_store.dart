// persistent store that redirect all request to store in future
import 'dart:async';

import './persistent_store_base.dart';

// redirect all methods to store that passed as future
class FutureProxyStore<T> extends PersistentStore<T> {
  late final Future<PersistentStore<T>> store;

  FutureProxyStore(this.store);

  @override
  Future<void> close() async {
    return (await store).close();
  }

  @override
  Future<void> init(
    FutureOr<T> Function() defaultValue,
    String storeName,
  ) async {
    return (await store).init(defaultValue, storeName);
  }

  @override
  Future<T> load() async => (await store).load();

  @override
  Future<T> save(T newValue) async => (await store).save(newValue);
}

extension FutureProxyStoreExtenstion<T> on Future<PersistentStore<T>> {
  FutureProxyStore<T> get futureProxyStore => FutureProxyStore(this);
}
