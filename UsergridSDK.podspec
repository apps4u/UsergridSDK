Pod::Spec.new do |s|
  s.name = 'UsergridSDK'
  s.version = '0.0.2'
  s.summary = 'Usergrid SDK for iOS written in Swift'
  s.homepage = 'https://github.com/RobertWalsh/UsergridSDK'
  s.license = 'MIT'
  s.author = { 'Robert Walsh' => 'rjwalsh1985@gmail.com' }
  s.social_media_url = 'https://twitter.com/Apigee'
  s.platform = :ios, '8.0'
  s.requires_arc = true

  s.source = { :git => 'https://github.com/RobertWalsh/UsergridSDK.git', :branch => 'master', :tag => 'v0.0.2' }
  s.source_files  = 'Source/*.swift','Source/Internal/*.swift'
end
