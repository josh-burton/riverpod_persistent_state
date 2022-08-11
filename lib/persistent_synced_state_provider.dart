import 'dart:async';

import 'package:riverpod/riverpod.dart';

import 'persistent_state_provider.dart';
import 'persistent_store_base.dart';

class _LateInitializationHolder<T> {
  PersistentStateNotifier<T>? notifier;

  final PersistentStateNotifier<T> Function() create;

  _LateInitializationHolder(this.create);

  Future<void> init() async {
    notifier = create();
    final hasError = await notifier!.stream
        .firstWhere((e) => e is! AsyncLoading<T>)
        .then((v) => v is AsyncError);

    if (hasError) {
      notifier!.set(await notifier!.store.defaultValue());
    }
  }
}

PersistentStateNotifier<T> _ensureInitialized<T>(
  PersistentStateNotifier<T>? value,
) {
  if (value == null) {
    throw 'PersistentSyncedProvider is not properly initialized call and await provider.awaitInitialization before runApp or use provider';
  }
  return value;
}

T _ensureLoaded<T>(
  AsyncValue<T> value,
) {
  if (value.whenOrNull(data: (_) => false) ?? true) {
    throw 'PersistentSyncedProvider notifer is not properly initialized, provider.awaitInitialization was called but not awaited';
  }
  return value.value as T;
}

class _PersistentSyncedStateNotifier<T> extends StateNotifier<T> {
  final PersistentStateNotifier<T> notifier;

  _PersistentSyncedStateNotifier(this.notifier)
      : super(_ensureLoaded(notifier.state));

  T update(T Function(T v) updater) {
    return state = notifier.update(updater).value as T;
  }

  Future<void> reset() => notifier.reset();
}

// persistent provider that store data in store and allow acces and modify it
// main difference from `PersistentStateProvider` it's state loaded before runApp
// and provide access to plain T value, in most contexts work as simple StateProvider
// that save value beetween application restarts
//
// use only for critical data that MUST be loaded before run app like Theme, Locale and maybe Authorization
// otherwise prefer to use PersistentStateStore cause this provider add delay before app launch
//
// for use create provider and `provider.awaitInitialized` before runApp and after
// native libs initialized
//
// behavior detail: if store load or init throw error provider initialized with default value for prevent application stuck on startup
// ignore: subtype_of_sealed_class
class PersistentSyncedStateProvider<T>
    extends StateNotifierProvider<_PersistentSyncedStateNotifier<T>, T> {
  final _LateInitializationHolder<T> _holder;

  PersistentSyncedStateProvider._(this._holder)
      : super(
          (_) => _PersistentSyncedStateNotifier<T>(
            _ensureInitialized(_holder.notifier),
          ),
        );

  factory PersistentSyncedStateProvider({
    required PersistentStore<T> store,
    required String name,
  }) =>
      PersistentSyncedStateProvider._(
        _LateInitializationHolder(() => PersistentStateNotifier(store: store)),
      );

  Future<void> awaitInitialized() async => _holder.init();
}
