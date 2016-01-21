Pod::Spec.new do |s|
  s.name = 'UsergridSDK'
  s.version = '0.0.4'
  s.summary = 'Usergrid SDK for iOS written in Swift'
  s.homepage = 'https://github.com/RobertWalsh/UsergridSDK'
  s.license = 'MIT'
  s.author = { 'Robert Walsh' => 'rjwalsh1985@gmail.com' }
  s.social_media_url = 'https://twitter.com/Apigee'
  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.1'
  s.tvos.deployment_target = '9.1'
  s.osx.deployment_target = '10.11'

  s.source = { :git => 'https://github.com/RobertWalsh/UsergridSDK.git', :branch => 'master', :tag => 'v' + s.version.to_s }
  s.source_files  = 'Source/*.swift'
end
