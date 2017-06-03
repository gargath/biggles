require './spec/spec_helper.rb'

RSpec.describe Biggles::JobRunner do
  it 'traps signals' do
    expect(Signal).to receive(:trap).with('TERM')
    expect(Signal).to receive(:trap).with('INT')
    options = { 'loglevel' => 'DEBUG', 'workers' => 1 }
    runner = Biggles::JobRunner.new(options)
    runner.send(:trap_signals)
  end
end
