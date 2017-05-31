require 'thread'
require 'biggles/job/oneshot'

module Biggles
  # Class to start and manage worker threads
  class JobRunner

    def initialize(options)
      @opts = options
      @logger = Logger.new(STDOUT)
      @logger.level = @opts['loglevel']
      @logger.progname='Main'.ljust(10)
      if @opts['activerecord_logging']
        ar_logger = Logger.new(STDOUT)
        ar_logger.level = @opts['loglevel']
        ar_logger.progname='SQL'.ljust(10)
        ActiveRecord::Base.logger = ar_logger
      else
        ActiveRecord::Base.logger = nil
      end
      @db_access = Mutex.new
    end

    def start
      @logger.info 'Biggles starting...'
      @logger.debug 'Debug logging enabled'
      @exiting = false
      loop do
        Signal.trap('INT') do
          puts 'Caught SIGINT during processing. Exiting cleanly...'
          @exiting = true
        end
        Signal.trap('TERM') do
          puts 'Caught SIGTERM during processing. Exiting cleanly...'
          @exiting = true
        end
        find_and_start_job
        @logger.debug 'Finished execution sweep'
        Signal.trap('INT') do
          puts 'Caught SIGINT during sleep.'
          @exiting = true
          throw :sigint
        end
        Signal.trap('TERM') do
          puts 'Caught SIGTERM during sleep.'
          @exiting = true
          throw :sigint
        end
        catch :sigint do
          sleep @opts['sweep_interval'] unless @exiting
        end
        break if @exiting
      end
      @logger.info 'Exiting...'
    end

    private

    def find_and_start_job
      @workers = []
      @opts['workers'].times do |n|
        @db_access.synchronize do
          job = Biggles::Job::OneShot.where(status: 'SCHEDULABLE').first
          if job
            job.status = 'PENDING'
            job.save
            @workers << Thread.new { process_job(job, n) }
          end
        end
      end
      @workers.each(&:join)
    end

    def process_job(job, thread_idx)
      if job
        logger = Logger.new(STDOUT)
        logger.progname="Worker-#{thread_idx}".ljust(10)
        start = Time.now
        job.status = 'EXECUTING'
        job.save
        logger.info "Starting executing of job #{job.id} using processor #{job.processor}"
        begin
          processor = Object.const_get(job.processor)
          processor.send(:execute)
          job.status = 'COMPLETED'
          job.save
        rescue NameError => ne
          logger.error "No processor '#{job.processor}' found for job #{job.id}"
          job.status = 'FAILED'
          job.save
        rescue => e
          logger.error "Job #{job.id} failed: #{e.message}"
          logger.error(e.backtrace)
          job.status = 'FAILED'
          job.save
        end
        duration = Time.now - start
        logger.info "Finished execution of job #{job.id} with status #{job.status} in #{duration} seconds."
      end
    end
  end
end