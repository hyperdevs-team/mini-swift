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
  s.source           = { :git => 'https://github.com/bq/mini-swift.git', :tag => "v#{s.version.to_s}" }
  s.social_media_url = 'https://twitter.com/bqreaders'

  s.ios.deployment_target = '11.0'
  s.ios.frameworks = 'UIKit'
  s.ios.source_files  = 'Source/**/*.swift'

  s.osx.deployment_target = '10.13'
  s.osx.frameworks = 'AppKit'
  s.osx.source_files  = 'Source/**/*.swift'

  s.watchos.deployment_target = '4.0'
  s.watchos.frameworks = 'UIKit', 'WatchKit'
  s.watchos.source_files  = 'Source/**/*.swift'

  s.tvos.deployment_target = '11.0'
  s.tvos.frameworks = 'UIKit'
  s.tvos.source_files  = 'Source/**/*.swift'

  s.frameworks = 'Foundation'
  s.dependency 'RxSwift', '~> 4.3'
  s.dependency 'MagicPills'
end
