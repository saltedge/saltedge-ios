Pod::Spec.new do |s|
  s.name         = "SaltEdge-iOS"
  s.version      = "1.0.0"
  s.summary      = "A handful of classes to help you interact with the Salt Edge API from your iOS app."

  s.description  = <<-DESC
                   SaltEdge-iOS is a library targeted at easing the interaction with the [Salt Edge API](https://docs.saltedge.com/).
                   The library aims to come in handy with some core API requests such as connecting a login, fetching accounts/transactions, et al.
                   DESC

  s.homepage     = "https://github.com/saltedge/saltedge-ios"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.source       = { :git => "https://github.com/saltedge/saltedge-ios.git", :tag => "v1.0.0" }
  s.source_files = 'Classes/**/**.{h,m}'
  s.requires_arc = true
  s.author       = "SaltEdge"
  s.platform     = :ios, "7.0"
  s.dependency   "AFNetworking", "~> 2.3.1"
end