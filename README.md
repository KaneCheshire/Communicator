# Communicator

[![CI Status](http://img.shields.io/travis/KaneCheshire/Communicator.svg?style=flat)](https://travis-ci.org/KaneCheshire/Communicator)
[![Version](https://img.shields.io/cocoapods/v/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)
[![License](https://img.shields.io/cocoapods/l/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)
[![Platform](https://img.shields.io/cocoapods/p/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)

## Introduction

Sending messages and data between watchOS and iOS apps
is possible thanks to Apple's work on `WatchConnectivity`,
however there are a lot of delegate callbacks to work with,
plus some of the API calls are similar and it's not really
clear which is needed for what purpose.

`Communicator` means you don't have to spend any time writing a cross-platform wrapper around `WatchConnectivity` and is extremely easy to use.

Each app gets its own shared `Communicator` object to use which handles all the underlying session stuff:

```swift
Communicator.shared
```

Usage between the two platforms is identical, so you can
use it in a shared framework with no workarounds.

Here's how you send a simple message with Communicator.

```swift
let message = Message(identifier: "1234", content: ["messageKey" : "This is some message content!"])
try? Communicator.shared.send(immediateMessage: message)
```

This will try to send a message to the counterpart immediately. If the underlying session is not active, the `try` will fail and Communicator will `throw` an error you can catch if you want.

On the other device you register as an observer for new messages:

```swift
Communicator.shared.messageReceivedObservers.add { message in
    if message.identifier == "1234" {
        print("Message received: \(message.content)")
    }
}
```

The great thing about using this style of observing means that you can observe these messages from anywhere in your app and filter out the ones you don't care about.

`Communicator` can also transfer `Blob`s and sync `Context`s.

`Blob`s are perfect for sending larger amounts of data (`WatchConnectivity` will reject large data in `Message`s), and will continue to transfer even if your app
is terminated during transfer.

You can use a `Context` to keep things in sync between devices, which makes it perfect for preferences. `Context`s are not suitable for messaging or sending large data.

## Usage

### `Communicator`

Each app has its own shared `Communicator` object which it
should use to communicate with the counterpart app.

```swift
Communicator.shared
```

The APIs between iOS and watchOS are almost identical, so
you can use `Communicator` anywhere, including in a shared iOS-watchOS framework.

`Communicator` uses `ObserverSet`s to notify observers/listeners when events occur, like a `Message` being sent or the activation state of the underlying session changing.

### `Message`

A `Message` is a simple object comprising of an identifier string of your choosing, and a JSON dictionary as content.

The keys of the JSON dictionary must be strings, and the values must be plist-types. That means anything you can save to `UserDefaults`; `String`, `Int`, `Data` etc. You also _cannot_ send large amounts of data between devices using a `Message` because the system will reject it. Instead, use a `Blob` for sending large amounts of data.

This is how you create a simple `Message`:

```swift
let json: JSONDictionary = ["TotalDistanceTravelled" : 10000.000]
let message = Message(identifier: "JourneyComplete", content: json)
```

And this is how you send it:

```swift
try? Communicator.shared.send(immediateMessage: message)
```

Notice that we're using `immediateMessage` in the above example. This works well for rapid communication between two devices, but is limited to small amounts of data and will fail if either of the devices becomes unreachable during communication.

You can also assign a `replyHandler` to the message. On the sending device, this `replyHandler` is executed by the system when the receiving device executes it on its end.

On the receiving device you listen for new messages, check the identifier and then execute the `replyHandler`, which will allow the system on the sending device to execute the `replyHandler` there. The `replyHandler` also expects a JSON dictionary just like the content of the message.

```swift
Communicator.shared.messageReceivedObservers.add { message in
    if message.identifier == "JourneyComplete" {
      let replyJSON: JSONDictionary = ["JourneyProcessed" : true]
      message.replyHandler?(replyJSON)
    }
}
```

You can also choose to send a message using the `guaranteed` method, however with this method the `replyHandler` is ignored even if you execute it on the receiving device. This is because messages can be queued while the receiving device is not currently receiving messages, so they're queued until the session is next created:

```swift
try? Communicator.shared.send(guaranteedMessage: message)
```

Because the messages are queued, they could be received in a stream on the receiving device when it's able to process them.

### `Blob`

A `Blob` is very similar to a `Message` but is better suited to sending larger bits of data. A `Blob` is created with an `identifier` but instead of assigning a JSON dictionary as the content, you assign pure `Data` instead.

This is how you create a `Blob`:

```swift
let largeData: Data = getJourneyHistoryData()
let blob = Blob(identifier: "JourneyHistory", content: largeData)
```

And this is how you transfer it to the other device:

```swift
try? Communicator.shared.transfer(blob: blob)
```

Because a `Blob` can be much larger than a `Message`, it might take significantly longer to send. The system handles this, and continues to send it even if the sending device becomes unreachable before it has completed.

On the receiving device you listen for new `Blob`s. Because these `Blob`s can often be queued waiting for the session to start again, `Communicator` will often notify observers very early on. This makes it a good idea to start observing for `Blob`s as soon as possible, like in the `AppDelegate` or `ExtensionDelegate`.

```swift
Communicator.shared.blobReceivedObservers.add { blob in
    if blob.identifier == "JourneyHistory" {
      let JourneyHistoryData: Data = blob.content
      // -- Do something with the data -- //
    }
}
```

You can also assign a completion handler when creating a blob, which will give you an error if an error was detected by the system.

### `Context`

A `Context` is a very lightweight object. A `Context` can be send and received by either device, and the system stores the last sent/received `Context` that you can query at any time. This makes it ideal for syncing lightweight things like preferences between devices.

A `Context` has no identifier, and simply takes a JSON dictionary as content. Like a `Message`, this content must be primitive types like `String`, `Int`, `Data` etc, and must not be too large or the system will reject it:

```swift
let json: JSONDictionary = ["ShowTotalDistance" : true]
let context = Context(content: json)
try? Communicator.shared.sync(context: context)
```

On the receiving device you listen for new `Context`s:

```swift
Communicator.shared.contextUpdatedObservers.add { context in
  if let shouldShowTotalDistance = context.content["ShowTotalDistance"] as? Bool {
    print("Show total distance setting changed: \(shouldShowTotalDistance)")
  }
}
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The watchOS and iOS example apps set up observers for new messages, blobs, reachability changes etc and prints out any
changes to the console. They set up these observers early on in the app, which is recommended for state changes and
observers of things that may have transferred while
the app was terminated, like Blobs.

Each app has some simple buttons which kick off sending a `Message` (with a reply handler), transferring a Blob and syncing a Context. Try running each target and seeing the output when you interact with the buttons.

## Requirements

Communicator relies on `WatchConnectivity`, Apple's framework for communicating between iOS and watchOS apps,
and in the future will also rely on `TABObserverSet` as an external dependency.

Communicator requires iOS 9.3 and newer and watchOS 2.2 and newer.

## Installation

Communicator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile and then run `pod install` in Terminal:

```ruby
pod "Communicator"
```

## Author

Kane Cheshire, @kanecheshire

## License

Communicator is available under the MIT license. See the LICENSE file for more info.
