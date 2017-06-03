require './spec/spec_helper.rb'
require 'sqlite3'

RSpec.describe Biggles::CLI do

  context 'configuration' do
    before(:all) do
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
        file.write("your text")
      end
    end

    after(:all) do
      File.delete 'biggles_spec_full_config.yml'
      File.delete 'biggles_spec_broken_config.yml'
    end

    it 'exits with error on broken config' do
      expect(-> { Biggles::CLI.parse_config('biggles_spec_broken_config.yml') }).to raise_error(SystemExit)
    end

    it 'uses config file values where provided' do
      expect(-> { Biggles::CLI.parse_config('biggles_spec_full_config.yml') }).not_to raise_error
      opts = Biggles::CLI.parse_config('biggles_spec_full_config.yml')
      expect(opts).not_to be_nil
      expect(opts['workers']).to eq(5)
      expect(opts['loglevel']).to eq('DEBUG')
      expect(opts['jobs_dir']).to eq('myjobs')
      expect(opts['activerecord_logging']).to eq(true)
      expect(opts['job_timeout']).to eq(8)
      expect(opts['database']).not_to be_nil
    end

    it 'uses default when no config file is provided' do
      expect(-> { Biggles::CLI.parse_config('') }).not_to raise_error
      opts = Biggles::CLI.parse_config('')
      expect(opts).not_to be_nil
      expect(opts['workers']).to eq(2)
      expect(opts['loglevel']).to eq('INFO')
      expect(opts['jobs_dir']).to eq('jobs')
      expect(opts['activerecord_logging']).to eq(false)
      expect(opts['job_timeout']).to eq(15)
    end
  end

  context 'start' do
    it 'starts the job runner' do
      jr = double('job_runner')
      expect(jr).to receive(:start)
      expect(Biggles::JobRunner).to receive(:new).and_return(jr)
      Biggles::CLI.start
    end
  end

  context 'schema' do
    before(:all) do
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

    after(:all) do
      File.delete('biggles_spec_config.yml')
      File.delete('test.sqlite3') if File.exist?('test.sqlite3')
    end

    it 'creates the schema' do
      Biggles::CLI.create_schema('biggles_spec_config.yml')
      db = SQLite3::Database.new 'test.sqlite3'
      rows = db.execute 'SELECT name FROM sqlite_master WHERE type=\'table\';'
      db.close
      expect(rows).not_to be_empty
      expect(rows.flatten).to include('biggles_one_shot', 'biggles_heartbeat', 'biggles_scheduled', 'biggles_recurring')
    end

    it 'removes the schema' do
      Biggles::CLI.remove_schema('biggles_spec_config.yml')
      db = SQLite3::Database.new 'test.sqlite3'
      rows = db.execute 'SELECT name FROM sqlite_master WHERE type=\'table\';'
      db.close
      expect(rows.flatten).to eq(['sqlite_sequence'])
    end
  end

end