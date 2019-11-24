# CHANGELOG

## Pending

---

## 4.0.0

> **NOTE:** Version 4 is a very breaking change.

- Now supports from iOS 10+ and watchOS 3+, availability checks in code removed where possible.
- Moved completion handler from `Blob` init to `Communicator.transfer(Blob)`.
- Moved the error handler from `ImmediateMessage` to `Communicator.send(ImmediateMessage)`
- Added completion handlers when sending `GuaranteedMessage`s and `ComplicationInfo`s.
- Added new `InteractiveImmediateMessage` which has a reply handler, removing the optional reply handler from `ImmediateMessage` all together.
- Replies in interactive messages now expect an `ImmediateMessage` rather than just a JSON file.
- Support for sending messages with just an identifier and empty content, with default values for their inits.
- Support for cancelling `GuaranteedMessage`s, `ComplicationInfo`s and `Blobs`s.
- Renamed `JSONDictionary` to `Content`.
- Removed `sessionIsNotActive` error, reachability is used instead now.
- Removed `throws` from most functions, now errors are reported more consistently in the completion handler where possible.
- Added support for automatically ending `WKWatchConnectivityRefreshBackgroundTask`s.
- `Reachability` is now reported at more opportunities, like when the user switches watches.
- `Reachability` cases are now more descriptive.
- Fixed `Communicator` from trying to re-activate the session immediately after it activated, which caused `WatchConnectivity` to log an error.
- To observe changes, you now call `observe` on the type you want to observe, i.e. `GuaranteedMessage.observe { message in }`
- Removed dependency on `TABObserverSet`.
- `WatchState` is now an enum rather than a struct.
- When observing changes you can now choose which `DispatchQueue` the handler is called on, which defaults to a special `communicator` queue off the main thread.
- Added `PhoneState` that can be observed and queried from the watch
- Reachability now properly takes into account if the companion app is installed.



## 3.3.0

- Migrated to Swift 5 and fixed warnings.

## 3.2.0

- Migrated to Swift 4.2.

## 3.1.0

- Added Reachability support.

## 3.0.0

- Added clearer messaging types for guaranteed and immediate messages.

## 2.0.0

- Migrated to Swift 4.

## 1.1.0

- Added ComplicationInfo.

## 1.0.0

- Initial release.
