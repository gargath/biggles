require 'yaml'
require 'logger'
require 'otr-activerecord'

module Biggles
  # Module for controlling command-line tool behaviour
  module CLI
    def self.parse_config(filename)
      options = { 'loglevel' => 'INFO' }
      begin
        options.merge! YAML.load_file(filename)
      rescue => e
        STDERR.puts "Failed to parse configuration file #{filename}: #{e.message}"
        exit 1
      end
    end

    def self.traps
      trap 'SIGINT' do
        puts 'Ctrl-C received. Exiting safely...'
        sleep 3
        exit 0
      end

      trap 'SIGTERM' do
        puts 'Kill received. Exiting safely...'
        sleep 3
        exit 0
      end
    end

    def self.start
      opts = parse_config('config.yaml')
      connect(opts)
      traps
      @logger = Logger.new(STDOUT)
      @logger.level = opts['loglevel']
      @logger.info 'Biggles starting...'
      @logger.debug 'Debug logging enabled'
      Kernel.loop do
        sleep 1
      end
    end

    def self.connect(opts)
      private_class_method
      begin
        if opts.key? 'database'
          puts 'Using DB configuration from Biggles config file'
          OTR::ActiveRecord.configure_from_hash! opts['database']
        elsif File.exist?("#{Dir.pwd}/config/database.yaml")
          puts "No DB configuration found. Using default #{Dir.pwd}/config/database.yaml"
          OTR::ActiveRecord.configure_from_file!(
            "#{Dir.pwd}/config/database/yaml"
          )
        else
          STDERR.puts 'No DB configuration found. Biggles cannot continue.'
          exit 2
        end
        ActiveRecord::Base.connection
      rescue => e
        STDERR.puts 'Failed to configure DB connection:'
        STDERR.puts e.message
        exit 2
      end
    end
  end
end
