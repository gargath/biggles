# Helper methods for schema management
module Biggles
  def self.create_tables
    success = true
    c = ActiveRecord::Base.connection
    begin
      c.create_table :biggles_one_shot do |t|
        t.column :name, :string
        t.column :processor, :string
        t.column :options, :text, limit: 100_000
        t.column :status, :string, null: false, default: 'SCHEDULABLE'
      end
    rescue => e
      $stderr.puts "Failed to create table biggles_one_shot: #{e}"
      success = false
    end

    begin
      c.create_table :biggles_scheduled
      c.create_table :biggles_recurring
    rescue
      $stderr.puts 'Failed to create other tables for some reason (who case?)'
      success = false
    end

    begin
      c.create_table :biggles_heartbeat, id: false do |t|
        t.column :pid, :string, unique: true
        t.column :timestamp, :timestamp
      end
    rescue => e
      $stderr.puts "Failed to create table biggles_heartbeat: #{e}"
      success = false
    end
    success
  end

  def self.remove_tables
    c = ActiveRecord::Base.connection
    c.drop_table :biggles_one_shot
    c.drop_table :biggles_scheduled
    c.drop_table :biggles_recurring
    c.drop_table :biggles_heartbeat
    if c.is_a? ActiveRecord::ConnectionAdapters::SQLite3Adapter
      c.execute('DELETE FROM sqlite_sequence WHERE name = \'biggles_one_shot\'')
    else
      c.execute('DROP SEQUENCE biggles_one_shot_sequence')
    end
  end
end
