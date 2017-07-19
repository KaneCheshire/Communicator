Pod::Spec.new do |s|
  s.name             = 'Communicator'
  s.version          = '1.0.0'
  s.summary          = 'Communication between iOS and watchOS just got a whole lot easier.'

  s.description      = <<-DESC
Stop dealing with all those `WatchConnectivity` delegate methods! Communicator obfuscates
all that away and leaves you with an easy-to-use API that lets you focus on making your
watchOS app shine.

You use Communicator pretty much exactly the same from your watchOS or iOS app.
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
