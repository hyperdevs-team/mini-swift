# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
  raise '`brew` is required. Please install brew. https://brew.sh/' unless system('which brew')

  puts('➡️  Bundle')
  sh('brew bundle')
  sh('bundle install')

  puts('➡️  Overcommit')
  sh('bundle exec overcommit --install')
  sh('bundle exec overcommit --sign')
  sh('bundle exec overcommit --sign pre-commit')

  puts('➡️  Carthage')
  sh('brew update')
  sh('brew outdated carthage || brew upgrade carthage')
  sh('carthage bootstrap --no-use-binaries --cache-builds --use-xcframeworks')
end
