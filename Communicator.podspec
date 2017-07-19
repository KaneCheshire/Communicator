Pod::Spec.new do |s|
  s.name             = 'Communicator'
  s.version          = '1.0.0'
  s.summary          = 'Communication between iOS and watchOS apps just got a whole lot easier.'

  s.description      = <<-DESC
Stop dealing with all those `WatchConnectivity` delegate methods!

Communicator obfuscates all that away and leaves you with an easy-to-use API that makes
it ridiculously easy to start sending messages, data and contexts between your iOS and
watchOS app.

Each app has a shared Communicator object which handles all the underlying `WatchConnectivity`
stuff, and wraps a lot of the communication into logical components like Messages, Contexts and Blobs.

Messages are ideal for quick communication between your iOS and watchOS app. Blobs are great
for sending larger amounts of data which you don't need an immediate reply from. And Contexts
are perfect for syncing settings between devices.
                       DESC

  s.homepage         = 'https://github.com/KaneCheshire/Communicator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kane Cheshire' => 'kane.cheshire@googlemail.com' }
  s.source           = { :git => 'https://github.com/KaneCheshire/Communicator.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kanecheshire'
  s.platforms = { :ios => "9.3", :watchos => "3.2" }
  s.source_files = 'Communicator/Classes/**/*'
  s.frameworks = 'WatchConnectivity'
end
