# A dummy job doing dummy things
module DummyJob
  def self.execute
    puts 'Job Starting'
    sleep 3
    puts 'Job Done!'
  end
end
