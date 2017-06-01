require 'spec_helper'

RSpec.describe Biggles do
  it 'has a version number' do
    expect(Biggles::VERSION).not_to be nil
  end

  it 'can create its schema' do
    co = double('connection')
    expect(ActiveRecord::Base).to receive(:connection).and_return(co)
    expect(co).to receive(:create_table).with(:biggles_one_shot)
    expect(co).to receive(:create_table).with(:biggles_scheduled)
    expect(co).to receive(:create_table).with(:biggles_recurring)
    expect(co).to receive(:create_table).with(:biggles_heartbeat, id: false)
    Biggles.create_tables
  end
end
