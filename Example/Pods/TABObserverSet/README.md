![The App Business](Assets/logo.png)

# TABObserverSet

[![CI Status](http://img.shields.io/travis/theappbusiness/TABObserverSet.svg?style=flat)](https://travis-ci.org/theappbusiness/TABObserverSet)
[![Version](https://img.shields.io/cocoapods/v/TABObserverSet.svg?style=flat)](http://cocoapods.org/pods/TABObserverSet)
[![License](https://img.shields.io/cocoapods/l/TABObserverSet.svg?style=flat)](http://cocoapods.org/pods/TABObserverSet)
[![Platform](https://img.shields.io/cocoapods/p/TABObserverSet.svg?style=flat)](http://cocoapods.org/pods/TABObserverSet)

`TABObserverSet`, originally conceived by [Mike Ash](https://github.com/mikeash/SwiftObserverSet), provides a Swift-y alternative to the traditional `NotificationCenter` style of reactive programming.

With a simple syntax, `TABObserverSet` is easy to use and read in your code.

## Integration

### Cocoapods

To integrate `TABObserverSet` using Cocoapods, simply add the following to your podfile:

```ruby
pod 'TABObserverSet', '2.0.0' # Swift 4
pod 'TABObserverSet', '1.1.1' # Swift 3
```

### Manual

If you're not using Cocoapods, you can integrate `TABObserverSet` into your project by adding `ObserverSet.swift` to your project's target.

## Usage

Usage is very simple.

Similar to `NotificationCenter`, you have a single _broadcaster_ and multiple _observers_. While `NotificationCenter`-style broadcasting can potentially result in a many-to-many relationship, `TABObserverSet` results in a one-to-many relationship, due to there only being a single broadcaster.

Here's a way you could set up a broadcaster:

```swift
class NetworkPoller {

  // Things that want to observe the broadcast can add themselves
  // to this `ObserverSet`
  let networkPollObservers = ObserverSet<Void>()

  // ... some magic code here which polls ... //

  private func networkPolled() {

    // Broadcast to any observers that the network has polled
    networkPollObservers.notify()
  }

}
```

Simple, right? In case you're wondering what the `Void` type is doing when setting up the observer set:

```swift
ObserverSet<Void>()
```

That's essentially declaring that we're not going to be passing in an argument when notifying observers.

You could declare that you will be passing any type, should you want to. Here's another example, where we pass an optional error when we notify observers:

```swift
class NetworkPoller {

  // Things that want to _subscribe_ to the _broadcast_ can add themselves
  // to this `ObserverSet`
  let networkPollObservers = ObserverSet<Error?>()

  // ... some magic code here which polls ... //

  private func networkPolled(_ error: Error?) {

    // Broadcast to any observers that the network has polled
    networkPollObservers.notify(error)
  }

}
```

So that's setting up the broadcaster, how about observers? That too is very simple:

```swift
let networkPoller = NetworkPoller()

class SettingsViewModel {

  init() {
    networkPoller.networkPollObservers.add(self, SettingsViewModel.networkPolled)
  }

  private func networkPolled(_ error: Error?) {
    if let error = error {
      print("Error! \(error)")
    } else {
      print("Network polled! :D")
    }
  }

}

class ResultsViewModel {

  init() {
    networkPoller.networkPollObservers.add(self, ResultsViewModel.networkPolled)
  }

  private func networkPolled(_ error: Error?) {
    if let error = error {
      print("Error! \(error)")
    } else {
      print("Network polled! :D")
    }
  }

}
```

In the above sample code, we have a single shared `NetworkPoller` instance (the _broadcaster_),
and two view models which want to do their own thing when the network is polled, so they _observe_ the event individually. This is not too disimillar from the way you can set up `#selectors` in Swift, but it's a lot cleaner.

You can also use closures to observe events, which is nice for testing:

```swift
func test_networkPoller_notifiesObservers() {
  let networkPoller = NetworkPoller()
  let expectation = self.expectation(description: "Wait for network to poll")
  networkPoller.networkPollObservers.add { error in
    XCTAssertNil(error)
    expectation.fulfill()
  }
  waitForExpectations(timeout: 1)
}
```

## Credits

`TABObserverSet` is a fork of [`SwiftObserverSet `](https://github.com/mikeash/SwiftObserverSet), created by Mike Ash.

Credit should be given to Mike Ash for the original idea.

## License

TABObserverSet is available under the MIT license. See the LICENSE file for more info.
