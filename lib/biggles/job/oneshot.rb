require 'active_record'
require 'json'

module Biggles
  module Job
    # One-Shot job type. These jobs will be executed as soon as a worker is
    # available.
    class OneShot < ActiveRecord::Base
      attr_readonly :processor, :id
      self.table_name = 'biggles_one_shot'
      self.sequence_name = 'biggles_one_shot_sequence'

      def options=(opts)
        write_attribute(:options, opts.to_json)
      end
    end
  end
end
