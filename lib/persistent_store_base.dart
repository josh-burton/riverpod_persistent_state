import 'dart:async';

/// store abstraction used on PersistentBlop
abstract class PersistentStore<T> {
  /// init call lazy only once before call load or save
  /// by default do nothing
  Future<void> init(
    FutureOr<T> Function() defaultValue,
    String storeName,
  );

  Future<T> load();

  Future<T> save(T newValue);

  Future<void> close();
}
