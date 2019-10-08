#!/usr/bin/env ruby

raise 'Test failed' unless system('swift test')
raise 'Generate linuxmain failed' unless system('swift test --generate-linuxmain')
raise 'Swiftformat failed' unless system('swift run swiftformat --swiftversion 5.0 .')
raise 'Swiftlint failed' unless system('swift run swiftlint autocorrect --path Sources/')
raise 'Git add failed' unless system('git add .')
