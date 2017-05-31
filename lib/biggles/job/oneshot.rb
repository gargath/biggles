require 'active_record'

module Biggles
  module Job
    # One-Shot job type. These jobs will be executed as soon as a worker is
    # available.
    class OneShot < ActiveRecord::Base
      attr_readonly :processor, :id
      self.table_name = 'biggles_one_shot'
    end
  end
end
