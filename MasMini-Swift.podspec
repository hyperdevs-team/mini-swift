# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name             = 'MasMini-Swift'
  s.version          = '1.1.2'
  s.swift_version    = '5.0'
  s.summary          = 'The minimal expression of a Flux architecture in Swift.'

  s.description      = <<~DESC
    The minimal expression of a Flux architecture in Swift.

    Mini is built with be a first class citizen in Swift applications: macOS, iOS and tvOS applications.
    With Mini, you can create a thread-safe application with a predictable unidirectional data flow,
    focusing on what really matters: build awesome applications.
  DESC

  s.homepage         = 'https://github.com/masmovil/MasMini-Swift'
  s.license          = { type: 'APACHE', file: 'LICENSE' }
  s.authors          = { 'MásMóvil' => 'info@grupomasmovil.com' }
  s.source           = { :git => 'https://github.com/masmovil/masmini-swift.git', :tag => "v#{s.version.to_s}" }
  s.social_media_url = 'https://twitter.com/masmovil'

  s.ios.deployment_target = '11.0'

  s.osx.deployment_target = '10.13'

  s.tvos.deployment_target = '11.0'

  s.frameworks = 'Foundation'

  s.dependency('RxSwift', '~> 5')
  s.dependency('SwiftNIOConcurrencyHelpers', '~> 2.0.0')

  s.default_subspec = 'Core'

  s.module_name = 'Mini'

  s.subspec('Core') do |ss|
    ss.ios.source_files = ['Sources/MiniSwift/*.swift', 'Sources/MiniSwift/Utils/**/*.swift']

    ss.osx.source_files = ['Sources/MiniSwift/*.swift', 'Sources/MiniSwift/Utils/**/*.swift']

    ss.tvos.source_files = ['Sources/MiniSwift/*.swift', 'Sources/MiniSwift/Utils/**/*.swift']
  end

  s.subspec('Log') do |ss|
    ss.ios.dependency('MasMini-Swift/Core')
    ss.ios.source_files = 'Sources/MiniSwift/LoggingService/*.swift'

    ss.osx.dependency('MasMini-Swift/Core')
    ss.osx.source_files = 'Sources/MiniSwift/LoggingService/*.swift'

    ss.tvos.dependency('MasMini-Swift/Core')
    ss.tvos.source_files = 'Sources/MiniSwift/LoggingService/*.swift'
  end

  s.subspec('Test') do |ss|
    ss.ios.dependency('MasMini-Swift/Core')
    ss.ios.source_files = 'Sources/MiniSwift/TestMiddleware/*.swift'

    ss.osx.dependency('MasMini-Swift/Core')
    ss.osx.source_files = 'Sources/MiniSwift/TestMiddleware/*.swift'

    ss.tvos.dependency('MasMini-Swift/Core')
    ss.tvos.source_files = 'Sources/MiniSwift/TestMiddleware/*.swift'
  end

  s.preserve_paths = ['Templates/*.stencil']
end
