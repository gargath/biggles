require './spec/spec_helper.rb'

RSpec.describe Biggles do
  context 'exceptions during table create' do
    it 'handles its exceptions' do
      c = double('conn')
      expect(ActiveRecord::Base).to receive(:connection).and_return(c)
      expect(c).to receive(:create_table).exactly(4).and_raise(RuntimeError)
      expect { Biggles.create_tables }.to output.to_stderr
    end
  end
end
