require './spec/spec_helper.rb'

RSpec.describe Biggles::Heartbeat do
  before(:all) do
    OTR::ActiveRecord.configure_from_hash!(
      adapter: 'sqlite3',
      database: 'test.sqlite3',
      pool: 5,
      timeout: 5000
    )
    ActiveRecord::Base.logger = nil
    Biggles.create_tables
  end

  after(:all) do
    ActiveRecord::Base.clear_active_connections!
    ActiveRecord::Base.remove_connection
    File.delete('test.sqlite3') if File.exist?('test.sqlite3')
  end

  it 'correctly reports staleness' do
    hb1 = Biggles::Heartbeat.create(pid: 123, timestamp: Time.now)
    hb2 = Biggles::Heartbeat.create(pid: 123, timestamp: Time.now - 60_000)
    hb1.save
    hb2.save
    expect(hb1.stale?).to be false
    expect(hb2.stale?).to be true
  end
end
