require 'active_record'
require 'json'

module Biggles
  module Job
    # One-Shot job type. These jobs will be executed as soon as a worker is
    # available.
    class Scheduled < ActiveRecord::Base
      attr_readonly :processor, :id
      validate :due_is_valid
      self.table_name = 'biggles_scheduled'
      self.sequence_name = 'biggles_scheduled_sequence'

      def options=(opts)
        write_attribute(:options, opts.to_json)
      end

      def due_is_valid
        errors.add(:due, 'Must be in the future') if due <= Time.now
      end
    end
  end
end
