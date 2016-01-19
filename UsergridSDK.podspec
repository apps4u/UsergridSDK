Pod::Spec.new do |s|
  s.name = 'UsergridSDK'
  s.version = '0.0.3'
  s.summary = 'Usergrid SDK for iOS written in Swift'
  s.homepage = 'https://github.com/RobertWalsh/UsergridSDK'
  s.license = 'MIT'
  s.author = { 'Robert Walsh' => 'rjwalsh1985@gmail.com' }
  s.social_media_url = 'https://twitter.com/Apigee'
  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.0'

  s.source = { :git => 'https://github.com/RobertWalsh/UsergridSDK.git', :branch => 'master', :tag => 'v0.0.3' }
  s.source_files  = 'Source/*.swift','Source/Internal/*.swift'
end
