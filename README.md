# Communicator

[![CI Status](http://img.shields.io/travis/KaneCheshire/Communicator.svg?style=flat)](https://travis-ci.org/KaneCheshire/Communicator)
[![Version](https://img.shields.io/cocoapods/v/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)
[![License](https://img.shields.io/cocoapods/l/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)
[![Platform](https://img.shields.io/cocoapods/p/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)

- [Introduction](#introduction)
- [Quick start](#quick-start)
- [Usage](#usage)
  - [`Communicator`](#communicator-1)
  - [`ImmediateMessage`](#immediatemessage)
  - [`InteractiveImmediateMessage`](#interactiveimmediatemessage)
  - [`GuaranteedMessage`](#guaranteedmessage)
  - [`Blob`](#blob)
  - [`Context`](#context)
  - [`WatchState`](#watchstate)
  - [`PhoneState`](#phonestate)
  - [`ComplicationInfo`](#complicationinfo)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
  - [SPM](#swift-package-manager)
  - [Cocoapods](#cocoapods)
- [Author](#author)
- [License](#license)

## Introduction

Sending messages and data between watchOS and iOS apps is possible thanks to Apple's work on `WatchConnectivity`, however there are a _lot_ of delegate callbacks to work with, some of the API calls are quite similar and it's not really clear which is needed and for what purpose.

`Communicator` tries to clear all this up, handles a lot of stuff for you, and it's extremely easy to use.

`Communicator` supports watch switching out-the-box, uses closures rather than delegate functions,
and allows multiple places in your app to react to messages and events.

## Quick start

Each app gets its own shared `Communicator` object to use which handles all the underlying session stuff:

```swift
Communicator.shared
```

Usage between the two platforms is essentially identical.

Here's how you send a simple message with `Communicator`:

```swift
let message = ImmediateMessage(identifier: "1234", content: ["messageKey" : "This is some message content!"])
Communicator.shared.send(message)
```

This will try to send a message to the counterpart immediately. If the receiving app is not appropriately reachable, the message sending will fail, but you can query this any time:

```swift
switch Communicator.shared.currentReachability {
  case .immediateMessaging: Communicator.shared.send(message)
  default: break
}
```

On the other device you register as an observer for new messages as early on as possible in your app's launch cycle:

```swift
ImmediateMessage.observe { message in
  guard message.identifier == "1234" else { return }
  print("Message received!", message)
}
```

You can observe these messages from anywhere in your app and filter out the ones you don't care about. Anything that can change or be received in `Communicator`, including `Reachability` and `WatchState`, is observable using the same syntax, just calling `observe` on the type you want to observe:

```swift
Reachability.observe { reachability in
  print("Reachability changed!", reachability)
}
```

Additionally, you can unobserve at any time:

```swift
let observation = Reachability.observe { _ in }
/// ...
Reachability.unobserve(observation)
```

`Communicator` can also transfer `GuaranteedMessage`s, data `Blob`s and also sync `Context`s.

`GuaranteedMessage`s are similar to `ImmediateMessage`s and `InteractiveImmediateMessage`s, in that they have an identifier, but they don't support reply handlers and can be sent when the reachability state is at least `.backgroundOnly`, and will continue to transfer even if your app is terminated during transfer.

`Blob`s are perfect for sending larger amounts of data (`WatchConnectivity` will reject large data in any other message type), can be sent when the reachability state is at least `.backgroundOnly`, and will continue to transfer even if your app is terminated during transfer.

You can use a `Context` to keep things in sync between devices, which makes it perfect for preferences. `Context`s are not suitable for messaging or sending large data. Sending or receiving a `Context` overwrites any previously sent `Context`, which you can query any time with `Communicator.shared.mostRecentlySentContext` and `Communicator.shared.mostRecentlyReceivedContext`

Lastly, you can update your watchOS complication from your iOS app by transferring a `ComplicationInfo`. You get a limited number of `ComplicationInfo` transfers a day, and you can easily query the remaining number of transfers available by getting the `currentWatchState` object.

If you have transfers available, your watch app is woken up in the background to process the `ComplicationInfo`.

> **NOTE:** You app must have a complication added to the user's _active_ watch face to be able to
wake your watch up in the background, and the number of transfers available must not be 0.

## Usage

### Communicator

Each app has its own shared `Communicator` object which it should use to communicate with the counterpart app.

```swift
Communicator.shared
```

The APIs between iOS and watchOS are almost identical.

The first time you access the `.shared` instance, `Communicator` will do what it needs to in order to activate the underlying session and report any received messages/data etc.

This means you should access the shared instance as early on as possible in your app's lifecycle, but also observe any changes as soon as possible to avoid losing data:

```swift
Reachability.observe { reachability in
  // Handle reachability change
}
ImmediateMessage.observe { message in
  // Handle immediate message
}
GuaranteedMessage.observe { message in
  // Handle guaranteed message
}
```

> **NOTE:** Observing any type will impliclty access the `.shared` instance, so you only need to observe things for `Communicator` to activate the underlying session.

### Querying the current reachability

Before sending any messages or data you should check the current reachability of the counterpart
app. This can change as the user switches watches, installs your app or backgrounds your app.

Additionally, since watchOS 6, it's possible to install a watch app without installing the iOS app,
which Communicator takes into account.

You can query the current reachability at any time:

```swift
let reachability = Communicator.shared.currentReachability
```

You can also observe and react to reachability changes:

```swift
Reachability.observe { reachability in
  // Handle reachability change
}
```

Different types of communication require a different minimum level of reachability.
I.e. `ImmediateMessage` and `InteractiveImmediateMessage` require `.immediatelyReachable`,
but `GuaranteedMessage`, `Blob`, `Context`, and `ComplicationInfo` require at least `.backgroundOnly`
(although can still be sent when `.immediatelyReachable`).

### Querying the current activation state

You can query the current activation state of Communicator at any time:

```swift
let state = Communicator.shared.currentState
```

You can also observe state changes:

```swift
Communicator.State.observe { state in
 // Handle new state
}
```

The state can change as the user switches watches. Generally, you won't need to use this state and
instead should query the reachability, which takes into account whether the counterpart app is currently installed.

### Querying the current state of the counterpart device

You can query the state of the user's paired watch at any time:

```swift
let watchState = Communicator.shared.currentWatchState
```

You can also observe state changes:

```swift
WatchState.observe { state in
 // Handle new state
}
```

The watch state provides information like whether the watch is paired, your app is installed,
a complication is added to the active watch face, and more.

Additionally, you can query the state of the iPhone from the watchOS app, since iOS 6 users
can install your watch app without installing the iOS app:

```swift
let phoneState = Communicator.shared.currentPhoneState
```

And like all other states you can observe changes:

```swift
PhoneState.observe { state in
  // Handle new state
}
```

### `ImmediateMessage`

An `ImmediateMessage` is a simple object comprising of an identifier string of your choosing, and a JSON dictionary as content.

The keys of the JSON dictionary must be strings, and the values must be plist-types. That means anything you can save to `UserDefaults`; `String`, `Int`, `Data` etc. You _cannot_ send large amounts of data between devices using a `ImmediateMessage` because the system will reject it. Instead, use a `Blob` for sending large amounts of data.

This is how you create a simple `ImmediateMessage`:

```swift
let content: Content = ["TotalDistanceTravelled" : 10000.00]
let message = ImmediateMessage(identifier: "JourneyComplete", content: json)
```

And this is how you send it:

```swift
Communicator.shared.send(message) { error in
  // Handle error
}
```

This works well for rapid, interactive communication between two devices, but is limited to small amounts of data and will fail if either of the devices becomes unreachable during communication.

If you send this from watchOS it will also wake up your iOS app in the background if it needs to so long as the current `Reachability` is `.immediatelyReachable`.

On the receiving device you listen for new messages:

```swift
ImmediateMessage.observe { message in
  if message.identifier == "JourneyComplete" {
    // Handle message
  }
}
```

> **NOTE:** The value of `Communicator.currentReachability` must be `.immediatelyReachable` otherwise an error will occur which you can catch by assigning an error handler when sending the message.

### `InteractiveImmediateMessage`

An `InteractiveImmediateMessage` is similar to a regular `ImmediateMessage` but it additionally takes
a reply handler that you _must_ execute yourself on the receiving device. Once you execute the handler
on the receiving device, it is called by the system on the sending device.

This provides a means for extremely fast communication between devices, but like an `ImmediateMessage`,
the reachability must be `.immediatelyReachable` during both the send and the reply.

On the sending device, send the message:

```swift
let message = InteractiveImmediateMessage(identifier: "message", content: ["hello": "world"])
Communicator.shared.send(message) { error in

}
```

And on the receiving device, listen for the message and execute the reply handler:

```swift
InteractiveImmediateMessage.observe { message in
  guard message.identifier == "message" else { return }
  let replyMessage = ImmediateMessage("identifier", content: ["reply": "message"])
  message.reply(replyMessage)
}
```

Like an `ImmediateMessage`, if you send this from your watch app the system will wake your iOS app
up in the background if needed, so long as the current reachability is `.immediatelyReachable`.

### `GuaranteedMessage`

You can also choose to send a message using the "guaranteed" method. `GuaranteedMessage`s don't have a reply handler because messages can be queued while the receiving device is not currently receiving messages, meaning they're queued until the session is next created:

```swift
let content: Content = ["CaloriesBurnt" : 400.00]
let message = GuaranteedMessage(identifier: "WorkoutComplete", content: content)
Communicator.shared.send(message) { result in
  // Handle success or failure
}
```

Because the messages are queued, they could be received in a stream on the receiving device when it's able to process them. You should make sure your observers are set up as soon as possible to avoid missing any messages, i.e. in your `AppDelegate` or `ExtensionDelegate`:

```swift
GuaranteedMessage.observe { message in
  if message.identifier == "CaloriesBurnt" {
    let content = message.content
    // Handle message
  }
}
```

> **NOTE:** On watchOS, receiving a `GuaranteedMessage` while in the background can cause the system to generate a `WKWatchConnectivityRefreshBackgroundTask`. If you assign this to the `Communicator`'s `task` property, `Communicator` will automatically handle ending the task for you at the right time.

The value of `Communicator.currentReachability` must not be `.notReachable` otherwise an error will occur.

### `Blob`

A `Blob` is very similar to a `GuaranteedMessage` but is better suited to sending larger bits of data. A `Blob` is created with an `identifier` but instead of assigning a JSON dictionary as the content, you assign pure `Data` instead.

This is how you create a `Blob`:

```swift
let largeData: Data = getJourneyHistoryData()
let blob = Blob(identifier: "JourneyHistory", content: largeData)
```

And this is how you transfer it to the other device:

```swift
Communicator.shared.transfer(blob: blob) { result in
  // Handle success or failure
}
```

Because a `Blob` can be much larger than a `Message`, it might take significantly longer to send. The system handles this, and continues to send it even if the sending device becomes unreachable before it has completed.

On the receiving device you listen for new `Blob`s. Because these `Blob`s can often be queued waiting for the session to start again, `Communicator` will often notify observers very early on. This makes it a good idea to start observing for `Blob`s as soon as possible, i.e. in the `AppDelegate` or `ExtensionDelegate`:

```swift
Blob.observe { blob in
  if blob.identifier == "JourneyHistory" {
    let JourneyHistoryData: Data = blob.content
    // ... do something with the data ... //
  }
}
```

> **NOTE:** On watchOS, receiving a `Blob` while in the background can cause the system to generate a `WKWatchConnectivityRefreshBackgroundTask`. If you assign this to the `Communicator`'s `task` property, `Communicator` will automatically handle ending the task for you at the right time.

The value of `Communicator.currentReachability` must not be `.notReachable` otherwise an error will occur.

### `Context`

A `Context` is a very lightweight object. A `Context` can be sent and received by either device, and the system stores the last sent/received `Context` that you can query at any time. This makes it ideal for syncing lightweight things like preferences between devices.

A `Context` has no identifier, and simply takes a JSON dictionary as content. Like an `ImmediateMessage`, this content must be primitive types like `String`, `Int`, `Data` etc, and must not be too large or the system will reject it:

```swift
let content: Content = ["ShowTotalDistance" : true]
let context = Context(content: content)
do {
  try Communicator.shared.sync(context)
} catch {
  // Handle error
}
```

You can also query the last sent context from either device:

```swift
let context = Communicator.shared.mostRecentlySentContext
```

On the receiving device you listen for new `Context`s:

```swift
Content.observe { context in
  if let shouldShowTotalDistance = context.content["ShowTotalDistance"] as? Bool {
    print("Show total distance setting changed: \(shouldShowTotalDistance)")
  }
}
```

You can also query the last received context from either device:

```swift
let context = Communicator.shared.mostRecentlyReceivedContext
```

> **NOTE:** On watchOS, receiving a `Context` while in the background can cause the system to generate a `WKWatchConnectivityRefreshBackgroundTask`. If you assign this to the `Communicator`'s `task` property, `Communicator` will automatically handle ending the task for you at the right time.

The value of `Communicator.currentReachability` must not be `.notReachable` otherwise an error will be thrown.

### `WatchState`

`WatchState` is one of the only iOS-only elements of `Communicator`. It provides some information
about the current state of the user's paired watch or watches, like whether a complication has been enabled
or whether the watch app has been installed.

You can observe any changes in the `WatchState` on iOS:

```swift
WatchState.observe { state in
  // Handle watch state
}
```

You can also query the current `WatchState` at any time from the iOS `Communicator`:

```swift
let watchState = Communicator.shared.currentWatchState
```

You can use `WatchState` retrieve a URL which points to a directory on the iOS device specific to the currently paired watch.

You can use this directory to store things specific to that watch, which you don't want associated with the user's other watches. This directory (and anything in it) is automatically deleted by the system if the user uninstalls your watchOS app or unpairs their watch.

### `PhoneState`

`PhoneState` is similar to the `WatchState` but is queried from the watch's side instead.

Since watchOS 6, users can install watch apps without installing the iOS app, and you can
use `PhoneState` to determine this.

### `ComplicationInfo`

A `ComplicationInfo` can only be sent from an iOS device, and can only be received on a watchOS device.
Its purpose is to wake the watchOS app in the background to process the data and update its complication. At the time of writing your iOS app can do this 50 times a day, and you can query the `currentWatchState` of the shared `Communicator` object on iOS to find out how many remaining updates you have left.

Just like a `Context`, a `ComplicationInfo` has no identifier and its content is a JSON dictionary:

```swift
let content: Content = ["NumberOfStepsWalked" : 1000]
let complicationInfo = ComplicationInfo(content: content)
```

And you send it from the iOS app like this:

```swift
Communicator.shared.transfer(complicationInfo) { result in
  // Handle success or failure
}
```

Upon successful transfer, the `success` case in the `result` provides the remaining complication
updates available that day.

On the watchOS side you observe new `ComplicationInfo`s being received. Just like other transfers that may happen in the background, it's a good idea to observe these early on, like in the `ExtensionDelegate`:

```swift
ComplicationInfo.observe { complicationInfo in
  // Handle update
}
```

The value of `Communicator.currentReachability` must not be `.notReachable` otherwise an error will be thrown.

> **NOTE:** On watchOS, receiving a `ComplicationInfo` while in the background can cause the system to generate a `WKWatchConnectivityRefreshBackgroundTask`. If you assign this to the `Communicator`'s `task` property, `Communicator` will automatically handle ending the task for you at the right time.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The watchOS and iOS example apps set up observers for new `Message`s, `Blob`s, reachability changes etc and prints out any
changes to the console. They set up these observers early on in the app, which is recommended for state changes and
observers of things that may have transferred while the app was terminated, like `Blob`s.

Try running each target and seeing the output when you interact with the buttons.

## Requirements

Communicator relies on `WatchConnectivity`, Apple's framework for communicating between iOS and watchOS apps, but has no external dependencies.

Communicator requires iOS 10.0 and newer and watchOS 3.0 and newer.

## Installation

### Swift Package Manager

Communicator supports SPM, simply add Communicator as a package dependency in Xcode 11 or newer.

### Cocoapods

Add the following line to your Podfile and then run `pod install` in Terminal:

```ruby
pod "Communicator"
```

## Author

Kane Cheshire, [@kanecheshire](https://twitter.com/kanecheshire)

## License

Communicator is available under the MIT license. See the LICENSE file for more info.
