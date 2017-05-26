require 'spec_helper'

RSpec.describe Biggles::Job::OneShot do
  before(:all) do
    ENV['rack_env'] = 'test'
    OTR::ActiveRecord.configure_from_hash!(
      adapter: 'sqlite3',
      database: 'test.sqlite3',
      pool: 5,
      timeout: 5000
    )
    Biggles.create_schema
  end

  after(:all) do
    ActiveRecord::Base.clear_active_connections!
    ActiveRecord::Base.remove_connection
    File.delete('test.sqlite3') if File.exist?('test.sqlite3')
  end

  it 'prevents updates to existing jobs' do
    j = Biggles::Job::OneShot.create(processor: 'TestProcessor',
                                     options: { x: 'y' })
    expect(j).not_to be_nil
    j.processor = 'AnotherProcessor'
    expect { j.save }.to raise_error ActiveRecord::ReadOnlyRecord
  end
end
