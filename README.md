# Communicator

[![CI Status](http://img.shields.io/travis/KaneCheshire/Communicator.svg?style=flat)](https://travis-ci.org/KaneCheshire/Communicator)
[![Version](https://img.shields.io/cocoapods/v/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)
[![License](https://img.shields.io/cocoapods/l/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)
[![Platform](https://img.shields.io/cocoapods/p/Communicator.svg?style=flat)](http://cocoapods.org/pods/Communicator)

## Introduction

Sending messages and data between watchOS and iOS apps
is possible thanks to Apple's work on `WatchConnectivity`,
however there are a lot of delegate callbacks to work with
plus some of the API calls are similar and it's not really
clear which is needed for what purpose.

Communicator means you don't have to spend any time writing
a cross-platform wrapper around this and is extremely easy
to use.

Each app gets its own shared Communicator object:

```swift
Communicator.shared
```

And usage between the two platforms is identical, so you can
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

`Communicator` can also transfer `Blob`s and sync `Context`s.

`Blob`s are perfect for sending larger amounts of data (`WatchConnectivity` will reject large data in `Message`s), and will continue to transfer even if your app
is terminated during transfer.

You can use a `Context` to keep things in sync between devices, which makes it perfect for preferences. `Context`s are not suitable for messaging or sending large data.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The watchOS and iOS example apps set up observers for new messages, blobs, reachability changes etc and prints out any
changes to the console. They set up these observers early on in the app, which is recommended for state changes and
observers of things that may have transferred while
the app was terminated, like Blobs.

Each app has some simple buttons which kick off sending a Message (with a reply handler), transferring a Blob and syncing a Context. Try running each target and seeing the output when you interact.

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
