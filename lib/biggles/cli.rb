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
        'loglevel'             => 'INFO',
        'workers'              => 2,
        'jobs_dir'             => 'jobs',
        'activerecord_logging' => false,
        'job_timeout'          => 15
      }
      if File.exist?(filename)
        begin
          options.merge! YAML.load_file(filename)
        rescue => e
          $stderr.puts "Failed to parse configuration file #{filename}: #{e.message}"
          exit 1
        end
      else
        puts 'No configuration file found, using defaults.'
      end
      options['loglevel'].upcase!
      options
    end

    def self.start(config_file = 'config/biggles.yml')
      opts = parse_config(config_file)
      connect(opts)
      if Dir.exist? opts['jobs_dir']
        require_all opts['jobs_dir']
      else
        $stderr.puts "Jobs directory #{opts['jobs_dir']} not found. Jobs will likely not work."
      end
      runner = Biggles::JobRunner.new(opts)
      runner.start
    end

    def self.schema(direction, config_file = 'config/biggles.yml')
      dirword = direction == :up ? 'create' : 'remove'
      opts = parse_config(config_file)
      begin
        connect(opts)
        if direction == :up
          Biggles.create_tables
        elsif direction == :down
          Biggles.remove_tables
        else
          raise ArgumentError, 'Schema can only go :up or :down'
        end
        puts "Biggles tables successfully #{dirword}d"
      rescue => e
        puts "Failed to #{dirword} database tables: #{e.message}"
      end
      ActiveRecord::Base.remove_connection
    end

    def self.connect(opts)
      private_class_method
      begin
        if opts.key? 'database'
          puts 'Using DB configuration from Biggles config file'
          OTR::ActiveRecord.configure_from_hash! opts['database']
        elsif File.exist?("#{Dir.pwd}/config/database.yml")
          puts "No DB configuration found. Using default #{Dir.pwd}/config/database.yml"
          OTR::ActiveRecord.configure_from_file!(
            "#{Dir.pwd}/config/database.yml"
          )
        else
          $stderr.puts 'No DB configuration found. Biggles cannot continue.'
          exit 2
        end
        if opts['activerecord_logging']
          ar_logger = Logger.new(STDOUT)
          ar_logger.level = opts['loglevel']
          ar_logger.progname = 'SQL'.ljust(10)
          ActiveRecord::Base.logger = ar_logger
        else
          ActiveRecord::Base.logger = nil
        end
        ActiveRecord::Base.connection
      rescue => e
        $stderr.puts 'Failed to configure DB connection:'
        $stderr.puts e.message
        exit 2
      end
    end
  end
end
