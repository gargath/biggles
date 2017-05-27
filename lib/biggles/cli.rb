require 'yaml'
require 'logger'

module Biggles
  # Module for controlling command-line tool behaviour
  module CLI
    def self.parse_config(filename)
      options = { 'loglevel' => 'INFO' }
      options.merge! YAML.load_file(filename)
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
      traps
      opts = parse_config('config.yaml')
      @logger = Logger.new(STDOUT)
      @logger.level = opts['loglevel']
      @logger.info 'Biggles starting...'
      @logger.debug 'Debug logging enabled'
      Kernel.loop do
        sleep 1
      end
    end
  end
end
