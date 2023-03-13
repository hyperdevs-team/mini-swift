# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name             = 'MasMini-Swift'
  s.version          = '2.1.1'
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

  s.ios.deployment_target = '14.1'

  s.osx.deployment_target = '11.0'

  s.tvos.deployment_target = '13.0'

  s.frameworks = 'Foundation'

  s.default_subspec = 'Core'

  s.module_name = 'Mini'

  s.subspec('Core') do |ss|
    ss.ios.source_files = ['Sources/*.swift', 'Sources/Utils/**/*.swift']

    ss.osx.source_files = ['Sources/*.swift', 'Sources/Utils/**/*.swift']

    ss.tvos.source_files = ['Sources/*.swift', 'Sources/Utils/**/*.swift']
  end
end
