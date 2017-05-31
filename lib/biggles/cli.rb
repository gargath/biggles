require 'yaml'
require 'logger'
require 'biggles/schema_helper'
require 'otr-activerecord'
require 'require_all'
require 'biggles/job_runner'

module Biggles
  # Module for controlling command-line tool behaviour
  module CLI
    def self.parse_config(filename)
      options = {
          'loglevel'       => 'INFO',
          'workers'        => 2,
          'sweep_interval' => 30,
          'jobs_dir'       => 'jobs',
          'activerecord_logging' => false
      }
      if File.exist?(filename)
        begin
          options.merge! YAML.load_file(filename)
        rescue => e
          puts "Failed to parse configuration file #{filename}: #{e.message}"
          exit 1
        end
      else
        puts 'No configuration file found, using defaults.'
      end
      options
    end

    def self.start
      opts = parse_config('config/biggles.yml')
      connect(opts)

      if Dir.exist? opts['jobs_dir']
        require_all opts['jobs_dir']
      else
        @logger.warn "Jobs director #{opts['jobs_dir']} not found. Jobs will likely not work."
      end
      runner = Biggles::JobRunner.new(opts)
      runner.start
    end

    def self.create_schema
      opts = parse_config('config/biggles.yml')
      begin
        connect(opts)
        puts '<>now connected<>'
        Biggles::create_tables
        puts '<>schema created<>'
        puts "Database schema successfully created"
      rescue => e
        puts "Failed to create database schema: #{e.message}"
      end
    end

    def self.connect(opts)
      private_class_method
      puts '<>Connecting<>'
      begin
        if opts.key? 'database'
          puts 'Using DB configuration from Biggles config file'
          puts '<>pre-configure<>'
          OTR::ActiveRecord.configure_from_hash! opts['database']
          puts '<>post-configure<>'
        elsif File.exist?("#{Dir.pwd}/config/database.yml")
          puts "No DB configuration found. Using default #{Dir.pwd}/config/database.yml"
          OTR::ActiveRecord.configure_from_file!(
            "#{Dir.pwd}/config/database.yml"
          )
        else
          STDERR.puts 'No DB configuration found. Biggles cannot continue.'
          exit 2
        end
        puts '<>configured<>'
        ActiveRecord::Base.connection
      rescue => e
        STDERR.puts 'Failed to configure DB connection:'
        STDERR.puts e.message
        exit 2
      end
    end
  end
end
