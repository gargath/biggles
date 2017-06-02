# Helper methods for schema management
module Biggles
  def self.create_tables
    c = ActiveRecord::Base.connection
    begin
      c.create_table :biggles_one_shot do |t|
        t.column :name, :string
        t.column :processor, :string
        t.column :options, :text, limit: 100_000
        t.column :status, :string
      end
    rescue => e
      puts "Failed to create table biggles_one_shot: #{e}"
    end

    begin
      c.create_table :biggles_scheduled
      c.create_table :biggles_recurring
    rescue

    end

    begin
      c.create_table :biggles_heartbeat, id: false  do |t|
        t.column :pid, :string, unique: true
        t.column :timestamp, :timestamp
      end
    rescue => e
      puts "Failed to create table biggles_heartbeat: #{e}"
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
