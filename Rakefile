# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
  sh('bundle install')
  puts('➡️  Overcommit')
  sh('bundle exec overcommit --install')
  sh('bundle exec overcommit --sign')
  sh('bundle exec overcommit --sign pre-commit')
  sh('bundle exec overcommit --sign post-checkout')
end
