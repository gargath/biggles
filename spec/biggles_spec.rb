require 'spec_helper'

RSpec.describe Biggles do
  it 'has a version number' do
    expect(Biggles::VERSION).not_to be nil
  end
  it 'has a one-shot job' do
    job = double('job')
    expect(Biggles::Job::OneShot).to receive(:new).and_return(job)
    Biggles::Job::OneShot.new
  end
end
