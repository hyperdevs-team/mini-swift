# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
  puts('➡️  Mint 🍃')
  sh('mint bootstrap')  
end

task(:lint) do
  sh('mint run swiftlint --fix --format')
end

task(:test) do
  sh('swift test --enable-code-coverage --disable-swift-testing')
end
