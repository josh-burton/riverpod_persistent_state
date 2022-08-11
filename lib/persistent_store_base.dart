import 'dart:async';

/// store abstraction used on PersistentBlop
abstract class PersistentStore<T> {
  /// init call lazy only once before call load or save
  /// by default do nothing
  Future<void> init();

  Future<T> load();

  Future<T> save(T newValue);

  Future<void> close();
}

// base class for stores that can be reset.
// Reset delete all data from persistent source: disk, db, remote server
// then load new value that implicit create default value
//
// usable in situation where we have corrupted data,
// or data format changed and we prefer reset over migration
abstract class ResetableStore {
  Future<void> reset();
}
