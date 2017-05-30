# Helper methods for schema management
module Biggles
  def self.create_tables
    c = ActiveRecord::Base.connection
    c.create_table :biggles_one_shot
    c.create_table :biggles_scheduled
    c.create_table :biggles_recurring
    c.add_column :biggles_one_shot, :name, :string
    c.add_column :biggles_one_shot, :processor, :string
    c.add_column :biggles_one_shot, :options, :text, limit: 100_000
    c.add_column :biggles_one_shot, :status, :string
  end
end
