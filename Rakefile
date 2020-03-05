# frozen_string_literal: true

task default: %w[setup]

task(:setup) do

  raise '`brew` is required. Please install brew. https://brew.sh/' unless system('which brew')

  puts('➡️  Bundle')
  sh('brew bundle')
  sh('bundle install')

  puts('➡️  SPM Resolve Dependencies')
  sh('swift package resolve')

  puts('➡️ Installing git hooks')
  sh('swift run komondor install')
end

task(:build) do
  sh('swift build --disable-sandbox -c release')
end

task(:test) do
  sh('swift test')
end

task(:pods) do
  sh('bundle exec pod lib lint --allow-warnings --fail-fast --subspec="Core"')
  sh('bundle exec pod lib lint --allow-warnings --fail-fast --subspec="Log"')
  sh('bundle exec pod lib lint --allow-warnings --fail-fast --subspec="Test"')
  sh('bundle exec pod lib lint --allow-warnings --fail-fast --subspec="MiniPromises"')
  sh('bundle exec pod lib lint --allow-warnings --fail-fast --subspec="MiniTasks"')
end

task(:docs) do
  sh('sourcedocs generate --min-acl public --spm-module Mini --output-folder docs/Mini')
  sh('sourcedocs generate --min-acl public --spm-module MiniTasks --output-folder docs/MiniTasks')
  sh('sourcedocs generate --min-acl public --spm-module MiniPromises --output-folder docs/MiniPromises')
  sh('moduleinterface generate --spm-module Mini --output-folder docs')
  sh('moduleinterface generate --spm-module MiniTasks --output-folder docs')
  sh('moduleinterface generate --spm-module MiniPromises --output-folder docs')
end
