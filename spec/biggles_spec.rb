require 'spec_helper'

RSpec.describe Biggles do
  it 'has a version number' do
    expect(Biggles::VERSION).not_to be nil
  end

  it 'can create its schema' do
    co = double('connection')
    expect(ActiveRecord::Base).to receive(:connection).and_return(co)
    expect(co).to receive(:create_table).with(:one_shots)
    expect(co).to receive(:create_table).with(:scheduleds)
    expect(co).to receive(:create_table).with(:recurrings)
    expect(co).to receive(:add_column).with(:one_shots, :name, :string)
    expect(co).to receive(:add_column).with(:one_shots, :processor, :string)
    expect(co).to receive(:add_column).with(:one_shots, :options, :text,
                                            limit: 100_000)
    Biggles.create_schema
  end
end
