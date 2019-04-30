# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
  unless system('which brew')
    raise '`brew` is required. Please install brew. https://brew.sh/'
  end
  puts('➡️  Bundle')
  sh('brew bundle')
  sh('bundle install')
  puts('➡️  Overcommit')
  sh('bundle exec overcommit --install')
  sh('bundle exec overcommit --sign')
  sh('bundle exec overcommit --sign pre-commit')
  sh('bundle exec overcommit --sign post-checkout')
  puts('➡️  Carthage')
  sh('carthage bootstrap --cache-builds --no-use-binaries')
end
