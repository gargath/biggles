require 'simplecov'
SimpleCov.start
require 'bundler/setup'
require 'otr-activerecord/activerecord'
require 'otr-activerecord/middleware/connection_management.rb'
require 'biggles'
require 'biggles/cli'
require 'biggles/heartbeat'
require 'biggles/job_runner'
require 'biggles/schema_helper'
require 'biggles/version'
require 'biggles/job/oneshot'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
