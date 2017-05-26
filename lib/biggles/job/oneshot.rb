require 'active_record'

module Biggles
  module Job
    # One-Shot job type. These jobs will be executed as soon as a worker is
    # available.
    class OneShot < ActiveRecord::Base
      attr_accessor :processor
      attr_accessor :options

      def readonly?
        new_record? ? false : true
      end
    end
  end
end
