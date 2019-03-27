Pod::Spec.new do |s|
  s.name             = 'Mini-Swift'
  s.version          = '0.1.0'
  s.summary          = 'The re-imagined Re-Flux architecture for Swift.'

  s.description      = <<-DESC
The re-imagined Re-Flux architecture for Swift. 
Dependencies: RxSwift
                       DESC

  s.homepage         = 'https://github.com/bq/Mini-Swift'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'bq' => 'info@bq.com' }
  s.source           = { :git => 'https://github.com/bq/mini-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bqreaders'

  s.swift_version = '4.2'
  s.ios.deployment_target = '11.0'

  s.source_files  = "Source", "Source/**/*.{swift}"

  s.frameworks = 'Foundation'
  #s.dependency 'RxSwift', '~> 4.3'
  
end
