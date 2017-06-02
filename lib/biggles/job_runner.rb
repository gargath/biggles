require 'thread'
require 'json'
require 'biggles/job/oneshot'
require 'biggles/heartbeat'
require 'concurrent'

module Biggles
  # Class to start and manage worker threads
  class JobRunner
    def initialize(options)
      @opts = options
      @logger = Logger.new(STDOUT)
      @logger.level = @opts['loglevel']
      @logger.progname = 'Main'.ljust(10)
      if @opts['activerecord_logging']
        ar_logger = Logger.new(STDOUT)
        ar_logger.level = @opts['loglevel']
        ar_logger.progname = 'SQL'.ljust(10)
        ActiveRecord::Base.logger = ar_logger
      else
        ActiveRecord::Base.logger = nil
      end
      @exiting = false
      @workers = Concurrent::FixedThreadPool.new(@opts['workers'],
                                                 idletime: 60,
                                                 max_queue: @opts['workers'],
                                                 fallback_policy: :abort)
    end

    def start
      @logger.info 'Biggles starting...'
      @logger.debug 'Debug logging enabled'
      trap_signals
      start_heartbeat
      loop do
        job = find_job if @workers.remaining_capacity > 0
        if job
          begin
            @logger.debug "Job #{job.id} enqueued, waiting for worker."
            @workers.post { run_job(job) }
          rescue Concurrent::RejectedExecutionError
            @logger.warn 'Failed to enqueue job. Queue full.'
            job.status = 'SCHEDULABLE'
            job.save
          end
        else
          sleep 2
        end
        break if @exiting
      end
      shutdown
      @logger.warn 'Shutdown complete'
    end

    private

    def trap_signals
      Signal.trap('INT') do
        puts 'Caught SIGINT during processing. Exiting cleanly...'
        @exiting = true
      end
      Signal.trap('TERM') do
        puts 'Caught SIGTERM during processing. Exiting cleanly...'
        @exiting = true
      end
    end

    def find_job
      job = Biggles::Job::OneShot.where(status: 'SCHEDULABLE').first
      return nil unless job
      job.status = 'PENDING'
      job.save
      job
    end

    def run_job(job)
      start = Time.now
      job.status = 'RUNNING'
      job.save
      logger = Logger.new(STDOUT)
      logger.progname = "Job-#{job.id}".ljust(10)
      logger.level = @logger.level
      logger.info 'Starting...'
      job_timeout = @opts['job_timeout']
      begin
        processor = Object.const_get(job.processor)
        job_opts = JSON.parse(job.options)
        Timeout.timeout(job_timeout) do
          processor.send(:execute, job_opts)
        end
        job.status = 'COMPLETE'
      rescue NameError
        logger.fatal "No processor '#{job.processor}' found for job #{job.id}"
        job.status = 'FAILED'
      rescue Timeout::Error
        logger.fatal "Job #{job.id} timed out after #{job_timeout} seconds."
        job.status = 'FAILED'
        job.save
        return
      rescue => e
        logger.fatal "Job #{job.id} failed: #{e.message}"
        e.backtrace.each do |line|
          logger.debug "  #{line}"
        end
        job.status = 'FAILED'
      end
      job.save
      duration = Time.now - start
      logger.info "Execution finished in #{duration} seconds"
    end

    def start_heartbeat
      h = Biggles::Heartbeat.first
      run_recovery if h
      h = Biggles::Heartbeat.create(pid: $$, timestamp: Time.now)
      h.save
      heartbeat_logger = Logger.new(STDOUT)
      heartbeat_logger.progname = 'Heartbeat'.ljust(10)
      @heartbeat = Concurrent::TimerTask.new(execution_interval: 60, timeout_interval: 10, run_now: true) do
        begin
          h.timestamp = Time.now
          h.save
          heartbeat_logger.debug '<thump>'
        rescue => e
          heartbeat_logger.error "Heartbeat failed to update DB because '#{e}' happened"
        end
      end
      heartbeat_logger.info 'Heartbeat starting'
      @heartbeat.execute
    end

    def stop_heartbeat
      @heartbeat.shutdown
      @heartbeat.wait_for_termination
      @logger.error 'Heartbeat failed to shut down properly.' unless @heartbeat.shutdown?
      Biggles::Heartbeat.delete_all
      @logger.info 'Hearbeat stopped'
    end

    def run_recovery; end

    def shutdown
      @logger.warn 'Biggles shutting down...'
      @workers.shutdown
      unless @workers.wait_for_termination(20)
        @logger.error 'Workers failed to terminate in time. Killing threads may leave inconsistent jobs.'
        @workers.kill
        @workers.wait_for_termination(10)
      end
      stop_heartbeat
    end
  end
end
