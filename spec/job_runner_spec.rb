require './spec/spec_helper.rb'

RSpec.describe Biggles::JobRunner do
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

  it 'traps signals' do
    expect(Signal).to receive(:trap).with('TERM')
    expect(Signal).to receive(:trap).with('INT')
    options = { 'loglevel' => 'DEBUG', 'workers' => 1 }
    runner = Biggles::JobRunner.new(options)
    runner.send(:trap_signals)
  end

  it 'prioritizes scheduled over one-shot' do
    j1 = Biggles::Job::OneShot.create(processor: 'TestProcessor', options: { x: 'y' })
    j2 = Biggles::Job::Scheduled.create(processor: 'TestProcessor', options: { x: 'y' }, due: Time.now + 1)
    j3 = Biggles::Job::OneShot.create(processor: 'TestProcessor', options: { x: 'z' })
    expect(j1.valid?).to be_truthy
    expect(j2.valid?).to be_truthy
    expect(j3.valid?).to be_truthy
    expect(j1.new_record?).to be_falsey
    expect(j2.new_record?).to be_falsey
    expect(j3.new_record?).to be_falsey

    options = { 'loglevel' => 'DEBUG', 'workers' => 1 }
    runner = Biggles::JobRunner.new(options)

    ret = runner.send(:find_job)
    expect(ret).to be_a(Biggles::Job::Scheduled)

    ret = runner.send(:find_job)

    expect(ret).to be_a(Biggles::Job::OneShot)

    ret = runner.send(:find_job)
    expect(ret).to be_a(Biggles::Job::OneShot)

    ret = runner.send(:find_job)
    expect(ret).to be_nil
  end
end
