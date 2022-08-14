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
  store: HiveJsonStore(
    defaultValue: () => const AuthorizationValue.unauthorized()
    fromJson: (json) => AuthorizationValue.fromJson(json),
    toJson: (value) => value.toJson(),
    boxName: 'token',
  ),
);
```