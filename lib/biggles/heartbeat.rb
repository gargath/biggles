require 'active_record'

module Biggles
  # The Biggles Heartbeat
  class Heartbeat < ActiveRecord::Base
    self.table_name = 'biggles_heartbeat'
    self.primary_key = 'pid'
  end
end
