## [2.1.0] - 2024-10-23

deps:
- bump riverpod to 2.6.1
- bump rxdart to 0.28.0
- bump hive to 2.2.3

## [2.0.0] - 2022-11-03

deps:
- bump riverpod to 2.0.0

## [1.1.0] - 2022-08-14

feat(refactor interface):
- remove storeName, defaultValue from `init` signature and add it to store
- resetable store and `reset` method for notifier
- HiveJsonStore optional `toJson`
- PersistentStore provide `defaultValue` getter

## [1.0.0] - 2022-08-04

feat(initial):
- extract code from internal projects
