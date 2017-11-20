require './spec/spec_helper.rb'

RSpec.describe Biggles::Job::Scheduled do
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

  it 'prevents updates to existing jobs' do
    j = Biggles::Job::Scheduled.create(processor: 'TestProcessor', options: { x: 'y' }, due: Time.now + 10)
    expect(j).not_to be_nil
    j.processor = 'AnotherProcessor'
    j.save
    j.reload
    expect(j.processor).not_to eq('AnotherProcessor')
  end

  it 'does not allow due dates in the past' do
    j = Biggles::Job::Scheduled.create(processor: 'TestProcessor', options: { x: 'y' }, due: Time.new - 1000)
    saved = j.save
    expect(saved).to be_falsey
    expect(j.valid?).to be_falsey
  end
end
