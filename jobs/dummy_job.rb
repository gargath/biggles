# A dummy job doing dummy things
module DummyJob
  def self.execute(opts)
    snooze = (opts['snooze'] ? opts['snooze'] : 0)
    puts "Jobbing for #{snooze} seconds"
    sleep snooze
    puts 'Job Done!'
  end
end
