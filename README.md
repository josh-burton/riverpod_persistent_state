Persistent riverpod store based on hive

## Features

Store state in persistent memory and restore it after application restarts

## Getting started

### install 
Execute script in project directory, or add dependency in `pubspec.yaml`

```sh
flutter pub add riverpod_persistent_state
```

## Usage

Define provider with unique name and use it as state provider after
```dart
final tokenProvider = PersistentStateProvider<AuthorizationValue>(
  // default value function that was called when data is not presented in store
  // that can be depend on other riverpod providers
  (ref) => () => const AuthorizationValue.unauthorized(),
  store: HiveJsonStore(
    fromJson: (json) => AuthorizationValue.fromJson(json),
    toJson: (value) => value.toJson(),
  ),
  name: 'token',
);
```