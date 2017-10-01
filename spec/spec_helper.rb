require 'rspec'
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
require 'biggles/job/scheduled'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module ConfigHelper
  def self.write_configs
    File.open('biggles_spec_full_config.yml', 'w') do |file|
      file.write("workers: 5\n"\
                   "loglevel: debug\n"\
                   "jobs_dir: myjobs\n"\
                   "database:\n"\
                   "  adapter: 'sqlite3'\n"\
                   "  database: 'test.sqlite3'\n"\
                   "  pool: 10\n"\
                   "  timeout: 5000\n"\
                   "activerecord_logging: true\n"\
                   "job_timeout: 8\n")
    end
    File.open('biggles_spec_broken_config.yml', 'w') do |file|
      file.write('invalid yaml')
    end
    File.open('biggles_spec_config.yml', 'w') do |file|
      file.write("workers: 5\n"\
                     "loglevel: debug\n"\
                     "jobs_dir: myjobs\n"\
                     "database:\n"\
                     "  adapter: 'sqlite3'\n"\
                     "  database: 'test.sqlite3'\n"\
                     "  pool: 10\n"\
                     "  timeout: 5000\n"\
                     "activerecord_logging: false\n"\
                     "job_timeout: 8\n")
    end
  end

  def self.delete_configs
    File.delete 'biggles_spec_full_config.yml'
    File.delete 'biggles_spec_broken_config.yml'
    File.delete 'biggles_spec_config.yml'
  end
end
