import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'persistent_store_base.dart';

export 'hive_json_store.dart';
export 'hive_store.dart';
export 'hive_string_store.dart';

class _SyncState<T> extends StateNotifier<AsyncValue<T>> {
  _SyncState() : super(const AsyncValue.loading());
}

// TODO await riverpod 2.0 then add cache provider to debounce multiple refresh calls
// and keep old data while reload with keep old data on reload flag set
class PersistentStateNotifier<T> extends StateNotifier<AsyncValue<T>> {
  late final StreamSubscription<void> _saveSub;

  late final Future<void> _initFuture;

  final _syncState = _SyncState<T>();

  PersistentStore<T> store;
  bool isLoading = false;

  T? _savedValue;

  @override
  Future<void> dispose() async {
    _syncState.dispose();
    _saveSub.cancel();

    await _save(state).then((_) => store.close());

    return super.dispose();
  }

  // future that complete when sync is proceed
  Future<AsyncValue<T>> get nextSync =>
      _syncState.stream.firstWhere((e) => e != const AsyncValue.loading());

  AsyncValue<T> set(T newValue) {
    return state = AsyncData(newValue);
  }

  // immediate return updated value, sync proceed in background with debounce
  // use `nextSync` getter if you want wait complete sync
  AsyncValue<T> update(T Function(T value) update) {
    return state = state.whenData(update);
  }

  Future<void> _save(AsyncValue<T> newState) async {
    if (mounted == false) return;

    _syncState.state = const AsyncValue.loading();
    await newState.maybeWhen(
      data: (value) async {
        final value = newState.value as T;
        if (_savedValue == value) return;
        _savedValue = await store.save(value);
      },
      orElse: () async {},
    );
    _syncState.state = newState;
  }

  Future<void> _load(_) async {
    if (mounted == false) return;
    if (isLoading == true) return;

    isLoading = true;

    state = const AsyncValue.loading();

    try {
      state = AsyncValue.data(await store.load());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace: stackTrace);
    }
    isLoading = false;
  }

  PersistentStateNotifier(
    FutureOr<T> Function() defaultValue, {
    required this.store,
    required String name,
    Duration saveDebounce = const Duration(milliseconds: 1000),
  }) : super(const AsyncValue.loading()) {
    _initFuture = store.init();
    _initFuture.then(_load);

    _saveSub = stream
        .delayWhen((event) => _initFuture.asStream())
        .whereType<AsyncData<T>>()
        .debounceTime(saveDebounce)
        .listen(_save);
  }
}

typedef CreateStoreFunction<T> = PersistentStore<T> Function(
  StateNotifierProviderRef ref,
);

typedef CreateDefaultValueFunction<T> = FutureOr<T> Function() Function(
  StateNotifierProviderRef ref,
);

// Provider to safe value in peristent store: disk, network, etc.
// This class in first place for infer StateNotifierProvider types
// ignore: subtype_of_sealed_class
class PersistentStateProvider<T>
    extends StateNotifierProvider<PersistentStateNotifier<T>, AsyncValue<T>> {
  PersistentStateProvider(
    /// initializer for default value if store does't contain value
    /// also allow recreate provider on other provider change through ref.watch
    CreateDefaultValueFunction<T> defaultValue, {
    required PersistentStore<T> store,
    required String name,
  }) : super(
          (ref) => PersistentStateNotifier(
            defaultValue(ref),
            store: store,
            name: name,
          ),
        );

  // allow to create store from riverpod ref
  PersistentStateProvider.createStore(
    /// initializer for default value if store does't contain value
    /// also allow recreate provider on other provider change through ref.watch
    CreateDefaultValueFunction<T> defaultValue, {
    required CreateStoreFunction<T> createStore,
    required String name,
  }) : super(
          (ref) => PersistentStateNotifier(
            defaultValue(ref),
            store: createStore(ref),
            name: name,
          ),
        );
}
