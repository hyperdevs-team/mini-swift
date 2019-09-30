#!/usr/bin/env ruby

`swift test`
`swift test --generate-linuxmain`
`swift run swiftformat .`
`swift run swiftlint autocorrect --path Sources/`
`git add .`
