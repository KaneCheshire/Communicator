Pod::Spec.new do |s|
  s.name             = 'Communicator'
  s.version          = '1.0.0'
  s.summary          = 'Communication between iOS and watchOS apps just got a whole lot easier.'

  s.description      = <<-DESC
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
                       DESC

  s.homepage         = 'https://github.com/KaneCheshire/Communicator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kane Cheshire' => 'kane.cheshire@googlemail.com' }
  s.source           = { :git => 'https://github.com/KaneCheshire/Communicator.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kanecheshire'
  s.platforms = { :ios => "9.3", :watchos => "2.2" }
  s.source_files = 'Communicator/Classes/**/*'
  s.frameworks = 'WatchConnectivity'
end
