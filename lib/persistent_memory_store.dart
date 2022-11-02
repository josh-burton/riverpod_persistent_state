import 'dart:async';

import 'package:flutter/cupertino.dart';
import './persistent_store_base.dart';

// in memory store for testing purpose
@visibleForTesting
class PersistentMemoryStore<T> implements PersistentStore<T> {
  late T value;

  @override
  final FutureOr<T> Function() defaultValue;

  PersistentMemoryStore({
    required this.defaultValue,
  });

  @override
  Future<void> close() async {}

  @override
  Future<void> init() async {
    value = await defaultValue();
  }

  @override
  Future<T> load() async => value;

  @override
  Future<T> save(T newValue) async => value = value;
}
