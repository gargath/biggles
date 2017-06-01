# Helper methods for schema management
module Biggles
  def self.create_tables
    c = ActiveRecord::Base.connection
    c.create_table :biggles_one_shot do |t|
      t.column :name, :string
      t.column :processor, :string
      t.column :options, :text, limit: 100_000
      t.column :status, :string
    end
    c.create_table :biggles_scheduled
    c.create_table :biggles_recurring
    c.create_table :biggles_heartbeat, id: false do |t|
      t.column :pid, :string
      t.column :timestamp, :timestamp
    end
  end

  def self.remove_tables
    c = ActiveRecord::Base.connection
    c.drop_table :biggles_one_shot
    c.drop_table :biggles_scheduled
    c.drop_table :biggles_recurring
    c.drop_table :biggles_heartbeat
  end
end
