Pod::Spec.new do |s|
  s.name = 'UsergridSDK'
  s.version = '0.0.1'
  s.summary = 'Usergrid SDK for iOS written in Swift'
  s.homepage = 'https://github.com/RobertWalsh/UsergridSDK'
  s.license = 'MIT'
  s.author = { 'Robert Walsh' => 'rwalsh@apigee.com' }
  s.social_media_url = 'https://twitter.com/Apigee'
  s.platform = :ios, '8.0'
  s.requires_arc = true

  s.source = { :git => 'https://github.com/RobertWalsh/UsergridSDK.git', :branch => 'master' }
  s.source_files  = 'Source/*.swift','Source/Internal/*.swift'
end
